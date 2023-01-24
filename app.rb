require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'

get('/') do
    slim(:register)
end

get('/login') do
    slim(:login)
end

get('/exercises') do
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    @result = db.execute("SELECT * FROM exercise")
    p @result
    slim(:exercises)
end

get('/workout') do
    slim(:workout)
end