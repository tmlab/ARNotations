class ActiveRecord::Base
  include TOXTM2
  include ARNotations::Characteristics
  include ARNotations::Id
  include ARNotations::Associations

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

    types.concat(occurrences.dclone) unless occurrences.blank?

    acc_types = []

    associations.dclone.each do |accs|
      acc_name = accs.delete_at(0)
      acc_opts = accs.delete_at(0)

      accs_p = self.send("#{acc_name}")

      acc_types << [acc_name.to_s, acc_opts] unless accs_p.blank?

      if accs_p.is_a?(Enumerable)
        accs_p.each do |acc_instance|
          acc_types << [acc_name.to_s+"_"+acc_instance.class.to_s, accs.delete_at(0)]
          acc_types << [acc_name.to_s, acc_opts]
        end unless accs_p.blank?
      else
        acc_types << [acc_name.to_s+"_"+accs_p.class.to_s, accs.delete_at(0)] unless accs_p.blank?
      end

      acc_types << [acc_name.to_s+"_"+self.class.to_s, accs.delete_at(0)]
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

      x << topic_as_type(type.to_s, attributes) #unless self.send("#{type.to_s}").blank?
    end

    #Create assosciates Instances
    associations.dclone.each do |accs|

      acc_name = accs.delete_at(0)
      accs_p = self.send("#{acc_name}")

      accs_p = [accs_p] unless accs_p.is_a? Array

      accs_p.each do |acc_instance|
        if !acc_instance.blank?
          stub = topic_stub(acc_instance) unless acc_instance.blank?
          stub << occurrence_to_xtm2("more_information", {:psi => "more_information"}, acc_instance.absolute_identifier)
          x << stub
        end
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
        
    names.each do |n_attr|
      puts "n_attr.pretty_inspect" + n_attr.pretty_inspect
      n = n_attr.at(0)

      x << name_to_xtm2(n, n_attr.at(1), self)
    end unless names.blank?

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
    x << default_name_to_xtm2(topic.default_name, topic) unless topic.default_name.blank?

    return x
  end

end