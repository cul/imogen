require 'imogen/iiif'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe Imogen::Iiif::Quality, type: :unit do
  before(:all) do
    @test_image = ImageStub.new(175,131)
  end
  describe "#get" do
    it "should nil for all the supported no-op values" do
      expect(subject.get('native')).to be_nil
      expect(subject.get('color')).to be_nil
      expect(subject.get('default')).to be_nil
      expect(subject.get(nil)).to be_nil
    end
    it "should return appropriate symbols for the transform values" do
      expect(subject.get('grey')).to eql(:grey)
      expect(subject.get('gray')).to eql(:grey)
      expect(subject.get('bitonal')).to eql(:bitonal)
    end
  end
end