module ARNotations
  module Id
    def self.absolute_identifier

      if self.respond_to? :url_to
        return url_to(self)
      else
        return ""
      end
    end

    def get_psi
      if psi.blank?
        return absolute_identifier.sub(self.identifier, "")
      else
        return psi
      end
    end

    def get_name(topic = self)
      if topic.default_name.blank?
        if topic.names.blank?
          return topic.identifier
        else
          return topic.send("#{topic.names.first.at(0)}")
        end
      else
        return topic.send("#{topic.default_name}")
      end

    end

    def get_name_node(topic = self)

      if topic.default_name.blank?
        if topic.names.blank?
          name = XML::Node.new 'name'
          name << TOXTM2.value(topic.identifier)
        else
          n_attr = topic.names.first
          name = name_to_xtm2(n_attr.at(0), n_attr.at(1), topic)
        end
      else
        name = default_name_to_xtm2(topic.default_name, topic)
      end

      return name
    end
  end
end
