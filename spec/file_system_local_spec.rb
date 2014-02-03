require_relative File.join('../lib', 'file_system_local')
require 'rack/test'

describe FileSystemLocal do
  
	before(:each) do
		@file_system = FileSystemLocal.new('spec/testwiki')
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
    FileSystemLocal.new("dir1/dir2/apage.md").should be_nil
  end
  
end