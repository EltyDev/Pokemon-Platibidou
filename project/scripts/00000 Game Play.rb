module GamePlay
    class Load
        def check_up
            if @delete_game
                while Input.press?(:B)
                    Graphics.update
                end
                scene = $scene
                $scene = self
                message = _get(25, 18)
                oui = _get(25, 20)
                non = _get(25, 21)
                c = display_message(message, 1, non, oui) #> Supprimer ?
                if c == 1
                    message = _get(25, 19)
                    c = display_message(message, 1, non, oui) #> Vraiment ?
                    if c == 1
                        File.delete(@filename) #> Ok :)
                        message = _get(25, 17)
                        display_message(message)
                    end
                end
                $scene = scene
                return @running = false
            end
            unless @pokemon_party
                Graphics.freeze
                $pokemon_party = PFM::Pokemon_Party.new(false,"fr")
                $pokemon_party.expand_global_var
                $trainer.redefine_var
                $scene = Scene_Map.new
                Yuki::TJN.force_update_tone
                @running = false
            end
        end
    end
end