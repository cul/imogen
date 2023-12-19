require 'imogen/zoomable'
module Imogen
  module Iiif
    module Tiles
      def self.scale_factors_for(full_image_width, full_image_height, tile_size)
        largest_scale_factor = Imogen::Zoomable.max_levels_for(full_image_width, full_image_height, tile_size)
        largest_scale_factor -= Math.log2(tile_size / 2) # remove scales smaller than tile size
        (0..(largest_scale_factor.to_i)).map { |exp| 2.pow(exp) }
      end

      # Yields many times, for each set of iiif tile raster opts for the given image.
      # @param img [Image] The image to be analyzed.
      # @param dest_dir [String] The target output directory for the tile subdirectory hierarchy.
      # @param format [String] Tile format
      # @param tile_size [Integer] Tile size
      # @param quality [String] IIIF quality value (e.g. 'color', 'default')
      # @yield [image, suggested_dest_path_for_tile, format, raster_opts] Image and tile generation info
      def self.for(img, dest_dir, format = :jpg, tile_size = 128, quality = 'default')
        format = :jpg if format.to_s == 'jpeg'

        width = img.width
        height = img.height

        # For this implementation, we will only support square tiles (same width and height)
        tile_width = tile_size
        tile_height = tile_size

        # If the original image dimensions are smaller than the tile_size,
        # generate a tile for region 'full' and size 'full'.
        if width < tile_size && height < tile_size
          raster_opts = {
            region: 'full',
            size: 'full',
            rotation: 0,
            quality: quality,
            format: format
          }

          dest_path = File.join(
            dest_dir,
            raster_opts[:region],
            raster_opts[:size],
            raster_opts[:rotation].to_s,
            "#{raster_opts[:quality]}.#{Imogen::Iiif::FORMATS[raster_opts[:format]]}"
          )
          yield(img, dest_path, raster_opts['format'], Imogen::Iiif.path_to_opts(dest_path, dest_dir))
        end


        # NOTE: Algorithm below is based on: https://iiif.io/api/image/2.1/#a-implementation-notes
        self.scale_factors_for(width, height, tile_size).each do |scale_factor|
          scale_factor_as_float = scale_factor.to_f

          col = 0
          x = 0
          while x < width
            row = 0
            y = 0
            while y < height
              # Calculate region parameters /xr,yr,wr,hr/
              xr = col * tile_width * scale_factor_as_float
              yr = row * tile_height * scale_factor_as_float
              wr = tile_width * scale_factor_as_float
              if xr + wr > width
                wr = width - xr
              end
              hr = tile_height * scale_factor_as_float
              if yr + hr > height
                hr = height - yr
              end
              # Calculate size parameters /ws,hs/
              ws = tile_width
              if xr + tile_width * scale_factor_as_float > width
                ws = (width - xr + scale_factor_as_float - 1) / scale_factor_as_float  # +scale_factor_as_floatZ-1 in numerator to round up
              end

              hs = tile_height
              if yr + tile_height * scale_factor_as_float > height
                hs = (height - yr + scale_factor_as_float - 1) / scale_factor_as_float
              end

              # If the region width (wr) or region height (hr) go negative, we've gone too far. Break!
              break if wr <= 0 || hr <= 0

              xr = xr.floor
              yr = yr.floor
              wr = wr.floor
              hr = hr.floor
              ws = ws.floor
              hs = hs.floor
              region = "#{xr},#{yr},#{wr},#{hr}"
              size = "#{ws},"

              # When tile_width and tile_height are the same, OpenSeadragon only specifies
              # the width for the size param in image slice URLs, so we will generally not
              # include the height in the size param string.
              size += "#{hs}" if tile_width != tile_height

              # Need to do this correction for OpenSeadragon Compatibility, since it asks for "full" in this case.
              region = 'full' if region == "0,0,#{width},#{height}"

              raster_opts = {
                region: region,
                size: size,
                rotation: 0,
                quality: quality,
                format: format
              }

              dest_path = File.join(
                dest_dir,
                raster_opts[:region],
                raster_opts[:size],
                raster_opts[:rotation].to_s,
                "#{raster_opts[:quality]}.#{Imogen::Iiif::FORMATS[raster_opts[:format]]}"
              )
              yield(img, dest_path, raster_opts['format'], Imogen::Iiif.path_to_opts(dest_path, dest_dir))

              row += 1
              y += tile_height
            end
            col += 1
            x += tile_width
          end
        end
      end

      # This method should NOT be used right now because it's missing some tiles that we rely on.
      # This method is just here as a partial vips-dzsave-based implementation that we may want to
      # build off in a fututure release.
      # The Imogen::Iiif::Tiles.for method should be used instead, since it generates all of the
      # expected tiles.
      # The issue with this method may be related to this:
      # https://github.com/libvips/libvips/discussions/2036
      def self.generate_with_vips_dzsave(img, output_dir, format: :jpeg, tile_size: 128, tile_filename_without_extension: 'default')
        warn "Warning: The generate_with_vips_dzsave is only partially functional and should not "\
             "be used to generate tiles yet.  If you use this method, some IIIF tiles will be missing."
        format = :jpg if format == :jpeg
        format = format.to_sym
        img.dzsave(
          output_dir,
          layout: 'iiif',
          suffix: ".tmp.#{format}",
          overlap: 0,
          tile_size: tile_size
        )

        # Update tile names with desired value
        Dir[File.join(output_dir, "**/*.tmp.#{format}")].each do |file_path|
          new_name = File.join(File.dirname(file_path), "#{tile_filename_without_extension}.#{format}")
          File.rename(file_path, new_name)
        end

        # Clean up unused additional dzsave files
        ['info.json', 'vips-properties.xml'].each do |unnecessary_file_name|
          File.delete(file_to_delete)
        end
      end
    end
  end
end
