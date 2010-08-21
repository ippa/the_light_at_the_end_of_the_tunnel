class Enemy < Chingu::GameObject
  trait :collision_detection
  trait :velocity
  trait :bounding_box, :scale => 0.80#, :debug => true
  
  def initialize(options = {})
    super
    
    self.zorder = 0
  end
end
