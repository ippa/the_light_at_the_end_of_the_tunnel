class Enemy < Chingu::GameObject
  has_trait :collision_detection
  has_trait :velocity
  has_trait :bounding_box, :scale => 0.80#, :debug => true
  
  def initialize(options = {})
    super
    
    self.image.retrofy
    self.zorder = 0
    self.factor = $window.factor
  end
end
