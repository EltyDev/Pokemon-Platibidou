require 'thread'
require 'socket'
require_relative 'PlayerClient'
module Online

    attr_reader :connected

    @players = []
    @player = nil
    @socket = nil
    @connected = false
    IP = "127.0.0.1"
    PORT = 8888
    LOCK = Mutex.new

    def self.connect()
        unless @connected
            @socket = TCPSocket.new(IP,PORT)
            @connected = true
            @player = PlayerClient.new("Venodez", $game_player.x, $game_player.y, $game_player.direction, $game_player.pattern, $game_map.map_id)
            self.send_data({"type": "connection", "value": @player})
            self.main_loop()
        end
    end

    def self.main_loop()
        Thread.new do
            LOCK.synchronize do
                Thread.main.wakeup
                while @connected
                    data = self.receive_data()
                    unless data == nil
                        puts data
                        self.handle_data(data)
                    end
                end
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

    def self.server_is_online?()
        return @socket.gets != nil
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
            @players = data[:value]
        else
            log_info("Error: Unknown Data => " + data.to_s)
        end
    end
end
