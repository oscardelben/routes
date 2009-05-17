require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Routes::Base do
  context 'storing new routes' do
    
    before(:each) do
      @new_instance = Routes::Base.new
    end
    
    it "should have an empty routes list on new" do
      @new_instance.routes.should == []
    end
    
    it "should be able to add a new route with the map method" do
      @new_instance.map('/foo', 'some action')
      @new_instance.routes.should == [['/foo/', 'some action']]
    end
    
    it "should consider the order of routes with the map method" do
      @new_instance.map('/first', 'first action')
      @new_instance.map('/second', 'second action')
      @new_instance.routes.should == [['/first/', 'first action'], ['/second/', 'second action']]
    end
    
    it "should append / at the start of path if needed" do
      @new_instance.map('foo/', nil)
      @new_instance.routes.should == [['/foo/', nil]]
    end
    
    it "should append / at the end of path if needed" do
      @new_instance.map('/foo', nil)
      @new_instance.routes.should == [['/foo/', nil]]
    end
        
    it "should be able to storea bunch of routes with the draw method" do
      proc = lambda { |path| "You are visiting #{path}" }
      regex = /pos.*/
      
      @new_instance.draw do
        map '/first', 'something'
        map '/second', :controller => 'foo', :action => 'bar'
        map '/third', proc
        map regex, 'something else'
      end
      
      @new_instance.routes.should == [
          ['/first/', 'something'],
          ['/second/', { :controller => 'foo', :action => 'bar' }],
          ['/third/', proc],
          [regex, 'something else']
        ]
    end
    
    
  end
  
  context 'routes recognization' do
    
    before(:each) do
      @instance = Routes::Base.new
      @instance.draw do
        map '/posts', :controller => 'posts', :action => 'index'
        map '/posts/:id', :controller => 'posts'
        map '/controller/:action', {}
        map '/:controller/:action/:id', {}
        map '/cool', lambda { |path| "This is #{path}" }
        map /.*/, :action => 'anything'
      end
    end
    
    it "should find route" do
      @instance.recognize('/posts').should == { :controller => 'posts', :action => 'index' }
    end
    
    it "should find route with symbols as parameters" do
      @instance.recognize('/posts/1').should == { :controller => 'posts', :id => '1' }
      @instance.recognize('/controller/new').should == { :action => 'new' }
      @instance.recognize('/posts/show/1').should == { :controller => 'posts', :action => 'show', :id => '1' }
    end
    
    it "should find route with regular expression" do
      @instance.recognize('/something').should == { :action => 'anything' }
    end
        
    it "should directly execute lambda routes" do
      @instance.recognize('/cool').should == "This is /cool"
    end
    
  end
end