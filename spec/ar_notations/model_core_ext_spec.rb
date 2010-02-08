require 'ar_notations_spec_helper'
  
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

    it "uses the given psi in the exportet topicmap fragment"
    
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

  describe "has_item_identifiers" do

    it "allows arnotating the class attributes to use as ItemIdentifiers for the topic" do
      Person.class_eval do
        has_item_identifiers :identifier
      end
    end

    it "uses the given item_identifiers in the exportet topicmap fragment"

  end

  describe "has_subject_identifiers" do

    it "allows arnotating the class attributes to use as SubjectIdentifiers for the topic" do
      Person.class_eval do
        has_item_identifiers absolute_identifier
      end
    end

    it "uses the given subject identifiers in the exportet topicmap fragment"

  end

  describe "has_names" do

    it "allows arnotating the class attributes to use as Names for the topic" do
      Person.class_eval do
        has_names :firstname
      end
    end

    it "uses the given names in the exportet topicmap fragment"
    
  end

  describe "has_occurrences" do

    it "allows arnotating the class attributes to use as Occurrences for the topic" do
      Person.class_eval do
        has_occurrences :degree
      end
    end

    it "uses the given occurrences in the exportet topicmap fragment"
    
  end

  describe "has_associations" do

    it "allows arnotating the class attributes to use as Associations for the topic" do
      Person.class_eval do
        has_associations :publications
      end
    end
    
    it "uses the given associations in the exportet topicmap fragment"
    
  end

end
