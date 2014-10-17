module Imogen
module Iiif
class Size < Transform
	def get(scale=nil)
    if scale.nil? or scale.eql? "0"
      return nil
    end
    if md = /^(\d+)?,(\d+)?$/.match(scale)
      w = md[1] ? min(Integer(md[1]), @width) : nil
      h = md[2] ? min(Integer(md[2]), @height) : nil
      raise BadRequest.new("bad scale #{scale}") unless w or h
      w ||= (@width * (h.to_f / @height)).round
      h ||= (@height * (w.to_f / @width)).round
      e = [w,h]
    elsif md = /^pct:(\d+(\.\d+)?)/.match(scale)
      p = Float(md[1])
      p = min(100,p).to_f
      raise BadRequest.new("bad size #{scale}") if p <= 0
      e = [(@width * p / 100).round, (@height * p / 100).round]
    else
      raise BadRequest.new("bad size #{scale}")
    end
    raise BadRequest.new("bad size #{scale}") if e[0] <= 0 or e[1] <= 0
    return e
  end
  def self.convert(img, size)
    dims = Size.new(img).get(size)
    if dims
      img.rescale(*dims) {|crop| yield crop}
    else
      yield img
    end
  end
end
end
end