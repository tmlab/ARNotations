#require 'rexml/document'
require 'libxml'


module TOXTM2  
  include LibXML
  
  def self.xmlNode(*attributes)
    return TOXTM2::xmlNode attributes
  end
  
  def self.xml_doc
    return LibXML::XML::Document.new
  end

  def self.type(type)
    res = TOXTM2::xmlNode('type')
    res << TOXTM2.to_xtm2_ref(type)
    return res
  end

  def self.instanceOf(topic)
    res = TOXTM2::xmlNode('instanceOf')
    res << TOXTM2.to_xtm2_ref(topic)
    return res
  end

  def self.locator(loc, tagname = "itemIdentity")
    x = TOXTM2::xmlNode(tagname)
    x['href'] = loc.to_s
    return x
  end

  def self.value(value)
    res = TOXTM2::xmlNode 'value'
    res << value
    return res
  end

  def self.res_data(value)
    res = TOXTM2::xmlNode 'resourceData'
    res << value
    return res
  end

  def self.to_xtm2_si(ref)
    x = TOXTM2::xmlNode 'topicRef'
    x['href'] = "#{ref}"
    return x

  end

  def self.to_xtm2_ref(ref)
    return to_xtm2_si("#"+ref)
  end

end