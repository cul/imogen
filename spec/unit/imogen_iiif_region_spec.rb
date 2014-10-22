require 'imogen/iiif'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe Imogen::Iiif::Region, type: :unit do
  before(:all) do
    @test_image = ImageStub.new(175,131)
  end
  subject {Imogen::Iiif::Region.new(@test_image)}
  describe "#get" do
    describe "with named regions" do
      it "should return nil for full or default" do
        expect(subject.get(nil)).to be_nil
        expect(subject.get("full")).to be_nil
      end
      it "should return symbol for featured" do
        expect(subject.get("featured")).to eql(:featured)
      end
    end
    describe "with an absolute region" do
      it "should calculate a contained region" do
        expect(subject.get("80,15,60,75")).to eql([80,15,140,90])
      end
      it "should reject zero-dimension boxes" do
        expect{subject.get("101,15,0,15")}.to raise_error Imogen::Iiif::BadRequest
        expect{subject.get("101,15,10,0")}.to raise_error Imogen::Iiif::BadRequest
      end
      describe "that exceeds the bounds" do
        it "should calculate an overlapping region" do
          expect(subject.get("80,15,100,175")).to eql([80,15,175,131])
        end
        it "should reject a disjoint region" do
          expect{subject.get("176,15,1,75")}.to raise_error Imogen::Iiif::BadRequest
        end
      end
    end
    describe "with a percentage region" do
      it "should calculate a contained region" do
        expect(subject.get("pct:80,15,10,75")).to eql([140,20,158,118])
      end
      it "should reject zero-dimension boxes" do
        expect{subject.get("pct:10.2,15,10.21,15")}.to raise_error Imogen::Iiif::BadRequest
      end
      describe "that exceeds the bounds" do
        it "should calculate an overlapping region" do
          expect(subject.get("pct:80,15,100,175")).to eql([140,20,175,131])
        end
        it "should reject a disjoint region" do
          expect{subject.get("pct:101,15,100,15")}.to raise_error Imogen::Iiif::BadRequest
        end
      end
    end
    it "should reject non-conforming regions" do
      expect{subject.get("px:1,2,3,4")}.to raise_error Imogen::Iiif::BadRequest
      expect{subject.get("-1,2,3,4")}.to raise_error Imogen::Iiif::BadRequest
      expect{subject.get("pct:-1,2,3,4")}.to raise_error Imogen::Iiif::BadRequest
    end 
  end
end