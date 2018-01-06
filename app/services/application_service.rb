class ApplicationService
  def self.merge_recursively(hash0, hash1, options = {})
    hash1.each do |key, val|
      if val.is_a?(Hash)
        if hash0[key].is_a?(Hash)
          merge_recursively(hash0[key], val, options)
        else
          hash0[key] = merge_recursively({}, val, options)
        end
      elsif options[:merge_arrays] && hash0[key].is_a?(Array) && val.is_a?(Array)
        if options[:merge_arrays] == 'append'
          hash0[key] += val
        elsif options[:merge_arrays] == 'union'
          hash0[key] |= val
        elsif options[:merge_arrays] == 'remove'
          hash0[key] -= val
        else
          raise "unrecognized merge operation '#{options[:merge_arrays]}'"
        end
      else
        hash0[key] = val
      end
      hash0.delete(key) if options[:compact] && hash0[key].nil?
    end
    hash0
  end

  def self.deep_clone_hash(hash1)
    merge_recursively({}, hash1)
  end

  def merge_recursively(hash0, hash1, options = {})
    self.class.merge_recursively(hash0, hash1, options)
  end

  def deep_clone_hash(hash1)
    merge_recursively({}, hash1)
  end
end
