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
        q = (quality || :native).to_sym
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
    autoload :Tiles, 'imogen/iiif/tiles'

    FORMATS = {jpeg: 'jpg', jpg: 'jpg', png: 'png'}
    EXTENSIONS = {'jpg' => :jpeg, 'png' => :png}
    def self.convert(img, dest_path, format=nil, opts={})
      format ||= opts.fetch(:format,:jpeg)
      format = format.to_sym
      raise BadRequest.new("bad format #{format}") unless FORMATS.include? format
      Region.convert(img, opts[:region]) do |region|
        Size.convert(region, opts[:size]) do |size|
          Rotation.convert(size, opts[:rotation]) do |rotation|
            Quality.convert(rotation, opts[:quality]) do |quality|
              dst = FreeImage::File.new(dest_path)
              format = :jpeg if format == :jpg
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
    def self.path_to_opts(path,parent_dir)
      if parent_dir and path.start_with? parent_dir
        path = path.sub(parent_dir,'')
      end
      path = path[1..-1] if path =~ /^\//
      parts = path.split('/')
      quality = parts[-1].split('.')[0].to_sym
      format = EXTENSIONS[parts[-1].split('.')[1]]
      {
        region: parts[0],
        size: parts[1],
        rotation: parts[2],
        quality: quality,
        format: format
      }
    end
  end
end