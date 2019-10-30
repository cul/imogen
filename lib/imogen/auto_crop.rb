module Imogen
  module AutoCrop
    autoload :Edges, 'imogen/auto_crop/edges'
    autoload :Box, 'imogen/auto_crop/box'
    def self.convert(img, dest_path, scale=768, format=:jpeg)
      frame = Edges.new(img)
      edges = frame.get(scale)
      img.copy(*edges) do |crop|
        crop.rescale(scale, scale) do |thumb|
          dst = FreeImage::File.new(dest_path)
          t24 = (crop.color_type == :rgb) ?  thumb.convert_to_24bits : thumb.convert_to_8bits
          dst.save(t24, format)
          t24.free
          thumb.free
        end
      end
    end
  end
end
