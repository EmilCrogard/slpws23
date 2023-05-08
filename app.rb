require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/flash'
require_relative './model.rb'

enable :sessions

include Model 

#Before block that checks if user is admin on specific routes
#
before('/admin/*') do 
    if session[:id] != 8
        flash[:notice] = "You do not have acces to this route"
        redirect('/exercises')
    end
end

#Before block that checks if user is logged in on workout routes
#
before('/workout/*') do
    session[:login_message] = ""
    if session[:id] == nil
        flash[:notice] = "You need to login"
        redirect('/login')
    end
end

#Before block that checks if user is logged in on exercises routes
#
before('/exercises/*') do
    session[:login_message] = ""
    if session[:id] == nil
        flash[:notice] = "You need to login"
        redirect('/login')
    end
end

# Redirects to '/workout' if logged in otherwise redirects to '/login'
#
get('/') do
    if session[:id] == nil
        redirect('/login')
    end
    redirect('/workout')
end

# Displays a login form
#
get('/login') do
    slim(:login)
end

# Displays a register form
#
get('/register') do
    session[:login_message] = ""
    slim(:register)
end

# Attempts login and updates the session
#
# @param [String] username, The username
# @param [String] password, The password
#
# @see Model#login_user
post('/login') do 
    cooldown()
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

# Attempts to register a new user and redirects to '/login'
#
# @param [String] username, The username
# @param [String] password, The password
# @param [String] password_confirm, The repeated password
#
# @see Model#register_user
post('/users/new') do
    cooldown()
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

# Displays all exercises
#
# @see Model#get_exercises 
get('/exercises') do
    if session[:id] == nil
        flash[:notice] = "You need to login"
        redirect('/login')
    end
    get_exercises()
    slim(:"/exercise/exercises")
end


# Displays a form to add a new exercise
#
get('/exercises/new') do
    slim(:"/exercise/new")
end

# Attempts to add a new exercise and redirect to '/exercises'
#
# @param [String] title, The title of the exercise
# @param [String] content, The information
# @param [Integer] muscle_id, The ID of the muscle 
#
# @see Model#new_exercise
post('/exercises/new') do
    title = params[:title]
    content = params[:content]
    muscle_id = params[:muscle]
    new_exercise(title, content, muscle_id)
    redirect('/exercises')
end

# Deletes an existing exercise and redirects to '/exercises'
#
# @param [Integer] :id, The ID of the exercise 
#
# @see Model#delete_exercises
post('/admin/exercises/:id/delete') do
    id = params[:id].to_i 
    delete_exercises(id)
    redirect('/exercises')
end

# Updates an existing exercise and redirects to '/exercises'
#
# @param [Integer] :id, The ID of the exercise
# @param [String] title, The title of the exercise
# @param [String] content, The information
# @param [Integer] muscle_id, The ID of the muscle 
#
# @see Model#update_exercises
post('/admin/exercises/:id/update') do
    id = params[:id].to_i 
    muscle_id = params[:muscle].to_i
    title = params[:title]
    content = params[:content]
    update_exercises(id, muscle_id, title, content)
    redirect('/exercises') 
end


# Displays a form to edit a specific exercise 
#
# @param [Integer] :id, The ID of the exercise
#
# @see Model#get_exercise_with_id
get('/admin/exercises/:id/edit') do
    id = params[:id].to_i
    get_exercise_with_id(id)
    slim(:"/exercise/edit")
end

#Displays a single exercise 
#
# @param [Integer] :id, The ID of the exercise
#
# @see Model#get_show_exercise
get('/exercises/:id') do
    id = params[:id].to_i
    get_show_exercise(id)
    slim(:"/exercise/show")
end

# Displays all workouts 
#
# @see Model#get_all_workouts 
get('/workout') do
    if session[:id] == nil
        flash[:notice] = "You need to login"
        redirect('/login')
    end
    get_all_workouts()
    slim(:"/workout/workouts")
end

# Displays a form to add a new exercise
#
# @see Model#get_all_exercise
get('/workout/new') do
    get_all_exercise()
    slim(:"/workout/new")
