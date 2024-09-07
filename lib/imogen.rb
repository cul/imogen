# encoding: UTF-8
require 'vips'
require 'ffi'

module Imogen
  extend FFI::Library

  # Note: library_name function comes from `require 'vips'`
  ffi_lib library_name("vips", 42)

  attach_function :vips_cache_get_max_mem, [], :int
  attach_function :vips_cache_set_max_mem, [:int], :void
  attach_function :vips_tracked_get_mem, [], :int

  def self.from(src_path)
    yield Vips::Image.matload(src_path)
  end
  module Scaled
    def self.convert(img, dest_path, scale=1500, format = :jpeg)
      w = img.width
      h = img.height
      dims = (w > h) ? [scale, scale*h/w] : [scale*w/h, scale]
      img.thumbnail_image(dims[0], height: dims[1]).write_to_file(dest_path, background: [255, 255, 255])
    end
  end
  module Cropped
    def self.convert(img, dest_path, edges, scale=nil, format=:jpeg)
      img.crop(*edges).write_to_file(dest_path, background: [255, 255, 255])
    end
  end
  require 'imogen/auto_crop'
  require 'imogen/zoomable'
  require 'imogen/iiif'

  def self.format_from(image_path)
    raise "format from path not implemented"
  end

  # @param [String] src_path The local file path to the image.
  # @param [Hash] opts The options to use when opening an image.
  # @option opts [Boolean] :revalidate (Requires libvips > 8.15) When true, will force the underlying
  #                                    Vips library to reload the source file instead of using cached
  #                                    data from an earlier read.  This is useful if the source
  #                                    file was recently recreated.
  def self.image(src_path, opts = {})
    if opts.empty?
      Vips::Image.new_from_file(src_path)
    else
      Vips::Image.new_from_file(src_path, **opts)
    end
  end

  # @param [String] src_path The local file path to the image.
  # @param [Hash] opts The options to use when opening an image.
  # @option opts [Boolean] :revalidate (Requires libvips > 8.15) When true, will force the underlying
  #                                    Vips library to reload the source file instead of using cached
  #                                    data from an earlier read.  This is useful if the source
  #                                    file was recently recreated.
  def self.with_image(src_path, opts = {}, &block)
    block.yield(image(src_path, opts))
  end
end
