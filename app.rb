require_relative 'models'

require 'roda'

class App < Roda
  plugin :default_headers,
    'Content-Type'=>'text/html',
    'Content-Security-Policy'=>"default-src 'self'; style-src 'self' https://maxcdn.bootstrapcdn.com;",
    #'Strict-Transport-Security'=>'max-age=16070400;', # Uncomment if only allowing https:// access
    'X-Frame-Options'=>'deny',
    'X-Content-Type-Options'=>'nosniff',
    'X-XSS-Protection'=>'1; mode=block'

  # Don't delete session secret from environment in development mode as it breaks reloading
  session_secret = ENV['RACK_ENV'] == 'development' ? ENV['APP_SESSION_SECRET'] : ENV.delete('APP_SESSION_SECRET')
  use Rack::Session::Cookie,
    :key => '_App_session',
    #:secure=>!TEST_MODE, # Uncomment if only allowing https:// access
    :secret=>(session_secret || SecureRandom.hex(40))

  plugin :csrf
  plugin :flash
  plugin :assets, :css=>'app.scss', :css_opts=>{:style=>:compressed, :cache=>false}
  plugin :render, :escape=>true
  plugin :multi_route

  Unreloader.require('routes'){}

  route do |r|
    r.assets
    r.multi_route

    r.root do
      view 'index'
    end
  end
end
