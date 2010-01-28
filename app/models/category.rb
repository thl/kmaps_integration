class Category < TopicalMapResource
  acts_as_active_resource_tree
  @@cached_categories_by_title = Hash.new
  
  def self.find_by_title(title)
    # Since its going as part of the url, space is not welcome on the rails side as a '+'. Should be %20 instead.
    @@cached_categories_by_title[title] ||= find(:first, :from => "#{prefix}#{collection_name}/by_title/#{CGI::escape(title).gsub(/\+/, '%20')}.xml")
  end
end