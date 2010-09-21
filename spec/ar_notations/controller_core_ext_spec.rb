# ARNotations is a Ruby on Rails plugin to map any kind of ActiveRecord
# model to a Topic Map Fragment, providing the ability
# to expose them TMExplore compatible using REST.
#
# Author:: Daniel Exner
# Copyright:: Copyright (c) 2010 Daniel Exner
# License:: MIT License (http://www.opensource.org/licenses/mit-license.php)

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