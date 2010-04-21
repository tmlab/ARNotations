require File.dirname(__FILE__) + '/../ar_notations_spec_helper'

describe Array do

  describe "to_xtm2" do
    
    it "should return an xtm2 representation of alle topics in the array" do
      pending 
      Project.all.to_xtm2.should_not be_nil
    end

    it "should return nothing if the array is empty" do
      [].to_xtm2.should be_nil
    end
    
  end
  
end