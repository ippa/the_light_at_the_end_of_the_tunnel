class OrigPlayer < Chingu::GameObject
  traits :timer, :velocity, :collision_detection
  trait :bounding_box, :debug => true
  
  def initialize(options)
    super
    
    self.input = { :holding_left => :left, 
                   :holding_right => :right,
                   :up => :jump }
                   
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
      self.velocity_y = -8
      @jumping = true
      Sound["jump.wav"].play(0.2)
    end
  end
    
  def left
    self.velocity_x = -@speed
    #@x -= @step  unless collision_left?(@step)
    #puts "collision left #{collision_left?(@step).to_s}"
    self.factor_x = -$window.factor
    @image = @animation[:running].next
  end

  def right
    self.velocity_x = @speed
    #@x += @step  unless collision_right?(@step)
    #puts "collision right #{collision_right?(@step).to_s}"
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
    #collision = false
    #image.line bb.left-offset, bb.top, bb.left-offset, bb.bottom, :color_control => proc { |c| if c[3] != 0; collision = true; end; :none }
    #return collision
    (bb.top.to_i .. bb.bottom.to_i).each do |y|
      return true if  $window.current_game_state.pixel_collision_at?(bb.left-offset, y)
    end
    return false
  end

  def collision_right?(offset = 0)
    #collision = false
    #image.line bb.right, bb.top, bb.right, bb.bottom, :color_control => proc { |c| puts c[3]; :none }
    #return collision
    
    (bb.top.to_i .. bb.bottom.to_i).each do |y|
      return true if  $window.current_game_state.pixel_collision_at?(bb.right+offset, y)
    end
    return false
  end

  def collision_bottom?
    #(self.bounding_box.left.to_i .. self.bounding_box.right.to_i).each do |x|
    #  return true if  $window.current_game_state.pixel_collision_at?(x, self.bounding_box.bottom)
    #end
    #return false
    $window.current_game_state.pixel_collision_at?(bb.centerx, bb.bottom)
  end
  def collision_top?
    #(self.bounding_box.left.to_i .. self.bounding_box.right.to_i).each do |x|
    #  return true if  $window.current_game_state.pixel_collision_at?(x, self.bounding_box.top.to_i)
    #end
    #return false
    $window.current_game_state.pixel_collision_at?(bb.centerx, bb.top)
  end
  
  def move_to_surface
    self.velocity_y = 0
    @jumping = false      
    self.y = surface_y  if distance_to_surface < @max_climb    
  end
  
  def update
    #@x = @x.round
    #@y = @y.round
        
    #
    # Walking into objects Left and Right => Revert back to last X
    #
    #if collision_left? || collision_right?
      if ((dy = distance_to_surface) < @max_climb)
        self.y = surface_y+1
      else
        @x = self.previous_x
      end
    #end
    
    # Jumping and hitting your head => Stop upwards motion
    if self.velocity_y < 0 && collision_top?
      self.velocity_y = 0
      @y = self.previous_y
    end    

    if collision_bottom?
      if self.velocity_y > 0
        @jumping = false 
        self.velocity_y = 0
      end
      
      self.y = surface_y+1  if distance_to_surface < @max_climb
    end

    self.velocity_x = 0
  end
  
end
