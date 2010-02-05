
class ActionController::Base
  include TOXTM2
  include ARNotations
  
  def array_to_xtm2(array)

    doc = TOXTM2::xml_doc
    x = doc.add_element 'topicMap', {'xmlns' => 'http://www.topicmaps.org/xtm/', 'version' => '2.0', 'reifier' => "#tmtopic"}

    #TODO
    #First we need the "more_information" occurrence
    x << TOXTM2::topic_as_type("more_information", :psi => "http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.3")

    #collect types
    types = {}

    array.each do |topic|
      types[topic.class.to_s] = TOXTM2::topic_as_type(topic.class.to_s, :psi => topic.get_psi)
    end

    types.each_value { |topic_type| x << topic_type }

    array.each() { |topic| x << topic.topic_stub }

    #Create TopicMap ID Reification
    y = REXML::Element.new('topic')
    y.add_attribute('id', "tmtopic")
    z = REXML::Element.new 'name'
    z << TOXTM2.value(array.first.topic_map)
    y << z
    x << y

    return doc
  end
end