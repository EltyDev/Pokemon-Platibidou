require 'socket'
require 'json'
require 'thread'
require_relative 'PlayerClient'

module Online

    @players = []
    @socket = nil
    @connected = false
    @player = PlayerClient.new("Venodez", 10000545)
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
        begin
            @socket = TCPSocket.new(IP, PORT)
        rescue
            log_info("Connexion impossible.")
            return nil
        end
        log_info("Connexion réussie.")
        @socket.puts(@player.to_hash.to_json)
        @connected = true
        while @connected
            begin
                if self.handle_message(@socket.gets) == 1
                    log_info("Connexion perdu.")
                    return nil
                end
            rescue
                log_info("Connexion perdu.")
                return nil
            end
        end
        log_info("Déconnecté du serveur.")
    end

    def self.handle_message(message)
        if message == nil
            return 1
        end
        return 0
    end
end