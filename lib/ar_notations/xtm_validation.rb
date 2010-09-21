# ARNotations is a Ruby on Rails plugin to map any kind of ActiveRecord
# model to a Topic Map Fragment, providing the ability
# to expose them TMExplore compatible using REST.
#
# Author:: Daniel Exner
# Copyright:: Copyright (c) 2010 Daniel Exner
# License:: MIT License (http://www.opensource.org/licenses/mit-license.php)

module ARNotations
  module XTMValidation
    def validate_xtm2

      schema_file = XML::Document.file(File.dirname(__FILE__)+'/xtm2.xsd')
      schema =  XML::Schema.document(schema_file)

      begin
        doc.validate_schema(schema)
      rescue LibXML::XML::Error
        #puts "XML Error: " + doc.to_s
      end
    end
  end
end
