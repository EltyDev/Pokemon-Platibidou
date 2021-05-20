module Online
    class PlayerClient
        attr_reader :id, :username, :pokemon_party
        
        def initialize(username, id, party: $pokemon_party)
            @username = username
            @id = id
            @pokemon_party = party
        end
        def to_hash()
            return {'username': @username, 'id': @id, 'party': @pokemon_party}
        end
    end
    def self.to_player_client(json)
        return PlayerClient.new(json['username'], json['id'], party: json['party'])
    end
end