require 'socket'
require 'json'
require_relative 'PlayerClient'

# Module to handle the server
module Server
    IP = '192.168.1.22'
    PORT = 8888
    SERVER = TCPServer.new(IP, PORT)
    @players = {}
    @first = true

    # Start the server
    def self.start()
        self.log("Information", "Serveur démarré avec succès", nil)
        loop do
            Thread.start(SERVER.accept) do |client|
                loop do
                    data = self.receive_data(client)
                    if data == nil
                        self.disconnect(client)
                        break
                    else
                        self.handle_data(client, data)
                    end
                end
            end
        end
    end

    # Send data to the client
    # @param client [TCPSocket] client to send data to
    # @param data [Hash] data to send
    # @return [Boolean] true if the data has been sent, false otherwise
    def self.send_data(client, data)
        data = Marshal.dump(data)
        client.write([data.bytesize].pack("I") + data)
        return true
    rescue => error
        log(error.class.to_s, error.message, nil)
        return false
    end

    # Receive data from the client
    # @return [Hash] data received
    def self.receive_data(client)
        size = client.recv(4).unpack("I").first
        data = client.recv(size)
        while data.bytesize < size
            data << client.recv(size - data.bytesize)
        end
        return Marshal.load(data)
    rescue => error
        log(error.class.to_s, error.message, nil)
        return nil
    end

    # Update the position of the players
    def self.update_all_positions()
        @players.each_key do |client|
            data = {}.merge(@players)
            data.delete(client)
            self.send_data(client, {"type": "update_position", "value": data.values})
        end
    end

    # Disconnect a client from the server
    # @param client [TCPSocket] client who sent the data
    def self.disconnect(client)
        self.log("Déconnexion", "", client)
        data = @players[client].uuid
        @players.delete(client)
        @players.each_key do |client2|
            self.send_data(client2, {"type": "disconnect", "value": data})
        end
    end

    # Log a message
    # @param type [String] type of the message
    # @param message [String] message to log
    # @param client [TCPSocket] client who sent the data
    def self.log(type, message, client)
        puts "―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――" if @first
        @first = false
        if client != nil
            if message == ""
                puts "[" + type + "] " + @players[client].username + ":" + @players[client].uuid
            else
                puts "[" + type + "] " + @players[client].username + ":" + @players[client].uuid + " ==> " + message
            end
        else
            puts "[" + type + "] " + message
        end
        puts "―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――"
    end

    # Handle the data received from the client
    # @param client [TCPSocket] client who sent the data
    # @param data [Hash] data received
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