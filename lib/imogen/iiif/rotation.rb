module Imogen
  module Iiif
    class Rotation < Transform
      RIGHT_ANGLES = [0,90,180,270]
      def get(rotate)
        return nil if [nil, 0, '0'].include?(rotate)
        raise BadRequest.new("bad rotate #{rotate}") unless rotate.to_s =~ /^-?\d+$/
        # libvips and IIIF spec counts clockwise
        r = rotate.to_i % 360
        raise BadRequest.new("bad rotate #{rotate}") unless RIGHT_ANGLES.include? r
        return r > 0 ? r : nil
      end
      def self.convert(img, rotate)
        rotation = Rotation.new(img).get(rotate)
        if rotation
          yield img.rot("d#{rotation}")
        else
          yield img
        end
      end
    end
  end
end
