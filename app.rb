require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/flash'
require_relative './model.rb'

enable :sessions

get('/') do
    if session[:id] == nil
        redirect('/login')
    end
    redirect('/workout')
end

get('/login') do
    slim(:login)
end

get('/register') do
    slim(:register)
end

post('/login') do 
    username = params[:username]
    password = params[:password]
    re_route = login_user(username, password)
    if re_route = 1
        redirect('/workout')
    elsif re_route = 2
        redirect('/login')
    end
end

get('/logout') do
    session[:id] = nil
    flash[:notice] = "You have been logged out!"
    redirect('/')
end

post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
    re_route = register_user(username, password, password_confirm)
    if re_route = 1
        redirect('/login')
    elsif re_route = 2
        redirect('/register')
    end
end

get('/exercises') do
    if session[:id] == nil
        redirect('/login')
    end
    get_exercises()
    slim(:"/exercise/exercises")
end

get('/exercises/new') do
    if session[:id] == nil
        redirect('/login')
    end
    slim(:"/exercise/new")
end

post('/exercises/new') do
    title = params[:title]
    content = params[:content]
    muscle_id = params[:muscle]
    new_exercise(title, content, muscle_id)
    redirect('/exercises')
end

post('/exercises/:id/delete') do
    id = params[:id].to_i 
    db = SQLite3::Database.new("db/database.db")
    db.execute("DELETE FROM exercise WHERE Id =?",id)
    db.execute("DELETE FROM exercise_muscles_rel WHERE exercise_id =?",id)
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
    if session[:id] == nil
        redirect('/login')
    end
    id = params[:id].to_i
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    @result = db.execute("SELECT * FROM exercise WHERE Id = ?",id).first
    slim(:"/exercise/edit")
end

get('/exercises/:id') do
    if session[:id] == nil
        redirect('/login')
    end
    id = params[:id].to_i
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    @result = db.execute("SELECT * FROM exercise WHERE Id = ?",id).first
    @muscle = db.execute("SELECT muscles.muscle_name 
                FROM exercise_muscles_rel 
                    INNER JOIN muscles ON exercise_muscles_rel.muscle_id = muscles.Id
                WHERE exercise_id = ?", id)
    slim(:"/exercise/show")
end

get('/workout') do
    if session[:id] == nil
        redirect('/login')
    end
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    @workout = db.execute("select * FROM workouts")
    slim(:"/workout/workouts")
end

get('/workout/new') do
    if session[:id] == nil
        redirect('/login')
    end
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    @result = db.execute("SELECT * FROM exercise")
    slim(:"/workout/new")
end

get('/workout/:id') do
    if session[:id] == nil
        redirect('/login')
    end
    id = params[:id].to_i
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    @workout = db.execute("SELECT * FROM workout_exercise_rel INNER JOIN exercise ON workout_exercise_rel.exercise_id = exercise.Id WHERE workout_exercise_rel.workout_id =?", id)
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
    user_id = session[:id]

    boolean = true
    array_workout.each do |validate|
        if validate == 0
            boolean = false
        end
    end
    
    if boolean 
        db = SQLite3::Database.new("db/database.db")
        db.execute("INSERT INTO workouts (Title, user_id) VALUES (?,?)",title, user_id)
        workout_id = db.execute("SELECT Id FROM workouts WHERE title = ?",title)
        i = 0
        array_workout.each do |workout_select|
            db.execute("INSERT INTO workout_exercise_rel (workout_id, exercise_id, set_) VALUES (?,?,?)",workout_id, workout_select, array_set[i])
            i+=1
        end
        redirect('/workout')
    else
        flash[:notice] = "Every exercise wasn't logged!"
        redirect('/workout/new')
    end
end

get('/workout/:id/edit') do
    if session[:id] == nil
        redirect('/login')
    end
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
    
    boolean = true
    array_workout.each do |validate|
        if validate == 0
            boolean = false
        end
    end

    if boolean
        workout_exercise_rel_id = db.execute("SELECT Id FROM workout_exercise_rel where workout_id=?",id)
        i = 0
        array_workout.each do |workout_select|
            db.execute("UPDATE workouts SET Title=?", title)
            db.execute("UPDATE workout_exercise_rel SET exercise_id=?, set_=? WHERE Id=?", workout_select, array_set[i], workout_exercise_rel_id[i][0])
            i+=1
        
        end
        redirect('/workout') 
    else 
        flash[:notice] = "Every exercise wasn't logged!"
        redirect("/workout/#{id}/edit")
    end
end

post('/workout/:id/delete') do
    id = params[:id].to_i 
    db = SQLite3::Database.new("db/database.db")
    db.execute("DELETE FROM workouts WHERE Id =?",id)
    db.execute("DELETE FROM workout_exercise_rel WHERE workout_id =?",id)
    flash[:notice] = "Workout was deleted"
    redirect('/workout')
end
