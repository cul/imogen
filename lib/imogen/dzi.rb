require 'imogen/zoomable'
require 'imogen/iiif'
module Imogen
  module Dzi
    def self.convert(img,dest_dir,format=:jpeg,opts={})
      override = opts[:override]
      
    end
    def self.iiif_paths(img,tile_size=512,format=:jpeg)
      width, height = img.width, img.height
      max_levels = Imogen::Zoomable.max_levels_for(width, height)
      results = {}
      max_levels.downto(0) do |level|
        c_ratio = 2**(max_levels-level)

        tile_side = tile_size*c_ratio
        x, col = 0, 0
        while x < width
          y, row = 0, 0
          while y < height
            results["#{level}/#{col_count}_#{row_count}"] = iiif_path_for_dzi(level,max_levels,col,row,tile_size,format)
            y += tile_side
            row += 1
          end
          x += tile_side
          col += 1
        end

      end
    end
    def self.iiif_opts_for_dzi(level,max_levels,col,row,tile_size=512,format=:jpeg)
      level = level.to_i
      max_levels = max_levels.to_i
      c_ratio = 2**(max_levels-level)

      tile_side = tile_size*c_ratio
      x = col * c_ratio
      y = row * c_ratio
      {
        region: "#{x},#{y},#{tile_side},#{tile_side}",
        size: "!#{tile_size},#{tile_size}",
        format: format,
        rotation: 0,
        quality: :native
      }
    end
    def self.iiif_path_for_dzi(level,max_levels,col,row,tile_size=512,format=:jpeg)
      opts = iiif_opts_for_dzi(level, max_levels,col,row,tile_size,format)
      "#{opts[:region]}/#{opts[:size]}/#{opts[:rotation]}/#{opts[:quality]}.#{Imogen::Iiif::FORMATS[format]}"
    end
  end
end