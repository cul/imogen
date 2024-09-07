require 'imogen/iiif'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe Imogen::Iiif::Tiles, type: :unit do
  before(:all) do
    @test_image = ImageStub.new(175, 131)
  end
  let(:tile512) {
    [
      '/full/full/0/default.jpg',
      '/full/175,/0/default.jpg'
    ]
  }
  let(:tile256) {
    [
      '/full/full/0/default.jpg',
      '/full/175,/0/default.jpg',
      '/full/88,/0/default.jpg'
    ]
  }
  let(:tile128) {
    [
      '/0,0,128,128/128,/0/default.jpg',
      '/0,128,128,3/128,/0/default.jpg',
      '/128,0,47,128/47,/0/default.jpg',
      '/128,128,47,3/47,/0/default.jpg',
      '/full/88,/0/default.jpg',
      '/full/44,/0/default.jpg'
    ]
  }
  let(:tile64) {
    [
      '/0,0,64,64/64,/0/default.jpg',
      '/0,64,64,64/64,/0/default.jpg',
      '/0,128,64,3/64,/0/default.jpg',
      '/64,0,64,64/64,/0/default.jpg',
      '/64,64,64,64/64,/0/default.jpg',
      '/64,128,64,3/64,/0/default.jpg',
      '/128,0,47,64/47,/0/default.jpg',
      '/128,64,47,64/47,/0/default.jpg',
      '/128,128,47,3/47,/0/default.jpg',
      '/0,0,128,128/64,/0/default.jpg',
      '/0,128,128,3/64,/0/default.jpg',
      '/128,0,47,128/24,/0/default.jpg',
      '/128,128,47,3/24,/0/default.jpg',
      '/full/44,/0/default.jpg',
      '/full/22,/0/default.jpg'
    ]
  }
  describe '#scale_factors_for' do
    it 'should calculate the expected scale factors for the given image width, height, and tile_size' do
      {
        32 =>  [1, 2, 4, 8, 16],
        64 =>  [1, 2, 4, 8],
        128 => [1, 2, 4],
        256 => [1, 2],
        512 => [1]
      }.each do |tile_size, expected_scale_factors|
        expect(
          described_class.scale_factors_for(@test_image.width, @test_image.height, tile_size)
        ).to eq(expected_scale_factors)
      end
    end
  end
  describe '#for' do
    it 'should produce the expected tiles for different tile sizes' do
      {
        512 => tile512,
        256 => tile256,
        128 => tile128,
        64 => tile64
      }.each do |tile_size, expected_tiles|
        actual = []
        described_class.for(@test_image, '', :jpeg, tile_size) do |img, dest_path, format, opts|
          actual << dest_path
        end
        expect(actual).to eql(expected_tiles)
      end
    end
    it 'should produce png when requested' do
      expected = tile256.collect {|x| x.sub(/jpg$/, 'png')}
      expected.uniq!
      actual = []
      described_class.for(@test_image, '', :png, 256) do |img, dest_path, format, opts|
        actual << dest_path
      end
      expect(actual).to eql(expected)
    end
    it 'should produce the expected quality when requested' do
      expected = tile256.collect {|x| x.sub(/default.jpg$/, 'color.jpg')}
      expected.uniq!
      actual = []
      described_class.for(@test_image, '', :jpg, 256, 'color') do |img, dest_path, format, opts|
        actual << dest_path
      end
      expect(actual).to eql(expected)
    end
  end
end
