class Map
  attr_reader :row, :col
  attr_accessor :map
  
  def initialize(options = {})
    @row = options[:row] || 1
    @col = options[:col] || 0    
    @map = options[:map] || [ [ ] ] 
  end
  
  def current
    @map[@row][@col] rescue nil
  end
    
  def right
    @col += 1
    current
  end

  def left
    @col -= 1
    current
  end

  def up
    @row -= 1
    current
  end

  def down
    @row += 1
    current
  end

end