module Imogen
	module Zoomable
    # levels for hypothetical 1x1 tiles
    def self.max_levels_for(*dims)
      return Math.log2(dims[0..1].max).ceil
    end
    # levels for width,height, tile_size=128
    def self.levels_for(*dims)
      max = dims[0..1].max || 0
      return 0 if max == 0
      tile_size = dims[2] || 128
      return Math.log2(dims[0..1].max.to_f / tile_size).ceil
    end
    def self.convert(img, dest_path)
      dst = FreeImage::File.new(dest_path)
      dst.save(img, :jp2, 8)
    end
  end
end