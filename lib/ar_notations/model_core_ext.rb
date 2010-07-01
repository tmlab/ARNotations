class ActiveRecord::Base
  include TOXTM2
  include ARNotations::Characteristics
  include ARNotations::Id
  include ARNotations::Associations
  include ARNotations::XTMValidation
  include ARNotations::FragmentMetadata

  # class_inheritable_accessor :item_identifiers
  class_inheritable_accessor :item_identifiers
  class_inheritable_accessor :names
  class_inheritable_accessor :default_name
  class_inheritable_accessor :occurrences
  class_inheritable_accessor :associations
  class_inheritable_accessor :psi
  class_inheritable_accessor :topic_map
  class_inheritable_accessor :more_info
  class_inheritable_accessor :internal_identifier
  # Method to set the identifier for a topic.
  # Multiple invocations will overwrite the identifier.
  #
  # @param [Symbol] identifier the identifier to use for the topic
  # @author Daniel Exner <exner@informatik.uni-leipzig.de>
  def self.has_identifier(identifier)
    self.internal_identifier = identifier
  end

  # Method to set the more_information occurrence for a topic.
  # Multiple invocations will overwrite the more_information occurrence.
  #
  # @param [Symbol] more_info the more_information occurrence to use for the topic
  # @author Daniel Exner <exner@informatik.uni-leipzig.de>
  def self.has_more_info(more_info)
    self.more_info = more_info
  end

  # Method to set the psi for a topic.
  # Multiple invocations will overwrite the psi.
  #
  # @param [String] psi the psi to use for the topic
  # @author Daniel Exner <exner@informatik.uni-leipzig.de>
  def self.has_psi(psi)
    self.psi= psi
  end

  # Method to set the topicmap name for a topic.
  # This will be modelled as a name in a Topic reifiing the TopicMap.
  # Multiple invocations will overwrite the topicmap name.
  #
  #
  # @param [String] topicmap the topicmap name to use for the topic
  # @author Daniel Exner <exner@informatik.uni-leipzig.de>
  def self.has_topicmap(topicmap)
    self.topic_map = topicmap
  end

  # Method to add item identifiers for the topic. Every invocation will
  # add another subject identifier to the fragment.
  #
  # @example
  # has_item_identifier :identifier
  #
  # @param [Array<Hash<Symbol>>] attributes array of item identifiers to add to the topic
  # @author Daniel Exner <exner@informatik.uni-leipzig.de>
  def self.has_item_identifier(* attributes)
    self.item_identifiers ||=[]

    self.item_identifiers << attributes
  end
  
  # Changed 2010-06-30: double method
  
  # # Method to add subject identifiers for the topic type. Every invocation will
  # # add another subject identifier to the fragment.
  # #
  # # @example
  # # has_item_identifier "http://www.topicmapslab.de/people/"
  # #
  # # @param [Array<Hash<Symbol>>] attributes array of subject identifiers to add to the topic
  # # @author Daniel Exner <exner@informatik.uni-leipzig.de>
  # def self.has_item_identifier(* attributes)
  #   self.item_identifiers ||=[]
  # 
  #   self.item_identifiers << attributes
  # end

  # Method to add names for the topic. Every invocation will add
  # another name with the given :psi to the fragment.
  #
  # @example
  # has_name  :lastname, :psi => "http://xmlns.com/foaf/0.1/familyName"
  # has_name  :firstname , :psi => "http://xmlns.com/foaf/0.1/givenName"
  #
  # @param [Array<Hash<Symbol>>] attributes array of names to add to the topic
  # @author Daniel Exner <exner@informatik.uni-leipzig.de>
  def self.has_name(* attributes)
    self.names ||=[]

    self.names << attributes
  end

  # Method to set one default name for the topic.
  # Multiple invocations will overwrite the default name.
  #
  # @param [Symbol] def_name default name to use for this topic
  # @author Daniel Exner <exner@informatik.uni-leipzig.de>
  def self.has_default_name(def_name)
    self.default_name = def_name
  end

  # Method to add occurrences for the topic. Every invocation will add
  # another occurrences with the given :psi to the fragment.
  #
  # @example
  # has_occurrence :description
  # has_occurrence :homepage
  #
  # @param [Array<Hash<Symbol>>] attributes array of occurrence to add to the topic
  # @author Daniel Exner <exner@informatik.uni-leipzig.de>
  def self.has_occurrence(* attributes)
    self.occurrences ||=[]

    self.occurrences << attributes
  end

  # Method to add associations for the topic.  Every invocation will add
  # another associations with the given roles to the fragment.
  #
  # @example
  # has_association :publications,
  # {:name => "authorship", :psi => "http://psi.topicmapslab.de/tml/authorship"},
  # {:name => "has author", :psi => "http://psi.topicmapslab.de/tml/work"},
  # {:name => "is author of", :psi => "http://psi.topicmapslab.de/tml/author"}
  #
  # @note with Ruby on Rails there are only binary associations possible but
  # you can model any arity.
  #
  # @example
  # has_association :gender,
  # {:name => "gendership", :psi => "http://psi.topicmapslab.de/tml/gendership"},
  # {:name => "is gender of", :psi => "http://psi.topicmapslab.de/tml/gender"},
  # {:name => "has gender", :psi => "http://psi.topicmapslab.de/tml/gender_person"}
  #
  # @param [Array<Hash<Symbol>>] attributes array of associations to add to the topic
  # @author Daniel Exner <exner@informatik.uni-leipzig.de>
  def self.has_association(* attributes)
    self.associations ||=[]

    self.associations << attributes
  end

  # Method to actually render a ActiveRecord::Base model
  # as XTM 2 Topic Map Fragment
  #
  # @return [TOXTM2::xml_doc] returns an XTM2 fragment
  # @author Daniel Exner <exner@informatik.uni-leipzig.de>
  def to_xtm2
    doc = TOXTM2::xml_doc

    x = TOXTM2::xmlNode('topicMap')
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

    acc_types = create_association_types(associations)

    # Changed 2010-06-29: test if acc_types.nil
    # types.concat(acc_types.uniq)
    types.concat(acc_types.uniq) if not acc_types.nil?

    create_types(types, x)

    #Create assosciates Instances
    create_association_instances(associations, x)

    #Create Intance
    x << topic_to_xtm2

    associations.each do |as|
      list = associations_to_xtm2(as)
      list.each { |assoc_type| x << assoc_type } unless list.blank?
    end unless associations.blank?

    #Create TopicMap ID Reification
    x << create_reificaton

    #validate_xtm2

    return doc

  end

  # returns the XTM 2.0 representation of this topic as an REXML::Element
  def topic_to_xtm2
    x = topic_stub
    
    # Changed 2010-07-01: added support for has_many relations,
    # now you can write: has_name :person_synonyms, :psi => "http://xmlns.com/foaf/0.1/nick", :attribute => :synonym
    names.each do |n_attr|
      if self.has_attribute?(n_attr.at(0))
        x << name_to_xtm2(n_attr.at(0), self.send("#{n_attr.at(0)}"), n_attr.at(1))
      else
        x = name_to_xtm2(n_attr.at(0), self.send("#{n_attr.at(0)}"), n_attr.at(1),x)
      end
    end unless names.blank?

    occurrences.each do |o_attr|
      if o_attr.instance_of?(:Hash)
        o = o_attr.dclone.delete(:attribute)
      else
        o = o_attr
      end
      x << occurrence_to_xtm2(o, o_attr)

    end unless occurrences.blank?

    return x
  end

  def topic_stub(topic = self)
    x = TOXTM2::xmlNode('topic')
    # Changed 2010-06-29: identifier --> internal_identifier
    # x['id'] = topic.identifier
    x['id'] = topic.send(topic.internal_identifier)

    item_identifiers.each do |ii|
      loc = topic.send("#{ii}")
      x << TOXTM2.locator(loc)
    end unless item_identifiers.blank?

    if item_identifiers.blank?
      x << TOXTM2.locator(topic.abs_identifier, "subjectIdentifier")
    else
      item_identifiers.each do |si|
        si_value = topic.send("#{si}")
        x << TOXTM2.locator(si_value, "subjectIdentifier")
      end
    end

    x << TOXTM2.instanceOf(topic.class.to_s)

    x << get_name_node(topic)

    return x
  end

  private

  # @author Daniel Exner <exner@informatik.uni-leipzig.de>
  def create_association_types(associations)
    acc_types = []

    associations.dclone.each do |accs_orig|
      accs = accs_orig.dclone
      # puts "accs.pretty_inspect: " + accs.pretty_inspect
      acc_name = accs.delete_at(0)
      acc_opts = accs.delete_at(0)

      accs_p = self.send("#{acc_name}")

      scopes = []

      if accs_p.blank?
        #puts "Keine Instanzen von: " + acc_name.to_s
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
          acc_types << [acc_name.to_s+"_"+accs_p.class.to_s, role_options]

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
  end

  # @author Daniel Exner <exner@informatik.uni-leipzig.de>
  def create_types(types, x)
    
    types.each do |type_h|

      #puts "type_h.pretty_inspect: " +type_h.pretty_inspect

      type = type_h[0]
      attributes = type_h[1] || {}

      attributes[:name] ||= type.to_s

      x << topic_as_type(attributes) #unless self.send("#{type.to_s}").blank?
    end
  end

  # @author Daniel Exner <exner@informatik.uni-leipzig.de>
  def create_association_instances(associations, x)

    associations.dclone.each do |accs|

      acc_name = accs.dclone.delete_at(0)
      accs_p = self.send("#{acc_name}")

      accs_p = [accs_p] unless accs_p.is_a? Array

      create_association_players(accs_p, x)

    end unless associations.blank?
  end

  # @author Daniel Exner <exner@informatik.uni-leipzig.de>
  def create_association_players(accs_p, x)
    accs_p.each do |acc_instance|
      if !acc_instance.blank?
        #x << acc_instance.topic_as_type({:name => get_name(acc_instance), :psi=>acc_instance.psi})
        stub = topic_stub(acc_instance)
        stub << occurrence_to_xtm2("more_information", {:psi => "more_information"}, acc_instance.more_info+"/"+acc_instance.send("#{internal_identifier}")+'.xtm') unless (acc_instance.more_info.blank? || acc_instance.identifier.blank?)
        x << stub
      end
    end unless accs_p.blank?
  end

end

class Object
  def dclone
    clone
  end
end
class Symbol
  def dclone ; self ; end
end
class Fixnum
  def dclone ; self ; end
end
class Float
  def dclone ; self ; end
end

class Array
  def dclone
    klone = self.clone
    klone.clear
    self.each{|v| klone << v.dclone}
    klone
  end
end
