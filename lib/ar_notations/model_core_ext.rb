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

    schema_file = XML::Document.file(File.dirname(__FILE__)+'/xtm2.xsd')
    schema =  XML::Schema.document(schema_file)

    doc = TOXTM2::xml_doc

    x = XML::Node.new('topicMap')
    x['xmlns'] = 'http://www.topicmaps.org/xtm/'
    x['version'] = '2.0'
    x['reifier'] = "#tmtopic"
    doc.root = x

    #TODO
    #First we need the "more_information" occurrence
    x << topic_as_type({:name => "more_information", :psi => $MORE_INFORMATION})

    #Create types
    x << topic_as_type({:name => self.class.to_s, :psi => psi, :more_info => self.more_info})

    if names.blank?
      types = []
    else
      types = names.dclone
    end

    types.concat(occurrences.dclone) unless occurrences.blank?

    acc_types = []

    associations.dclone.each do |accs_orig|
      accs = accs_orig.dclone
      puts "accs.pretty_inspect: " + accs.pretty_inspect

      acc_name = accs.delete_at(0)
      acc_opts = accs.delete_at(0)

      accs_p = self.send("#{acc_name}")

      scopes = []

      if accs_p.blank?
        puts "Keine Instanzen von: " + acc_name.to_s
      else

        if accs_p.is_a?(Enumerable)
          #Role
          role_options = accs.delete_at(0)
          acc_types << [acc_name.to_s+"_"+accs_p.first.class.to_s, role_options]

          #Scoped names
          scopes << role_options[:name]

          #Player
          acc_types << [accs_p.first.class.to_s, {:psi => accs_p.first.psi, :name => accs_p.first.class.to_s}]

          #Nametypes of players
          if (accs_p.first.default_name.blank? && !accs_p.first.names.blank?)
            acc_types << accs_p.first.names.first
          end

        else
          #Role
          role_options = accs.delete_at(0)
          acc_types << [acc_name.to_s+"_"+accs_p.class.to_s,role_options]

          #Scoped names
          scopes << role_options[:name]

          #Player
          acc_types << [accs_p.class.to_s, {:psi => accs_p.psi, :name => accs_p.class.to_s}]

          #Nametypes of players
          if (accs_p.default_name.blank? && !accs_p.names.blank?)
            acc_types << accs_p.names.first
          end

        end
        #Role self
        self_opts = accs.delete_at(0)
        acc_types << [acc_name.to_s+"_"+self.class.to_s, self_opts]
        scopes << self_opts[:name]

        #Assosciation

        acc_opts[:scope] = scopes.uniq

        acc_types << [acc_name.to_s, acc_opts]

      end

    end unless associations.blank?

    types.concat(acc_types.uniq)

    types.each do |type_h|

      puts "type_h.pretty_inspect: " +type_h.pretty_inspect

      type = type_h[0]
      attributes = type_h[1] || {}

      attributes[:name] ||= type.to_s

      x << topic_as_type(attributes) #unless self.send("#{type.to_s}").blank?
    end

    #Create assosciates Instances
    associations.dclone.each do |accs|

      acc_name = accs.dclone.delete_at(0)
      accs_p = self.send("#{acc_name}")

      accs_p = [accs_p] unless accs_p.is_a? Array

      accs_p.each do |acc_instance|
        if !acc_instance.blank?
          #x << acc_instance.topic_as_type({:name => get_name(acc_instance), :psi=>acc_instance.psi})
          stub = topic_stub(acc_instance) unless acc_instance.blank?
          stub << occurrence_to_xtm2("more_information", {:psi => "more_information"}, acc_instance.abs_identifier)
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
    if not self.topic_map.blank?
      y = XML::Node.new('topic')
      y['id'] = "tmtopic"

      z = XML::Node.new 'name'
      z << TOXTM2.value("TopicMap: " + self.topic_map)
      y << z
      x << y
    end

    logger.info doc.pretty_inspect

    begin
      doc.validate_schema(schema)
    rescue LibXML::XML::Error
      puts "XML Error: " + doc.to_s
    end
    return doc

  end

  # returns the XTM 2.0 representation of this topic as an REXML::Element
  def topic_to_xtm2

    x = topic_stub

    names.each do |n_attr|
      x << name_to_xtm2(n_attr.at(0), self.send("#{n_attr.at(0)}"), n_attr.at(1))
    end unless names.blank?

    occurrences.each do |o_attr|

      if o_attr.is_a? :Hash
        o = o_attr.dclone.delete(:attribute)
      else
        o = o_attr
      end
      x << occurrence_to_xtm2(o, o_attr)

    end unless occurrences.blank?

    return x
  end

  def topic_stub(topic = self)
    x = XML::Node.new('topic')
    x['id'] = topic.identifier

    item_identifiers.each do |ii|
      loc = topic.send("#{ii}")
      x << TOXTM2.locator(loc)
    end unless item_identifiers.blank?

    if subject_identifiers.blank?
      x << TOXTM2.locator(topic.abs_identifier, "subjectIdentifier")
    else
      subject_identifiers.each do |si|
        si_value = topic.send("#{si}")
        x << TOXTM2.locator(si_value, "subjectIdentifier")
      end
    end

    x << TOXTM2.instanceOf(topic.class.to_s)

    x << get_name_node(topic)

    return x
  end

end