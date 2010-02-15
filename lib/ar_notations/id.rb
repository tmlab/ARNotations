module ARNotations
  module Id
    def self.absolute_identifier

      if self.respond_to? :url_to
        return url_to(self)
      else
        return ""
      end
    end

    def get_psi
      return absolute_identifier.sub(self.identifier, "")
    end

  end
end
