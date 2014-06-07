require_relative File.join('../lib', 'commonplace')
require_relative File.join('../lib', 'server')
require 'rack/test'

describe Commonplace do
	before(:each) do
		@w = Commonplace.new(file_system: 'local', dir: 'spec/testwiki')
	end
		
	it "check returns true for an existing directory" do
		@w.valid?.should == true
	end
	
	it "check returns false for a non-existing directory" do
		w = Commonplace.new(file_system: 'local', dir:'spec/testdir')
		w.valid?.should == false
	end
	
	it "returns directory entry with no files for an empty directory" do
		# create a new directory
		Dir.mkdir('spec/testdir2')
		w = Commonplace.new(file_system: 'local', dir: 'spec/testdir2')
    print(w.list_pages)
		w.list_pages[:files].should == []
		
		# remove directory
		Dir.rmdir('spec/testdir2')
	end
  
  it "should list all files paths from directories" do
  	@w.get_directory_files('dir1/').should == ['dir1/',['dir1/dir2', 'dir1/dir2/apage.md','dir1/dir2/apdf.pdf','dir1/dir2/what.md']]
  end
	
	it "should return nil when accessing a non-existing file" do
		@w.page('testfile').should == nil
	end
	
	it "should return contents of a file when accessing an existing file" do
		@w.page('test').raw.should == "Test file - don't change these contents."
		@w.page('test').content.should == "<p>Test file - don't change these contents.</p>\n"
	end
	
	it "should return a Page instance when a valid page is requested" do
		@w.page('test').class.should == Page
	end
	
	it "should return valid raw content for an existing page" do
		@w.page('test').raw.should == "Test file - don't change these contents."
	end
	
	it "should return a capitalized, underscore free title based on the file name" do
		@w.page('test_spaces').name.should == "Test spaces"
	end
	
	it "should work out of the box" do
		w = Commonplace.new(file_system: 'local', dir: "wiki")
		w.valid?.should == true
		w.page('_home').name.should == "Home"
		w.page('markdown_test').name.should == "Markdown test"
	end
	
	it "should save a page correctly" do
		@w.save('savetest', "This is a test save").class.should == Page
		@w.page('savetest').raw.should == "This is a test save"
	end
	
	it "should convert pages to files and back" do
		fwd = Page.title_to_permalink("This is a test page name")
		fwd.should == "this_is_a_test_page_name"
		rev = Page.permalink_to_title(fwd)
		rev.should == "This is a test page name"
	end
  
  it "should convert permalink with dirs to title" do
    permalink = "dir1/dir2/file_name"
    title = Page.permalink_to_title "dir1/dir2/file_name"
    title.should == "File name"
  end
	
	it "should look for links in double square brackets and create anchor tags" do
		@w.page('linktest').content.should == "<p><a class=\"internal\" href=\"/test\">Test</a></p>\n"
	end
	
	it "should highlight links to pages that don't exist with the correct class" do
		@w.page('linktest2').content.should == "<p><a class=\"internal new\" href=\"/non_existing_page\">Non existing page</a></p>\n"
	end
end

describe CommonplaceServer do
	include Rack::Test::Methods
	
	def app
    @server ||= CommonplaceServer.new!
    @server.settings.stub(:readonly){false}
    @server
	end
	
  
	it "renders the homepage successfully" do
		get '/'
		last_response.should be_ok
	end
	
	it "renders an existing page successfully" do
		get '/_home'
		last_response.should be_ok
	end
	
	it "returns a 404 when trying to view a page that doesnt exist" do
		get '/anonexistingpagehopefully'
		last_response.should_not be_ok
		last_response.status.should == 404
	end

	it "renders the edit page for an existing page successfully" do
		get '/p/_home/edit'
		last_response.should be_ok
	end

	it "returns a 404 when trying to edit a page that doesnt exist" do
		get '/p/anonexistingpagehopefully/edit'
		last_response.should_not be_ok
		last_response.status.should == 404
	end
	
	it "renders the page list successfully" do
		get '/list'
		last_response.should be_ok
	end
	
	it "renders the new page successfully" do
		get '/p/new'
		last_response.should be_ok
	end
	
	it "renders the new page for a specific page successfully" do
		get '/p/new/anonexistingpagehopefully'
		last_response.should be_ok
	end
end