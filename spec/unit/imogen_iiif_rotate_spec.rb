require 'imogen/iiif'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe Imogen::Iiif::Rotation, type: :unit do
  before(:all) do
    @test_image = ImageStub.new(175,131)
  end
  subject {Imogen::Iiif::Rotation.new(@test_image)}
  describe "#get" do
    describe "with values mod 360 in 90 degree rotations" do
      it "should return [0, false] angle and flip for 0 or '0' or nil" do
        expect(subject.get(0)).to eq([0, false])
        expect(subject.get(360)).to eq([0, false])
        expect(subject.get("360")).to eq([0, false])
        expect(subject.get("-360")).to eq([0, false])
        expect(subject.get("0")).to eq([0, false])
        expect(subject.get(nil)).to eq([0, false])
      end
      it "should return the expected angle and flip for positive values" do
        expect(subject.get(90)).to eql([90, false])
        expect(subject.get("90")).to eql([90, false])
        expect(subject.get("180")).to eql([180, false])
        expect(subject.get("270")).to eql([270, false])
        expect(subject.get("450")).to eql([90, false])
      end
      it "should return the expected angle and flip for negative values" do
        expect(subject.get(-90)).to eql([270, false])
        expect(subject.get("-90")).to eql([270, false])
        expect(subject.get("-180")).to eql([180, false])
        expect(subject.get("-270")).to eql([90, false])
        expect(subject.get("-450")).to eql([270, false])
      end
      it "should return the expected angle and flip for string values that start with an exclamation point" do
        expect(subject.get("!0")).to eql([0, true])
        expect(subject.get("!90")).to eql([90, true])
        expect(subject.get("!180")).to eql([180, true])
        expect(subject.get("!270")).to eql([270, true])
        expect(subject.get("!-90")).to eql([270, true])
        expect(subject.get("!-180")).to eql([180, true])
        expect(subject.get("!-270")).to eql([90, true])
        expect(subject.get("!-450")).to eql([270, true])
      end
    end
    it "should reject arbitrary integer and float values" do
      expect{subject.get(2)}.to raise_error Imogen::Iiif::BadRequest
      expect{subject.get("2")}.to raise_error Imogen::Iiif::BadRequest
      expect{subject.get("90.0")}.to raise_error Imogen::Iiif::BadRequest
    end
    it "should reject bad values" do
      expect{subject.get("-2,")}.to raise_error Imogen::Iiif::BadRequest
    end
  end
end
