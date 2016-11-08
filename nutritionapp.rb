# myapp.rb
require 'sinatra'
require 'json'
require 'mysql2'

require File.join(File.dirname(__FILE__), 'dbcfg.rb')

set :bind, '0.0.0.0'
set :port, '4568'
set :json_content_type, :js

client = Mysql2::Client.new(:username => $username, :password => $password, :database => $schema, :reconnect => true)

get '/' do
    'You have reached the Team Red API'
end

get '/venues' do
    db_result = client.query("SELECT * FROM Venues;")
    hash_result = { :count => db_result.count, :venues => [] }
    db_result.each do |row|
        hash_result[:venues].push({:id => row["ID"], :name => row["Name"]})
    end
    hash_result.to_json
end

get '/venues/:vid/meals' do
    clean_vid = client.escape(params[:vid])
    db_result = client.query("SELECT * FROM Meals WHERE VenueID='#{clean_vid}'")
    hash_result = { :count => db_result.count, :meals => [] }
    db_result.each do |row|
        hash_result[:meals].push({:id => row["ID"], :name => row["Name"], :servingsizeoz => row["ServingSizeOz"], :nutritionvalues => JSON.parse(row["NutritionValues"])})
    end
    hash_result.to_json
end

get '/meals/:mid' do
    clean_mid = client.escape(params[:mid])
    db_result = client.query("SELECT * FROM Meals WHERE ID='#{clean_mid}'")
    hash_result = { :count => db_result.count, :meals => [] }
    db_result.each do |row|
        hash_result[:meals].push({:id => row["ID"], :name => row["Name"], :servingsizeoz => row["ServingSizeOz"], :nutritionvalues => JSON.parse(row["NutritionValues"])})
    end
    hash_result.to_json
end

post '/venues' do
    @name = client.escape(params[:name])
    dbResult = client.query("INSERT INTO Venues (Name) VALUES ('#{@name}')")
    { :response => dbResult }.to_json
end