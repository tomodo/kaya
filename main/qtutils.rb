require 'korundum4'
require 'item'

class Object
  def tap
    yield self
    self
  end
  
  def metaclass
    class << self
      self
    end
  end
  
  def metaclass_eval(&blk)
    metaclass.instance_eval(&blk)
  end
end

class Qt::Painter
  def paint
    yield self
  ensure
    self.end
  end
  
  def saving
    save
    yield self
  ensure
    restore
  end
end

class Qt::Image
  def to_pix
    Qt::Pixmap.from_image self
  end
  
  def self.painted(size, &blk)
    Qt::Image.new(size.x, size.y, Qt::Image::Format_ARGB32_Premultiplied).tap do |img|
      img.fill(0)
      Qt::Painter.new(img).paint(&blk)
    end
  end
end

module PrintablePoint
  def to_s
    "(#{x}, #{y})"
  end
end

module PrintableRect
  def to_s
    "[#{x}, #{y} - #{width}, #{height}]"
  end
end

class Qt::Point
  include PrintablePoint
end

class Qt::PointF
  include PrintablePoint
end

class Qt::Size
  include PrintablePoint
  
  def x
    width
  end
  
  def y
    height
  end
end

class Qt::Rect
  include PrintableRect
end

class Qt::RectF
  include PrintableRect
end

class Qt::Pixmap
  def self.from_svg(size, file)
    renderer = Qt::SvgRenderer.new(file)
    Qt::Image.painted(size) {|p| renderer.render(p) }.to_pix
  end  
end

class Qt::Object
  def self.on(sign, &blk)
    connect(SIGNAL(sign.to_s + '()', &blk))
  end
end

class Qt::Timer
  def self.every(interval, &blk)
    time = Qt::Time.new
    time.restart
    
    new.tap do |timer|
      timer.on(:timeout) { blk[time.elapsed] }
      timer.start(interval)
    end
  end
end
