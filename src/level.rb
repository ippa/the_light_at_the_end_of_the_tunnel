class Level < GameState 
  has_trait :timer
  
  def initialize(options = {})
    super
    
    @bg2 = Color.new(0xFFBB0C25)
    @bg1 = Color.new(0xFF720817)
    
    @entry_x = player.x
    @entry_y = player.y
  end
  
  def level_image
    @level_image || "#{self.to_s.downcase}.bmp"
  end
  
  def background=(image)
    @background = GameObject.create(:image => image, :rotation_center => :top_left, :zorder => 20, :factor => $window.factor)
  end
  
  def player
    $window.player
  end
  def height
    $window.height
  end
  def width
    $window.width
  end
  def map
    $window.map
  end
  def draw
    super
    fill_gradient(:from => @bg1, :to => @bg2, :zorder => -1)
  end
    
  def update
    super
    
    if player.x >= width    # RIGHT
      player.x = 1
      player.y -= 5
      switch_game_state(map.right)
    elsif player.x < 0      # LEFT
      player.y -= 5
      player.x = width-1
      switch_game_state(map.left)
    elsif player.y > height # DOWN
      player.y = 1
      switch_game_state(map.down)
    elsif player.y < 0      # UP
      player.y = height-1
      switch_game_state(map.up)
    end
    
    player.each_collision(Enemy) do |player, enemy|
      unless player.paused?
        player.pause!
        Sound["die.wav"].play(0.1)
        after(1000) { player.velocity_y = 0; player.x = @entry_x; player.y = @entry_y; player.unpause!; }
      end
    end
    
    game_objects.destroy_if { |game_object| game_object.outside_window? }
    
    # $window.caption = "towards nirvana. #{self.class} - x/y #{$window.player.x}/#{$window.player.y} FPS: #{$window.fps} - Game objects: #{game_objects.size}"
  end
  
  def pixel_collision_at?(x, y)
    x = (x / $window.factor).to_i
    y = (y / $window.factor).to_i
    return false    if outside_window?(x, y)
    not @background.image.transparent_pixel?(x, y)
  end

  def distance_to_surface(x, y, max_steps = nil)
    steps = 0
    steps += 1  while pixel_collision_at?(x, y - steps) && (y - steps) > 0
    return steps
  end

  def outside_window?(x, y)    
    x <= 0 || x >= @background.image.width || y <= 0 || y >= @background.image.height
  end
  
end

class Level1 < Level
  has_trait :timer
  def setup
    player.show!
    self.background = "level1.bmp"
    every(2000) { Enemy.create(:image => "drop.bmp", :x => 300, :velocity_y => 5) }
  end
end

class LevelUp < Level
  def setup
    self.background = "level_up.bmp"
  end 
end

class LevelAir < Level
  def setup
    self.background = "level_air.bmp"
  end  
end

class LevelAir2 < Level
  def setup
    self.background = "level_air2.bmp"
  end  
end

class Level2 < Level
  def setup
    self.background = "level2.bmp"
    every(1000) { Enemy.create(:image => "drop.bmp", :x => 200, :velocity_y => 5) }
    every(1500) { Enemy.create(:image => "drop.bmp", :x => 300, :velocity_y => 5) }
    every(1500) { Enemy.create(:image => "drop.bmp", :x => 500, :velocity_y => 5) }
  end
end

class Level22 < Level
  def setup
    self.background = "level22.bmp"
  end
end

class Level3 < Level
  def setup
    self.background = "level3.bmp"
  end
end

class Level4 < Level
  def setup
    self.background = "level4.bmp"
    Enemy.create(:image => "acid.png", :rotation_center => :top_left, :x => 200, :y => 400)
  end
end

class Level5 < Level
  def setup
    self.background = "level5.bmp"
  end
end

class Level6 < Level
  def setup
    self.background = "level6.bmp"
  end
end

class Level7 < Level
  def setup
    self.background = "level7.bmp"
    every(1000) { Enemy.create(:image => "acid_drop.bmp", :x => 150, :velocity_y => 5) }
    every(1500) { Enemy.create(:image => "acid_drop.bmp", :x => 250, :velocity_y => 5) }
    every(2000) { Enemy.create(:image => "acid_drop.bmp", :x => 350, :velocity_y => 5) }
  end
end

class Level8 < Level
  def setup
    self.background = "level8.bmp"
    Enemy.create(:image => "small_acid.bmp", :rotation_center => :top_left, :x => 260, :y => 250)
  end
end

class Level9 < Level
  def setup
    self.background = "level9.bmp"
  end
end

class Poop < Level
  def setup
    Sound["poop.wav"].play(0.1)
    self.background = "poop.bmp"
    @landed = false
    
    player.pause!
    player.input = {}
    player.factor = 1
    $window.factor = 1
    player.x = 127 * 3
    player.y = 114 * 3
    
    every(500, :name => :falling) { 
      Sound["falling.wav"].play(0.1) 
      player.y += 7
    }
  end
  
  def update
    super
    if player.y > 153 * 3 && @landed == false
      stop_timer(:falling)
      Sound["land.wav"].play(0.1)
      @landed = true
    end
  end
end
