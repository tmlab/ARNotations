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

    #TODO
    #First we need the "more_information" occurrence
    x << TOXTM2::topic_as_type("more_information", :psi => "http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.3")
    
    #collect types
    types = {}

    array.each do |topic|
      types[topic.class.to_s] = TOXTM2::topic_as_type(topic.class.to_s, :psi => topic.get_psi)
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
  class_inheritable_accessor :default_name
  class_inheritable_accessor :occurrences
  class_inheritable_accessor :associations
  class_inheritable_accessor :psi
  class_inheritable_accessor :topic_map
  def self.has_psi(psi)

    self.psi= psi
  end

  def self.has_topicmap(topicmap)

    self.topic_map = topicmap
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

  def self.has_default_name(def_name)
    self.default_name = def_name
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

    doc = TOXTM2::xml_doc
    x = doc.add_element 'topicMap', {'xmlns' => 'http://www.topicmaps.org/xtm/', 'version' => '2.0', 'reifier' => "#tmtopic"}

    #Create types
    if psi.blank?
      x << TOXTM2::topic_as_type(self.class.to_s, :psi => get_psi)
    else
      x << TOXTM2::topic_as_type(self.class.to_s, :psi => psi)
    end

    types = names.dclone
    types.concat(occurrences) unless occurrences.blank?
    types.concat(associations) unless associations.blank?

    acc_types = []

    associations.each do |accs|

      accs_p = self.send("#{accs}")

      accs_p.each do |acc_instance|
        acc_types << accs.to_s+"_"+acc_instance.class.to_s
        acc_types << accs.to_s+"_"+self.class.to_s
      end unless accs_p.blank?

    end unless associations.blank?

    types.concat(acc_types.uniq)

    types.each do |type|
      attributes = type if type.is_a? Hash
      attributes ||= {}

      if psi.blank?
        attributes[:psi] ||= self.get_psi+"#"+type.to_s
      else
        attributes[:psi] ||= self.psi+"#"+type.to_s
      end

      x << TOXTM2::topic_as_type(type.to_s, attributes)
    end

    #Create Intance
    x << topic_to_xtm2

    associations.each do |as|
      list = associations_to_xtm2(as)
      list.each {|assoc_type| x << assoc_type } unless list.blank?
    end

    #Create TopicMap ID Reification
    y = REXML::Element.new('topic')
    y.add_attribute('id', "tmtopic")
    z = REXML::Element.new 'name'
    z << TOXTM2.value(self.topic_map)
    y << z
    x << y
    
    return doc
  end

  def self.absolute_identifier

    if self.respond_to? :url_to
      return url_to(self)
    else
      return ""
    end
  end

  def get_psi
    return absolute_identifier.sub(self.identifier, "")
  end

  # returns the XTM 2.0 representation of this topic as an REXML::Element
  def topic_to_xtm2

    x = topic_stub

    occurrences.each do |o, o_attr|
      x << occurrence_to_xtm2(o, o_attr)

    end unless occurrences.blank?

    return x
  end

  def topic_stub
    x = REXML::Element.new('topic')
    x.add_attribute('id', self.identifier)

    item_identifiers.each do |ii|
      loc = self.send("#{ii}")
      x << TOXTM2.locator(loc)
    end unless item_identifiers.blank?

    subject_identifiers.each do |si|
      si_value = self.send("#{si}")
      x << TOXTM2.locator(si_value, "subjectIdentifier")
    end unless subject_identifiers.blank?

    #TODO Needs more information Occurrence
    #    x << TOXTM2.locator(absolute_identifier) # itemIdentity
    x << occurrence_to_xtm2("more_information", {}, absolute_identifier)

    x << TOXTM2.instanceOf(self.class.to_s)

    x << default_name_to_xtm2(default_name)
    
    names.each do |n, n_attr|
      x << name_to_xtm2(n, n_attr)
    end unless names.blank?
    
    
    
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

    acc_instances.delete_if { |x| x.blank? }

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

  def default_name_to_xtm2(name)
    value = self.send "#{name}"

    x = REXML::Element.new 'name'
    #x << TOXTM2.locator(absolute_identifier.to_s+"#"+name.to_s)

    if value
      x << TOXTM2.value(value)

    end

    return x
    
  end
  
  def name_to_xtm2(name, name_attr={})

    value = self.send "#{name}"

    x = REXML::Element.new 'name'
    #x << TOXTM2.locator(absolute_identifier.to_s+"#"+name.to_s)

    name_attr ||= {}

    name_attr[:psi] ||=name.to_s
    x << TOXTM2.type(name_attr[:psi])

    if value
      x << TOXTM2.value(value)

    end

    return x
  end

  def occurrence_to_xtm2(occ, occ_attr= {}, value = self.send("#{occ}"))
    
    x = REXML::Element.new 'occurrence'

    #x << TOXTM2.locator(absolute_identifier.to_s+"#"+occ.to_s)

    occ_attr[:psi] ||=occ.to_s
    x << TOXTM2.type(occ_attr[:psi])

    if value
      x << TOXTM2.value(value)
    end

    return x
  end

  def association_role_to_xtm2(acc_role_object, acc_role_loc, acc)

    x = REXML::Element.new 'role'

    #x << TOXTM2.locator(acc_role_loc)
    x << TOXTM2.type(acc+"_"+acc_role_object.class.to_s)
    x << TOXTM2.to_xtm2_si(acc_role_loc)

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