end

#Displays a single workout 
#
# @param [Integer] :id, The ID of the workout
#
# @see Model#get_workout_info
get('/workout/:id') do
    id = params[:id].to_i
    if get_workout_user(id)[0][0] != session[:id]
        flash[:notice] = "You dont have access to this workout"
        redirect('/workout')
    end
    get_workout_info(id)
    slim(:"/workout/show")
end

# Attempts to add a new workout and redirect to '/workout'
#
# @param [String] title, The title of the workout
# @param [Integer] workout_select_1, The ID of the chosen exercise
# @param [Integer] workout_select_2, The ID of the chosen exercise
# @param [Integer] workout_select_3, The ID of the chosen exercise
# @param [Integer] workout_select_4, The ID of the chosen exercise
# @param [Integer] workout_select_5, The ID of the chosen exercise
#
# @param [Integer] set_1, Number of sets
# @param [Integer] set_2, Number of sets
# @param [Integer] set_3, Number of sets
# @param [Integer] set_4, Number of sets
# @param [Integer] set_5, Number of sets
#
# @see Model#add_workout
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

# Displays a form to edit a specific workout 
#
# @param [Integer] :id, The ID of the workout
#
# @see Model#get_workout_and_exercises
get('/workout/:id/edit') do
    id = params[:id].to_i
    if get_workout_user(id)[0][0] != session[:id]
        flash[:notice] = "You dont have access to this workout"
        redirect('/workout')
    end
    get_workout_and_exercises(id)
    slim(:"/workout/edit")
end

# Updates an existing workout and redirects to '/workout'
#
# @param [Integer] :id, The ID of the workout
# @param [String] title, The title of the workout
# @param [Integer] workout_select_1, The ID of the chosen exercise
# @param [Integer] workout_select_2, The ID of the chosen exercise
# @param [Integer] workout_select_3, The ID of the chosen exercise
# @param [Integer] workout_select_4, The ID of the chosen exercise
# @param [Integer] workout_select_5, The ID of the chosen exercise
#
# @param [Integer] set_1, Number of sets
# @param [Integer] set_2, Number of sets
# @param [Integer] set_3, Number of sets
# @param [Integer] set_4, Number of sets
# @param [Integer] set_5, Number of sets
#
# @see Model#update_workouts
post('/workout/:id/update') do
    id = params[:id].to_i 
    if get_workout_user(id)[0][0] != session[:id]
        flash[:notice] = "You dont have access to this workout"
        redirect('/workout')
    end
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

# Deletes an existing workout and redirects to '/workout'
#
# @param [Integer] :id, The ID of the workout 
#
# @see Model#workout_delete
post('/workout/:id/delete') do
    id = params[:id].to_i 
    if get_workout_user(id)[0][0] != session[:id]
        flash[:notice] = "You dont have access to this workout"
        redirect('/workout')
    end
    workout_delete(id)
    redirect('/workout')
end

# Catches error 404 and redirects to '/workout'
#
not_found do
    flash[:notice] = "404 page not found"
    redirect('/workout')
end

#Function that stops the user from trying to login too many times during a short period of time
#
def cooldown()

    if session[:login_lock] == "true" && Time.now.to_i - session[:login_lock_time].to_i < 30
        session[:time] = []
        session[:login_message] = "You do not have access to login, #{30 - (Time.now.to_i - session[:login_lock_time].to_i)} seconds left"
        redirect('/login')
    end

    session[:login_lock] = "" 

    timenow = Time.now
    if session[:time] == nil
      session[:time] = [timenow]
    else
      session[:time].prepend(timenow)
    end
    timediff = timenow.to_i-session[:time][1].to_i
    if timediff < 4 && session[:time].length > 1
        sleep(2)
    end

    if session[:time].length > 3
        if Time.now.to_i - session[:time][3].to_i < 20
            session[:login_message] = "You do not have access to login, 30 seconds"
            session[:login_lock_time] = Time.now
            session[:login_lock] = "true" 
        end
    end

end