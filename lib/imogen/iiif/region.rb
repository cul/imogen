#!ruby

module Imogen
module Iiif
class Region < Transform
  # returns leftX, topY, rightX, bottomY
  def get(region=nil)
    if region.nil? || region.to_s == 'full'
      return nil
    elsif region.to_s == 'featured'
      return :featured
    elsif md = /^pct:(\d+(\.\d+)?),(\d+(\.\d+)?),(\d+(\.\d+)?),(\d+(\.\d+)?)$/.match(region)
      p = [Float(md[1]),Float(md[3]),Float(md[5]),Float(md[7])]
      if p[2] == 0 or p[3] == 0
        raise BadRequest.new("Invalid region: #{region}")
      end
      e = [
        max(0,(@width * p[0] / 100).round),
        max(0,(@height * p[1] / 100).round),
        min(@width,(@width * (p[0] + p[2]) / 100).round),
        min(@height,(@height * (p[1] + p[3]) / 100).round)
      ]
    elsif md = /^(\d+),(\d+),(\d+),(\d+)$/.match(region)
      p = [Integer(md[1]),Integer(md[2]),Integer(md[3]),Integer(md[4])]
      if p[2] == 0 or p[3] == 0
        raise BadRequest.new("Invalid region: #{region}")
      end
      e = [
        max(0,p[0]),
        max(0,p[1]),
        min(@width,(p[0] + p[2])),
        min(@height,(p[1] + p[3]))
      ]
    else
      raise BadRequest.new("Invalid region (syntax): #{region}")
    end
    if (e[0] > @width or e[1] > @height)
      raise BadRequest.new("Invalid region (disjoint): #{region}")
    end      
    if (e[2]) * (e[3]) < 100
      raise BadRequest.new("Region too small: #{region}")
    end
    return e
  end
  def self.convert(img, region)
    edges = Region.new(img).get(region)
    if edges.nil?
      yield img
    else
      if edges == :featured
        frame = Imogen::AutoCrop::Edges.new(img)
        begin
          edges = frame.get([img.width, img.height,768].min)
        ensure
          frame.unlink
        end
      end
      img.copy(*edges) {|crop| yield crop}
    end
  end
end
end
end