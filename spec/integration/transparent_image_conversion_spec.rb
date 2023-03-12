require 'imogen'
require 'tmpdir'

describe 'Transparent image conversion', vips: true do
  let(:output_file) { Dir.tmpdir + '/test-imogen-convert.jpg' }
  let(:vips_image_double) do
    dbl = double(Vips::Image)
    allow(dbl).to receive(:height).and_return(1080)
    allow(dbl).to receive(:width).and_return(1920)
    dbl
  end

  describe 'Imogen::Iiif.convert' do
    it "should convert transparent pixels to white pixels when converting to a raster type that does not support transparency" do
      Imogen.with_image(fixture('sample-with-transparency.png').path) do |img|
        expect(img.getpoint(0, 0)).to eq([255, 255, 255, 0.0])
        Imogen::Iiif.convert(img, output_file, 'jpg', region: 'full', size: 'full', quality: 'color', rotation: '0')
      end

      Imogen.with_image(output_file) do |img|
        expect(img.getpoint(0, 0)).to eq([255, 255, 255])
      end
    ensure
      File.delete(output_file) if File.exist?(output_file)
    end

    it "should pass the expected background parameter when calling write_to_file" do
      expect(Imogen).to receive(:with_image).and_yield(vips_image_double)
      expect(vips_image_double).to receive(:write_to_file).with(String, {background: [255, 255, 255]})
      Imogen.with_image(fixture('sample.jpg').path) do |img|
        Imogen::Iiif.convert(img, output_file, 'jpg', region: 'full', size: 'full', quality: 'color', rotation: '0')
      end
    end
  end

  describe 'Imogen::AutoCrop.convert' do
    # Note: The test below is reliable because the input image is square, but it might fail if the
    # fixture image is ever changed, since a non-square image may have an unpredictable
    # auto-detected, featured, square region.  This is fine though, since in this case we're only
    # testing transparent pixel conversion and not testing cropping behavior.
    it "should convert transparent pixels to white pixels when converting to a raster type that does not support transparency" do
      Imogen.with_image(fixture('sample-with-transparency.png').path) do |img|
        expect(img.getpoint(0, 0)).to eq([255, 255, 255, 0.0])
        Imogen::AutoCrop.convert(img, output_file, 500)
      end

      Imogen.with_image(output_file) do |img|
        expect(img.getpoint(0, 0)).to eq([255, 255, 255])
      end
    ensure
      File.delete(output_file) if File.exist?(output_file)
    end

    it "should pass the expected background parameter when calling write_to_file" do
      allow(Imogen::Iiif::Region::Featured).to receive(:convert).and_yield(vips_image_double)
      expect(vips_image_double).to receive(:write_to_file).with(String, {background: [255, 255, 255]})
      Imogen.with_image(fixture('sample.jpg').path) do |img|
        Imogen::AutoCrop.convert(img, output_file, 500)
      end
    end
  end
end
