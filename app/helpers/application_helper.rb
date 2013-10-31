module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "Transloc App"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def javascript(*files)
    content_for(:javascripts) { javascript_include_tag *files, "data-turbolinks-track" => true }
  end

end
