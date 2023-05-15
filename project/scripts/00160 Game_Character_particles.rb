class Game_Character

    remove_method :particle_push

    def particle_push
        return if @particles_disabled
        method_name = PARTICLES_METHODS.key?(system_tag) ? PARTICLES_METHODS[system_tag] : nil # Fix index error
        send(method_name) if method_name
    end
end