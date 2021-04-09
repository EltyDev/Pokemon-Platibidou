class Game_Player < Game_Character
    
    attr_accessor :freeze
    
    def initialize
        super
        @wturn = 0
        @bump_count = 0
        @freeze = false
        @on_acro_bike = false
        @acro_count = 0
    end

    def update
        unless @freeze
            return send(@update_callback) if @update_callback
            last_moving = moving?
            if moving? || $game_system.map_interpreter.running? ||
                @move_route_forcing || $game_temp.message_window_showing || @sliding # or follower_sliding?
                if $game_system.map_interpreter.running?
                    @step_anime = false
                    enter_in_walking_state if @state == :running
                end
            else
                player_update_move
                player_move_on_cracked_floor_update if moving? && !last_moving
            end
            @wturn -= 1 if @wturn > 0
            last_real_x = @real_x
            last_real_y = @real_y
            super
            update_scroll_map(last_real_x, last_real_y)
            update_check_trigger(last_moving) unless moving? || @sliding
        else
            update_appearance(0)
        end
    end
end