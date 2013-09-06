module ResearchersHelper
  # Returns the Gravatar (http://gravatar.com/) for the given researcherer.
  def gravatar_for(researcher)
    gravatar_id = Digest::MD5::hexdigest(researcher.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
    image_tag(gravatar_url, alt: researcher.name, class: "gravatar")
  end
end
