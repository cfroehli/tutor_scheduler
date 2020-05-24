Billy.configure do |config|
  config.proxy_host = Socket.gethostname
  config.whitelist << Socket.gethostname
end
