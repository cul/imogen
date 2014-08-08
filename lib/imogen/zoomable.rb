#require 'image_science'
module Imogen
	module Zoomable
    def self.levels_for(*dims)
      max = dims[0..1].max || 0
      return 0 if max < 192
      max_tiles = (max.to_f / 96)
      Math.log2(max_tiles).floor
    end
    def self.convert(img, dest_path)
      dst = FreeImage::File.new(dest_path)
      dst.save(img, :jp2, 8)
    end
  end
end