class Pokemon_Event < Game_Event

    def initialize(map_id, x, y, pokemon)
        @pokemon = pokemon
        
        route = RPG::MoveRoute.new
        route.repeat = false
        route.list = [RPG::MoveCommand.new(14, [0, 0]), RPG::MoveCommand.new]
        
        event = RPG::Event.new(x + ::Yuki::MapLinker::OffsetX, y + ::Yuki::MapLinker::OffsetY)
        event.pages[0].graphic.character_name = "cynthia_hgss"
        event.pages[0].list = [
        RPG::EventCommand.new(209, 0, [0, route]),
        RPG::EventCommand.new(355, 0, ["$game_system.cry_play(%d)" % [@pokemon.id]]),
        RPG::EventCommand.new
        ]
        
        event_id = 1
        until $game_map.events[event_id] == nil
            event_id += 1
        end
        event.id = event_id
        $game_map.events[event_id] = self
        super(map_id, event)
    end
end