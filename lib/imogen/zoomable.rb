module Imogen
	module Zoomable
    def self.max_levels_for(*dims)
      return Math.log2(dims.max).ceil
    end
    def self.levels_for(*dims)
      max = dims[0..1].max || 0
      tile_size = dims[2] || 96
      return 0 if max < (2*tile_size)
      return (max_levels_for(*dims) - Math.log2(tile_size)).floor
    end
    def self.convert(img, dest_path)
      dst = FreeImage::File.new(dest_path)
      dst.save(img, :jp2, 8)
    end
  end
end