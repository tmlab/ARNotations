require 'ar_notations_spec_helper'

describe ActionController::Base do

  describe "array_to_xtm2" do
    
    it "should return an xtm2 representation of alle topics in the array" do
      pending 
      ProjectsController.new.array_to_xtm2(Project.all).should_not be_nil
    end

    it "should return nothing if the array is empty" do
      ProjectsController.new.array_to_xtm2([]).should be_nil
    end
    
  end
  
end