require 'socket'
require 'json'
require_relative 'PlayerClient'

module Server
    IP = '127.0.0.1'
    PORT = 8888
    SERVER = TCPServer.new(IP, PORT)
    @players = []

    def self.start()
        loop do
            Thread.start(SERVER.accept) do |client|
                @players.push(JSON.parse(client.gets, object_class: Online::PlayerClient, create_additions: true))
                puts @players[0].data.party
            end
        end    
    end
end

Server.start()