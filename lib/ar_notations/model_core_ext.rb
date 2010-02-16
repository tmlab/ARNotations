class ActiveRecord::Base
  include TOXTM2
  include ARNotations::Characteristics
  include ARNotations::Id

  class_inheritable_accessor :item_identifiers
  class_inheritable_accessor :subject_identifiers
  class_inheritable_accessor :names
  class_inheritable_accessor :default_name
  class_inheritable_accessor :occurrences
  class_inheritable_accessor :associations
  class_inheritable_accessor :psi
  class_inheritable_accessor :topic_map
  class_inheritable_accessor :more_info
  def self.has_more_info(more_info)

    self.more_info = more_info
  end

  def self.has_psi(psi)

    self.psi= psi
  end

  def self.has_topicmap(topicmap)

    self.topic_map = topicmap
  end

  def self.has_item_identifier(*attributes)
    self.item_identifiers ||=[]

    self.item_identifiers << attributes
  end

  def self.has_subject_identifier(*attributes)
    self.subject_identifiers ||=[]

    self.subject_identifiers << attributes
  end

  def self.has_name(*attributes)
    self.names ||=[]

    self.names  << attributes
  end

  def self.has_default_name(def_name)
    self.default_name = def_name
  end

  def self.has_occurrence(*attributes)
    self.occurrences ||=[]

    self.occurrences  << attributes
  end

  def self.has_association(*attributes)
    self.associations ||=[]

    self.associations  << attributes
  end

  def to_xtm2

    doc = TOXTM2::xml_doc
    x = doc.add_element 'topicMap', {'xmlns' => 'http://www.topicmaps.org/xtm/', 'version' => '2.0', 'reifier' => "#tmtopic"}

    #TODO
    #First we need the "more_information" occurrence
    x << topic_as_type("more_information", :psi => $MORE_INFORMATION)

    #Create types
    if psi.blank?
      x << topic_as_type(self.class.to_s, {:psi => get_psi, :more_info => self.more_info})
    else
      x << topic_as_type(self.class.to_s, {:psi => psi, :more_info => self.more_info})
    end

    if names.blank?
      types = []
    else
      types = names.dclone
    end

    types.concat(occurrences) unless occurrences.blank?
    types.concat(associations) unless associations.blank?

    acc_types = []

    associations = associations.to_a

    associations.each do |accs|

      accs_p = self.send("#{accs}")

      accs_p.each do |acc_instance|
        acc_types << accs.to_s+"_"+acc_instance.class.to_s
        acc_types << accs.to_s+"_"+self.class.to_s
      end unless accs_p.blank?

    end unless associations.blank?

    types.concat(acc_types.uniq)

    types.each do |type_h|

      type = type_h[0]
      attributes = type_h[1] || {}

      if psi.blank?
        attributes[:psi] ||= self.get_psi+"#"+type.to_s
      else
        attributes[:psi] ||= self.psi+"#"+type.to_s
      end

      x << topic_as_type(type.to_s, attributes) unless self.send("#{type.to_s}").blank?
    end

    #Create assosciates Instances
    associations.each do |accs|

      accs_p = self.send("#{accs}")

      accs_p = accs_p.to_s
      accs_p.each do |acc_instance|
        x << topic_stub(acc_instance)
      end unless accs_p.blank?

    end unless associations.blank?

    #Create Intance
    x << topic_to_xtm2

    associations.each do |as|
      list = associations_to_xtm2(as)
      list.each {|assoc_type| x << assoc_type } unless list.blank?
    end unless associations.blank?

    #Create TopicMap ID Reification
    y = REXML::Element.new('topic')
    y.add_attribute('id', "tmtopic")
    z = REXML::Element.new 'name'
    z << TOXTM2.value(self.topic_map)
    y << z
    x << y

    return doc
  end

  # returns the XTM 2.0 representation of this topic as an REXML::Element
  def topic_to_xtm2

    x = topic_stub

    occurrences.each do |o_attr|
      if o.is_a? :Hash
        o = o_attr.delete(:attribute)
      else
        o = o_attr
      end
      x << occurrence_to_xtm2(o, o_attr)

    end unless occurrences.blank?

    return x
  end

  def topic_stub(topic = self)
    x = REXML::Element.new('topic')
    x.add_attribute('id', topic.identifier)

    item_identifiers.each do |ii|
      loc = topic.send("#{ii}")
      x << TOXTM2.locator(loc)
    end unless item_identifiers.blank?

    subject_identifiers.each do |si|
      si_value = topic.send("#{si}")
      x << TOXTM2.locator(si_value, "subjectIdentifier")
    end unless subject_identifiers.blank?

    x << TOXTM2.instanceOf(topic.class.to_s)

    if topic.default_name.blank?
      topic.names.first do |n, n_attr|
        x << name_to_xtm2(n, n_attr, topic)
      end unless topic.names.blank?
    else
      x << default_name_to_xtm2(topic.default_name, topic)
    end
    
    x << occurrence_to_xtm2("more_information", {:psi => "more_information"}, topic.absolute_identifier)  unless topic.more_info.blank?

    return x
  end

end