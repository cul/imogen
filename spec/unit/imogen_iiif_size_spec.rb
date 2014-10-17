require 'imogen/iiif'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe Imogen::Iiif::Size, type: :unit do
  before(:all) do
    @test_image = ImageStub.new(175,131)
  end
  subject {Imogen::Iiif::Size.new(@test_image)}
  describe "#get" do
    describe "with scaling width" do
      it "should calculate for a good value" do
        expect(subject.get("105,")).to eql([105, 79])
      end
      it "should not upscale" do
        expect(subject.get("350,")).to eql([175, 131])
      end
      it "should reject bad values" do
        expect{subject.get("0,")}.to raise_error Imogen::Iiif::BadRequest
        expect{subject.get("-2,")}.to raise_error Imogen::Iiif::BadRequest
      end
    end
    describe "with scaling height" do
      it "should calculate for a good value" do
        # partial pixels get rounded up
        expect(subject.get(",79")).to eql([106,79])
      end
      it "should not upscale" do
        expect(subject.get(",262")).to eql([175, 131])
      end
      it "should reject bad values" do
        expect{subject.get(",0")}.to raise_error Imogen::Iiif::BadRequest
        expect{subject.get(",-2")}.to raise_error Imogen::Iiif::BadRequest
      end
    end
    describe "with scaling width and height" do
      it "should calculate for a good value" do
        expect(subject.get("105,79")).to eql([105, 79])
      end
      it "should not upscale" do
        expect(subject.get("350,262")).to eql([175, 131])
      end
      it "should reject bad values" do
        expect{subject.get("350,0")}.to raise_error Imogen::Iiif::BadRequest
        expect{subject.get("350,-2")}.to raise_error Imogen::Iiif::BadRequest
        expect{subject.get("0,262")}.to raise_error Imogen::Iiif::BadRequest
        expect{subject.get("0,262")}.to raise_error Imogen::Iiif::BadRequest
      end
    end
    describe "with a percentage scale" do
      it "should calculate for a good value" do
        expect(subject.get("pct:60.0")).to eql([105, 79])
      end
      it "should not upscale" do
        expect(subject.get("pct:105")).to eql([175, 131])
      end
      it "should reject bad values" do
        expect{subject.get("pct:-20")}.to raise_error Imogen::Iiif::BadRequest
        expect{subject.get("pct:0")}.to raise_error Imogen::Iiif::BadRequest
      end
    end
  end
end