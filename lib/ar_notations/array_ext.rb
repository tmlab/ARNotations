require 'libxml'

class Array
  include TOXTM2
  include ARNotations::Characteristics
  def array_to_xtm2(array)

    if array.blank?
      return
    end

    schema_file = XML::Document.file(File.dirname(__FILE__)+'/xtm2.xsd')
    schema =  XML::Schema.document(schema_file)

    doc = TOXTM2::xml_doc

    x = XML::Node.new('topicMap')
    x['xmlns'] = 'http://www.topicmaps.org/xtm/'
    x['version'] = '2.0'
    x['reifier'] = "#tmtopic"
    doc.root = x

    #TODO
    #First we need the "more_information" occurrence
    x << topic_as_type({:name => "more_information", :psi => $MORE_INFORMATION})

    #collect types
    types = {}

    array.each do |topic|
      types[topic.class.to_s] = topic_as_type({:name => topic.class.to_s, :psi => topic.psi})
    end

    types.each_value do |topic_type|
      x << topic_type
    end

    array.each() do |topic|
      stub = topic.topic_stub
      stub << occurrence_to_xtm2("more_information", {:psi => "more_information"}, topic.more_info+"/"+topic.send("#{topic.internal_identifier}")+'.xtm')  unless topic.more_info.blank?
      x << stub
    end

    #Create TopicMap ID Reification
    if not array.first.topic_map.blank?
      y = XML::Node.new('topic')
      y['id'] = "tmtopic"
      z = XML::Node.new 'name'
      z << TOXTM2.value("TopicMap: " + array.first.topic_map)
      y << z
      x << y
    end

    begin
      doc.validate_schema(schema)
    rescue LibXML::XML::Error
      puts "XML Error: " + doc.to_s
    end
    return doc
  end

  def to_xtm2
    return array_to_xtm2(self)
  end
end
