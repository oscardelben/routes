module Routes  
  class Building
    
    class << self
      
      def map(route, action={})
        Routes::Store.routes << [normalize_route(route), action]
      end
    
      def draw(&block)
        class_eval(&block)
      end
    
      private
    
      def normalize_route(route)
        if route.is_a? String
          route = "/#{route}" unless route[0] == ?/
          route = "#{route}/" unless route[-1] == ?/
        end
        route
      end
      
    end
     
  end
end