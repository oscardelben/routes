module Routes
  
  VERSION = [0,1]
  
  class Base
    
    attr_accessor :routes
    
    def initialize
      @routes = []
    end
    
    def map(route, action=nil)
      @routes << [normalize_route(route), action]
    end
    
    def draw(&block)
      instance_eval(&block)
    end
    
    def recognize(path)
      routes.each do |route|
        route_pattern = route[0]
        result = route[1]
        
        if route_pattern.is_a? String
          route_segments = segments_from_string(route_pattern)
          path_segments = segments_from_string(path)
          
          if route_segments.size == path_segments.size
            
            path_segments.each_with_index do |path_segment, index|
              route_segment = route_segments[index]
  
              if route_segment[0] == ?:
                result.merge!(eval(route_segment) => path_segment) # I suppose it is an hash
              elsif path_segment != route_segment
                result = nil
                break
              end
            end
          else
            result = nil
          end
        elsif route_pattern.respond_to?(:match)
          if route_pattern =~ path
            return give_back_result(result, path)
          else
            result = nil
          end
        end
        
        return give_back_result(result, path) if result
      end
      result ||= nil
      
      return give_back_result(result, path)
    end
    
    private
    
    def normalize_route(route)
      if route.is_a? String
        route = "/#{route}" unless route[0] == ?/
        route = "#{route}/" unless route[-1] == ?/
      end
      route
    end
    
    # segments_from_string('/foo/bar/3') => ['foo', 'bar', 3']
    def segments_from_string(path)
      path[1..-1].split('/')
    end
    
    def give_back_result(result, path)
      if result.respond_to?(:call)
        result.call(path)
      else
        result
      end
    end
    
  end
end