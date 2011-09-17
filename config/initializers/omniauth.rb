
#OmniAuth.config.full_host = "http://primetime-dev.infinite-labs.net"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google, 'primetime-dev.infinite-labs.net', 'g4LLGFt7FTTXOCLz85fXFzu_', :scope => 'http://gdata.youtube.com'
end