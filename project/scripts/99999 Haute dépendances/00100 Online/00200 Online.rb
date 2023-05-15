require 'thread'
require 'socket'

# Module to handle online features
module Online

    attr_reader :connected

    @players = {}
    @player = nil
    @socket = nil
    @connected = false
    IP = "83.196.120.106"
    PORT = 8888
    LOCK = Mutex.new

    # Connect to the server
    def self.connect()
        unless @connected
            begin
                @socket = TCPSocket.new(IP,PORT)
            rescue
                log_info("Connexion impossible")
                return
            end
            @connected = true
            @player = PlayerClient.new($pokemon_party.trainer.name, $game_player.x, $game_player.y, $game_player.direction, $game_map.map_id)
            self.send_data({"type": "connection", "value": @player})
            self.main_loop
        end
    end

    # Main loop of the client
    def self.main_loop()
        thread = Thread.new do
            LOCK.synchronize do
                Thread.main.wakeup
                log_info("Connexion réussi")
                while @connected
                    data = self.receive_data()
                    unless data == nil
                        self.handle_data(data)
                    end
                    sleep 0.01
                end
            end
        end
    end

    # Disconnect from the server
    def self.disconnect()
        @socket.close()
        @connected = false
    end


    # Send data to the server
    # @param data [Hash] data to send
    # @return [Boolean] true if the data has been sent, false otherwise
    def self.send_data(data)
        log_info("Envoie de données...")
        data = Marshal.dump(data)
        @socket.write([data.bytesize].pack("I") + data)
        return true
    rescue Exception
        return false
    end

    def self.receive_data()
        log_info("Récepetion de données...")
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

    # Check if the player has moved
    # @return [Boolean] true if the player has moved, false otherwise
    def self.has_moved?()
        return false unless @connected
        return $game_player.x != @player.x || $game_player.y != @player.y || $game_player.direction != @player.direction || $game_map.map_id != @player.map_id
    end

    # Update the position of the player on the server
    def self.update_position()
        return unless self.has_moved?
        self.send_data({"type": "update_position", "value": {"x": $game_player.x, "y": $game_player.y, "direction": $game_player.direction, "map_id": $game_map.map_id}})
        @player.x = $game_player.x
        @player.y = $game_player.y
        @player.direction = $game_player.direction
        if $game_map.map_id != @player.map_id
            @player.map_id = $game_map.map_id
        end
    end

    # Handle the data received from the server
    # @param data [Hash] data received from the server
    def self.handle_data(data)
        case data[:type]
        when "update_position"
            data[:value].each do |player| 
                if !@players.has_key?(player.uuid)
                    @players[player.uuid] = GamePlayer_Event.new(player.map_id, player.x, player.y, "cynthia_hgss")
                else
                    player_client = @players[player.uuid]
                    if player.map_id != player_client.map_id
                        player_client.erase()
                        @players[player.uuid] = GamePlayer_Event.new(player.map_id, player.x, player.y, "cynthia_hgss")
                    end
                    if player.direction != player_client.direction
                        case player.direction
                        when 2
                            player_client.turn_down()
                        when 4
                            player_client.turn_left()
                        when 6
                            player_client.turn_right()
                        when 8
                            player_client.turn_up()
                        end
                    end
                    if player.x != player_client.x
                        if player.x > player_client.x
                            player_client.move_right()
                        else
                            player_client.move_left()
                        end
                    elsif player.y != player_client.y
                        if player.y > player_client.y
                            player_client.move_down()
                        else
                            player_client.move_up()
                        end
                    end
                end
            end
        when "disconnect"
            log_info("Déconnexion de " + data[:value])
            uuid = data[:value]
            @players[uuid].erase()
            @players.delete(uuid)
        else
            log_info("Error: Unknown Data => " + data.to_s)
        end
    end
end
