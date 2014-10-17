module Imogen
  module Iiif
    class BadRequest < Exception; end
    class Transform
      def initialize(src)
        @width = 0
        @height = 0
        if src.respond_to? :width and src.respond_to? :height
          img = src
          @width = src.width
          @height = src.height
        else
          raise "#{src.class.name} does not report width and height" 
        end
      end
      def max(x,y)
        (x > y) ? x : y
      end
      def min(x,y)
        (x < y) ? x : y
      end
    end
    module Quality
      VALUES = [:native, :color, :grey, :bitonal]
      def self.get(quality=:native)
        q = quality.to_sym
        raise BadRequest.new("bad quality #{quality}") unless VALUES.include? q
        return (q == :native or q == :color) ? nil : q
      end
      def self.convert(img, quality)
        q = get(quality)
        if q == :grey
          img.convert_to_greyscale {|c| yield c}
        elsif q == :bitonal
          img.threshold(128) {|c| yield c}
        else
          yield img
        end
      end
    end
    autoload :Region, 'imogen/iiif/region'
    autoload :Size, 'imogen/iiif/size'
    autoload :Rotation, 'imogen/iiif/rotation'

    FORMATS = [:jpeg, :png]
    def self.convert(img, dest_path, format=:jpeg, opts={})
      raise BadRequest.new("bad format #{format}") unless FORMATS.include? format
      Region.convert(img, opts[:region]) do |region|
        Size.convert(region, opts[:size]) do |size|
          Rotation.convert(size, opts[:rotation]) do |rotation|
            Quality.convert(rotation, opts[:quality]) do |quality|
              dst = FreeImage::File.new(dest_path)
              if (img.color_type == :rgb)
                quality.convert_to_24bits {|result| dst.save(result, format)}
              else
                quality.convert_to_8bits {|result| dst.save(result, format)}
              end
            end
          end
        end
      end
    end
  end
end