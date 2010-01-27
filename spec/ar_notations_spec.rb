require File.dirname(__FILE__) + '/spec_helper'

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

  describe "has_topicmaps" do

    it "allows binding a Topic to some specifig topicmaps"

  end

  describe "has_item_identifiers" do

    it "allows arnotating the class attributes to use as ItemIdentifiers for the topic"

  end

  describe "has_subject_identifiers" do

    it "allows arnotating the class attributes to use as SubjectIdentifiers for the topic"

  end

  describe "has_names" do

    it "allows arnotating the class attributes to use as Names for the topic"

  end

  describe "has_occurrences" do

    it "allows arnotating the class attributes to use as Occurrences for the topic"

  end

  describe "has_associations" do

    it "allows arnotating the class attributes to use as Associations for the topic"

  end

end
