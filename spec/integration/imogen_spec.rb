require 'imogen'
require 'tmpdir'

describe Imogen, vips: true do
  describe ".with_image" do
    let(:source_path) { fixture('sample.jpg').path }
    let(:revalidate) { true }

    it 'calls Vips::Image.new_from_file in the expected way when no opts are passed' do
      expect(Vips::Image).to receive(:new_from_file).with(source_path)
      Imogen.with_image(source_path) do |img|
        # don't need to do anything with the image for this test
      end
    end

    it 'passes the revalidate option to the underlying Vips::Image.new_from_file method' do
      expect(Vips::Image).to receive(:new_from_file).with(source_path, revalidate: revalidate)
      Imogen.with_image(source_path, revalidate: revalidate) do |img|
        # don't need to do anything with the image for this test
      end
    end
  end
end
