require 'imogen/iiif'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe Imogen::Iiif::Rotation, type: :unit do
  before(:all) do
    @test_image = ImageStub.new(175,131)
  end
  subject {Imogen::Iiif::Rotation.new(@test_image)}
  describe "#get" do
    describe "with values mod 360 in 90 degree rotations" do
      it "should nil for 0 or nil" do
        expect(subject.get("360")).to be_nil
        expect(subject.get("-360")).to be_nil
        expect(subject.get("0")).to be_nil
        expect(subject.get(nil)).to be_nil
      end
      # IIIF rotation is opposite FreeImage
      it "should calculate for positive values" do
        expect(subject.get("90")).to eql(270)
        expect(subject.get("180")).to eql(180)
        expect(subject.get("270")).to eql(90)
        expect(subject.get("450")).to eql(270)
      end
      # IIIF rotation is opposite FreeImage
      it "should calculate for negative values" do
        expect(subject.get("-90")).to eql(90)
        expect(subject.get("-180")).to eql(180)
        expect(subject.get("-270")).to eql(270)
        expect(subject.get("-450")).to eql(90)
      end
    end
    it "should reject arbitrary integer and float values" do
        expect{subject.get("2")}.to raise_error Imogen::Iiif::BadRequest
        expect{subject.get("90.0")}.to raise_error Imogen::Iiif::BadRequest
    end
    it "should reject bad values" do
        expect{subject.get("-2,")}.to raise_error Imogen::Iiif::BadRequest
    end
  end
end