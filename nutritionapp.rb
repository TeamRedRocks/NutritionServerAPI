# myapp.rb
require 'sinatra'
require 'json'
require 'mysql2'

require './dbcfg.rb'

set :bind, '0.0.0.0'
set :port, '4568'
set :json_content_type, :js

client = Mysql2::Client.new(:username => $username, :password => $password, :database => $schema, :reconnect => true)


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

get '/venues/:vid/meals' do
    clean_vid = client.escape(params[:vid]);
    dbResults = client.query("SELECT * FROM Meals WHERE VenueID='#{clean_vid}'");
    prereturn = { :count => dbResults.count, :meals => [] }
    dbResults.each do |row|
        prereturn[:meals].push({:id => row["ID"], :name => row["Name"], :servingsizeoz => row["ServingSizeOz"], :nutritionvalues => JSON.parse(row["NutritionValues"])})
    end
    prereturn.to_json
end

get '/meals/:mid' do
    clean_mid = client.escape(params[:mid]);
    dbResults = client.query("SELECT * FROM Meals WHERE ID='#{clean_mid}'");
    prereturn = { :count => dbResults.count, :meals => [] }
    dbResults.each do |row|
        prereturn[:meals].push({:id => row["ID"], :name => row["Name"], :servingsizeoz => row["ServingSizeOz"], :nutritionvalues => JSON.parse(row["NutritionValues"])})
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