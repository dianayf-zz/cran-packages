require 'bundler'

Bundler.setup
Bundler.require :default, ENV.fetch("APP_ENV")

%W(lib config concepts services routes).each do |d|
  require_all Dir.glob("#{d}/**/*.rb")
end

CranPackagesAPI = Rack::Builder.new do
  run Routers::Root
end
