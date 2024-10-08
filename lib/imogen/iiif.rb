module Imogen
  module Iiif
    class BadRequest < StandardError; end
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
      VALUES = {native: nil, default: nil, color: nil, bitonal: :bitonal, grey: :grey, gray: :grey}
      def self.get(quality=:native)
        q = (quality || :native).to_sym
        raise BadRequest.new("bad quality #{quality}") unless VALUES.include? q
        return VALUES[q]
      end
      def self.convert(img, quality)
        q = get(quality)
        if q == :grey
          yield img.copy(interpretation: :b_w)
        elsif q == :bitonal
          yield img.copy(interpretation: :b_w) > 128
        else
          yield img
        end
      end
    end
    autoload :Region, 'imogen/iiif/region'
    autoload :Size, 'imogen/iiif/size'
    autoload :Rotation, 'imogen/iiif/rotation'
    autoload :Tiles, 'imogen/iiif/tiles'

    FORMATS = {jpeg: 'jpg', jpg: 'jpg', png: 'png', jp2: 'jp2'}
    EXTENSIONS = {'jpg' => :jpeg, 'png' => :png, 'jp2' => :jp2}

    def self.convert(img, dest_path, format=nil, opts={})
      format ||= opts.fetch(:format,:jpeg)
      format = format.to_sym
      raise BadRequest.new("bad format #{format}") unless FORMATS.include? format
      Region.convert(img, opts[:region]) do |region|
        Size.convert(region, opts[:size]) do |size|
          Rotation.convert(size, opts[:rotation]) do |rotation|
            Quality.convert(rotation, opts[:quality]) do |quality|
              quality.write_to_file(dest_path, background: [255, 255, 255])
              yield quality if block_given?
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
