# ARNotations is a Ruby on Rails plugin to map any kind of ActiveRecord
# model to a Topic Map Fragment, providing the ability
# to expose them TMExplore compatible using REST.
#
# Author:: Daniel Exner
# Copyright:: Copyright (c) 2010 Daniel Exner 
# License:: MIT License (http://www.opensource.org/licenses/mit-license.php)

require File.dirname(__FILE__) + '/../ar_notations_spec_helper'

describe ARNotations::Associations do
  
  before(:each) do
    Person.class_eval do
      has_association :publications
    end
    @person = Person.new
    @publication = Publication.new      
    @person.publications.push(@publication)
  end
    
  describe "associations_to_xtm2" do
    
    it "should return an xtm2 representation of all associations" do
      pending
      @person.associations_to_xtm2(@person.publications).should_be_instance_of(Array)      
    end
    
  end
  
  describe "association_role_to_xtm2" do
    
    it "should return an xtm2 representation of the given association role" do
      pending      
      @person.association_role_to_xtm2(@publication, @person.publications).should_be_instance_of(REXML::Element)
    end
  end
  
end
