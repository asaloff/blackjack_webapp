require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'your_secret'


get '/form' do
  erb :form
end

get '/nested_template' do
  erb :"/nest/nested"
end