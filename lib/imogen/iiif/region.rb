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
    return e
  end
  def self.convert(img, region)
    edges = Region.new(img).get(region)
    if edges.nil?
      yield img
    else
      if edges == :featured
        side = [img.width, img.height,768].min
        Featured.convert(img, side) { |x| yield x }
      else
        # edges are leftX, topY, rightX, bottomY
        # Vips wants left, top, width, height
        yield img.extract_area(edges[0], edges[1], edges[2] - edges[0], edges[3] - edges[1])
      end
    end
  end
  class Featured < Transform
    SQUARISH = 5.to_f / 6
    ONE_THIRD = 1.to_f / 3
    def self.convert(img, scale = 768, opts = {})
      middle_dims = [(img.width * 2 * ONE_THIRD).floor, (img.height * 2 * ONE_THIRD).floor]
      x_offset = (img.width * ONE_THIRD/2).floor
      y_offset = (img.height * ONE_THIRD/2).floor
      crop_scale = middle_dims.min
      smart_crop_opts = {interesting: (squarish?(img) ? :centre : :entropy)}.merge(opts)
      window = img.extract_area(x_offset, y_offset, middle_dims[0], middle_dims[1])
      smartcrop = window.smartcrop(crop_scale, crop_scale, **smart_crop_opts)
      # Vips counts with negative offsets from left and top
      yield smartcrop.thumbnail_image(scale, height: scale)
    end

    # returns leftX, topY, rightX, bottomY
    def self.get(img, scale = 768, opts = {})
      middle_dims = [(img.width * 2 * ONE_THIRD).floor, (img.height * 2 * ONE_THIRD).floor]
      x_offset = (img.width * ONE_THIRD/2).floor
      y_offset = (img.height * ONE_THIRD/2).floor
      crop_scale = middle_dims.min
      smart_crop_opts = {interesting: (squarish?(img) ? :centre : :entropy)}.merge(opts)
      window = img.extract_area(x_offset, y_offset, middle_dims[0], middle_dims[1])
      smartcrop = window.smartcrop(crop_scale, crop_scale, **smart_crop_opts)
      # Vips counts with negative offsets from left and top
      left = (window.xoffset + smartcrop.xoffset)*-1
      top = (window.yoffset + smartcrop.yoffset)*-1
      right = left + smartcrop.width
      bottom = top + smartcrop.height
      return [left, top, right, bottom]
    end

    def self.squarish?(img)
      if img.is_a? Vips::Image
        dims = [img.width, img.height]
        ratio = dims.min.to_f / dims.max
        return ratio >= Featured::SQUARISH
      else
        raise "#{img.class.name} is not a Vips::Image"
      end
    end
  end
end
end
end
