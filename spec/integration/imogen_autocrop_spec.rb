require 'imogen'
require 'tmpdir'

describe Imogen::AutoCrop, vips: true do
  describe "#convert" do
    let(:output_file) { Dir.tmpdir + '/test-imogen-crop.jpg' }
    it "should successfully convert the image" do
      Imogen.with_image(fixture('sample.jpg').path) do |img|
        Imogen::AutoCrop.convert(img, output_file, 150)
      end
      expect(File.exist?(output_file)).to be true
      expect(File.size?(output_file)).to be > 0
    ensure
      File.delete(output_file) if File.exist?(output_file)
    end
  end
end
