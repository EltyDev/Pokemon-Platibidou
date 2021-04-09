module RPG
  class Sprite
    SHADER = <<~EOSHADER
      uniform sampler2D texture;
      uniform float hue;

      // Source: https://gist.github.com/mairod/a75e7b44f68110e1576d77419d608786
      vec3 hueShift( vec3 color, float hueAdjust ) {

        const vec3  kRGBToYPrime = vec3 (0.299, 0.587, 0.114);
        const vec3  kRGBToI      = vec3 (0.596, -0.275, -0.321);
        const vec3  kRGBToQ      = vec3 (0.212, -0.523, 0.311);

        const vec3  kYIQToR     = vec3 (1.0, 0.956, 0.621);
        const vec3  kYIQToG     = vec3 (1.0, -0.272, -0.647);
        const vec3  kYIQToB     = vec3 (1.0, -1.107, 1.704);

        float   YPrime  = dot (color, kRGBToYPrime);
        float   I       = dot (color, kRGBToI);
        float   Q       = dot (color, kRGBToQ);
        float   hue     = atan (Q, I);
        float   chroma  = sqrt (I * I + Q * Q);

        hue += hueAdjust;

        Q = chroma * sin (hue);
        I = chroma * cos (hue);

        vec3    yIQ   = vec3 (YPrime, I, Q);

        return vec3( dot (yIQ, kYIQToR), dot (yIQ, kYIQToG), dot (yIQ, kYIQToB) );
      }

      void main() {
        vec4 color = texture2D(texture, gl_TexCoord[0].xy);
        color.rgb = hueShift(color.rgb, hue);
        gl_FragColor = color * gl_Color;
      }
    EOSHADER
    @@_animations = []
    @@_reference_count = {}
    def initialize(viewport = nil)
      super(viewport)
      @_whiten_duration = 0
      @_appear_duration = 0
      @_escape_duration = 0
      @_collapse_duration = 0
      @_damage_duration = 0
      @_animation_duration = 0
      @_blink = false
      @_reverse = false
      @_option = 0
      @_registered_x = 0
      @_registered_y = 0
      @_registered_ox = 0
      @_registered_oy = 0
    end

    def register_position
      @_registered_x = x
      @_registered_ox = ox
      @_registered_y = y
      @_registered_oy = oy
    end

    def reset_position
      self.x = @_registered_x
      self.ox = @_registered_ox
      self.y = @_registered_y
      self.oy = @_registered_oy
    end

    def dispose_animation
      return unless @_animation_sprites

      @_animation_sprites.each(&:dispose)
      @_animation_sprites = nil
      @_animation = nil
    end

    def dispose_loop_animation
      return unless @_loop_animation_sprites

      @_loop_animation_sprites.each(&:dispose)
      @_loop_animation_sprites = nil
      @_loop_animation = nil
    end

    def animation(animation, hit, reverse = false)
      dispose_animation
      @_animation = animation
      return if @_animation == nil
      p animation.name
      @_animation_hit = hit
      @_animation_duration = @_animation.frame_max
      animation_name = @_animation.animation_name
      animation_hue = @_animation.animation_hue
      bitmap = RPG::Cache.animation(animation_name, animation_hue)
=begin
      if @@_reference_count.include?(bitmap)
        @@_reference_count[bitmap] += 1
      else
        @@_reference_count[bitmap] = 1
      end
=end
      @_animation_sprites = []
      if @_animation.position != 3 || !@@_animations.include?(animation)
        0.upto(15) do
          sprite = LiteRGSS::ShaderedSprite.new(viewport)
          sprite.bitmap = bitmap
          sprite.shader = LiteRGSS::Shader.new(SHADER)
          sprite.shader.set_float_uniform('hue', Math::PI * (360 - animation_hue) / 180)
          sprite.visible = false
          @_animation_sprites.push(sprite)
        end
        @@_animations.push(animation) unless @@_animations.include?(animation)
      end
      @_option = 0
      @_reverse = reverse
      if animation.name.include?('/')
        split_list = animation.name.split('/')
        if split_list.length == 2
          @_option = 1 if split_list[0].include?('R')
          @_reverse = false if split_list[0].include?('N')
          @_option = 2 if split_list[0].include?('M')
        end
      end
      update_animation
    end

    def update
      super
      if @_whiten_duration > 0
        @_whiten_duration -= 1
        color.alpha = 128 - (16 - @_whiten_duration) * 10
      end
      if @_appear_duration > 0
        @_appear_duration -= 1
        self.opacity = (16 - @_appear_duration) * 16
      end
      if @_escape_duration > 0
        @_escape_duration -= 1
        self.opacity = 256 - (32 - @_escape_duration) * 10
      end
      if @_collapse_duration > 0
        @_collapse_duration -= 1
        self.opacity = 256 - (48 - @_collapse_duration) * 6
      end
