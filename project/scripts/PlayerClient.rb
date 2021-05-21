module Online
    class PlayerClient
        attr_reader :id, :username, :x, :y, :map_id

        def initialize(username, id, x, y, map_id)
            @username = username
            @id = id
            @x = x
            @y = y
            @map_id = map_id
        end
        def to_json()
            return {'username': @username, 'id': @id, 'x': @x, 'y': @y, 'map_id': @map_id}
        end
    end
    def self.to_player_client(json)
        return PlayerClient.new(json['username'], json['id'], json['x'], json['y'], json['map_id'])
    end
end