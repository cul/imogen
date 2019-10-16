module Imogen
module Iiif
class Rotation < Transform
  RIGHT_ANGLES = [0,90,180,270]
  def get(rotate)
    return nil if [nil, 0, '0'].include?(rotate)
    raise BadRequest.new("bad rotate #{rotate}") unless rotate.to_s =~ /^-?\d+$/
    # negate offset because IIIF spec counts clockwise, FreeImage counterclockwise
    r = (rotate.to_i * -1) % 360
    r = r + 360 if r < 0
    raise BadRequest.new("bad rotate #{rotate}") unless RIGHT_ANGLES.include? r
    return r > 0 ? r : nil
  end
  def self.convert(img, rotate)
    rotation = Rotation.new(img).get(rotate)
    if rotation
      img.rotate(rotation) {|crop| yield crop}
    else
      yield img
    end
  end
end
end
end
