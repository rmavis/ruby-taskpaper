class Hash

  def sieve( dirt )
    ret = { }

    self.keys.each do |key|
      if dirt.has_key?(key)
        if self[key].is_a?(Hash) && dirt[key].is_a?(Hash)
          ret[key] = self[key].sieve(dirt[key])
        else
          ret[key] = dirt[key]
        end
      else
        ret[key] = self[key]
      end
    end

    return ret
  end

end
