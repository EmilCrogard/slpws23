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
    @result = db.execute("SELECT * FROM exercise_muscles_rel INNER JOIN exercise on exercise_muscles_rel.exercise_id = exercise.Id")
    slim(:"/exercise/exercises")
end

get('/exercises/new') do
    slim(:"/exercise/new")
end

post('/exercises/new') do
    title = params[:title]
    content = params[:content]
    muscle_id = params[:muscle]
    db = SQLite3::Database.new("db/database.db")
    db.execute("INSERT INTO exercise (title, content) VALUES (?,?)",title, content)
    exercise_id = db.execute("SELECT Id FROM exercise WHERE title = ?",title)
    db.execute("INSERT INTO exercise_muscles_rel (exercise_id, muscle_id) VALUES (?,?)", exercise_id, muscle_id)
    redirect('/exercises')
end

post('/exercises/:id/delete') do
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
    slim(:"/exercise/show")
end

get('/workout') do
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    @workout = db.execute("select * FROM workouts")
    slim(:"/workout/workouts")
end

get('/workout/new') do
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    @result = db.execute("SELECT * FROM exercise")
    slim(:"/workout/new")
end

get('/workout/:id') do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    @workout = db.execute("SELECT * FROM workout_exercise_rel INNER JOIN exercise on workout_exercise_rel.exercise_id = exercise.Id")
    slim(:"/workout/show")
end

post('/workout/new') do
    title = params[:title]
    workout_select_1 = params[:workout_select_1].to_i
    workout_select_2 = params[:workout_select_2].to_i
    workout_select_3 = params[:workout_select_3].to_i
    workout_select_4 = params[:workout_select_4].to_i
    workout_select_5 = params[:workout_select_5].to_i
    array_workout = [workout_select_1, workout_select_2, workout_select_3, workout_select_4, workout_select_5]
    set_1 = params[:set_1].to_i
    set_2 = params[:set_2].to_i
    set_3 = params[:set_3].to_i
    set_4 = params[:set_4].to_i
    set_5 = params[:set_5].to_i
    array_set = [set_1, set_2, set_3, set_4, set_5]
    db = SQLite3::Database.new("db/database.db")
    db.execute("INSERT INTO workouts (Title) VALUES (?)",title)
    workout_id = db.execute("SELECT Id FROM workouts WHERE title = ?",title)
    i = 0
    array_workout.each do |workout_select|
        db.execute("INSERT INTO workout_exercise_rel (workout_id, exercise_id, set_) VALUES (?,?,?)",workout_id, workout_select, array_set[i])
        i+=1
    end
    i = 0
    redirect('/workout')
end
