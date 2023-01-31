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
    slim(:"/exercise/exercises")
end

get('/exercises/new') do
    slim(:"/exercise/new")
end

post('/exercises/new') do
    title = params[:title]
    artist_id = params[:content]
    p "vi fick in datan #{title} och #{content}"
    db = SQLite3::Database.new("db/database.db")
    db.execute("INSERT INTO exercise (title, content) VALUES (?,?)",title, content)
    redirect('/exercises')
end

post('/exercises/:id/update') do
    id = params[:id].to_i 
    db = SQLite3::Database.new("db/database.db")
    db.execute("DELETE FROM exercise WHERE Id =?",id)
    redirect('/exercises')
end

post('/exercises/:id/update') do
    id = params[:id].to_i 
    title = params[:title]
    content = params[:content]
    db = SQLite3::Database.new("db/database.db")
    db.execute("UPDATE exercise SET title=?,content=? WHERE Id = ?",title,content,id)
    redirect('/exercises') 
  end

get('/exercises/:id/edit') do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    @result = db.execute("SELECT * FROM exercise WHERE Id = ?",id).first
    slim(:"/exercise/edit")
end

get('/exercises/:id') do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    @result = db.execute("SELECT * FROM exercise WHERE Id = ?",id).first
    p @result
    slim(:"/exercise/show")
end

get('/workout') do
    slim(:workout)
end