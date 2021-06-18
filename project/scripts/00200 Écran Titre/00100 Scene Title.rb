# The title screen scene
class Scene_Title
    # @return [Integer] ID of the map to display as intro movie (0 = no intro)
    remove_const :INTRO_MOVIE_MAP_ID
    INTRO_MOVIE_MAP_ID = 1 #Mettre le numéro de votre map qui va servir d’intro
    # Init the title display part
    def init_title
    end
    # Play the title display part
    def play_title
        if $game_variables[27] == 2 # Va servir pour boucler l’intro une fois la musique finie
        Audio.bgm_stop
        return
    end
    @loop = false
    end
end