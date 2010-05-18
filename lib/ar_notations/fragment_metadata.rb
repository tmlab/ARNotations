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