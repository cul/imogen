#!ruby
require 'opencv'
module Imogen::AutoCrop::Box
  include OpenCV
  class Best
    def initialize(grayscale)
      @corners = grayscale.good_features_to_track(0.3, 1.0, block_size: 3, max: 20)
      if @corners.nil? or @corners.length == 0
        @center = Center.new(grayscale)
      else
        @center = nil
      end
    end

    def self.distance(p1, p2)
      dx = p1.x.to_i - p2.x.to_i
      dy = p1.y.to_i - p2.y.to_i
      return Math.sqrt((dx * dx) + (dy * dy)) 
    end

    def box()
      return @center.box unless @center.nil?
      c = median()
      cp = BoxInfo.new(c[0], c[1],0)
      total_distance = 0;
      features = @corners.collect {|corner| d = Best.distance(corner, cp); total_distance += d; {x: corner.x, y: corner.y, d: d}}
      mean_distance = total_distance/features.length
      sigma = features.inject(0) {|memo, feature| v = feature[:d] - mean_distance; memo += (v*v)}
      sigma = Math.sqrt(sigma.to_f/features.length)
      # 2 sigmas would capture > 95% of normally distributed features
      cp.radius = 2*sigma
      cp
    end

    def median()
      @median ||= begin
        xs = []
        ys = []
        @corners.each {|c| xs << c.x.to_i; ys << c.y.to_i}
        xs.sort!
        ys.sort!
        ix = 0
        if (@corners.length % 2 == 0)
          l = (@corners.length == 2) ? 0 : (@corners.length/2)
          x = ((xs[l] + xs[l+1]) /2).floor
          y = ((ys[l] + ys[l+1]) /2).floor
          [x,y]
        else
          r = (@corners.length/2).ceil
          [xs[r], ys[r]]
        end
      end
    end
  end
  class Center
    def initialize(grayscale)
      @center ||= [(grayscale.cols/2).floor, (grayscale.rows/2).floor]
      @radius = @center.min
      @ratio = @radius / @center.max
    end
    def box
      return BoxInfo.new(@center[0],@center[1],@radius)
    end
  end
  class BoxInfo
    attr_reader :x, :y
    attr_accessor :radius
    def initialize(x,y,r)
      @x = x
      @y = y
      @radius = r
    end
  end
  def self.info(grayscale)
    dims = [grayscale.cols, grayscale.rows]
    ratio = dims.min / dims.max
    ratio < 0.84 ? Best.new(grayscale).box() : Center.new(grayscale).box()
  end
end