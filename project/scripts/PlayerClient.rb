require_relative 'securerandom'
module Online
    class PlayerClient
        attr_accessor :uuid, :username, :x, :y, :direction, :pattern, :map_id

        def initialize(username, x, y, direction, pattern, map_id)
            @username = username
            @uuid = SecureRandom.uuid
            @x = x
            @y = y
            @direction = direction
            @pattern = pattern
            @map_id = map_id
        end
    end
end