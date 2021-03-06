# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'point'
require 'games/state_base'

module Chess
  class State < StateBase
    attr_reader :castling_rights
    attr_accessor :en_passant_square
    
    class CastlingRights
      def initialize
        @wk = @wq = @bq = @bk = true
      end
      
      def king?(color)
        color == :white ? @wk : @bk
      end
      
      def queen?(color)
        color == :white ? @wq : @bq
      end
      
      def cancel_king(color)
        if color == :white
          @wk = false
        else
          @bk = false
        end
      end
      
      def cancel_queen(color)
        if color == :white
          @wq = false
        else
          @bq = false
        end
      end

      def ==(other)
        @wk == other.king?(:white) &&
          @wq = other.queen?(:white) &&
          @bk = other.king?(:black) &&
          @bq = other.queen?(:black)
      end
    end
    
    def initialize(board, move_factory, piece_factory)
      super
      @turn = :white
      @castling_rights = CastlingRights.new
    end
    
    def initialize_copy(other)
      super
      @castling_rights = other.castling_rights.dup
    end
    
    def setup
      # place pawns
      each_color do |color|
        (0...@board.size.x).each do |i|
          @board[Point.new(i, row(1, color))] = piece_factory.new(color, :pawn)
        end
        y = row(0, color)
        [:rook, :knight, :bishop, :queen, :king, :bishop, :knight, :rook].each_with_index do |type, x|
          @board[Point.new(x, y)] = piece_factory.new(color, type)
        end
      end
    end
    
    def row(i, color)
      color == :white ? @board.size.y - 1 - i : i
    end
    
    def each_color
      yield :white
      yield :black
    end
    
    def capture_square(move)
      if move.type == :en_passant_capture
        Point.new(move.dst.x, move.src.y)
      else
        move.dst
      end
    end
    
    def perform!(move)
      if move.type == :en_passant_trigger
        self.en_passant_square = move.src + direction(turn)
      else
        self.en_passant_square = nil
      end
      
      capture_on! capture_square(move)
      
      piece = @board[move.src]
      if piece and piece.type == :king
        @castling_rights.cancel_king(turn)
        @castling_rights.cancel_queen(turn)
      end
      each_color do |color|
        [:src, :dst].each do |m|
          @castling_rights.cancel_king(color) if move.send(m) == Point.new(7, row(0, color))
          @castling_rights.cancel_queen(color) if move.send(m) == Point.new(0, row(0, color))
        end
      end
      
      basic_move move
      
      if move.type == :promotion
        promote_on!(move.dst, move.promotion) if move.promotion
      elsif move.type == :king_side_castling
        basic_move move_factory.new(move.dst + Point.new(1, 0), move.dst - Point.new(1, 0))
      elsif move.type == :queen_side_castling
        basic_move move_factory.new(move.dst - Point.new(2, 0), move.dst + Point.new(1, 0))
      end
      
      switch_turn!
    end
     
    def perform_en_passant_trigger(move)
      self.en_passant_square = move.src + direction(turn)
    end
    
    def perform_en_passant_capture(move)
      capture_on! 
    end
    
    def capture_on!(p)
      @board[p] = nil
    end
    
    def switch_turn!
      self.turn = opposite_turn turn
    end
    
    def opposite_turn(t)
      t == :white ? :black : :white
    end
    
    def king_starting_position(color)
      Point.new(4, row(0, color))
    end
    
    def to_s
      board.to_s + "\nturn = #{turn}"
    end
    
    def direction(color)
      Point.new(0, color == :white ? -1 : 1)
    end

    def ==(other)
      super(other) &&
        @castling_rights == other.castling_rights
    end
  end
end
