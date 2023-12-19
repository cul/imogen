require 'imogen'
require 'tmpdir'

describe Imogen::Iiif::Tiles, vips: true do
  let(:source_image) { fixture('sample.jpg').path } # sample.jpg is 1920w × 3125h
  let(:tile_size) { 512 }
  let(:output_dir) { Dir.tmpdir + '/tile-output-dir' }
  let(:expected_files) do
    [
      '/0,0,512,512/512,/0/default.jpg',
      '/0,512,512,512/512,/0/default.jpg',
      '/0,1024,512,512/512,/0/default.jpg',
      '/0,1536,512,512/512,/0/default.jpg',
      '/0,2048,512,512/512,/0/default.jpg',
      '/0,2560,512,512/512,/0/default.jpg',
      '/0,3072,512,53/512,/0/default.jpg',
      '/512,0,512,512/512,/0/default.jpg',
      '/512,512,512,512/512,/0/default.jpg',
      '/512,1024,512,512/512,/0/default.jpg',
      '/512,1536,512,512/512,/0/default.jpg',
      '/512,2048,512,512/512,/0/default.jpg',
      '/512,2560,512,512/512,/0/default.jpg',
      '/512,3072,512,53/512,/0/default.jpg',
      '/1024,0,512,512/512,/0/default.jpg',
      '/1024,512,512,512/512,/0/default.jpg',
      '/1024,1024,512,512/512,/0/default.jpg',
      '/1024,1536,512,512/512,/0/default.jpg',
      '/1024,2048,512,512/512,/0/default.jpg',
      '/1024,2560,512,512/512,/0/default.jpg',
      '/1024,3072,512,53/512,/0/default.jpg',
      '/1536,0,384,512/384,/0/default.jpg',
      '/1536,512,384,512/384,/0/default.jpg',
      '/1536,1024,384,512/384,/0/default.jpg',
      '/1536,1536,384,512/384,/0/default.jpg',
      '/1536,2048,384,512/384,/0/default.jpg',
      '/1536,2560,384,512/384,/0/default.jpg',
      '/1536,3072,384,53/384,/0/default.jpg',
      '/0,0,1024,1024/512,/0/default.jpg',
      '/0,1024,1024,1024/512,/0/default.jpg',
      '/0,2048,1024,1024/512,/0/default.jpg',
      '/0,3072,1024,53/512,/0/default.jpg',
      '/1024,0,896,1024/448,/0/default.jpg',
      '/1024,1024,896,1024/448,/0/default.jpg',
      '/1024,2048,896,1024/448,/0/default.jpg',
      '/1024,3072,896,53/448,/0/default.jpg',
      '/0,0,1920,2048/480,/0/default.jpg',
      '/0,2048,1920,1077/480,/0/default.jpg',
      '/full/240,/0/default.jpg',
      '/full/120,/0/default.jpg',
    ].map { |partial_path| File.join(output_dir, partial_path) }
  end

  describe "#for" do
    it "should successfully generate the expected tile files" do
      Imogen.with_image(source_image) do |image|
        Imogen::Iiif::Tiles.for(image, output_dir, :jpeg, tile_size) do |img, suggested_tile_dest_path, format, opts|
          FileUtils.mkdir_p(File.dirname(suggested_tile_dest_path))
          Imogen::Iiif.convert(img, suggested_tile_dest_path, format, opts)
        end
      end
      generated_files = Dir["#{output_dir}/**/*.jpg"]

      # Check for missing files and extra unexpected files
      missing_files = expected_files.sort - generated_files.sort
      extra_unexepcted_files = generated_files.sort - expected_files.sort
      expect(missing_files).to eq([])
      expect(extra_unexepcted_files).to eq([])
    ensure
      FileUtils.rm_rf(output_dir) if File.exist?(output_dir)
    end
  end

  describe "#generate_vips_dzsave_tiles" do
    pending "should successfully generate the expected tile files" do
      Imogen.with_image(source_image) do |image|
        Imogen::Iiif::Tiles.generate_with_vips_dzsave(image, output_dir, format: 'jpg', tile_size: tile_size)
      end
      generated_files = Dir["#{output_dir}/**/*.jpg"]

      # Check for missing files and extra unexpected files
      missing_files = expected_files.sort - generated_files.sort
      extra_unexepcted_files = generated_files.sort - expected_files.sort
      # TODO: Remove this `if` statement and `warn` method call once the generate_vips_dzsave_tiles implementation works properly.
      if missing_files.length.positive? || extra_unexepcted_files.length.positive?
        warn "generate_with_vips_dzsave test:\nmissing_files: #{missing_files.length}, extra_unexepcted_files: #{extra_unexepcted_files.length}"
      end
      expect(missing_files).to eq([])
      expect(extra_unexepcted_files).to eq([])
    ensure
      FileUtils.rm_rf(output_dir) if File.exist?(output_dir)
    end
  end
end

