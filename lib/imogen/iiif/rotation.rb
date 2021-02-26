module Imogen
  module Iiif
    class Rotation < Transform
      RIGHT_ANGLES = [0,90,180,270]
      def get(rotate)
        return [0, false] if rotate.nil?
        original_rotate_value = rotate
        rotate = rotate.to_s
        raise BadRequest.new("bad rotate #{original_rotate_value}") unless rotate =~ /^!?-?\d+$/
        flip = rotate.to_s.start_with?('!')
        # libvips and IIIF spec counts clockwise
        angle = rotate.sub(/^!/, '').to_i % 360
        raise BadRequest.new("bad rotate #{original_rotate_value}") unless RIGHT_ANGLES.include?(angle)
        return angle, flip
      end

      def self.convert(img, rotate)
        angle, flip = Rotation.new(img).get(rotate)
        # IIIF spec applies horizontal flip ("mirrored by reflection on the vertical axis") before rotation
        img = img.fliphor if flip
        # No need to rotate if angle is zero
        img = img.rot("d#{angle}") unless angle.zero?
        yield img
      end
    end
  end
end
