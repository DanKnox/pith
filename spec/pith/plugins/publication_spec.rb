require 'spec_helper'
require "pith/plugins/publication"

describe Pith::Plugins::Publication::TemplateMethods do

  before do
    @template = OpenStruct.new(:meta => {})
    @template.extend(Pith::Plugins::Publication::TemplateMethods)
  end

  describe "#published_at" do

    it "defaults to nil" do
      @template.published_at.should be_nil
    end
    
    it "is derived by parsing the 'published' meta-field" do
      @template.meta["published"] = "25 Dec 1999 22:30"
      @template.published_at.should == Time.local(1999, 12, 25, 22, 30)
    end

  end

  describe "#updated_at" do

    it "defaults to #published_at" do
      @template.meta["published"] = "25 Dec 1999 22:30"
      @template.updated_at.should == Time.local(1999, 12, 25, 22, 30)
    end
    
    it "can be overridden with an 'updated' meta-field" do
      @template.meta["published"] = "25 Dec 1999 22:30"
      @template.meta["published"] = "1 Jan 2000 03:00"
      @template.updated_at.should == Time.local(2000, 1, 1, 3, 0)
    end

  end
  
end
