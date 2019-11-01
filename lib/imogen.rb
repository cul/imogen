# encoding: UTF-8
require 'vips'
module Imogen

  def self.from(src_path)
    yield Vips::Image.matload(src_path)
  end
  module Scaled
    def self.convert(img, dest_path, scale=1500, format = :jpeg)
      w = img.width
      h = img.height
      dims = (w > h) ? [scale, scale*h/w] : [scale*w/h, scale]
      img.thumbnail_image(dims[0], height: dims[1]).write_to_file(dest_path)
    end
  end
  module Cropped
    def self.convert(img, dest_path, edges, scale=nil, format=:jpeg)
      img.crop(*edges).write_to_file(dest_path)
    end
  end
  require 'imogen/auto_crop'
  require 'imogen/zoomable'
  require 'imogen/iiif'

  def self.format_from(image_path)
    raise "format from path not implemented"
  end

  def self.image(src_path, flags=0)
    Vips::Image.new_from_file(src_path)
  end
  def self.with_image(src_path, flags = 0, &block)
    block.yield(image(src_path, flags))
  end
end
