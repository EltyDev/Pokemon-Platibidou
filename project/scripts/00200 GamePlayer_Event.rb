class GamePlayer_Event < Game_Event

    def initialize(map_id, x, y, graphic_name)
        event = RPG::Event.new(x , y)
        event.pages[0].graphic.character_name = graphic_name
        event_id = 1
        until $game_map.events[event_id] == nil
            event_id += 1
        end
        event.id = event_id
        $game_map.events[event_id] = self
        super(map_id, event)
    end
end