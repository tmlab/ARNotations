require 'rexml/document'

module TOXTM2  

  def self.xml_doc
    dtd = ["topicMap PUBLIC", '\'-//TopicMaps.Org//DTD XML Topic Maps (XTM) 2.0//EN\'', "http://www.isotopicmaps.org/sam/sam-xtm/xtm.dtd"]

    doc = REXML::Document.new
    doc << REXML::DocType.new(dtd)
    doc << REXML::XMLDecl.new
  end

  def self.type(type)
    res = REXML::Element.new('type')
    res << TOXTM2.to_xtm2_ref(type)
    return res
  end

  def self.instanceOf(topic)
    res = REXML::Element.new('instanceOf')
    res << TOXTM2.to_xtm2_ref(topic)
    return res
  end

  def self.locator(loc, tagname = "itemIdentity")
    x = REXML::Element.new(tagname)
    x.add_attribute('href',loc.to_s)

    return x
  end

  def self.value(value)
    res = REXML::Element.new 'value'
    res.text = value
    return res
  end

  def self.res_data(value)
    res = REXML::Element.new 'resourceData'
    res.text = value
    return res
  end

  def self.to_xtm2_si(ref)
    x = REXML::Element.new 'topicRef'
    x.add_attribute('href', "#{ref}")

    return x

  end

  def self.to_xtm2_ref(ref)
    return to_xtm2_si("#"+ref)
  end

  def self.topic_as_type(id, attributes={})
    x = REXML::Element.new('topic')
    x.add_attribute('id', id)

    y = REXML::Element.new 'name'
    y << TOXTM2.value(id)
    x << y
    x << TOXTM2.locator(attributes[:psi], "subjectIdentifier")

    return x
  end

end