module ARNotations
  module Characteristics
    include LibXML
    def default_name_to_xtm2(value, name_attr={})

      x = XML::Node.new 'name'

      if name_attr && name_attr[:scope]
        y = XML::Node.new 'scope'
        y << TOXTM2.to_xtm2_ref(name_attr[:scope])
        x << y
      end

      if value
        x << TOXTM2.value(value)

      end

      return x

    end

    def name_to_xtm2(type, value, name_attr={})

      x = XML::Node.new 'name'

      name_attr ||= {}

      name_attr[:name] ||= type.to_s

      x << TOXTM2.type(name_attr[:name].gsub(/\W+/, '_'))

      if name_attr && name_attr[:scope]
        y = XML::Node.new 'scope'
        y << TOXTM2.to_xtm2_ref(name_attr[:scope])
        x << y
      end

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

      if not attributes[:scope].blank?
        attributes[:scope].each do |scope|
          x << default_name_to_xtm2(scope, {:scope => scope})
        end
      else
        x << default_name_to_xtm2(id)
      end

      x << occurrence_to_xtm2("more_information", {:psi => "more_information"}, attributes[:more_info])  unless attributes[:more_info].blank?

      return x
    end

  end
end

