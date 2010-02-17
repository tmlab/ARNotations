module ARNotations
  module Associations
    # returns the XTM 2.0 representation of this association as an REXML::Element
    def associations_to_xtm2(accay)
      acc_array = accay.dclone

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

      acc_instances.each do |acc_instance|

        #Assosciation
        x = REXML::Element.new 'association'
        x << TOXTM2.type(acc_opts[:name])

        #Roles
        x << association_role_to_xtm2(self, acc.to_s)
        x << association_role_to_xtm2(acc_instance, acc.to_s)
        associations << x
      end

      return associations
    end

    def association_role_to_xtm2(acc_role_object, acc)
      x = REXML::Element.new 'role'

      #x << TOXTM2.locator(acc_role_loc)
      x << TOXTM2.type(acc+"_"+acc_role_object.class.to_s)
      x << TOXTM2.to_xtm2_ref(acc_role_object.identifier)
      #puts "acc_role_object.absolute_identifier: " + acc_role_object.absolute_identifier

      return x
    end

  end
end
