# I don't know yet how to best store routes, so for now I just use this class

module Routes
  class Store
    class << self
      attr_accessor :routes
      
      def routes
        @routes ||= []
      end
    end
  end
end