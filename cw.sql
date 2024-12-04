CREATE TABLE 
    staff(
        staff_id serial PRIMARY KEY NOT NULL,
        staff_name VARCHAR (50) NOT NULL,
        staff_lname VARCHAR (50) NOT NULL,
        staff_email VARCHAR(100) NOT NULL,
        hire_date DATE NOT NULL,
        branch_id INTEGER NOT NULL,
        FOREIGN KEY (branch_id) REFERENCES branch (branch_id)
        is_manager BOOLEAN NOT NULL,
    )

CREATE TABLE 
    role (
        role_id serial PRIMARY KEY NOT NULL,
        role_name VARCHAR(50) NOT NULL,
        description TEXT
    )

CREATE TABLE 
    staff_assigments (
        assigment_id serial PRIMARY KEY NOT NULL,
        staff_id INTEGER NOT NULL,
        branch_id INTEGER NOT NULL,
        role_id INTEGER NOT NULL,
        start_date DATE NOT NULL,
        end_date DATE
    )

CREATE TABLE 
    students (
        student_id serial PRIMARY KEY NOT NULL,
        student_name VARCHAR(50) NOT NULL,
        student_lname VARCHAR(50) NOT NULL,
        student_email VARCHAR(100) NOT NULL,
        student_phone VARCHAR(15) NOT NULL,
        student_dob DATE NOT NULL
        academic_level ENUM('L4', 'L5', 'L6', 'L7') NOT NULL,
        branch_id INTEGER NOT NULL
        FOREIGN KEY branch_id REFERENCES branch (branch_id),
        enrollemnt_date DATE NOT NULL
    )

CREATE TABLE 
    emergency_contact(
        contact_id serial PRIMARY KEY NOT NULL,
        student_id INT NOT NULL,
        FOREIGN KEY student_id REFERENCES students (student_id),
        full_name VARCHAR(100) NOT NULL,
        relationship VARCHAR(50) NOT NULL,
        emergency_phone VARCHAR(15) NOT NULL,
        emergency_email VARCHAR(100) NOT NULL
    )

CREATE TABLE
    courses(
        course_id serial PRIMARY KEY NOT NULL,
        course_name VARCHAR(100) NOT NULL,
        description TEXT,
        academic_level ENUM('L4', 'L5', 'L6', 'L7') NOT NULL,
        duration INTEGER NOT NULL,--years--
        branch_id INTEGER NOT NULL,
        FOREIGN KEY branch_id REFERENCES branch (branch_id)
    )

CREATE TABLE
    modules(
        module_id serial PRIMARY KEY NOT NULL,
        course_id INTEGER NOT NULL,
        FOREIGN KEY course_id REFERENCES courses (course_id),
        module_name VARCHAR(50) NOT NULL,
        subject_area ENUM
    )