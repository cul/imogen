module Imogen
module Iiif
class Rotation < Transform
  RIGHT_ANGLES = [0,90,180,270]
  def get(rotate)
    if rotate.nil? or rotate.eql? '0'
      return nil
    end
    raise BadRequest.new("bad rotate #{rotate}") unless rotate =~ /^-?\d+$/
    r = rotate.to_i % 360
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