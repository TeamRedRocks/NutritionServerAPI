# myapp.rb
require 'sinatra'
require 'json'
require 'mysql2'

set :bind, '0.0.0.0'
set :json_content_type, :js

client = Mysql2::Client.new(:username => "app.nutrition", :password => "subXzbKLc*j[t+vz,1$'^Fr_VU@C", :database => "nutrition")


get '/' do
    'You have reached the Team Red API'
end

get '/venues' do
    dbResults = client.query("SELECT * FROM Venues;")
    prereturn = { :count => dbResults.count, :venues => [] }
    dbResults.each do |row|
        prereturn[:venues].push({:id => row["ID"], :name => row["Name"]})
    end
    prereturn.to_json
end

#begin
#rescue mysql2::Error => e
#	puts '#{e.errno}(#{e.sqlstate}): #{e.error}'
#	exit 1
#ensure
#	client.close if client
#end