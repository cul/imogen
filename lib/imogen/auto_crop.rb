module Imogen
  module AutoCrop
    def self.convert(img, dest_path, scale=768, opts = {})
      Imogen::Iiif::Region::Featured.convert(img, scale, opts) do |smartcrop|
        smartcrop.write_to_file(dest_path, background: [255, 255, 255])
      end
    end
  end
end
