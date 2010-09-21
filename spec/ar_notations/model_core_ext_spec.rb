# ARNotations is a Ruby on Rails plugin to map any kind of ActiveRecord
# model to a Topic Map Fragment, providing the ability
# to expose them TMExplore compatible using REST.
#
# Author:: Daniel Exner
# Copyright:: Copyright (c) 2010 Daniel Exner
# License:: MIT License (http://www.opensource.org/licenses/mit-license.php)

require File.dirname(__FILE__) + '/../ar_notations_spec_helper'
  
describe ActiveRecord::Base do
  
  describe "has_psi" do

    it "allows to add a specific Subject-Identifiers as type for a Topic" do
      Person.class_eval do
        has_psi "http://psi.ontopedia.net/foaf_Person"
      end
    end

    it "sets the psi for the topic type" do
      Person.psi.should == "http://psi.ontopedia.net/foaf_Person"
    end

    it "sets the psi for every instance of this topic type" do
      peter = Person.new
      peter.psi.should == "http://psi.ontopedia.net/foaf_Person"
    end

    
  end

  describe "has_topicmap" do

    it "allows binding a Topic to some specific topicmap" do
      Person.class_eval do
        has_topicmap "http://psi.ontopedia.net/FOAF_Vocabulary"
      end
    end

    it "sets the topicmap for the topic type" do
      Person.topic_map.should == "http://psi.ontopedia.net/FOAF_Vocabulary"
    end

    it "sets the topicmap for every instance of this topic type" do
      peter = Person.new
      peter.topic_map.should == "http://psi.ontopedia.net/FOAF_Vocabulary"
    end

  end

  describe "has_item_identifier" do

    it "allows arnotating the class attributes to use as ItemIdentifiers for the topic" do
      Person.class_eval do
        has_item_identifier :identifier
      end
    end


  end

  describe "has_item_identifier" do

    it "allows arnotating the class attributes to use as SubjectIdentifiers for the topic" do
      Person.class_eval do
        has_item_identifier "http://example.zz/si"
      end
    end

  end

  describe "has_name" do

    it "allows arnotating the class attributes to use as Names for the topic" do
      Person.class_eval do
        has_name :firstname
      end
    end
    
    it "allows arnotating the class attributes to use as Names for the topic using a given PSI" do
      Person.class_eval do
        has_name :firstname, :psi => "http://psi.topicmapslab.de/firstname"
      end
    end

  end

  describe "has_occurrence" do

    it "allows arnotating the class attributes to use as Occurrences for the topic" do
      Person.class_eval do
        has_occurrence :degree
      end
    end

    it "allows arnotating the class attributes to use as Occurrences for the topic using a given PSI" do
      Person.class_eval do
        has_occurrence :degree, :psi => "http://psi.topicmapslab.de/degree"
      end
    end
    
    
  end

  describe "has_association" do

    it "allows arnotating the class attributes to use as Associations for the topic" do
      Person.class_eval do
        has_association :publications
      end
    end
    
    it "allows arnotating the class attributes to use as Associations for the topic using a given PSI" do
      Person.class_eval do
        has_association :publications, :psi => "http://psi.topicmapslab.de/publications"
      end
    end
    
  end
  
  describe "to_xtm2" do
    
    it "should return the current AR Object as xtm2 Fragment" do
      pending
      #@person = mock_model(Person)      
      #@person.stub!(:psi_prefix, "http://www.r1.exner.topicmapslab.de/people/")
      @person = Person.new
      
      #@person.should_receive(:to_xtm2).and_return(@response)
      @responce = @person.to_xtm2
      @responce.should_be_instance_of(REXML::Document)
      
      @responce.should have_tag("topicMap")
      
    end
  end
  
  describe "topic_to_xtm2" do
    
    it "should return the current topic as xtm2" do
      pending
      @person = Person.new
      @person.topic_to_xtm2.should_be_instance_of(REXML::Element)
    end
  end
  
  describe "topic_stub" do
    
    it "should return the current topic as xtm2 stub" do
      pending
      @person = Person.new
      @person.topic_stub.should_be_instance_of(REXML::Element)
    end
    
  end

end
