module  Helpers

    def render_directory_list(directory_meta, nested_already=false)
      html_string = ""
      html_string << "<div class=\"tree well\"><ul> <li>" unless nested_already
      html_string << "<span class=\"node\"><span class=\"glyphicon glyphicon-folder-open\"></span><a href=\"/#{directory_meta[:link]}\">#{directory_meta[:title]}</a></span>"
            html_string << "<ul>"
      directory_meta[:files].each do |page|
        if page[:dir]
          html_string << "<li>"+render_directory_list(page, true)+"</li>"
        else
          html_string << "<li><span class=\"node\"><a href=\"/#{page[:link]}\">#{page[:title]}</a></span></li>"
        end
      end
      html_string << "</ul>"
      html_string << "</div></ul></li>" unless nested_already
      
      return html_string
    end
    
    def render_breadcrumb(permalink)
      files=[]
      Pathname.new(permalink).descend{|v| files << v.to_s}
      last_file = files.pop
      content = <<HTML
      <ol class="breadcrumb">
        <li><a href="/">Home </a></li>
HTML
        files.each do |file|
          content << "<li><a href=\"/#{file}\">#{Page.permalink_to_title file}</a></li> "
        end
        unless last_file == '_home'
          content << "<li> #{ Page.permalink_to_title last_file} </li>"
        end 
      content<< "</ol>"
    end
end
