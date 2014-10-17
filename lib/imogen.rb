# encoding: UTF-8
require 'ffi'
require 'rbconfig'
require 'free-image'
module Imogen

  def self.from(src_path)
    FreeImage::Bitmap.open(src_path) do |img|
      yield img
    end
  end
  module Scaled
    def self.convert(img, dest_path, scale=1500, format = :jpeg)
      w = img.width
      h = img.height
      dims = (w > h) ? [scale, scale*h/w] : [scale*w/h, scale]
      img.rescale(dims[0], dims[1]) do |scaled|
        scaled = (scaled.color_type == :rgb) ?  scaled.convert_to_24bits : scaled.convert_to_8bits
        dst = FreeImage::File.new(dest_path)
        dst.save(scaled, format)
        scaled.free
      end
    end
  end
  module Cropped
    def self.convert(img, dest_path, edges, scale=nil, format=:jpeg)
    end
  end
  require 'imogen/auto_crop'
  require 'imogen/zoomable'
  require 'imogen/iiif'

  def self.search_paths
    @search_paths ||= begin
      if ENV['FREE_IMAGE_LIBRARY_PATH']
        [ ENV['FREE_IMAGE_LIBRARY_PATH'] ]
      elsif FFI::Platform::IS_WINDOWS
        ENV['PATH'].split(File::PATH_SEPARATOR)
      else
        [ '/usr/local/{lib64,lib32,lib}', '/opt/local/{lib64,lib32,lib}', '/usr/{lib64,lib32,lib}' ]
      end
    end
  end

  def self.find_lib(lib)
    files = search_paths.inject(Array.new) do |array, path|
      file_name = File.expand_path(File.join(path, "#{lib}.#{FFI::Platform::LIBSUFFIX}"))
      array << Dir.glob(file_name)
      array
    end
    files.flatten.compact.first
  end

  def self.free_image_library_paths
    @free_image_library_paths ||= begin
      libs = %w{libfreeimage libfreeimage.3 FreeImage}

      libs.map do |lib|
        find_lib(lib)
      end.compact
    end
  end

  extend ::FFI::Library

  if free_image_library_paths.any?
    ffi_lib(*free_image_library_paths)
  elsif FFI::Platform.windows?
    ffi_lib("FreeImaged")
  else
    ffi_lib("freeimage")
  end

  ffi_convention :stdcall if FFI::Platform.windows?

  def self.format_from(image_path)
    result = FreeImage.FreeImage_GetFileType(image_path, 0)
    FreeImage.check_last_error

    if result == :unknown
      # Try to guess the file format from the file extension
      result = FreeImage.FreeImage_GetFIFFromFilename(image_path)
      FreeImage.check_last_error
    end
    result
  end

  def self.image(src_path)

    flags = 0

    fif = format_from(src_path)
    if ((fif != :unknown) and FreeImage.FreeImage_FIFSupportsReading(fif))
      ptr = FreeImage.FreeImage_Load(fif, src_path, flags)
      FreeImage.check_last_error
      return FreeImage::Bitmap.new(ptr, nil)
    end
    return nil
  end
  def self.with_image(src_path, &block)

    flags = 0

    fif = format_from(src_path)
    if ((fif != :unknown) and FreeImage.FreeImage_FIFSupportsReading(fif))
      ptr = FreeImage.FreeImage_Load(fif, src_path, flags)
      FreeImage.check_last_error
      FreeImage::Bitmap.new(ptr, nil, &block)
    end
  end
end