=begin
      # Never reached
      if @_damage_duration > 0
        @_damage_duration -= 1
        case @_damage_duration
        when 38..39
          @_damage_sprite.y -= 4
        when 36..37
          @_damage_sprite.y -= 2
        when 34..35
          @_damage_sprite.y += 2
        when 28..33
          @_damage_sprite.y += 4
        end
        @_damage_sprite.opacity = 256 - (12 - @_damage_duration) * 32
        if @_damage_duration == 0
          dispose_damage
        end
      end
=end
      if @_animation && (Graphics.frame_count % 3 == 1) # % 2 == 0
        @_animation_duration -= 1
        update_animation
      end
      if @_loop_animation && (Graphics.frame_count % 3 == 1) # % 2 == 0
        update_loop_animation
        @_loop_animation_index += 1
        @_loop_animation_index %= @_loop_animation.frame_max
      end
      if @_blink
        @_blink_count = (@_blink_count + 1) % 32
        if @_blink_count < 16
          alpha = (16 - @_blink_count) * 6
        else
          alpha = (@_blink_count - 16) * 6
        end
        color.set(255, 255, 255, alpha)
      end
      @@_animations.clear
      viewport&.update
    end

    def animation_set_sprites(sprites, cell_data, position)
      # Cas Spécial : le sprite de mouvement du Pokémon
      sprite = sprites[15]
      pattern = cell_data[15, 0]
      jump = false
      unless sprite && pattern && pattern != -1
        sprite&.visible = false
        jump = true
      end

      x_compensate = 0
      y_compensate = 0

      unless jump
        if position == 3
          if viewport
            self.x = viewport.rect.width / 2
            self.y = viewport.rect.height - 48 # / 2 added here
          else
            self.x = Graphics.width / 2
            self.y = Graphics.height / 2
          end
        else
          self.x = @_registered_x
          self.y = @_registered_y
        end

        if @_reverse && position == 3
          self.x = 320 - x # 620 - self.x
          self.y = 220 - y # 440 - self.y #328 - self.y
          # self.ox = self.src_rect.width / 2
          # self.oy = self.src_rect.height / 2
        end

        if @_reverse
          self.x -= cell_data[15, 1] / 2
          self.y -= cell_data[15, 2] / 2
          x_compensate += cell_data[15, 1] / 2 if position != 3
          y_compensate += cell_data[15, 2] / 2 if position != 3
        else
          self.x += cell_data[15, 1] / 2
          self.y += cell_data[15, 2] / 2
          x_compensate -= cell_data[15, 1] / 2 if position != 3
          y_compensate -= cell_data[15, 2] / 2 if position != 3
        end
        self.zoom = cell_data[15, 3].to_i / 200.0
      end

      15.times do |i| # for i in 0..14
        sprite = sprites[i]
        pattern = cell_data[i, 0]

        next sprite&.visible = false unless sprite && pattern && pattern != -1

        sprite.visible = true
        sprite.src_rect.set(pattern % 5 * 192, pattern / 5 * 192, 192, 192)

        if position == 3
          if viewport
            sprite.x = viewport.rect.width / 2
            sprite.y = viewport.rect.height - 48
          else
            sprite.x = Graphics.width / 2 # 320
            sprite.y = Graphics.height / 2 # 240
          end
        else
          sprite.x = x - ox / 2 + src_rect.width / 4
          sprite.y = y - oy / 2 + src_rect.height / 4
          sprite.y -= src_rect.height / 8 if position == 0
          sprite.y += src_rect.height / 8 if position == 2
        end

        if @_reverse && position == 3
          sprite.x = 320 - sprite.x # 620 - sprite.x
          sprite.y = 220 - sprite.y # 328 - sprite.y
        end

        if @_reverse
          sprite.x -= cell_data[i, 1] / 2 - x_compensate
          sprite.y -= cell_data[i, 2] / 2 - y_compensate
        else
          sprite.x += cell_data[i, 1] / 2 + x_compensate
          sprite.y += cell_data[i, 2] / 2 + y_compensate
        end

        sprite.z = 2000
        sprite.ox = 96
        sprite.oy = 96
        sprite.zoom = cell_data[i, 3].to_i / 200.0
        sprite.angle = cell_data[i, 4].to_i
        sprite.angle += 180 if @_option == 1 && @_reverse
        sprite.mirror = (cell_data[i, 5] == 1)
        sprite.mirror = (sprite.mirror == false) if @_option == 2 && @_reverse
        sprite.opacity = cell_data[i, 6] * opacity / 255.0
        sprite.shader.blend_type = cell_data[i, 7]
      end
    end
  end
end
