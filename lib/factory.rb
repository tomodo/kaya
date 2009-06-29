# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

class Factory
  attr_reader :component

  def initialize(klass = nil, &blk)
    @blk = blk
    @component = klass
  end
  
  def new(*args)
    @blk[*args]
  end
end
