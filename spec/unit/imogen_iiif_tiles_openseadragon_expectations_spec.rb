require 'imogen/iiif'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe Imogen::Iiif::Tiles, type: :unit do
  describe 'OpenSeadragon Tile expectations' do
    let(:tile_size) { 512 }
    let(:portrait_test_image) { ImageStub.new(1920, 3125) }
    let(:osd_portrait_expected_tiles) do
      [
        '/0,0,1024,1024/512,/0/default.jpg',
        '/0,0,1920,2048/480,/0/default.jpg',
        '/0,0,512,512/512,/0/default.jpg',
        '/0,1024,1024,1024/512,/0/default.jpg',
        '/0,1024,512,512/512,/0/default.jpg',
        '/0,1536,512,512/512,/0/default.jpg',
        '/0,2048,1024,1024/512,/0/default.jpg',
        '/0,2048,1920,1077/480,/0/default.jpg',
        '/0,2048,512,512/512,/0/default.jpg',
        '/0,2560,512,512/512,/0/default.jpg',
        '/0,3072,1024,53/512,/0/default.jpg',
        '/0,3072,512,53/512,/0/default.jpg',
        '/0,512,512,512/512,/0/default.jpg',
        '/1024,0,512,512/512,/0/default.jpg',
        '/1024,0,896,1024/448,/0/default.jpg',
        '/1024,1024,512,512/512,/0/default.jpg',
        '/1024,1024,896,1024/448,/0/default.jpg',
        '/1024,1536,512,512/512,/0/default.jpg',
        '/1024,2048,512,512/512,/0/default.jpg',
        '/1024,2048,896,1024/448,/0/default.jpg',
        '/1024,2560,512,512/512,/0/default.jpg',
        '/1024,3072,512,53/512,/0/default.jpg',
        '/1024,3072,896,53/448,/0/default.jpg',
        '/1024,512,512,512/512,/0/default.jpg',
        '/1536,0,384,512/384,/0/default.jpg',
        '/1536,1024,384,512/384,/0/default.jpg',
        '/1536,1536,384,512/384,/0/default.jpg',
        '/1536,2048,384,512/384,/0/default.jpg',
        '/1536,2560,384,512/384,/0/default.jpg',
        '/1536,3072,384,53/384,/0/default.jpg',
        '/1536,512,384,512/384,/0/default.jpg',
        '/512,0,512,512/512,/0/default.jpg',
        '/512,1024,512,512/512,/0/default.jpg',
        '/512,1536,512,512/512,/0/default.jpg',
        '/512,2048,512,512/512,/0/default.jpg',
        '/512,2560,512,512/512,/0/default.jpg',
        '/512,3072,512,53/512,/0/default.jpg',
        '/512,512,512,512/512,/0/default.jpg',
        '/full/120,/0/default.jpg',
        '/full/240,/0/default.jpg',
      ]
    end

    let(:landscape_test_image) { ImageStub.new(1920, 1213) }
    let(:osd_landscape_expected_tiles) do
      [
        '/0,0,1024,1024/512,/0/default.jpg',
        '/0,0,512,512/512,/0/default.jpg',
        '/0,1024,1024,189/512,/0/default.jpg',
        '/0,1024,512,189/512,/0/default.jpg',
        '/0,512,512,512/512,/0/default.jpg',
        '/1024,0,512,512/512,/0/default.jpg',
        '/1024,0,896,1024/448,/0/default.jpg',
        '/1024,1024,512,189/512,/0/default.jpg',
        '/1024,1024,896,189/448,/0/default.jpg',
        '/1024,512,512,512/512,/0/default.jpg',
        '/1536,0,384,512/384,/0/default.jpg',
        '/1536,1024,384,189/384,/0/default.jpg',
        '/1536,512,384,512/384,/0/default.jpg',
        '/512,0,512,512/512,/0/default.jpg',
        '/512,1024,512,189/512,/0/default.jpg',
        '/512,512,512,512/512,/0/default.jpg',
        '/full/240,/0/default.jpg',
        '/full/480,/0/default.jpg'
      ]
    end

    describe '#for' do
      it 'should produce the expected tiles for a sample dimension portrait orientation image' do
        actual = []
        expected = osd_portrait_expected_tiles
        described_class.for(portrait_test_image, '', :jpeg, tile_size) do |img, dest_path, format, opts|
          actual << dest_path
        end

        # Check for missing files and extra unexpected files
        missing_files = expected.sort - actual.sort
        extra_unexepcted_files = actual.sort - expected.sort
        expect(missing_files).to eq([])
        expect(extra_unexepcted_files).to eq([])
      end

      it 'should produce the expected tiles for a sample dimension landscape orientation image' do
        actual = []
        expected = osd_landscape_expected_tiles
        described_class.for(landscape_test_image, '', :jpeg, tile_size) do |img, dest_path, format, opts|
          actual << dest_path
        end

        # Check for missing files and extra unexpected files
        missing_files = expected.sort - actual.sort
        extra_unexepcted_files = actual.sort - expected.sort
        expect(missing_files).to eq([])
        expect(extra_unexepcted_files).to eq([])
      end
    end
  end
end
