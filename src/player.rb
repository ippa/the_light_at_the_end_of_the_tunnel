class Player < Chingu::GameObject
  has_traits :timer, :velocity, :collision_detection
  has_trait :bounding_box, :scale => 0.80
  
  def initialize(options)
    super
    
    self.input = { :holding_left => :left, 
                   :holding_right => :right,
                   :up => :jump }
                   
    @animation = Hash.new
    @animation[:full] = Animation.new(:file => "player.bmp", :size => [8,9], :delay => 40).retrofy
    @animation[:running] = @animation[:full][0..3]    
    @image = @animation[:full].first

    @speed = 2
    self.rotation_center = :center_center
    self.factor = $window.factor
    self.acceleration_y = 0.3
    self.max_velocity = 10
    @previous_bounding_box = self.bounding_box
    @jumping = false
    cache_bounding_box
  end
  
  def jump
    unless @jumping
      self.velocity_y = -7
      @jumping = true
      Sound["jump.wav"].play(0.2)
    end
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
    $window.current_game_state.distance_to_surface(bb.centerx, bb.bottom)
  end
  
  def collision_left?
    collision = false
    image.line bb.left, bb.top, bb.left, bb.bottom, :color_control => proc { |c| if c[3] != 0; collision = true; end; :none }    
  end

  def collision_right?    
    collision = false
    image.line bb.right, bb.top, bb.right, bb.bottom, :color_control => proc { |c| if c[3] != 0; collision = true; end; :none }
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
  
  def update    
    if collision_bottom?
      @jumping = false
      self.velocity_y = 0
      @y = self.previous_y
    end

    if self.velocity_y < 0 && collision_top?
      self.velocity_y = 0
    end
    
    if collision_left? || collision_right?
      if ((dy = distance_to_surface) < 7)
        @y -= dy
      else
        @x = self.previous_x
      end
    end
    
    self.velocity_x = 0
  end
  
end
