module Routes
  class Recognition
  
    attr_accessor :path, :result, :route_pattern
  
    def initialize(path)
      @path = path
      @result = nil
    end
  
    def recognize
      Routes::Store.routes.each do |route|
        @route_pattern = route[0]
        @result = route[1]
      
        filter_route!
      
        return result if result
      end
    
      # Nothing matched
      result
    end
  
    private
    
    def filter_route!
      if route_pattern.is_a? String
        match_with_string
      elsif route_pattern.respond_to?(:match)
        match_with_regexp
      end
    end
    
    def match_with_string
      if compatible_segments?     
        match_segments
      else
        self.result = nil
      end
    end
  
    def match_with_regexp
      if route_pattern =~ path
        return result
      else
        self.result = nil
      end
    end
  
    def segments_from_string(path)
      path[1..-1].split('/')
    end
  
    def update_result(key, value)
      self.result.merge!(key => value)
    end
  
    def route_segments
      segments_from_string(route_pattern)
    end
  
    def path_segments
      segments_from_string(path)
    end
  
    # TODO: path_segments is calculated 2 times
    def compatible_segments?
      route_segments.size == path_segments.size
    end
  
    def match_segments
      path_segments.each_with_index do |path_segment, index|
        route_segment = route_segments[index]
      
        if route_segment[0] == ?:
          update_result(eval(route_segment), path_segment)
        elsif path_segment != route_segment
          self.result = nil
          break
        end
      end
    end
  
  end
end