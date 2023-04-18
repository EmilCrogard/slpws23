
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

def get_exercises()
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    @result = db.execute("SELECT * FROM exercise_muscles_rel INNER JOIN exercise on exercise_muscles_rel.exercise_id = exercise.Id")
end

def new_exercise(title, content, muscle_id)
    db = SQLite3::Database.new("db/database.db")
    db.execute("INSERT INTO exercise (title, content) VALUES (?,?)",title, content)
    exercise_id = db.execute("SELECT Id FROM exercise WHERE title = ?",title)
    db.execute("INSERT INTO exercise_muscles_rel (exercise_id, muscle_id) VALUES (?,?)", exercise_id, muscle_id)
end

