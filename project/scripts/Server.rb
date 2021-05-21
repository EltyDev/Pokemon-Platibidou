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
                puts client.gets
            end
        end
    end

    def self.receive_data(data)
        return JSON.parse(data)
    end
end

Server.start()