module Model 
    # Attempts to login user
    #
    # @param [string] username The username
    # @param [string] password The password
    # @return [integer]
    def login_user(username, password)
        db = SQLite3::Database.new('db/database.db')
        db.results_as_hash = true
        result = db.execute("SELECT * FROM users WHERE username = ?",username).first
        if result

            pwdigest = result["pwdigest"]
        
            if BCrypt::Password.new(pwdigest) == password
            session[:id] = result["Id"]
            return 1
            else 
            flash[:notice] = "Wrong password!"
            return 2
            end
        else 
            flash[:notice] = "Username doesn't exist!"
            return 2 
        end 
    end

    # Attempts to create new user
    #
    # @param [string] username The username
    # @param [string] password The password
    # @param [string] password_confirm The repeated password
    # @return [integer]
    def register_user(username, password, password_confirm)
        db = SQLite3::Database.new('db/database.db')
        name_array = db.execute("SELECT username FROM users")
        boolean = true
        i = 0
        while name_array.length > i
            if name_array[i][0] == username
                boolean = false
            end
            i += 1
        end

        if boolean 
            if (password == password_confirm) 
                password_digest = BCrypt::Password.create(password)
                db.execute("INSERT INTO users (username,pwdigest) VALUES (?,?)",username,password_digest)
                return 1
            else
                flash[:notice] = "Passwords didn't match!"
                return 2
                
            end
        else 
            flash[:notice] = "Username already exists!"
            return 2
        end
    end

    # Gets the user of a specific workout
    #
    # @param [Integer] id The id of the workout
    def get_workout_user(id)
        db = SQLite3::Database.new("db/database.db")
        result = db.execute("SELECT user_id FROM workouts WHERE id = ?", id)
        return result 
    end


    # Gets all exercises from exercise_muscles_rel INNER JOIN exercise 
    #
    def get_exercises()
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true
        @result = db.execute("SELECT * FROM exercise_muscles_rel INNER JOIN exercise on exercise_muscles_rel.exercise_id = exercise.Id")
    end

    # Attempts to add a row in the exercise table and exercise_muscles_rel table
    #
    # @param [Integer] muscle_id The muscle's ID
    # @params [String] title The title of the exercise
    # @params [String] content The content of the exercise
    def new_exercise(title, content, muscle_id)
        db = SQLite3::Database.new("db/database.db")
        db.execute("INSERT INTO exercise (title, content) VALUES (?,?)",title, content)
        exercise_id = db.execute("SELECT Id FROM exercise WHERE title = ?",title)
        db.execute("INSERT INTO exercise_muscles_rel (exercise_id, muscle_id) VALUES (?,?)", exercise_id, muscle_id)
    end

    # Attempts to delete a row from the exercise table and exercise_muscles_rel table
    #
    # @param [Integer] id The exercise's ID
    def delete_exercises(id)
        db = SQLite3::Database.new("db/database.db")
        db.execute("DELETE FROM exercise WHERE Id =?",id)
        db.execute("DELETE FROM exercise_muscles_rel WHERE exercise_id =?",id)
    end

    # Attempts to update a row in the exercise table and exercise_muscles_rel table
    #
    # @param [Integer] id The exercise's ID
    # @param [Integer] muscle_id The muscle's ID
    # @params [String] title The title of the exercise
    # @params [String] content The content of the exercise
    def update_exercises(id, muscle_id, title, content)
        db = SQLite3::Database.new("db/database.db")
        db.execute("UPDATE exercise SET title=?,content=? WHERE Id = ?",title,content,id)
        db.execute("UPDATE exercise_muscles_rel SET muscle_id=? WHERE exercise_id = ?",muscle_id,id)
    end

    # Gets all data from the exercise table and the muscle_name from the muslce table with a specific id 
    #
    # @param [Integer] id The exercise's ID
    def get_show_exercise(id)
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true
        @result = db.execute("SELECT * FROM exercise WHERE Id = ?",id).first
        @muscle = db.execute("SELECT muscles.muscle_name 
                    FROM exercise_muscles_rel 
                        INNER JOIN muscles ON exercise_muscles_rel.muscle_id = muscles.Id
                    WHERE exercise_id = ?", id)
    end

    # Gets all data from the exercise table with a specific ID
    #
    # @param [Integer] id The exercise's ID
    def get_exercise_with_id(id)
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true
        @result = db.execute("SELECT * FROM exercise WHERE Id = ?",id).first
    end

    #gets all data from the workouts table 
    #
    def get_all_workouts()
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true
        @workout = db.execute("select * FROM workouts")
    end

    #gets all data from the exercise table 
    #
    def get_all_exercise()
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true
        @result = db.execute("SELECT * FROM exercise")
    end

    # Gets all data from workout_exercise_rel INNER JOIN exercise with a specific ID
    #
    # @param [Integer] id The workout's ID
    def get_workout_info(id)
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true
        @workout = db.execute("SELECT * FROM workout_exercise_rel INNER JOIN exercise ON workout_exercise_rel.exercise_id = exercise.Id WHERE workout_exercise_rel.workout_id =?", id)
    end

    # Attempts to add a row in the workouts table and workout_exercise_rel table
    #
    # @param [Integer] user_id The users ID
    # @param [Array] array_workout array with exercise ID's
    # @param [Array] array_set array with number of sets 
    # @params [String] title The title of the article
    #
    # @return [integer]
    def add_workout(array_workout, array_set, user_id, title)
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
            return 1
        else
            flash[:notice] = "Every exercise wasn't logged!"
            return 2 
        end
    end

    # get all data from exercise table and all data with a specific id from the workouts table
    #
    # @param [Integer] id The workout's ID
    def get_workout_and_exercises(id)
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true
        @result = db.execute("SELECT * FROM exercise")
        @workout = db.execute("SELECT * FROM workouts WHERE Id = ?",id).first
    end

    # Attempts to update a row in the workouts table and workout_exercise_rel table
    #
    # @param [Integer] id The ID fo the workout
    # @param [Array] array_workout array with exercise ID's
    # @param [Array] array_set array with number of sets 
    # @params [String] title The title of the article
    #
    # @return [integer]
    def update_workouts(array_set, array_workout, title, id)
        db = SQLite3::Database.new("db/database.db")
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
            return 1 
        else 
            flash[:notice] = "Every exercise wasn't logged!"
            return 2
        end
    end

    # Attempts to delete a row from the workouts table and workout_exercise_rel table
    #
    # @param [Integer] id The article's ID
    def workout_delete(id)
        db = SQLite3::Database.new("db/database.db")
        db.execute("DELETE FROM workouts WHERE Id =?",id)
        db.execute("DELETE FROM workout_exercise_rel WHERE workout_id =?",id)
        flash[:notice] = "Workout was deleted"
    end
end