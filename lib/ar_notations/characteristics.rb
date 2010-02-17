module ARNotations
  module Characteristics
    def default_name_to_xtm2(name, topic=self)
      value = topic.send "#{name}"

      x = XML::Node.new 'name'
      #x << TOXTM2.locator(absolute_identifier.to_s+"#"+name.to_s)

      if value
        x << TOXTM2.value(value)

      end

      return x

    end

    def name_to_xtm2(name, name_attr={}, topic=self)

      value = topic.send "#{name}"

      x = XML::Node.new 'name'
      #x << TOXTM2.locator(absolute_identifier.to_s+"#"+name.to_s)

      name_attr ||= {}

      name_attr[:name] ||=name.to_s
        
      x << TOXTM2.type(name_attr[:name].gsub(/\W+/, '_'))

      if value
        x << TOXTM2.value(value)

      end

      return x
    end

    def occurrence_to_xtm2(occ, occ_attr= {}, value = self.send("#{occ}"))

      x = XML::Node.new 'occurrence'

      #x << TOXTM2.locator(absolute_identifier.to_s+"#"+occ.to_s)

      occ_attr[:psi] ||=occ.to_s
      x << TOXTM2.type(occ_attr[:psi])

      x << TOXTM2.res_data(value) unless value.blank?

      return x
    end

    def topic_as_type(attributes={})
      x = XML::Node.new('topic')
      id = attributes[:name]
        
      x['id'] = id.gsub(/\W+/,'_')
      
      x << TOXTM2.locator(attributes[:psi], "subjectIdentifier")
        
      y = XML::Node.new 'name'
      y << TOXTM2.value(id)
      x << y
      
      x << occurrence_to_xtm2("more_information", {:psi => "more_information"}, attributes[:more_info])  unless attributes[:more_info].blank?

      return x
    end

  end
end

