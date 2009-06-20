require 'test/unit'
require 'controller'
require 'rubygems'
require 'mocha'

class TestController < Test::Unit::TestCase
  def setup
    @board = mock('board')
    class << @board
      include Observable
    end
    @history = mock('history')
    @controller = Controller.new(@board, @history)
  end
  
  def test_on_new_move
    @history.expects(:add_move).once.with('state', 'move')
    @board.expects(:highlight).once.with('move')
    @board.fire :new_move => { :state => 'state', :move => 'move' }
  end
  
  def test_back
    @history.expects(:back).returns(['state', 'move'])
    @history.expects(:move).returns('last_move')
    @board.expects(:back).with('state', 'move')
    @board.expects(:highlight).once.with('last_move')
    @board.fire :back
  end
  
  def test_forward
    @history.expects(:forward).returns(['state', 'move'])
    @board.expects(:forward).with('state', 'move')
    @board.expects(:highlight).once.with('move')
    @board.fire :forward
  end
end
