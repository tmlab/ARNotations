puts "Core Extensions geladen"

module TOXTM2
  require 'rexml/document'

  def self.xml_doc
    dtd = ["topicMap PUBLIC", '\'-//TopicMaps.Org//DTD XML Topic Maps (XTM) 2.0//EN\'', "http://www.isotopicmaps.org/sam/sam-xtm/xtm.dtd"]

    doc = REXML::Document.new
    doc << REXML::DocType.new(dtd)
    doc << REXML::XMLDecl.new
  end

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
    return to_xtm2_si("#"+ref)
  end

  def self.topic_as_type(id, attributes={})
    x = REXML::Element.new('topic')
    x.add_attribute('id', id)

    x << TOXTM2.locator(attributes[:psi], "subjectIdentifier")

    return x
  end

end

class ActionController::Base
  include TOXTM2
  def array_to_xtm2(array)

    doc = TOXTM2::xml_doc
    x = doc.add_element 'topicMap', {'xmlns' => 'http://www.topicmaps.org/xtm/', 'version' => '2.0'}

    #collect types
    types = {}

    array.each do |topic|
      types[:topic.class.to_s] = TOXTM2::topic_as_type(topic.class.to_s, :psi => topic.get_psi)
    end

    types.each_value { |topic_type| x << topic_type }

    array.each() { |topic| x << topic.topic_stub }

    return doc
  end
end

class ActiveRecord::Base
  include TOXTM2

  class_inheritable_accessor :item_identifiers
  class_inheritable_accessor :subject_identifiers
  class_inheritable_accessor :names
  class_inheritable_accessor :occurrences
  class_inheritable_accessor :associations
  class_inheritable_accessor :psi
  class_inheritable_accessor :topic_maps
  def self.has_psi(psi)

    self.psi psi
  end

  def self.has_topicmaps(*attributes)
    self.topic_maps ||=[]

    self.topic_maps.concat(list)

  end

  def self.has_item_identifiers(*attributes)
    self.item_identifiers ||=[]

    self.item_identifiers.concat(attributes)
  end

  def self.has_subject_identifiers(*attributes)
    self.subject_identifiers ||=[]

    self.subject_identifiers.concat(attributes)
  end

  def self.has_names(*attributes)
    self.names ||=[]

    self.names.concat(attributes)
  end

  def self.has_occurrences(*attributes)
    self.occurrences ||=[]

    self.occurrences.concat(attributes)
  end

  def self.has_associations(*attributes)
    self.associations ||=[]

    self.associations.concat(attributes)
  end

  def to_xtm2
    require 'set'

    doc = TOXTM2::xml_doc
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

    associations.each do |as|
      list = associations_to_xtm2(as) unless self.send("#{as}").blank?
      list.each {|assoc_type| x << assoc_type } unless list.blank?
    end

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

  def absolute_identifier
    url_to(self)
  end

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

    return x
  end

  # returns the XTM 2.0 representation of this association as an REXML::Element
  def associations_to_xtm2(acc)

    assoc = self.send("#{acc}")

    if assoc.is_a?(Array)
      acc_instances = assoc
    else
      acc_instances = []
      acc_instances.push(assoc)
    end

    associations = []

    acc_instances.each do |acc_instance|
      #Assosciation
      x = REXML::Element.new 'association'
      TOXTM2.locator(absolute_identifier.to_s+"#"+acc.to_s)
      x << TOXTM2.type(acc.to_s)

      #Roles
      x << association_role_to_xtm2(self, "#"+self.identifier, acc.to_s)
      x << association_role_to_xtm2(acc_instance, acc_instance.absolute_identifier, acc.to_s)
      associations << x
    end

    return associations
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

  def association_role_to_xtm2(acc_role_object, acc_role_loc, acc)

    x = REXML::Element.new 'role'

    x << TOXTM2.locator(acc_role_loc)
    x << TOXTM2.type(acc+"_"+acc_role_object.class.to_s)
    x << TOXTM2.to_xtm2_si(acc_role_object.absolute_identifier.to_s)

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
