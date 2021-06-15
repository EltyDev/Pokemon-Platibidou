require 'thread'
require 'socket'
require_relative 'PlayerClient'
module Online

    attr_reader :connected

    @players = {}
    @player = nil
    @socket = nil
    @connected = false
    IP = "83.196.123.232"
    PORT = 8888
    LOCK = Mutex.new

    def self.connect()
        unless @connected
            @socket = TCPSocket.new(IP,PORT)
            @connected = true
            @player = PlayerClient.new($pokemon_party.trainer.name, $game_player.x, $game_player.y, $game_player.direction, $game_player.pattern, $game_map.map_id)
            self.send_data({"type": "connection", "value": @player})
            self.main_loop()
        end
    end

    def self.main_loop()
        Thread.new do
            LOCK.synchronize do
                Thread.main.wakeup
                log_info("Connexion réussi")
                while @connected
                    @connected = false if @socket.closed?
                    data = self.receive_data()
                    unless data == nil
                        self.handle_data(data)
                    end
                end
                log_info("Connexion interrompu")
                Thread.main.wakeup
            end
        end
        sleep unless LOCK.locked?
    end


    def self.disconnect()
        @socket.close()
        @connected = false
    end


    def self.send_data(data)
        data = Marshal.dump(data)
        @socket.write([data.bytesize].pack("I") + data)
        return true
    rescue Exception
        return false
    end

    def self.receive_data()
        return unless @connected
        size = @socket.recv(4).unpack("I").first
        data = @socket.recv(size)
        while data.bytesize < size
            until @socket.readable?
                send(update_method)
            end
            data << @socket.recv(size - data.bytesize)
        end 
        return Marshal.load(data)
    rescue Exception
        return nil
    end

    def self.has_moved?()
        return false unless @connected
        return $game_player.x != @player.x || $game_player.y != @player.y || $game_player.direction != @player.direction
    end

    def self.update_position()
        return unless self.has_moved?
        self.send_data({"type": "update_position", "value": {"x": $game_player.x, "y": $game_player.y, "direction": $game_player.direction, "pattern": $game_player.pattern, "map_id": $game_map.map_id}})
        @player.x = $game_player.x
        @player.y = $game_player.y
        @player.direction = $game_player.direction
        @player.pattern = $game_player.pattern
    end

    def self.handle_data(data)
        case data[:type]
        when "update_position"
            data[:value].each do |player| 
                if !@players.has_key?(player.uuid)
                    @players[player.uuid] = GamePlayer_Event.new(player.map_id, player.x, player.y, "cynthia_hgss")
                    $game_temp.player_new_x = $game_player.x
                    $game_temp.player_new_y = $game_player.y
                    $game_temp.player_transferring = true   
                else
                    case player.direction
                    when 2
                        @players[player.uuid].turn_down()
                    when 4
                        @players[player.uuid].turn_left()
                    when 6
                        @players[player.uuid].turn_right()
                    when 8
                        @playerss[player.uuid].turn_up()
                    end
                    @players[player.uuid].moveto(player.x, player.y)
                end
            end
        else
            log_info("Error: Unknown Data => " + data.to_s)
        end
    end
end
