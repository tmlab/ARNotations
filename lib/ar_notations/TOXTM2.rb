# ARNotations is a Ruby on Rails plugin to map any kind of ActiveRecord
# model to a Topic Map Fragment, providing the ability
# to expose them TMExplore compatible using REST.
#
# Author:: Daniel Exner
# Copyright:: Copyright (c) 2010 Daniel Exner
# License:: MIT License (http://www.opensource.org/licenses/mit-license.php)

#require 'rexml/document'
require 'nokogiri'


module TOXTM2  

  def self.xmlNode(* attributes)
    puts "attributes: #{attributes}"
    return Nokogiri::XML::Node.new(attributes)
  end
  
  def self.xml_doc
    return Nokogiri::XML::Document.new
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
