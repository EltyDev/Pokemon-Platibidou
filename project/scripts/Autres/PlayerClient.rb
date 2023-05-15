module Online
    # Class to handle the player on the client side and send it to the server
    class PlayerClient
        attr_accessor :uuid, :username, :x, :y, :direction, :map_id
        
        def initialize(username, x, y, direction, map_id)
            @username = username
            @uuid = SecureRandom.uuid
            @x = x
            @y = y
            @direction = direction
            @map_id = map_id
        end
    end
end