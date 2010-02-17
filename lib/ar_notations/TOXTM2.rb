#require 'rexml/document'
require 'libxml'


module TOXTM2  

  def self.xml_doc
 
    doc = LibXML::XML::Document.new
    return doc
  end

  def self.type(type)
    res = XML::Node.new('type')
    res << TOXTM2.to_xtm2_ref(type)
    return res
  end

  def self.instanceOf(topic)
    res = XML::Node.new('instanceOf')
    res << TOXTM2.to_xtm2_ref(topic)
    return res
  end

  def self.locator(loc, tagname = "itemIdentity")
    x = XML::Node.new(tagname)
    x['href'] = loc.to_s
    return x
  end

  def self.value(value)
    res = XML::Node.new 'value'
    res << value
    return res
  end

  def self.res_data(value)
    res = XML::Node.new 'resourceData'
    res << value
    return res
  end

  def self.to_xtm2_si(ref)
    x = XML::Node.new 'topicRef'
    x['href'] = "#{ref}"
    return x

  end

  def self.to_xtm2_ref(ref)
    return to_xtm2_si("#"+ref)
  end

end