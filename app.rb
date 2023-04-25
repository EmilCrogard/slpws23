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
    if re_route == 1
        redirect('/workout')
    elsif re_route == 2
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
    if re_route == 1
        redirect('/login')
    elsif re_route == 2
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
    delete_exercises(id)
    redirect('/exercises')
end

post('/exercises/:id/update') do
    id = params[:id].to_i 
    muscle_id = params[:muscle].to_i
    title = params[:title]
    content = params[:content]
    update_exercises(id, muscle_id, title, content)
    redirect('/exercises') 
end

get('/exercises/:id/edit') do
    if session[:id] == nil
        redirect('/login')
    end
    id = params[:id].to_i
    get_exercise_with_id(id)
    slim(:"/exercise/edit")
end

get('/exercises/:id') do
    if session[:id] == nil
        redirect('/login')
    end
    id = params[:id].to_i
    get_show_exercise(id)
    slim(:"/exercise/show")
end

get('/workout') do
    if session[:id] == nil
        redirect('/login')
    end
    get_all_workouts()
    slim(:"/workout/workouts")
end

get('/workout/new') do
    if session[:id] == nil
        redirect('/login')
    end
    get_all_exercise()
    slim(:"/workout/new")
end

get('/workout/:id') do
    if session[:id] == nil
        redirect('/login')
    end
    id = params[:id].to_i
    get_workout_info(id)
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

    re_route = add_workout(array_workout, array_set, user_id, title)

    if re_route == 1
        redirect('/workout')
    elsif re_route == 2
        redirect('/workout/new')
    end
end

get('/workout/:id/edit') do
    if session[:id] == nil
        redirect('/login')
    end
    id = params[:id].to_i
    get_workout_and_exercises(id)
    slim(:"/workout/edit")
end

post('/workout/:id/update') do
    id = params[:id].to_i 
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
     
    re_route = update_workouts(array_set, array_workout, title, id)

    if re_route == 1
        redirect('/workout')
    elsif re_route == 2
        redirect("/workout/#{id}/edit")
    end
end

post('/workout/:id/delete') do
    id = params[:id].to_i 
    workout_delete(id)
    redirect('/workout')
end
