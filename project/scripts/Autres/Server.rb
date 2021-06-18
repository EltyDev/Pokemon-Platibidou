require 'socket'
require 'json'
require_relative 'PlayerClient'

module Server
    IP = '192.168.1.22'
    PORT = 8888
    SERVER = TCPServer.new(IP, PORT)
    @players = {}
    @first = true

    def self.start()
        loop do
            Thread.start(SERVER.accept) do |client|
                loop do
                    data = self.receive_data(client)
                    if data == nil
                        self.log("Déconnexion", "", client=client)
                        @players.delete(client)
                        Thread.stop
                    else
                        self.handle_data(client, data)
                    end
                end
            end
        end
    end

    def self.send_data(client, data)
        data = Marshal.dump(data)
        client.write([data.bytesize].pack("I") + data)
        return true
    rescue Exception
        return false
    end

    def self.receive_data(client)
        size = client.recv(4).unpack("I").first
        data = client.recv(size)
        while data.bytesize < size
            data << client.recv(size - data.bytesize)
        end
        return Marshal.load(data)
    rescue Exception
        return nil
    end

    def self.update_all_positions()
        @players.each_key do |client|
            data = {}.merge(@players)
            data.delete(client)
            self.send_data(client, {"type": "update_position", "value": data.values})
        end
    end

    def self.log(type, message, client)
        puts "―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――" if @first
        @first = false
        if message == ""
            puts "[" + type + "] " + @players[client].username + ":" + @players[client].uuid
        else
            puts "[" + type + "] " + @players[client].username + ":" + @players[client].uuid + " ==> " + message
        end
        puts "―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――"
    end

    def self.handle_data(client, data)
        case data[:type]
        when "connection"
            @players[client] = data[:value]
            self.log("Connexion", data[:value].to_s, client) 
        when "update_position"
            @players[client].x = data[:value][:x]
            @players[client].y = data[:value][:y]
            @players[client].direction = data[:value][:direction]
            @players[client].map_id = data[:value][:map_id]
            self.update_all_positions()
            self.log("Informations", data[:value].to_s, client)
        end
    end
end

Server.start()  