# ARNotations is a Ruby on Rails plugin to map any kind of ActiveRecord
# model to a Topic Map Fragment, providing the ability
# to expose them TMExplore compatible using REST.
#
# Author:: Daniel Exner
# Copyright:: Copyright (c) 2010 Daniel Exner
# License:: MIT License (http://www.opensource.org/licenses/mit-license.php)

module ARNotations
  module FragmentMetadata
    def create_reificaton

      if not self.topic_map.blank?
        y = TOXTM2::xmlNode('topic')
        y['id'] = "tmtopic"

        z = TOXTM2::xmlNode 'name'
        z << TOXTM2.value("TopicMap: " + self.topic_map)
        y << z

      end
      return y
    end

  end
end