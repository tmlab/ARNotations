puts "Core Extensions geladen"

module TOXTM2
  require 'rexml/document'

  def self.type(type)
    res = REXML::Element.new('type')
    res << TOXTM2.to_xtm2_ref(type)
    return res
  end

  def self.instanceOf(topic)
    res = REXML::Element.new('instanceOf')
    res << TOXTM2.to_xtm2_ref(topic)
    return res
  end

  def self.locator(loc, tagname = "itemIdentity")
    x = REXML::Element.new(tagname)
    x.add_attribute('href',loc.to_s)

    return x
  end

  def self.value(value)
    res = REXML::Element.new 'resourceData'
    res.text = value
    return res
  end

  def self.to_xtm2_si(ref)
    x = REXML::Element.new 'topicRef'
    x.add_attribute('href', "#{ref}")

    return x

  end

  def self.to_xtm2_ref(ref)
    x = REXML::Element.new 'topicRef'
    x.add_attribute('href', "##{ref}")

    return x
  end

  def self.topic_as_type(id, topic)
    x = REXML::Element.new('topic')
    x.add_attribute('id', id)
    x << TOXTM2.locator(topic.to_s, "subjectIdentifier")

    return x
  end

end

class ActionController::Base
  include TOXTM2
  
  def array_to_xtm2(array)
    doc = REXML::Document.new
    doc << REXML::XMLDecl.new

    x = doc.add_element 'topicMap', {'xmlns' => 'http://www.topicmaps.org/xtm/', 'version' => '2.0'}

    array.each() { |topic| x << TOXTM2::topic_as_type(topic.to_s, topic.absolute_identifier) }

    return doc
  end
end

class ActiveRecord::Base
  include TOXTM2
  
  def to_xtm2
    require 'set'
    
    puts "To_xtm2 aufgerufen fuer: " + absolute_identifier
    doc = REXML::Document.new
    doc << REXML::XMLDecl.new

    x = doc.add_element 'topicMap', {'xmlns' => 'http://www.topicmaps.org/xtm/', 'version' => '2.0'}

    x << REXML::Comment.new("Occurrences count: #{occurrences.size}")
    x << REXML::Comment.new("Associations count: #{associations.size}")

    #Create types
    x << TOXTM2::topic_as_type(self.class.to_s, psi)
    
    types = names.to_set
    types << occurrences
    types << associations

    names.each do |types|
      x << TOXTM2::topic_as_type(types.to_s, psi+types.to_s) unless self.send("#{types}").blank?
    end

    #Create Intance
    x << topic_to_xtm2

    return doc
  end

  class_inheritable_accessor :item_identifiers
  class_inheritable_accessor :subject_identifiers
  class_inheritable_accessor :names
  class_inheritable_accessor :occurrences
  class_inheritable_accessor :associations

  self.item_identifiers ||= []
  self.subject_identifiers ||= []
  self.names ||=[]
  self.occurrences ||=[]
  self.associations ||=[]

  protected

  def psi
    return absolute_identifier.sub(self.identifier, "")
  end

  # returns the XTM 2.0 representation of this topic as an REXML::Element
  def topic_to_xtm2

    x = REXML::Element.new('topic')
    x.add_attribute('id', self.identifier)

    item_identifiers.each { |ii| x << TOXTM2.locator(ii) }
    subject_identifiers.each { |si| x << TOXTM2.locator(si, "subjectIdentifier") }
    x << TOXTM2.locator(absolute_identifier) # itemIdentity

    x << TOXTM2.instanceOf(self.class.to_s)

    names.each do |n|
      x << name_to_xtm2(n) unless self.send("#{n}").blank?
    end
    occurrences.each do |o|
      x << occurrence_to_xtm2(o) unless self.send("#{o}").blank?

    end
    associations.each do |as|
      x << association_to_xtm2(as) unless self.send("#{as}").blank?
    end

    return x
  end

  # returns the XTM 2.0 representation of this association as an REXML::Element
  def association_to_xtm2(acc)

    roles = self.send "#{acc}"

    x = REXML::Element.new 'association'
    TOXTM2.locator(absolute_identifier.to_s+"#"+acc.to_s)
    x << TOXTM2.type(acc.to_s)

    roles.each { |r| x << association_role_to_xtm2(r,acc.to_s) }

    return x
  end

  def name_to_xtm2(name)

    value = self.send "#{name}"

    if value
      x = REXML::Element.new 'name'
      x << TOXTM2.locator(absolute_identifier.to_s+"#"+name.to_s)
      x << TOXTM2.type(name.to_s)
      (x << REXML::Element.new('value')).text = value # adds the value within a value-element
      return x
    end
  end

  def occurrence_to_xtm2(occ)

    value = self.send("#{occ}")

    x = REXML::Element.new 'occurrence'

    x << TOXTM2.locator(absolute_identifier.to_s+"#"+occ.to_s)
    x << TOXTM2.type(occ.to_s)
    x << TOXTM2.value(value)

    return x
  end

  def association_role_to_xtm2(acc_role, acc)

    x = REXML::Element.new 'role'

    x << TOXTM2.locator(absolute_identifier.to_s+"#"+acc_role.class.to_s)
    x << TOXTM2.type(acc+"_"+acc_role.class.to_s)
    x << TOXTM2.to_xtm2_si(acc_role.absolute_identifier.to_s)

    return x
  end

end

# Way to go in Rails 3
#class CTMResponder < ActionController::Responder
#
#  def to_ctm
#    return
#  end
#
#end
#
#class TopicMapResponder < ActionController::Responder
#  include CTMResponder
#  include XTM2Responder
#end
#
#class ActionController::Base
#
#  protected
#
#  def responder
#    TopicMapResponder
#  end
#end
