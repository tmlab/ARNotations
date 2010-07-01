module ARNotations
  module Characteristics
    include LibXML

    def default_name_to_xtm2(value, name_attr={})

      x = TOXTM2::xmlNode 'name'

      if name_attr && name_attr[:scope]
        y = TOXTM2::xmlNode 'scope'
        y << TOXTM2.to_xtm2_ref(name_attr[:scope].gsub(/\W+/, '_'))
        x << y
      end

      if value
        x << TOXTM2.value(value)
        return x
      else
        return nil
      end

    end

    def name_to_xtm2(type, value, name_attr={},doc = nil)
      name_attr ||= {}
      name_attr[:name] ||= type.to_s

      
      if name_attr && name_attr[:scope]
        y = TOXTM2::xmlNode 'scope'
        y << TOXTM2.to_xtm2_ref(name_attr[:scope].gsub(/\W+/, '_'))
        x << y
      end

      if value && self.has_attribute?(type)
        x = TOXTM2::xmlNode 'name'
        x << TOXTM2.type(name_attr[:name].gsub(/\W+/, '_'))
        x << TOXTM2.value(value)
        return x
      elsif value && !self.has_attribute?(type)
        # how to build an array of nodes?
        value.each do |v|
          y = TOXTM2::xmlNode 'name'
          y << TOXTM2.type(name_attr[:name].gsub(/\W+/, '_'))
          y << TOXTM2.value(eval("v.#{name_attr[:attribute]}"))
          doc << y
        end
        return doc
      else
        return nil
      end

    end

    def occurrence_to_xtm2(occ, occ_attr= {}, value = self.send("#{occ}"))

      x = TOXTM2::xmlNode 'occurrence'

      #x << TOXTM2.locator(absolute_identifier.to_s+"#"+occ.to_s)

      occ_attr[:psi] ||=occ.to_s
      x << TOXTM2.type(occ_attr[:psi])

      x << TOXTM2.res_data(value) unless value.blank?

      return x
    end

    def topic_as_type(attributes={})
      x = TOXTM2::xmlNode('topic')
      id = attributes[:name]

      x['id'] = id.gsub(/\W+/, '_')

      x << TOXTM2.locator(attributes[:psi], "subjectIdentifier")

      if not attributes[:scope].blank?
        attributes[:scope].each do |scope|
          x << default_name_to_xtm2(scope, {:scope => scope})
        end
      end
      x << default_name_to_xtm2(id)

      x << occurrence_to_xtm2("more_information", {:psi => "more_information"}, attributes[:more_info]+".xtm") unless attributes[:more_info].blank?

      return x
    end

  end
end

