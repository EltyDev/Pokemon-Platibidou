require 'socket'
require 'json'
require 'thread'

module Online
    include GameData::SystemTags

    @players = []
    @socket = nil
    @connected = false
    @player = PlayerClient.new("Venodez", 1000, $game_player.x, $game_player.y, $game_map.map_id)
    IP = "127.0.0.1"
    PORT = 8888
    LOCK = Mutex.new

    def self.connect()
        Thread.new do
            LOCK.synchronize do
                Thread.main.wakeup
                self.main_loop()
                Thread.main.wakeup
            end
        end
        return nil
    end

    def self.disconnect()
        @connected = false
    end

    def self.main_loop()
        log_info("Tentative de connexion.")
        puts $game_system
        begin
            @socket = TCPSocket.new(IP, PORT)
        rescue
            log_info("Connexion impossible.")
            return nil
        end
        log_info("Connexion réussie.")
        @connected = true
        while @connected
            begin
                if !self.server_is_online?()
                    log_info("Connexion perdu.")
                    return nil
                else
                    self.update_position() if self.has_moved?()
                end
            rescue
                log_info("Connexion perdu.")
                return nil
            end
        end
        log_info("Déconnecté du serveur.")
    end

    def self.send_data(data)
        @socket.puts(data.to_json)
    end

    def self.server_is_online?()
        return @socket.gets != nil
    end

    def self.has_moved?()
        return $pokemon_party.game_player.x != @player.x || $pokemon_party.game_player.y != @player.y

    end

    def self.update_position()
        self.send_data({"type": "update", "x": $pokemon_party.game_player.x, "y": $pokemon_party.game_player.y})
    end
end

Online.connect()