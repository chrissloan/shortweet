# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def http_base
    "http://#{request.host_with_port}"
  end
  
  def shortenify(url)
     url ? http_base + "/" + url.base62_encode : ""
  end
  
end
