module ARNotations
  module Characteristics
    def default_name_to_xtm2(name, topic=self)
      value = topic.send "#{name}"

      x = REXML::Element.new 'name'
      #x << TOXTM2.locator(absolute_identifier.to_s+"#"+name.to_s)

      if value
        x << TOXTM2.value(value)

      end

      return x

    end

    def name_to_xtm2(name, name_attr={}, topic=self)

      value = topic.send "#{name}"

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

      x << TOXTM2.res_data(value) unless value.blank?

      return x
    end

    def topic_as_type(id, attributes={})
      x = REXML::Element.new('topic')
      x.add_attribute('id', id)

      y = REXML::Element.new 'name'
      y << TOXTM2.value(id)
      x << y
      x << TOXTM2.locator(attributes[:psi], "subjectIdentifier")
      x << occurrence_to_xtm2("more_information", {:psi => "more_information"}, attributes[:more_info])  unless attributes[:more_info].blank?

      return x
    end

  end
end

