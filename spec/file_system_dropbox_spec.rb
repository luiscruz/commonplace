require_relative File.join('../lib', 'file_system_dropbox')
require 'rack/test'
require 'fake_dropbox'

describe FileSystemDropbox do
  fake_dropbox = FakeDropbox::Glue.new('fake_dropbox')
  
	before(:each) do
		@file_system = FileSystemDropbox.new('/testwiki', 'fake_access_token')
	end
  
  it 'should retrieve content of a file' do
    content = @file_system.get_file_content("dir1/dir2/apage.md")
    content.should == 'What a wonderful day!'
  end
  
  it 'should say whether it is a directory or not' do
    @file_system.is_directory?("dir1/dir2/apage.md").should be_false
    @file_system.is_directory?("dir1/dir2/").should be_true
  end
  
  it 'should say whether it is a file or not' do
    @file_system.is_file?("dir1/dir2/apage.md").should be_true
    @file_system.is_file?("dir1/dir2/").should be_false
  end
  
  it 'should not accept invalid directories for root' do
    FileSystemDropbox.new("dir1/dir2/apage.md", '').should be_nil
  end
  
  it 'should identify markdown files' do
    @file_system.is_markdown?("dir1/dir2/apage").should be_true
    @file_system.is_pdf?("dir1/dir2/apage").should be_false
  end
  
  it 'should identify pdf files' do
    @file_system.is_pdf?("dir1/dir2/apdf").should be_true
    @file_system.is_markdown?("dir1/dir2/apdf").should be_false
  end
  
  it 'should get directory entries properly' do
    @file_system.get_directory_files('dir1').should include('dir2')
  end
  
  it 'should create a directory' do
    response = @file_system.mkdir('dir1/delete_me')
    response['is_dir'].should be_true
    #permissions do not allow to remove directories:
    #@file_system.client.file_delete(response['path'])
  end
  
  it 'should create a file with content' do
    @file_system.new_file("dir1/delete_me_file.md", "Hello World")
    content = @file_system.get_file_content("dir1/delete_me_file.md")
    content.should == 'Hello World'
  end
end