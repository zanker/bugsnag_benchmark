module CleanerOld
  def self.cleanup_obj(obj, filters = nil, seen=Set.new)
    return nil unless obj

    # Protect against recursion of recursable items
    if obj.is_a?(Hash) || obj.is_a?(Array) || obj.is_a?(Set)
      return "[RECURSION]" if seen.include? obj

      # We duplicate the seen set here so that no updates by further cleanup_obj calls
      # are persisted beyond that call.
      seen = seen.dup
      seen << obj
    end

    case obj
    when Hash
      clean_hash = {}
      obj.each do |k,v|
        if filters_match?(k, filters)
          clean_hash[k] = "[FILTERED]"
        else
          clean_obj = cleanup_obj(v, filters, seen)
          clean_hash[k] = clean_obj
        end
      end
      clean_hash
    when Array, Set
      obj.map { |el| cleanup_obj(el, filters, seen) }.compact
    when Numeric, TrueClass, FalseClass
      obj
    when String
      cleanup_string(obj)
    else
      str = obj.to_s
      # avoid leaking potentially sensitive data from objects' #inspect output
      if str =~ /#<.*>/
        '[OBJECT]'
      else
        cleanup_string(str)
      end
    end
  end

  def self.cleanup_string(str)
    if defined?(str.encoding) && defined?(Encoding::UTF_8)
      if str.encoding == Encoding::UTF_8
        str.valid_encoding? ? str : str.encode('utf-16', {:invalid => :replace, :undef => :replace}).encode('utf-8')
      else
        str.encode('utf-8', {:invalid => :replace, :undef => :replace})
      end
    elsif defined?(Iconv)
      Iconv.conv('UTF-8//IGNORE', 'UTF-8', str) || str
    else
      str
    end
  end

  def self.filters_match?(object, filters)
    str = object.to_s

    Array(filters).any? do |f|
      case f
      when Regexp
        str.match(f)
      else
        str.include?(f.to_s)
      end
    end
  end
end
