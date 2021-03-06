# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'toolkit'

class Point
  include PrintablePoint
  attr_reader :x, :y
  
  def initialize(x, y)
    @x = x
    @y = y
  end
  
  def == other
    other and @x == other.x and @y == other.y
  end
  
  def + other
    self.class.new(@x + other.x, @y + other.y)
  end
  
  def - other
    self.class.new(@x - other.x, @y - other.y)
  end
  
  def * factor
    self.class.new(@x * factor, @y * factor)
  end
  
  def / factor
    self.class.new(@x / factor, @y / factor)
  end
  
  def eql?(other)
    other.instance_of?(Point) and self == other
  end
  
  def hash
    [@x, @y].hash
  end
  
  def unit
    Point.new(@x.unit, @y.unit)
  end
  
  def =~(other)
    other.nil? or
    (((not other.x) or other.x == x) and
      ((not other.y) or other.y == y))
  end
  
  def to_coord(ysize)
    "#{(self.x + ?a).chr if x}#{(ysize - self.y) if self.y}"
  end
  
  def self.from_coord(s, ysize, opts = { })
    if s =~ /^([a-zA-Z]?)(\d*)/
      letter = $1
      number = $2
      x = unless letter.empty? 
        if letter =~ /[a-z]/
          letter[0] - ?a
        else 
          letter[0] - ?A
        end
      end
      y = ysize - number.to_i unless number.empty?
      if (x and y) or (not opts[:strict])
        new x, y
      end
    end
  end
end

class PointRange
  include Enumerable
  
  attr_reader :src, :dst, :delta
  
  def initialize(src, dst)
    @src = src
    @dst = dst
    @delta = @dst - @src
    @increment = @delta.unit
  end
  
  def each
    current = @src
    while current != @dst
      yield current
      current += @increment
    end
  end
  
  def parallel?
    @delta.x == 0 or @delta.y == 0
  end
  
  def diagonal?
    @delta.x.abs == @delta.y.abs
  end
  
  def valid?
    parallel? or diagonal?
  end
end

class Numeric
  def unit
    self <=> 0
  end
end
