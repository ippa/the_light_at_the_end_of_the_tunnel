#
# 
#
require 'rubygems'
require 'opengl'
require 'texplay'

#begin
#  require '../chingu/lib/chingu'
#rescue LoadError
  require 'chingu'
#end

ENV['PATH'] = File.join(ROOT,"lib") + ";" + ENV['PATH']

include Gosu
include Chingu

require_all File.join(ROOT, 'src')

class Game < Chingu::Window
  attr_reader :player, :map
  attr_accessor :factor
  
  def initialize
    @factor = 3
    super(320 * 3, 180 * 3, false)
    
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
    switch_game_state(@map.current)
    
    #switch_game_state(Level8)
  end
    
end

Game.new.show