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