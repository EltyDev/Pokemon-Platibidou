module GamePlay
    class Load < Base
        remove_const :LANGUAGE_CHOICE_LIST
        remove_const :DEFAULT_GAME_LANGUAGE
        DEFAULT_GAME_LANGUAGE = 'fr'
        LANGUAGE_CHOICE_LIST = []
    end
end