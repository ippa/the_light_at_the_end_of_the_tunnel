#
# 
#
GAMEROOT = File.dirname(File.expand_path($0))
ENV['PATH'] = File.join(GAMEROOT,"lib") + ";" + ENV['PATH']

require 'rubygems' unless RUBY_VERSION =~ /1\.9/
require 'chingu'
require 'texplay'

DEBUG = false
include Gosu
include Chingu

require_all File.join(ROOT, 'src')

exit if defined?(Ocra)

class Game < Chingu::Window
  attr_reader :player, :map
  
  def initialize
    super(320 * 3, 180 * 3, false)
    
    self.factor = 3
    Gosu::enable_undocumented_retrofication
    
    $window.caption = "the light at the end of the tunnel. ~~ http://ippa.se/gaming ~~ a LD#16 entry, theme 'Exploration'."
    
    self.input = { :esc => :close, :p => Chingu::GameStates::Pause, :f1 => :next_level }
    @player = Player.create(:x => 100, :y => 100, :zorder => 100, :visible => false)
    
    Sound["jump.wav"] # <-- lame caching untill chingu gets "cache_media()" or simular
    Sound["land.wav"]
    Sound["die.wav"]
    Sound["falling.wav"]
    Sound["poop.wav"]

    map = [ [LevelUp, nil, nil, nil],
            [Level1, Level2,Level22, nil],
            [LevelAir, nil, Level3, nil],
            [LevelAir2, Level5, Level4, nil],
            [nil, Level6, Level7, nil],
            [nil, Level8, Level9, Poop],
           ]            

    @map = Map.new(:map => map, :row => 1, :col => 0)
    
    #@map = Map.new(:map => map, :row => 5, :col => 2)
    #@player.x = 3
    #@player.y = 200
    
    switch_game_state(@map.current)
  end
    
end

Game.new.show