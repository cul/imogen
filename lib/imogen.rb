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
  # @option opts [Boolean] :nocache When true, will clear the Vips cache before opening the image.
  def self.image(src_path, opts = {})
    # TODO: Change to `new_from_file(src_path, {nocache: nocache})`, or something similar,
    # when these two GitHub issues are addressed:
    # 1) https://github.com/libvips/ruby-vips/issues/360
    # 2) https://github.com/libvips/libvips/pull/3370
    clear_vips_cache_mem if opts[:nocache] == true
    Vips::Image.new_from_file(src_path)
  end

  # @param [String] src_path The local file path to the image.
  # @param [Hash] opts The options to use when opening an image.
  # @option opts [Boolean] :nocache When true, will clear the Vips cache before opening the image.
  def self.with_image(src_path, opts = {}, &block)
    block.yield(image(src_path, opts))
  end

  # TODO: The clear_vips_cache_mem method can be removed once these two tickets are addressed:
  # 1) https://github.com/libvips/ruby-vips/issues/360
  # 2) https://github.com/libvips/libvips/pull/3370
  def self.clear_vips_cache_mem
    # store original max because we'll restore it later
    original_max_value = vips_cache_get_max_mem

    # Drop max mem to 0, which also internally triggers a trim operation that clears out old cache entries
    vips_cache_set_max_mem(0)

    # Restore original value to support future caching operations
    vips_cache_set_max_mem(original_max_value)
  end
end
