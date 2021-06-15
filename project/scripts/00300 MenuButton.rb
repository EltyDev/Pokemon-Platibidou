module UI

    class PSDKMenuButton < SpriteStack

        remove_const :TEXT_MESSAGES
        TEXT_MESSAGES =
            [
                [:text_get, 14, 1], # Dex
                [:text_get, 14, 0], # PARTY
                [:text_get, 14, 2], # BAG
                [:text_get, 14, 3], # TCARD
                [:text_get, 14, 5], # Options
                [:text_get, 14, 4], # Save
                [:ext_text, 9000, 26], # Quit
                [:text_get, 14, 2], # BAG (girl)
                [:text_get, 14, 6] # Online
            ]

        def initialize(viewport, real_index, positional_index)
            x = BASIC_COORDINATE.first + positional_index * OFFSET_COORDINATE.first
            y = BASIC_COORDINATE.last + positional_index * OFFSET_COORDINATE.last
            super(viewport, x, y)
            @real_index = real_index
            if @real_index >= 7
                @real_index = real_index + 1
            end
            @real_index = 7 if real_index == 2 && $trainer.playing_girl
            @selected = false
            add_background('menu_button')
            # @type [SpriteSheet]
            @icon = add_sprite(12, 0, 'menu_icons', 2, 9, type: SpriteSheet)
            @icon.select(0, @real_index)
            @icon.set_origin(@icon.width / 2, @icon.height / 2)
            @icon.set_position(@icon.x + @icon.ox, @icon.y + @icon.oy)
            add_text(40, 0, 0, 23, send(*TEXT_MESSAGES[@real_index]).sub(PFM::Text::TRNAME[0], $trainer.name))
        end
    end
end