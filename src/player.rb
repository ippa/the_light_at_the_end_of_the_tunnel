class Player < Chingu::GameObject
  traits :timer, :collision_detection
  trait :bounding_box, :debug => DEBUG
  trait :velocity, :apply => false
  
  def initialize(options)
    super
    
    self.input = { :holding_left => :left, 
                   :holding_right => :right,
                   :holding_up => :jump }
                   
    @animation = Hash.new
    @animation[:full] = Animation.new(:file => File.join(ROOT, "media", "player.bmp"), :size => [8,9], :delay => 40)
    @animation[:running] = @animation[:full][0..3]    
    @image = @animation[:full].first

    @speed = 2
    @step = 2
    @max_climb = 10
    self.rotation_center = :center_bottom
    self.factor = $window.factor
    
    self.acceleration_y = 0.3
    self.max_velocity = 10
    
    @previous_bounding_box = self.bounding_box
    @jumping = false
    cache_bounding_box
  end
  
  def jump
    #return unless collision_bottom?
    unless @jumping
      self.velocity_y = -7
      @jumping = true
      Sound["jump.wav"].play(0.2)
    end
  end
  
  def land
    self.velocity_y = 0
    @jumping = false
    @image = @animation[:running].first
  end
  
  def left
    self.velocity_x = -@speed
    self.factor_x = -$window.factor
    @image = @animation[:running].next
  end

  def right
    self.velocity_x = @speed
    self.factor_x = $window.factor
    @image = @animation[:running].next
  end
  
  def distance_to_surface
    $window.current_game_state.distance_to_surface(bb.centerx, bb.bottom, @max_climb)
  end
  
  def surface_y
    $window.current_game_state.surface_y_from(bb.centerx, bb.bottom, @max_climb)
  end
  
  def collision_left?(offset = 0)
    (bb.top.to_i .. bb.bottom.to_i).each do |y|
      return true if  $window.current_game_state.pixel_collision_at?(bb.left-offset, y)
    end
    return false
  end

  def collision_right?(offset = 0)    
    (bb.top.to_i .. bb.bottom.to_i).each do |y|
      return true if  $window.current_game_state.pixel_collision_at?(bb.right+offset, y)
    end
    return false
  end

  def collision_bottom?
    $window.current_game_state.pixel_collision_at?(bb.centerx, bb.bottom)
  end
  def collision_top?
    $window.current_game_state.pixel_collision_at?(bb.centerx, bb.top)
  end
  
  def move_to_surface
    self.velocity_y = 0
    @jumping = false      
    self.y = surface_y  if distance_to_surface < @max_climb    
  end
  
  def update    
    
    stop_y = (self.y + self.velocity_y).to_i
    step = (self.velocity_y < 0) ? -1 : 1
    while @y != stop_y
      @y += step
      if collision_bottom? || collision_top?
        @y -= step
        land
        break
      end
    end
    
    #@x += @velocity_x
    
    stop_x = (self.x + self.velocity_x).to_i
    step = (self.velocity_x < 0) ? -1 : 1
    while @x != stop_x
      @x += step
      if collision_left? || collision_right?
        dy = distance_to_surface
        
        if dy < @max_climb
          @y -= dy
        else
          @x -= step
        end
        
        break
      end
    end

        
    if collision_bottom?
     # land
      dy = distance_to_surface
      if dy < @max_climb
        @y -= dy
      else
        @x = @previous_x
      end
    end
    
    self.velocity_x = 0
  end
  
end
