module GamePlay
    # Main menu UI
    #
    # Rewritten thanks to Jaizu demand
    class Menu < BaseCleanUpdate
        
        remove_const :ACTION_LIST

        ACTION_LIST = %i[open_dex open_party open_bag open_tcard open_option open_save open_quit open_online]

        def init_conditions()
            @conditions =
                [
                    $game_switches[Yuki::Sw::Pokedex], # Pokedex
                    $actors.any?, # Party
                    !$bag.locked, # Bag
                    true, # Trainer card
                    true, # Options
                    !$game_system.save_disabled, # Save
                    true, #Exit
                    true #Online
                ]
        end

        def open_online()
            Online.connect()
            @running = false
        end
    end

end