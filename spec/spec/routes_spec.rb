require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Routes do
  context 'storing new routes' do
    
    before(:each) do
      Routes::Store.routes = []
    end
        
    it "should have an empty routes list on new" do
      Routes::Store.routes.should == []
    end
    
    it "should be able to add a new route with the map method" do
      Routes::Building.map('/foo', 'some action')
      Routes::Store.routes.should == [['/foo/', 'some action']]
    end
    
    it "should consider the order of routes with the map method" do
      Routes::Building.map('/first', 'first action')
      Routes::Building.map('/second', 'second action')
      Routes::Store.routes.should == [['/first/', 'first action'], ['/second/', 'second action']]
    end
    
    it "should append / at the start of path if needed" do
      Routes::Building.map('foo/', nil)
      Routes::Store.routes.should == [['/foo/', nil]]
    end
    
    it "should append / at the end of path if needed" do
      Routes::Building.map('/foo', nil)
      Routes::Store.routes.should == [['/foo/', nil]]
    end
        
    it "should be able to storea bunch of routes with the draw method" do
      proc = lambda { |path| "You are visiting #{path}" }
      regex = /pos.*/
      
      Routes::Building.draw do
        map '/first', 'something'
        map '/second', :controller => 'foo', :action => 'bar'
        map '/third', proc
        map regex, 'something else'
      end
      
      Routes::Store.routes.should == [
          ['/first/', 'something'],
          ['/second/', { :controller => 'foo', :action => 'bar' }],
          ['/third/', proc],
          [regex, 'something else']
        ]
    end
    
    
  end
  
  context 'routes recognition' do
    
    before(:each) do
      Routes::Store.routes = []
      
      Routes::Building.draw do
        map '/posts', :controller => 'posts', :action => 'index'
        map '/posts/:id', :controller => 'posts'
        map '/controller/:action', {}
        map '/:controller/:action/:id', {}
        map '/cool', lambda { |path| "This is #{path}" }
        map /.*/, :action => 'anything'
      end
    end
    
    it "should find route" do
      Routes::Recognition.new('/posts').recognize.should == { :controller => 'posts', :action => 'index' }
    end
    
    it "should find route with symbols as parameters" do
      Routes::Recognition.new('/posts/1').recognize.should == { :controller => 'posts', :id => '1' }
      Routes::Recognition.new('/controller/new').recognize.should == { :action => 'new' }
      Routes::Recognition.new('/posts/show/1').recognize.should == { :controller => 'posts', :action => 'show', :id => '1' }
    end
    
    it "should find route with regular expression" do
      Routes::Recognition.new('/something').recognize.should == { :action => 'anything' }
    end
        
    it "should return lambda routes" do
      route = Routes::Recognition.new('/cool').recognize
      route.call('/cool').should == "This is /cool"
    end
    
  end
end