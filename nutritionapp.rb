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

get '/recommendations/:nutrient' do
    @clean_nutrient = client.escape(params[:nutrient])
    db_result = client.query("SELECT * FROM NutrientRecommendations WHERE LCASE(Nutrient)=LCASE('#{@clean_nutrient}')")
    hash_result = { :count => db_result.count, :recommendations => [] }
    db_result.each do |row|
        hash_result[:recommendations].push({:key => row["Key"], :nutrient => row["Nutrient"], :recommendation => row["Recommendation"], :datasource => row["DataSource"]})
    end
    hash_result.to_json
end

post '/venues' do
    if params[:name] == nil
        status 400
        body ({ :error => "The 'name' parameter must be specified"}.to_json)
        return
    end
    @name = client.escape(params[:name])
    
    dbResult = client.query("SELECT * FROM Venues WHERE Name = '#{@name}'")
    if (dbResult.count > 0)
        status 409
        body ({ :error => "This venue exists and duplicates are not supported" }.to_json)
        return
    end
    
    dbResult = client.query("INSERT INTO Venues (Name) VALUES ('#{@name}')")
    body ({ :message => "Venue '#{@name}' was added successfully" }.to_json)
end

post '/venues/:vid/meals' do
    # todo loop through required params instead
    if params[:name] == nil
        status 400
        body ({ :error => "The 'name' parameter must be specified"})
        return
    elseif params[:servingsizeoz] == nil
        status 400
        body ({ :error => "The 'servingsizeoz' parameter must be specified"})
        return
    elseif params[:nutritionvaluesjson] == nil
        status 400
        body ({ :error => "The 'nutritionvaluesjson' parameter must be specified"})
        return
    elseif not(/^\d+(\.\d+)?$/ =~ params[:servingsizeoz])
        status 400
        body ({ :error => "The 'servingsizeoz' parameter must be a number"})
        return
    end
    
    begin
        JSON.parse(params[:nutritionvaluesjson])
    rescue JSON::ParserError => e
        status 400
        body ({ :error => "The 'nutritionvaluesjson' parameter must contain only valid JSON data"})
        return
    end
    
    @vidClean = client.escape(params[:vid])
    @name = client.escape(params[:name])
    @servingSizeOz = client.escape(params[:servingsizeoz])
    @nutritionValues = client.escape(params[:nutritionvaluesjson])
    
    dbResult = client.query("SELECT * FROM Meals WHERE VenueID = #{@vidClean} AND Name = '#{@name}'")
    if (dbResult.count > 0)
        status 409
        body ({ :error => "This meal exists under this venue and duplicates are not supported" }.to_json)
        return
    end
    
    dbResult = client.query("INSERT INTO Meals (Name, VenueID, ServingSizeOz, NutritionValues) VALUES ('#{@name}', #{@vidClean}, '#{@servingSizeOz}', '#{@nutritionValues}')")
    body ({ :message => "Meal '#{@name}' was added successfully" }.to_json)
end

post '/recommendation' do
	if params[:key] == nil
        status 400
        body ({ :error => "The 'key' parameter must be specified. This should be a unique identifier less than 65 characters long."})
        return
	elseif params[:nutrient] == nil
        status 400
        body ({ :error => "The 'nutrient' parameter must be specified. This should be the nutrient the recommendation references."})
        return
	elseif params[:recommendation] == nil
        status 400
        body ({ :error => "The 'recommendation' parameter must be specified. It should contain a message about what users are to do if they are low on a nutrient."})
        return
	end
	
    @key = client.escape(params[:key])
    @nutrient = client.escape(params[:nutrient])
    @recommendation = client.escape(params[:recommendation])
    @datasource = ""
	if params[:datasource] != nil
		@datasource = client.escape(params[:datasource])
    end
    
    dbResult = client.query("SELECT * FROM NutrientRecommendations WHERE NutrientRecommendations.Key = '#{@key}'")
    if (dbResult.count > 0)
        status 409
        body ({ :error => "This recommendation key exists and duplicates are not supported" }.to_json)
        return
    end
	
	dbResult = client.query("INSERT INTO NutrientRecommendations (NutrientRecommendations.Key, Nutrient, Recommendation, DataSource) VALUES ('#{@key}', '#{@nutrient}', '#{@recommendation}', '#{@datasource}')")
    body ({ :message => "Recommendation '#{@key}' was added successfully" }.to_json)
end