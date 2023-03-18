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

post('/login') do 
    username = params[:username]
    password = params[:password]
    p username, password
    db = SQLite3::Database.new('db/database.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first

    if result

        pwdigest = result["pwdigest"]
    
        if BCrypt::Password.new(pwdigest) == password
          id = result["id"]
          redirect('/workout')
        else 
          "FEL LÖSEN!"
        end
      else 
        "ICKE EXISTERANDE ANVÄNDARNAMN!"
      end
    
end

post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
    p username, password, password_confirm
    if (password == password_confirm)
        #lägg till användare
        password_digest = BCrypt::Password.create(password)
        p password_digest
        db = SQLite3::Database.new('db/database.db')
        db.execute("INSERT INTO users (username,pwdigest) VALUES (?,?)",username,password_digest)
        redirect('/workout')
      else
        #felhantering
        "Lösenorden matchade inte!"
      end
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
    muscle_id = params[:muscle].to_i
    title = params[:title]
    content = params[:content]
    db = SQLite3::Database.new("db/database.db")
    db.execute("UPDATE exercise SET title=?,content=? WHERE Id = ?",title,content,id)
    db.execute("UPDATE exercise_muscles_rel SET muscle_id=? WHERE exercise_id = ?",muscle_id,id)
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
    #@muscle = ("SELECT muscles.muscle_name 
                #FROM (exercise_muscles_rel 
                    #INNER JOIN muscles ON exercise_muscles_rel.muscle_id = muscles.Id)
                #WHERE exercise_id = ?", id)
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
    @workout = db.execute("SELECT * FROM workout_exercise_rel INNER JOIN exercise on workout_exercise_rel.exercise_id = exercise.Id WHERE workout_id =?", id)
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

get('/workout/:id/edit') do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    @result = db.execute("SELECT * FROM exercise")
    @workout = db.execute("SELECT * FROM workouts WHERE Id = ?",id).first
    slim(:"/workout/edit")
end

post('/workout/:id/update') do
    id = params[:id].to_i 
    db = SQLite3::Database.new("db/database.db")
    redirect('/workout') 
end

post('/workout/:id/delete') do
    id = params[:id].to_i 
    db = SQLite3::Database.new("db/database.db")
    db.execute("DELETE FROM workouts WHERE Id =?",id)
    redirect('/workout')
end
