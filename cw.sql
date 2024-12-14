-- -------------------------------
-- Creates and connects to database named "cw_1"
-- -------------------------------

IF EXISTS "cw_1"
    DELETE DATABASE "cw_1";

CREATE DATABASE "cw_1";

\c cw_1

-- -------------------------------
-- Table structure for branch
-- -------------------------------

DROP TABLE 
    IF EXISTS branch CASCADE;

CREATE TABLE branch (
    branch_id SERIAL PRIMARY KEY UNIQUE NOT NULL,
    address VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL, 
    capacity INT NOT NULL,
    facilities TEXT
);

-- -------------------------------
-- Table structure for staff
-- -------------------------------

DROP TABLE  
    IF EXISTS staff CASCADE;

CREATE TABLE staff (
        staff_id SERIAL PRIMARY KEY UNIQUE NOT NULL,
        branch_id INT NOT NULL,
        fname VARCHAR(30) NOT NULL,
        lname VARCHAR(30) NOT NULL,
        email VARCHAR(100) NOT NULL,
        phone VARCHAR(15) NOT NULL,
        hire_date DATE NOT NULL,
        is_manager BOOLEAN,
        valid_dbs BOOLEAN NOT NULL,
        FOREIGN KEY branch_id REFERENCES branch (branch_id)
    );

-- -------------------------------
-- Table structure for role
-- -------------------------------

DROP TABLE 
    IF EXISTS role;

CREATE TABLE 
    role (
        role_id SERIAL PRIMARY UNIQUE KEY NOT NULL,
        name VARCHAR(50) NOT NULL,
        description TEXT
    );

-- -------------------------------
-- Table structure for staff_assignments
-- -------------------------------

DROP TABLE  
    IF EXISTS staff_assignments;

CREATE TABLE staff_assigments (
    assignment_id SERIAL PRIMARY UNIQUE KEY NOT NULL,
    staff_id INT NOT NULL,
    branch_id INT NOT NULL,
    role_id INT NOT NULL,
    start_date DATE,
    end_date DATE,
    FOREIGN KEY staff_id REFERENCES staff (staff_id),
    FOREIGN KEY branch_id REFERENCES branch (branch_id),
    FOREIGN KEY role_id REFERENCES role (role_id)
);

-- -------------------------------
-- Table structure for course
-- -------------------------------

DROP TABLE 
    IF EXISTS course;

CREATE TABLE course (
    course_id SERIAL PRIMARY KEY NOT NULL,
    branch_id
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    academic_level ENUM('L4', 'L5', 'L6', 'L7') NOT NULL,
    duration DATE NOT NULL,
    FOREIGN KEY branch_id REFERENCES branch (branch_id)
)

-- -------------------------------
-- Table structure for student
-- -------------------------------

DROP TABLE
    IF EXISTS student;

CREATE TABLE student (
        student_id SERIAL PRIMARY UNIQUE KEY NOT NULL,
        branch_id INTEGER NOT NULL,
        name VARCHAR(50) NOT NULL,
        lname VARCHAR(50) NOT NULL,
        email VARCHAR(100) NOT NULL,
        phone VARCHAR(15) NOT NULL,
        dob DATE NOT NULL,
        FOREIGN KEY branch_id REFERENCES branch (branch_id)
);

-- -------------------------------
-- Table structure for module
-- -------------------------------

DROP TABLE
    IF EXISTS module;

CREATE TABLE module (
    module_id SERIAL PRIMARY KEY UNIQUE NOT NULL,
    course_id INT NOT NULL,
    student_id INT NOT NULL,
    name VARCHAR(100) UNIQUE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    duration DATE NOT NULL,
    subject_area ENUM(
        'Maths',
        'Applied Mathematics',
        'Statistics',
        'Discrete Mathematics',
        'English Literature',
        'English Language',
        'Poetry',
        'Combined Science',
        'Physics', 
        'Biology',
        'Chemistry',
        'History',
        'Geography',
        'Religious Studies',
        'Criminology'
    ) NOT NULL,
    credits INT,
    description TEXT,
    FOREIGN KEY course_id REFERENCES course (course_id),
    FOREIGN KEY student_id REFERENCES student (student_id)
);

-- -------------------------------------
-- Table structure for emergency_contact
-- -------------------------------------

DROP TABLE
    IF EXISTS emergency_contact;

CREATE TABLE emergency_contact (
    contact_id SERIAL PRIMARY KEY UNIQUE NOT NULL,
    student_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    relationship ENUM(
        'Parent',
        'Other Family Member',
        'Guardian',
        'Spouse',
        'Friend'
    ),
    phone VARCHAR(15),
    email VARCHAR(100),
    FOREIGN KEY student_id REFERENCES student (student_id)
);

-- -------------------------
-- Table structure for room
-- -------------------------

DROP TABLE
    IF EXISTS room;

CREATE TABLE room (
    room_id SERIAL PRIMARY KEY UNIQUE NOT NULL,
    number INT NOT NULL,
    capacity INT NOT NULL,
    type ENUM(
        'Classroom',
        'Lecture Hall',
        'Workshop',
        'Lab',
        'Tutorial Session'

    ) NOT NULL,
    facilities TEXT  
     
);





-- -------------------------
-- Functions Library
-- -------------------------

-- create duration field using update on functions
-- attending within room will use function to select student_id where 
