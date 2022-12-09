require 'imogen'
require 'tmpdir'

describe Imogen::AutoCrop, vips: true do
  describe "#convert" do
    let(:output_file) { Dir.tmpdir + '/test-imogen-convert.jpg' }
    it "should successfully convert the image" do
      expect_any_instance_of(Vips::Image).to receive(:write_to_file).with(String, {background: [255, 255, 255]}).and_call_original
      Imogen.with_image(fixture('sample.jpg').path) do |img|
        Imogen::Iiif.convert(img, output_file, 'jpg', region: '50,60,500,800', size: '!100,100', quality: 'color', rotation: '!90')
      end
      expect(File.exist?(output_file)).to be true
      expect(File.size?(output_file)).to be > 0
    ensure
      File.delete(output_file) if File.exist?(output_file)
    end
  end
end
