# ARNotations is a Ruby on Rails plugin to map any kind of ActiveRecord
# model to a Topic Map Fragment, providing the ability
# to expose them TMExplore compatible using REST.
#
# Author:: Daniel Exner
# Copyright:: Copyright (c) 2010 Daniel Exner
# License:: MIT License (http://www.opensource.org/licenses/mit-license.php)

require File.dirname(__FILE__) + '/../ar_notations_spec_helper'

describe ARNotations::Characteristics do
  
  describe "default_name_to_xtm2" do
        
    it "should return an xtm2 representation of the default_name" do
      pending
      Person.class_eval do
        default_name :lastname
      end
      @person = Person.new
      @person.lastname = "Mueller"
      @person.default_name_to_xtm2.should_be_instance_of(REXML::Element)
    end
    
  end
  
  describe "name_to_xtm2" do
    
    it "should return an xtm2 representation of the name" do
      pending
      Person.class_eval do
        has_name :lastname
      end
      @person = Person.new
      @person.lastname = "Mueller"
      @person.name_to_xtm2(lastname).should_be_instance_of(REXML::Element)
    end
    
  end
    
  describe "occurrence_to_xtm2" do
    
    it "should return an xtm2 representation of the occurrence" do
      pending
      Person.class_eval do
        has_occurrence :lastname
      end
      @person = Person.new
      @person.lastname = "Mueller"
      @person.occurrence_to_xtm2(lastname).should_be_instance_of(REXML::Element)
    end
  
  end
  
end