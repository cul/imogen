require 'imogen/zoomable'
module Imogen
  module Iiif
    module Tiles
      def self.scale_factor_for(*dims)
        Imogen::Zoomable.levels_for(*dims)**2
      end
      def self.for(img,dest_dir,format=:jpeg,tile_size=128,override=false)
        width, height = img.width, img.height
        max_level = Imogen::Zoomable.levels_for(width,height,tile_size)
        max_level.downto(0) do |level|
          scale = 0.5**level
          level_width = (img.width*scale).ceil 
          level_width = (img.height*scale).ceil 
          region_size = (tile_size / scale).ceil
          region_width = (scale * img.width).ceil
          region_height = (scale * img.height).ceil
          x, col = 0, 0
          while x < width
            y, row = 0, 0
            while y < height
              region = "#{x},#{y},#{[width-x,region_size].min},#{[height-y,region_size].min}"
              size = "full"
              dest_path = File.join(dest_dir,region,size,'0',"native.#{Imogen::Iiif::FORMATS[format]}")
              unless File.exists? dest_path or override
                yield(img,dest_path,format,Imogen::Iiif.path_to_opts(dest_path,dest_dir))
              end
              y += region_size
              row += 1
            end
            x += region_size
            col += 1
          end
        end
      end
    end
  end
end