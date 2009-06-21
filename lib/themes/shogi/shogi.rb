require 'qtutils'
require 'themes/theme'
require 'themes/shadow'
require 'themes/background'

class ShogibanBackground
  include Theme
  include Background
  
  BACKGROUND_COLOR = Qt::Color.new(0xeb, 0xd6, 0xa0)
  LINE_COLOR = Qt::Color.new(0x9c, 0x87, 0x55)
  
  theme :name => 'Shogiban',
        :keywords => %w(shogi board)
        
  def initialize(opts = {})
    @squares = opts[:board_size] || opts[:game].size
  end
  
  def pixmap(size)
    Qt::Image.painted(Qt::Point.new(size.x * @squares.x, size.y * @squares.y)) do |p|
      (0...@squares.x).each do |x|
        (0...@squares.y).each do |y|
          rect = Qt::RectF.new(size.x * x, size.y * y, size.x, size.y)
          p.fill_rect(rect, Qt::Brush.new(BACKGROUND_COLOR))
        end
      end
      pen = p.pen
      pen.width = 2
      pen.color = LINE_COLOR
      p.pen = pen
      (0..@squares.x).each do |x|
        p.draw_line(x * size.x, 0, x * size.x, @squares.y * size.y)
      end
      (0..@squares.y).each do |y|
        p.draw_line(0, y * size.y, size.x * @squares.x, y * size.y)
      end
    end.to_pix
  end
end

class ShogiTheme
  include Theme
  include Shadower
  
  BASE_DIR = File.dirname(__FILE__)
  TYPES = { :knight => 'n' }
  NUDE_TILE = File.join(BASE_DIR, 'nude_tile.svg')
  RATIOS = {
    :king => 1.0,
    :rook => 0.96,
    :bishop => 0.93,
    :gold => 0.9,
    :silver => 0.9,
    :knight => 0.86,
    :lance => 0.83,
    :pawn => 0.8 }

  theme :name => 'Shogi',
        :keywords => %w(shogi pieces)

  def initialize(opts = {})
    @loader = lambda do |piece, size|
      tile = Qt::SvgRenderer.new(NUDE_TILE)
      kanji = Qt::SvgRenderer.new(filename(piece))
      ratio = RATIOS[piece.type] || 0.9
      img = Qt::Image.painted(size) do |p|
        p.scale(ratio, ratio)
        p.translate(size * (1 - ratio) / 2)
        if piece.color == :white
          p.translate(size)
          p.rotate(180)
        end
        tile.render(p)
        kanji.render(p)
      end
    end
    if opts.has_key? :shadow
      @loader = with_shadow(@loader)
    end
  end

  def pixmap(piece, size)
    @loader[piece, size].to_pix
  end
  
  def filename(piece)
    color = piece.color.to_s[0, 1]
#     type = TYPES[piece.type] || piece.type.to_s[0, 1]
    name = piece.type.to_s.gsub(/^promoted_/, 'p') + ".svg"
    File.join(BASE_DIR, name)
  end
end
