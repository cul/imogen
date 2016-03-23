#!ruby
require 'opencv'
require 'free-image'
require 'tempfile'

module Imogen::AutoCrop
class Edges
  include OpenCV
  def initialize(src)
    @xoffset = 0
    @yoffset = 0
    if src.is_a? FreeImage::Bitmap
      img = src
      #@xoffset = img.width.to_f/6
      #@yoffset = img.height.to_f/6
      if Imogen::AutoCrop::Box.squarish? img
        #@xoffset = @xoffset/2
        #@yoffset = @yoffset/2
      end
      @tempfile = Tempfile.new(['crop','.png'])

      img.copy(@xoffset,@yoffset,img.width-@xoffset,img.height-@yoffset) do |crop|
        crop.save(@tempfile.path, :png)
        crop.free
      end
    else
      raise src.class.name 
    end
    # use bigger features on bigger images?
    # gaussian([p1 = 3, p2 = 3, p3 = 0.0, p4 = 0.0])
    kernel = 3
    cvmat = CvMat.load(@tempfile.path, CV_LOAD_IMAGE_COLOR)
    gauss = cvmat.blur_gaussian(7,7,0.0,0.0,:border_complete)
    gs = gauss.BGR2GRAY
    # on a color image we can call BGR2GRAY
    @grayscale =
      gs.laplace(kernel).convert_scale_abs(:scale => 1, :shift => 0)
    @xrange = (0..@grayscale.cols)
    @yrange = (0..@grayscale.rows)
  end

  def bound_min(center)
    [center.x - @xrange.min, @xrange.max - center.x, center.y - @yrange.min, @yrange.max - center.y].min
  end

  # returns leftX, topY, rightX, bottomY
  def get(*args)
    c = Imogen::AutoCrop::Box.info(@grayscale)
    r = c.radius.floor
    # adjust the box
    coords = [c.x, c.y]
    min_rad = args.max/2
    unless r >= min_rad && r <= bound_min(c)
      # first adjust to the lesser of max (half short dimension) and min (half requested length) radius
      # this might require upscaling in rare situations to preserve bound safety
      r = min_rad if r < min_rad
      max_rad = [@xrange.max - @xrange.min, @yrange.max - @yrange.min].min / 2
      r = max_rad if r > max_rad
      # now move the center point minimally to accomodate the necessary radius
      coords[0] = @xrange.max - r if (coords[0] + r) > @xrange.max  
      coords[0] = @xrange.min + r if (coords[0] - r) < @xrange.min  
      coords[1] = @yrange.max - r if (coords[1] + r) > @yrange.max  
      coords[1] = @yrange.min + r if (coords[1] - r) < @yrange.min  
    end
    coords = [coords[0] + @xoffset, coords[1] + @yoffset].collect {|i| i.floor}
    c = coords

    return [c[0]-r, c[1]-r, c[0]+r, c[1] + r]
  end
  def unlink
    @tempfile.unlink
  end
end
end