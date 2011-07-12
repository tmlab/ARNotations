# ARNotations is a Ruby on Rails plugin to map any kind of ActiveRecord
# model to a Topic Map Fragment, providing the ability
# to expose them TMExplore compatible using REST.
#
# Author:: Daniel Exner
# Copyright:: Copyright (c) 2010 Daniel Exner
# License:: MIT License (http://www.opensource.org/licenses/mit-license.php)

module ARNotations
  module Id
    include TOXTM2
    
    # Changed 2010-06-29: identifier --> internal_identifier
    def abs_identifier
      return psi+'/'+self.send(internal_identifier)
      # return psi+'/'+identifier
    end

    def get_name(topic = self)
      if topic.default_name.blank?
        if topic.names.blank?
          return topic.send(internal_identifier)
          # return topic.identifier
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
          name = TOXTM2::xmlNode 'name'
          name << TOXTM2.value(topic.send(internal_identifier))
          # name << TOXTM2.value(topic.identifier)
        else
          n_attr = topic.names.first
          name = name_to_xtm2(n_attr.at(0), topic.send("#{n_attr.at(0)}"), n_attr.at(1))
        end
      else
        name = default_name_to_xtm2(topic.send("#{topic.default_name}"))
      end

      return name
    end
  end
end
