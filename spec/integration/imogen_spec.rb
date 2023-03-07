require 'imogen'
require 'tmpdir'

describe Imogen, vips: true do
  describe ".with_image" do
    it 'should call clear_vips_cache_mem when nocache option is provided' do
      expect(Vips::Image).to receive(:new_from_file)
      expect(Imogen).to receive(:clear_vips_cache_mem)
      Imogen.with_image(fixture('sample.jpg').path, nocache: true) do |img|
        # don't need to do anything with the image for this test
      end
    end

    it 'should not call clear_vips_cache_mem when nocache option is not provided, or is false' do
      expect(Vips::Image).to receive(:new_from_file).twice
      expect(Imogen).not_to receive(:clear_vips_cache_mem)
      Imogen.with_image(fixture('sample.jpg').path, nocache: false) do |img|
        # don't need to do anything with the image for this test
      end
      Imogen.with_image(fixture('sample.jpg').path) do |img|
        # don't need to do anything with the image for this test
      end
    end
  end
end
