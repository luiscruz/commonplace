class FileSystemAbstract
  
  def new_file(path, content)
    raise 'unimplemented method'
  end
  
  def mkdir(path)
    raise 'unimplemented method'
  end
  
  def get_file_content(path)
    raise 'unimplemented method'
  end
  
  def get_directory_files(path)
    raise 'unimplemented method'
  end
  
  def is_directory?(path)
    raise 'unimplemented method'
  end
  
  def is_file?(path, extension = nil)
    raise 'unimplemented method'
  end
  
  #path has file without extension
  def is_markdown?(path)
    is_file?(path, 'md')
  end
  
  def is_pdf?(path)
    is_file?(path, 'pdf')
  end
end