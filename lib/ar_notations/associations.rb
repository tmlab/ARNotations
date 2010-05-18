module ARNotations
  module Associations
    include LibXML
    
    # returns the XTM 2.0 representation of this association as an REXML::Element
    def associations_to_xtm2(acc_array_orig)
      acc_array = acc_array_orig.dclone
      
      acc = acc_array.delete_at(0)      
      acc_opts = acc_array.delete_at(0)
      
      acc_opts ||= {}
        
      acc_opts[:name] ||= acc.to_s+"_association"

      acc_opts[:name].gsub!(/\W+/, '_')
        
      assoc = self.send("#{acc}")

      if assoc.is_a?(Array)
        acc_instances = assoc
      else
        acc_instances = []
        acc_instances.push(assoc)
      end

      associations = []

      acc_instances.delete_if { |x| x.blank? }
               
      acc_opts_other = acc_array.delete_at(0)
      acc_opts_other ||= {}
        
      acc_opts_self = acc_array.delete_at(0)
      acc_opts_self ||= {}

        
      acc_instances.each do |acc_instance|
        
        #Assosciation
        x = TOXTM2::xmlNode 'association'
        x << TOXTM2.type(acc_opts[:name])

        #Roles
        acc_opts_other[:name] ||= acc.to_s+"_"+acc_instance.class.to_s
        acc_opts_self[:name] ||= acc.to_s+"_"+self.class.to_s
                    
        x << association_role_to_xtm2(acc_instance, acc_opts_other)
        x << association_role_to_xtm2(self, acc_opts_self)
        associations << x
      end

      return associations
    end

    def association_role_to_xtm2(acc_role_object, acc_arno)
      
      x = TOXTM2::xmlNode 'role'
      
      x << TOXTM2.type(acc_arno[:name].gsub(/\W+/, '_'))
      x << TOXTM2.to_xtm2_ref(acc_role_object.identifier)

      return x
    end

  end
end
