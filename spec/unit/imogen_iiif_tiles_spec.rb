require 'imogen/iiif'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe Imogen::Iiif::Tiles, type: :unit do
  before(:all) do
    @test_image = ImageStub.new(175,131)
  end
  let(:fullSize) { ["/0,0,175,131/full/0/native.jpg"]}
  let(:tile128) {
    [
      "/0,0,128,128/full/0/native.jpg",
      "/128,0,47,128/full/0/native.jpg",
      "/0,128,128,3/full/0/native.jpg",
      "/128,128,47,3/full/0/native.jpg"
    ]
  }
  let(:tile64) {
    [
      "/0,0,64,64/full/0/native.jpg",
      "/64,0,64,64/full/0/native.jpg",
      "/128,0,47,64/full/0/native.jpg",
      "/0,64,64,64/full/0/native.jpg",
      "/64,64,64,64/full/0/native.jpg",
      "/128,64,47,64/full/0/native.jpg",
      "/0,128,64,3/full/0/native.jpg",
      "/64,128,64,3/full/0/native.jpg",
      "/128,128,47,3/full/0/native.jpg",
    ]
  }
  describe '#scale_factor_for' do
    it 'should calculate for different tile sizes' do
      width, height = @test_image.width, @test_image.height
      (0..8).each do |exp|
        tile_size = 2**exp
        expected = (8 - exp)**2
        expect(subject.scale_factor_for(width, height, tile_size)).to eql(expected)
      end
    end
  end
  describe '#for' do
    it 'should produce a single tile when contained' do
      expected = fullSize
      actual = []
      subject.for(@test_image,'',:jpeg,256) do |img,dest_path,format,opts|
        actual << dest_path
      end
      expect(actual).to eql(expected)
    end
    it 'should produce a tileset when half' do
      expected = fullSize + tile128
      expected.uniq!
      actual = []
      subject.for(@test_image,'',:jpeg,128) do |img,dest_path,format,opts|
        actual << dest_path
      end
      actual.uniq!
      expect(actual.sort).to eql(expected.sort)
    end
    it 'should produce a single tileset' do
      expected = fullSize + tile128 + tile64
      expected.uniq!
      actual = []
      subject.for(@test_image,'',:jpeg,64) do |img,dest_path,format,opts|
        actual << dest_path
      end
      actual.uniq!
      expect(actual.sort).to eql(expected.sort)
    end
    it 'should produce png when requested' do
      expected = fullSize.collect {|x| x.sub(/jpg$/,'png')}
      expected.uniq!
      actual = []
      subject.for(@test_image,'',:png,256) do |img,dest_path,format,opts|
        actual << dest_path
      end
      expect(actual).to eql(expected)
    end
  end
end