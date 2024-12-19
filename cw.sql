-------------------
-- Creates and connects to database named "cw_1"
-- -------------------------------

IF EXISTS "cw_1"
    DELETE DATABASE "cw_1";

CREATE DATABASE "cw_1";

\c cw_1

--Drops tables if needed--
DROP TABLE IF EXISTS 
    role, staff_assignments, staff, branch, course, room, session, 
    student, module, feedback, student_feedback, emergency_contact 
CASCADE;

--Create the ENUM types for the tables--
CREATE TYPE rating_enum AS ENUM ('Excellent', 'Good', 'Average', 'Poor');
CREATE TYPE academic_level_enum AS ENUM ('L4', 'L5', 'L6', 'L7');
CREATE TYPE role_enum AS ENUM ('Manager', 'Instructor', 'Support', 'Technician');
CREATE TYPE relationship_enum AS ENUM ('Parent', 'Other Family Member', 'Guardian', 'Spouse', 'Friend');
CREATE TYPE session_type_enum AS ENUM ('Classroom', 'Lecture Hall', 'Workshop', 'Lab', 'Tutorial Session');
CREATE TYPE subject_area_enum AS ENUM (
    'Maths', 'Applied Mathematics', 'Statistics', 'Discrete Mathematics', 'English Literature',
    'English Language', 'Poetry', 'Combined Science', 'Physics', 'Biology', 'Chemistry', 
    'History', 'Geography', 'Religious Studies', 'Criminology'
);

-- -------------------------------
-- Table structure for branch
-- -------------------------------
CREATE TABLE branch (
    branch_id SERIAL PRIMARY KEY NOT NULL,
    name VARCHAR(50) NOT NULL,
    address VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL, 
    capacity INT NOT NULL,
    facilities TEXT
);

-- -------------------------------
-- Table structure for staff
-- -------------------------------
CREATE TABLE staff (
        staff_id SERIAL PRIMARY KEY NOT NULL,
        branch_id INT NOT NULL,
        fname VARCHAR(30) NOT NULL,
        lname VARCHAR(30) NOT NULL,
        email VARCHAR(100) NOT NULL,
        phone VARCHAR(15) NOT NULL,
        hire_date DATE NOT NULL,
        is_manager BOOLEAN,
        valid_dbs BOOLEAN NOT NULL,
        FOREIGN KEY (branch_id) REFERENCES branch (branch_id),
        UNIQUE (email, phone)
    );

-- -------------------------------
-- Table structure for role
-- -------------------------------
CREATE TABLE 
    role (
        role_id SERIAL PRIMARY KEY NOT NULL,
        name VARCHAR(50) NOT NULL,
        description TEXT
    );

-- -------------------------------
-- Table structure for staff_assignments
-- -------------------------------
CREATE TABLE staff_assignments (
    assignment_id SERIAL PRIMARY KEY NOT NULL,
    staff_id INT NOT NULL,
    branch_id INT NOT NULL,
    role_id INT NOT NULL,
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (staff_id) REFERENCES staff (staff_id),
    FOREIGN KEY (branch_id) REFERENCES branch (branch_id),
    FOREIGN KEY (role_id) REFERENCES role (role_id),
);

-- -------------------------------
-- Table structure for course
-- -------------------------------
CREATE TABLE course (
    course_id SERIAL PRIMARY KEY NOT NULL,
    branch_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    academic_level academic_level_enum NOT NULL,
    duration INT NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES branch (branch_id),
    UNIQUE (name)
);

-- -------------------------------
-- Table structure for student
-- -------------------------------
CREATE TABLE student (
    student_id SERIAL PRIMARY KEY NOT NULL,
    branch_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    lname VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    dob DATE NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES branch (branch_id),
    UNIQUE (email, phone)
);

-- -------------------------------
-- Table structure for module
-- -------------------------------
CREATE TABLE module (
    module_id SERIAL PRIMARY KEY NOT NULL, 
    course_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    duration TEXT,
    subject_area subject_area_enum NOT NULL,
    credits INT,
    description TEXT,
    FOREIGN KEY (course_id) REFERENCES course (course_id),
    UNIQUE (name)
);

-- -------------------------------------
-- Table structure for emergency_contact
-- -------------------------------------
CREATE TABLE emergency_contact (
    contact_id SERIAL PRIMARY KEY NOT NULL,
    student_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    relationship relationship_enum NOT NULL,
    phone VARCHAR(15),
    email VARCHAR(100),
    FOREIGN KEY (student_id) REFERENCES student (student_id)
);

-- -------------------------
-- Table structure for room
-- -------------------------
CREATE TABLE room (
    room_id SERIAL PRIMARY KEY NOT NULL,
    number INT NOT NULL,
    capacity INT NOT NULL,
    type session_type_enum NOT NULL,
    facilities TEXT,
    UNIQUE (number)
);


-- -------------------------
-- Table structure for session
-- -------------------------
CREATE TABLE session (
    session_id SERIAL PRIMARY KEY NOT NULL,
    module_id INT NOT NULL,
    staff_id INT NOT NULL,
    number INT NOT NULL,
    session_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    FOREIGN KEY (module_id) REFERENCES module (module_id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES staff (staff_id) ON DELETE CASCADE,
    FOREIGN KEY (number) REFERENCES room (number) ON DELETE CASCADE,
    CHECK (start_time < end_time),
    UNIQUE (number)
);

-- -------------------------
-- Table structure for feedback
-- -------------------------
CREATE TABLE feedback (
    feedback_id SERIAL PRIMARY KEY,
    rating rating_enum NOT NULL,
    comments TEXT,
    date_submitted DATE NOT NULL DEFAULT CURRENT_DATE,
    session_id INT NOT NULL,
    FOREIGN KEY (session_id) REFERENCES session (session_id) ON DELETE CASCADE,
);

-- -------------------------
-- Table structure student_feedback
-- -------------------------
CREATE TABLE student_feedback (
    feedback_id INT NOT NULL,
    student_id INT NOT NULL,
    PRIMARY KEY (feedback_id, student_id),
    FOREIGN KEY (feedback_id) REFERENCES feedback (feedback_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES student (student_id) ON DELETE CASCADE
);


INSERT INTO branch (name, address, region, capacity, facilities)
VALUES
('London Branch', '123 Main Street, London', 'Greater London', 100, 'Parking, Cafeteria, Library'),
('Manchester Branch', '45 High Street, Manchester', 'Greater Manchester', 150, 'Library, Gym, Workshop Facilities'),
('Birmingham Branch', '678 Elm Avenue, Birmingham', 'West Midlands', 120, 'Lecture Halls, IT Labs, Cafeteria'),
('Leeds Branch', '90 Church Road, Leeds', 'West Yorkshire', 110, 'Parking, Gym, Cafeteria'),
('Glasgow Branch', '11 King Street, Glasgow', 'Glasgow City', 80, 'Library, Cafeteria'),
('Bristol Branch', '555 Market Lane, Bristol', 'South West', 140, 'Lecture Halls, IT Labs, Cafeteria'),
('Liverpool Branch', '78 Queensway, Liverpool', 'Merseyside', 130, 'Gym, Library, Parking'),
('Edinburgh Branch', '89 St. Andrew’s Street, Edinburgh', 'Edinburgh', 95, 'Cafeteria, IT Labs'),
('Cardiff Branch', '321 Green Road, Cardiff', 'Wales', 90, 'Library, Gym, Parking'),
('Belfast Branch', '101 North Avenue, Belfast', 'Northern Ireland', 85, 'IT Labs, Workshop Facilities');

INSERT INTO staff (branch_id, fname, lname, email, phone, hire_date, is_manager, valid_dbs)
VALUES
(1, 'John', 'Smith', 'john.smith@port.ac.uk', '07123456789', '2018-02-14', TRUE, TRUE),   -- Branch 1: London
(1, 'Emily', 'Brown', 'emily.brown@port.ac.uk', '07123456790', '2020-06-25', FALSE, TRUE),
(1, 'Michael', 'Taylor', 'michael.taylor@port.ac.uk', '07123456791', '2021-04-10', FALSE, TRUE),
(1, 'Sarah', 'Johnson', 'sarah.johnson@port.ac.uk', '07123456792', '2021-12-01', FALSE, TRUE),

(2, 'Sarah', 'Jones', 'sarah.jones@port.ac.uk', '07123456793', '2019-11-05', TRUE, TRUE),  -- Branch 2: Manchester
(2, 'James', 'Wilson', 'james.wilson@port.ac.uk', '07123456794', '2020-07-15', FALSE, TRUE),
(2, 'Sophia', 'Davis', 'sophia.davis@port.ac.uk', '07123456795', '2021-09-01', FALSE, TRUE),
(2, 'Liam', 'Taylor', 'liam.taylor@port.ac.uk', '07123456796', '2022-01-20', FALSE, TRUE),

(3, 'David', 'White', 'david.white@port.ac.uk', '07123456797', '2019-03-20', TRUE, TRUE),  -- Branch 3: Birmingham
(3, 'Olivia', 'Thomas', 'olivia.thomas@port.ac.uk', '07123456798', '2020-10-30', FALSE, TRUE),
(3, 'Matthew', 'Green', 'matthew.green@port.ac.uk', '07123456799', '2021-12-12', FALSE, TRUE),
(3, 'Rachel', 'Adams', 'rachel.adams@port.ac.uk', '07123456800', '2022-03-01', FALSE, TRUE),

(4, 'Emma', 'Hall', 'emma.hall@port.ac.uk', '07123456801', '2022-01-05', TRUE, TRUE),     -- Branch 4: Leeds
(4, 'Daniel', 'Harris', 'daniel.harris@port.ac.uk', '07123456802', '2020-08-18', FALSE, TRUE),
(4, 'Charlotte', 'Martinez', 'charlotte.martinez@port.ac.uk', '07123456803', '2021-11-25', FALSE, TRUE),
(4, 'Benjamin', 'Clark', 'benjamin.clark@port.ac.uk', '07123456804', '2021-05-30', FALSE, TRUE),

(5, 'William', 'Lopez', 'william.lopez@port.ac.uk', '07123456805', '2020-02-10', TRUE, TRUE), -- Branch 5: Glasgow
(5, 'Mia', 'Lee', 'mia.lee@port.ac.uk', '07123456806', '2021-03-28', FALSE, TRUE),
(5, 'Christopher', 'Clark', 'christopher.clark@port.ac.uk', '07123456807', '2022-07-13', FALSE, TRUE),
(5, 'Sophie', 'Rodriguez', 'sophie.rodriguez@port.ac.uk', '07123456808', '2022-11-01', FALSE, TRUE),

(6, 'Elizabeth', 'Lewis', 'elizabeth.lewis@port.ac.uk', '07123456809', '2019-05-07', TRUE, TRUE), -- Branch 6: Bristol
(6, 'Benjamin', 'Walker', 'benjamin.walker@port.ac.uk', '07123456810', '2020-09-22', FALSE, TRUE),
(6, 'Ella', 'Young', 'ella.young@port.ac.uk', '07123456811', '2021-10-09', FALSE, TRUE),
(6, 'Olivia', 'Miller', 'olivia.miller@port.ac.uk', '07123456812', '2022-06-10', FALSE, TRUE),

(7, 'Alexander', 'King', 'alexander.king@port.ac.uk', '07123456813', '2020-01-16', TRUE, TRUE), -- Branch 7: Liverpool
(7, 'Grace', 'Scott', 'grace.scott@port.ac.uk', '07123456814', '2021-04-23', FALSE, TRUE),
(7, 'Ethan', 'Turner', 'ethan.turner@port.ac.uk', '07123456815', '2021-07-05', FALSE, TRUE),
(7, 'Isabella', 'Wright', 'isabella.wright@port.ac.uk', '07123456816', '2022-02-14', FALSE, TRUE),

(8, 'Samuel', 'Hill', 'samuel.hill@port.ac.uk', '07123456817', '2022-02-19', TRUE, TRUE), -- Branch 8: Edinburgh
(8, 'Ava', 'Adams', 'ava.adams@port.ac.uk', '07123456818', '2021-06-30', FALSE, TRUE),
(8, 'Oliver', 'Davis', 'oliver.davis@port.ac.uk', '07123456819', '2021-08-25', FALSE, TRUE),
(8, 'Emma', 'Taylor', 'emma.taylor@port.ac.uk', '07123456820', '2022-03-15', FALSE, TRUE),

(9, 'Ethan', 'Mitchell', 'ethan.mitchell@port.ac.uk', '07123456821', '2020-03-12', TRUE, TRUE), -- Branch 9: Cardiff
(9, 'Isabella', 'Perez', 'isabella.perez@port.ac.uk', '07123456822', '2021-09-15', FALSE, TRUE),
(9, 'Jack', 'Carter', 'jack.carter@port.ac.uk', '07123456823', '2021-11-01', FALSE, TRUE),
(9, 'Lily', 'Brown', 'lily.brown@port.ac.uk', '07123456824', '2022-04-10', FALSE, TRUE),

(10, 'William', 'Clark', 'william.clark@port.ac.uk', '07123456825', '2020-01-12', TRUE, TRUE), -- Branch 10: Belfast
(10, 'Mia', 'Lopez', 'mia.lopez@port.ac.uk', '07123456826', '2021-08-05', FALSE, TRUE),
(10, 'Benjamin', 'Lewis', 'benjamin.lewis@port.ac.uk', '07123456827', '2022-02-15', FALSE, TRUE),
(10, 'Charlotte', 'Walker', 'charlotte.walker@port.ac.uk', '07123456828', '2022-06-05', FALSE, TRUE);


INSERT INTO role (name, description)
VALUES
('Branch Manager', 'Oversees the branch operations and ensures the delivery of educational services.'), --branch manager, admin priveleges--
('Academic Lecturer', 'Delivers academic content and assesses students across L4-L7 programs.'),
('Program Coordinator', 'Manages academic programs and ensures quality standards are met.'),
('Module Leader', 'Coordinates and develops academic modules.'), --module leader, select & update priveleges--
('Academic Advisor', 'Guides students in educational planning and academic progress.'),
('Career Counselor', 'Provides career advice and supports job placement for students.'),
('Resource Specialist', 'Manages library resources and integrates digital tools.'),
('Facilities Support Staff', 'Handles cleaning and maintenance of the branch facilities.'),
('Educational Technologist', 'Supports the use of technology in education and maintains IT systems.'),
('Student Engagement Officer', 'Enhances student experience through events and initiatives.'),
('Vocational Trainer', 'Delivers hands-on vocational training to students.'),
('Marketing Specialist', 'Promotes SES programs and attracts students through marketing strategies.'),
('Finance Officer', 'Manages branch budgets, financial records, and payroll.'),
('STEM Specialist', 'Focuses on STEM education and interdisciplinary projects.'),
('Hospitality Coordinator', 'Handles food services and event catering for the branch.'),
('Facilities Manager', 'Oversees maintenance and management of facilities.'),
('Content Integration Specialist', 'Ensures smooth integration between the database and content management systems.'),
('Student Welfare Officer', 'Addresses student well-being and provides personal support.'),
('Receptionist', 'Manages front-desk operations and administrative support.');


INSERT INTO staff_assignments (staff_id, branch_id, role_id, start_date, end_date)
VALUES
-- Assignments for Branch 1: London
(1, 1, 1, '2022-01-01', NULL),   --manager
(2, 1, 2, '2022-01-15', NULL),  
(3, 1, 3, '2023-03-01', NULL),   
(4, 1, 4, '2022-02-01', NULL),   --module leader

-- Assignments for Branch 2: Manchester
(5, 2, 1, '2021-12-01', NULL),   --manager
(6, 2, 2, '2022-01-10', NULL),   
(7, 2, 4, '2023-06-01', NULL),   --module leader
(8, 2, 12, '2023-02-15', NULL),  

-- Assignments for Branch 3: Birmingham
(9, 3, 1, '2022-04-01', NULL),   --manager
(10, 3, 2, '2023-01-20', NULL),  
(11, 3, 7, '2023-03-10', NULL),  
(12, 3, 4, '2022-11-01', NULL),  --module leader

-- Assignments for Branch 4: Leeds
(13, 4, 1, '2021-10-01', NULL),  --manager
(14, 4, 3, '2022-02-01', NULL),  
(15, 4, 4, '2023-01-01', NULL), --module leader
(16, 4, 5, '2022-09-01', NULL),  

-- Assignments for Branch 5: Glasgow
(17, 5, 1, '2021-07-01', NULL),  --manager
(18, 5, 2, '2022-12-01', NULL),  
(19, 5, 5, '2022-03-01', NULL),  
(20, 5, 4, '2022-06-01', NULL),  --module leader

-- Assignments for Branch 6: Bristol
(21, 6, 1, '2023-01-01', NULL),  --manager
(22, 6, 4, '2023-02-01', NULL),  --module leader
(23, 6, 13, '2023-03-01', NULL), 
(24, 6, 5, '2022-06-10', NULL),  

-- Assignments for Branch 7: Liverpool
(25, 7, 1, '2023-05-01', NULL),  --manager
(26, 7, 4, '2023-04-01', NULL),  --module leader
(27, 7, 1, '2023-06-01', NULL), 
(28, 7, 2, '2023-07-01', NULL), 

-- Assignments for Branch 8: Edinburgh
(29, 8, 4, '2023-07-01', NULL),  --module leader
(30, 8, 3, '2023-08-01', NULL),  
(31, 8, 1, '2023-09-01', NULL),  --manager
(32, 8, 5, '2023-10-01', NULL),  

-- Assignments for Branch 9: Cardiff
(33, 9, 1, '2023-10-01', NULL),  --manager
(34, 9, 4, '2023-11-01', NULL),  --module leader
(35, 9, 2, '2023-12-01', NULL),  
(36, 9, 6, '2024-01-01', NULL),  

-- Assignments for Branch 10: Belfast
(37, 10, 1, '2024-01-01', NULL),  --manager
(38, 10, 2, '2024-02-01', NULL),  
(39, 10, 5, '2024-03-01', NULL),  
(40, 10, 4, '2024-04-01', NULL); --module leader


INSERT INTO course (branch_id, name, description, academic_level, duration)
VALUES
-- Courses for Branch 1: London
(1, 'Advanced Mathematics', 'Comprehensive course in advanced mathematical theories and applications.', 'L6', '180 Days'),
(1, 'Creative Writing', 'Exploring fiction, poetry, and creative nonfiction.', 'L5', '120 Days'),
(1, 'Business Management', 'Foundations of managing businesses in competitive environments.', 'L7', '240 Days'),

-- Courses for Branch 2: Manchester
(2, 'Data Science Fundamentals', 'Introduction to data analytics, machine learning, and visualization.', 'L6', '200 Days'),
(2, 'History of Modern Europe', 'Critical analysis of European history from 1800 to present.', 'L5', '180 Days'),
(2, 'Marketing Strategies', 'Techniques for effective marketing in a digital world.', 'L7', '150 Days'),

-- Courses for Branch 3: Birmingham
(3, 'Software Development', 'Advanced programming and systems design principles.', 'L6', '200 Days'),
(3, 'Physics in Everyday Life', 'Understanding the principles of physics through real-world applications.', 'L5', '180 Days'),
(3, 'Health and Social Care', 'Preparing for careers in healthcare and community services.', 'L4', '160 Days'),

-- Courses for Branch 4: Leeds
(4, 'Environmental Science', 'Study of environmental systems, sustainability, and conservation.', 'L6', '180 Days'),
(4, 'Introduction to Criminology', 'Fundamentals of criminological theory and criminal justice.', 'L4', '150 Days'),
(4, 'Entrepreneurship and Innovation', 'Creating and managing innovative businesses.', 'L7', '210 Days'),

-- Courses for Branch 5: Glasgow
(5, 'Biological Sciences', 'Comprehensive overview of modern biology and research methods.', 'L5', '180 Days'),
(5, 'English Literature', 'In-depth study of classic and modern English literary works.', 'L6', '200 Days'),
(5, 'Vocational Training: Electrician', 'Hands-on training for becoming a certified electrician.', 'L4', '140 Days'),

-- Courses for Branch 6: Bristol
(6, 'Cybersecurity', 'Advanced techniques for protecting information systems.', 'L7', '220 Days'),
(6, 'Applied Statistics', 'Practical applications of statistics in various industries.', 'L5', '180 Days'),
(6, 'Educational Leadership', 'Developing leadership skills for academic institutions.', 'L7', '240 Days'),

-- Courses for Branch 7: Liverpool
(7, 'Graphic Design', 'Introduction to digital and traditional design techniques.', 'L5', '150 Days'),
(7, 'Engineering Principles', 'Study of mechanical, electrical, and civil engineering fundamentals.', 'L6', '210 Days'),
(7, 'Psychology Basics', 'Understanding human behavior and mental processes.', 'L4', '120 Days'),

-- Courses for Branch 8: Edinburgh
(8, 'Artificial Intelligence', 'Deep dive into AI, machine learning, and neural networks.', 'L7', '200 Days'),
(8, 'World Literature', 'Exploring literary works from across the globe.', 'L6', '180 Days'),
(8, 'Hospitality Management', 'Training for careers in the hospitality industry.', 'L5', '160 Days'),

-- Courses for Branch 9: Cardiff
(9, 'Geography and Climate Change', 'Study of geographical patterns and climate change impacts.', 'L6', '190 Days'),
(9, 'Introduction to Poetry', 'Understanding and creating poetic works.', 'L4', '130 Days'),
(9, 'Project Management', 'Mastering project planning and execution.', 'L7', '180 Days'),

-- Courses for Branch 10: Belfast
(10, 'Public Speaking and Communication', 'Improving confidence and effectiveness in public speaking.', 'L4', '120 Days'),
(10, 'Bio-information', 'Integrating biology and computational methods for research.', 'L6', '210 Days'),
(10, 'Ethics in Business', 'Understanding ethical challenges in modern business.', 'L7', '200 Days');


INSERT INTO student (branch_id, name, lname, email, phone, dob)
VALUES
(1, 'John', 'Smith', 'up2196830@myport.ac.uk', '07123456789', '1998-05-14'),
(1, 'Emily', 'Brown', 'up2429146@myport.ac.uk', '07123456790', '2000-08-20'),
(1, 'Michael', 'Taylor', 'up2573533@myport.ac.uk', '07123456791', '1999-02-12'),
(1, 'Sarah', 'Jones', 'up2082731@myport.ac.uk', '07123456792', '2001-11-05'),
(1, 'James', 'Wilson', 'up2954200@myport.ac.uk', '07123456793', '1997-06-25'),
(1, 'Sophia', 'Davis', 'up2237307@myport.ac.uk', '07123456794', '2002-09-15'),
(2, 'David', 'White', 'up2653061@myport.ac.uk', '07123456795', '1998-03-20'),
(2, 'Olivia', 'Thomas', 'up2825965@myport.ac.uk', '07123456796', '2000-10-30'),
(2, 'Matthew', 'Green', 'up2677738@myport.ac.uk', '07123456797', '1999-12-12'),
(2, 'Emma', 'Hall', 'up2473010@myport.ac.uk', '07123456798', '2001-01-05'),
(2, 'Daniel', 'Harris', 'up2201345@myport.ac.uk', '07123456799', '2000-08-18'),
(2, 'Charlotte', 'Martinez', 'up2958721@myport.ac.uk', '07123456800', '2001-11-25'),
(3, 'William', 'Lopez', 'up2531959@myport.ac.uk', '07123456801', '1997-02-10'),
(3, 'Mia', 'Lee', 'up2709382@myport.ac.uk', '07123456802', '1999-03-28'),
(3, 'Christopher', 'Clark', 'up2364814@myport.ac.uk', '07123456803', '2002-07-13'),
(3, 'Elizabeth', 'Lewis', 'up2615228@myport.ac.uk', '07123456804', '1999-05-07'),
(3, 'Benjamin', 'Walker', 'up2498746@myport.ac.uk', '07123456805', '2001-09-22'),
(3, 'Ella', 'Young', 'up2897513@myport.ac.uk', '07123456806', '2000-10-09'),
(4, 'Alexander', 'King', 'up2594480@myport.ac.uk', '07123456807', '1998-01-16'),
(4, 'Grace', 'Scott', 'up2432905@myport.ac.uk', '07123456808', '2001-04-23'),
(4, 'Samuel', 'Hill', 'up2745367@myport.ac.uk', '07123456809', '2000-02-19'),
(4, 'Ava', 'Adams', 'up2583993@myport.ac.uk', '07123456810', '1999-06-30'),
(4, 'Ethan', 'Mitchell', 'up2076431@myport.ac.uk', '07123456811', '2000-03-12'),
(4, 'Isabella', 'Perez', 'up2768419@myport.ac.uk', '07123456812', '2001-09-15'),
(5, 'Jack', 'Carter', 'up2511294@myport.ac.uk', '07123456813', '1999-11-01'),
(5, 'Olivia', 'Walker', 'up2278705@myport.ac.uk', '07123456814', '2000-04-22'),
(5, 'Sophia', 'Davis', 'up2661674@myport.ac.uk', '07123456815', '2001-05-30'),
(5, 'David', 'White', 'up2405847@myport.ac.uk', '07123456816', '2000-08-01'),
(5, 'Charlotte', 'Martinez', 'up2795760@myport.ac.uk', '07123456817', '1999-02-15'),
(5, 'Matthew', 'Green', 'up2683438@myport.ac.uk', '07123456818', '2002-03-20'),
(6, 'Jack', 'Carter', 'up2501740@myport.ac.uk', '07123456819', '1999-10-01'),
(6, 'David', 'White', 'up2670215@myport.ac.uk', '07123456820', '1999-12-12'),
(6, 'Michael', 'Taylor', 'up2490124@myport.ac.uk', '07123456821', '1998-07-13'),
(6, 'Sophia', 'Davis', 'up2461322@myport.ac.uk', '07123456822', '2001-08-01'),
(6, 'Olivia', 'Thomas', 'up2392749@myport.ac.uk', '07123456823', '2002-02-11'),
(6, 'Grace', 'Scott', 'up2589389@myport.ac.uk', '07123456824', '2000-03-18'),
(7, 'Emma', 'Hall', 'up2556805@myport.ac.uk', '07123456825', '2002-01-05'),
(7, 'Sophia', 'Davis', 'up2613789@myport.ac.uk', '07123456826', '1999-10-05'),
(7, 'David', 'White', 'up2327411@myport.ac.uk', '07123456827', '2000-12-15'),
(7, 'James', 'Wilson', 'up2765124@myport.ac.uk', '07123456828', '2001-08-10'),
(7, 'Matthew', 'Green', 'up2176140@myport.ac.uk', '07123456829', '1999-07-25'),
(7, 'Charlotte', 'Martinez', 'up2634809@myport.ac.uk', '07123456830', '2000-01-12'),
(8, 'Isabella', 'Perez', 'up2798253@myport.ac.uk', '07123456831', '1998-02-14'),
(8, 'Benjamin', 'Walker', 'up2736350@myport.ac.uk', '07123456832', '2001-11-19'),
(8, 'Grace', 'Scott', 'up2694217@myport.ac.uk', '07123456833', '2000-08-20'),
(8, 'Charlotte', 'Martinez', 'up2366723@myport.ac.uk', '07123456834', '1998-07-04'),
(8, 'David', 'White', 'up2465698@myport.ac.uk', '07123456835', '2001-05-16'),
(8, 'Ethan', 'Mitchell', 'up2482043@myport.ac.uk', '07123456836', '2000-09-22'),
(9, 'James', 'Wilson', 'up2900467@myport.ac.uk', '07123456837', '1999-01-06'),
(9, 'Olivia', 'Thomas', 'up2580349@myport.ac.uk', '07123456838', '2000-05-09'),
(9, 'Sophia', 'Davis', 'up2574931@myport.ac.uk', '07123456839', '2001-12-15'),
(9, 'Emma', 'Hall', 'up2427743@myport.ac.uk', '07123456840', '1999-09-29'),
(9, 'David', 'White', 'up2570836@myport.ac.uk', '07123456841', '2001-02-01'),
(9, 'Charlotte', 'Martinez', 'up2659182@myport.ac.uk', '07123456842', '1999-04-12'),
(10, 'Olivia', 'Thomas', 'up2730134@myport.ac.uk', '07123456843', '2001-08-23'),
(10, 'Sophia', 'Davis', 'up2710248@myport.ac.uk', '07123456844', '2002-06-18'),
(10, 'Grace', 'Scott', 'up2438017@myport.ac.uk', '07123456845', '2001-01-25'),
(10, 'David', 'White', 'up2477594@myport.ac.uk', '07123456846', '2000-11-11'),
(10, 'Ethan', 'Mitchell', 'up2724025@myport.ac.uk', '07123456847', '1999-04-06'),
(10, 'Benjamin', 'Walker', 'up2602534@myport.ac.uk', '07123456848', '2002-03-17'),
(10, 'Liam', 'Smith', 'up2749083@myport.ac.uk', '07123456849', '1999-07-22'),
(10, 'Charlotte', 'Brown', 'up2662154@myport.ac.uk', '07123456850', '2001-02-14'),
(10, 'Zoe', 'Wilson', 'up2827304@myport.ac.uk', '07123456851', '2000-03-09'),
(10, 'Lucas', 'Adams', 'up2763125@myport.ac.uk', '07123456852', '1998-11-13'),
(10, 'Ella', 'Evans', 'up2548190@myport.ac.uk', '07123456853', '2002-05-22'),
(10, 'Oliver', 'Harris', 'up2892413@myport.ac.uk', '07123456854', '1999-12-04'),
(10, 'Mia', 'Jackson', 'up2749086@myport.ac.uk', '07123456855', '2000-01-30'),
(10, 'Aiden', 'Lee', 'up2592081@myport.ac.uk', '07123456856', '2002-11-17'),
(10, 'Lily', 'Martin', 'up2830199@myport.ac.uk', '07123456857', '1999-03-10'),
(10, 'Jacob', 'King', 'up2613742@myport.ac.uk', '07123456858', '2000-06-26');

INSERT INTO module (course_id, name, start_date, end_date, duration, subject_area, credits, description)
VALUES
-- Maths
(1, 'Introduction to Algebra', '2024-01-10', '2024-06-10', "5 Months", 'Maths', 20, 'An introductory course on algebraic concepts, including equations and inequalities.'),
(1, 'Calculus I', '2024-02-15', '2024-07-15', "5 Months", 'Maths', 25, 'A foundational module on calculus focusing on limits, derivatives, and integration.'),
(1, 'Linear Algebra', '2024-03-01', '2024-08-01', "5 Months", 'Maths', 20, 'A study of vector spaces, matrices, and linear transformations.'),
(1, 'Discrete Mathematics', '2024-04-01', '2024-09-01', "5 Months", 'Maths', 22, 'An introduction to discrete structures, combinatorics, and graph theory.'),
(1, 'Differential Equations', '2024-05-10', '2024-10-10', "5 Months", 'Maths', 23, 'An advanced course on solving ordinary differential equations and their applications.'),
(1, 'Mathematical Proofs', '2024-06-15', '2024-11-15', "5 Months", 'Maths', 20, 'A module focusing on the principles and techniques of mathematical proof writing.'),

-- Applied Mathematics
(2, 'Applied Calculus', '2024-02-10', '2024-07-10', "5 Months", 'Applied Mathematics', 24, 'A course that applies calculus to real-world problems in engineering and physics.'),
(2, 'Numerical Methods', '2024-03-01', '2024-08-01', "5 Months", 'Applied Mathematics', 25, 'An exploration of numerical techniques used in solving complex mathematical problems.'),
(2, 'Optimization Methods', '2024-04-05', '2024-09-05', "5 Months", 'Applied Mathematics', 23, 'A study of mathematical optimization techniques in various scientific fields.'),
(2, 'Mathematical Modelling', '2024-05-01', '2024-10-01', "5 Months", 'Applied Mathematics', 25, 'A course on creating and analyzing mathematical models for real-world scenarios.'),
(2, 'Probability Theory', '2024-06-01', '2024-11-01', "5 Months", 'Applied Mathematics', 22, 'A course on the fundamental principles of probability theory and its applications.'),
(2, 'Complex Variables', '2024-07-01', '2024-12-01', "5 Months", 'Applied Mathematics', 24, 'An advanced course on functions of a complex variable and their applications.'),

-- Statistics
(3, 'Introduction to Statistics', '2024-01-10', '2024-06-10', "5 Months", 'Statistics', 20, 'A beginner module on basic statistical concepts such as mean, median, and standard deviation.'),
(3, 'Probability and Statistics', '2024-02-15', '2024-07-15', "5 Months", 'Statistics', 22, 'A deeper look into probability distributions, hypothesis testing, and confidence intervals.'),
(3, 'Regression Analysis', '2024-03-01', '2024-08-01', "5 Months", 'Statistics', 21, 'A course on statistical modeling techniques such as linear regression and logistic regression.'),
(3, 'Time Series Analysis', '2024-04-01', '2024-09-01', "5 Months", 'Statistics', 23, 'A module that covers techniques for analyzing data points in time-dependent sequences.'),
(3, 'Statistical Inference', '2024-05-01', '2024-10-01', "5 Months", 'Statistics', 24, 'A course focused on methods of making inferences from sample data, including estimation and hypothesis testing.'),
(3, 'Multivariate Statistics', '2024-06-01', '2024-11-01', "5 Months", 'Statistics', 25, 'An advanced module covering the analysis of multiple variables simultaneously, including principal component analysis.'),

-- Discrete Mathematics
(4, 'Logic and Set Theory', '2024-01-10', '2024-06-10',"5 Months", 'Discrete Mathematics', 20, 'A study of formal logic, sets, and relations, with applications in computer science.'),
(4, 'Graph Theory', '2024-02-10', '2024-07-10',"5 Months", 'Discrete Mathematics', 22, 'An introduction to graph theory and its applications in algorithms and networking.'),
(4, 'Combinatorics', '2024-03-01', '2024-08-01',"5 Months", 'Discrete Mathematics', 20, 'A course on combinatorial mathematics, including counting principles and binomial coefficients.'),
(4, 'Algorithms and Complexity', '2024-04-05', '2024-09-05',"5 Months", 'Discrete Mathematics', 25, 'A module on algorithmic problem solving and the complexity of computational tasks.'),
(4, 'Coding Theory', '2024-05-01', '2024-10-01',"5 Months", 'Discrete Mathematics', 23, 'A course focused on error detection and correction in communication systems.'),
(4, 'Automata Theory', '2024-06-01', '2024-11-01',"5 Months", 'Discrete Mathematics', 24, 'An introduction to the theory of automata, languages, and computation.'),

-- English Literature
(5, 'English Poetry from the 18th Century', '2024-01-10', '2024-06-10',"5 Months", 'English Literature', 22, 'An analysis of 18th-century poetry, exploring key poets like William Blake and Alexander Pope.'),
(5, 'Victorian Novelists', '2024-02-15', '2024-07-15',"5 Months", 'English Literature', 20, 'A module on the works of Victorian novelists such as Charles Dickens and the Brontë sisters.'),
(5, 'Shakespearean Drama', '2024-03-01', '2024-08-01',"5 Months", 'English Literature', 23, 'An in-depth study of Shakespeare’s major plays, including historical and contemporary interpretations.'),
(5, 'Modernist Literature', '2024-04-01', '2024-09-01',"5 Months", 'English Literature', 25, 'A course on modernist authors like James Joyce, Virginia Woolf, and T.S. Eliot.'),
(5, 'Romantic Poetry', '2024-05-01', '2024-10-01',"5 Months", 'English Literature', 22, 'A study of Romantic poets, including Wordsworth, Keats, and Shelley, focusing on their poetic techniques.'),
(5, 'American Literature', '2024-06-01', '2024-11-01',"5 Months", 'English Literature', 24, 'A course on the evolution of American literature from the 19th to the 20th century.'),

-- English Language
(6, 'Introduction to Linguistics', '2024-01-10', '2024-06-10',"5 Months", 'English Language', 20, 'A basic introduction to the study of language and linguistics.'),
(6, 'Phonetics and Phonology', '2024-02-10', '2024-07-10',"5 Months", 'English Language', 22, 'A study of speech sounds and their roles in spoken language.'),
(6, 'Syntax and Semantics', '2024-03-01', '2024-08-01',"5 Months", 'English Language', 20, 'A module covering sentence structure and meaning in English.'),
(6, 'Sociolinguistics', '2024-04-01', '2024-09-01',"5 Months", 'English Language', 23, 'An exploration of the relationship between language and society, focusing on dialects and language change.'),
(6, 'Pragmatics', '2024-05-01', '2024-10-01',"5 Months", 'English Language', 24, 'A study of how context influences meaning in language use.'),
(6, 'Discourse Analysis', '2024-06-01', '2024-11-01',"5 Months", 'English Language', 25, 'A course on analyzing language in use, focusing on conversation and written texts.'),

-- Poetry
(7, 'Modern Poetry', '2024-01-10', '2024-06-10',"5 Months", 'Poetry', 20, 'A study of modern poets such as W.B. Yeats, Sylvia Plath, and Langston Hughes.'),
(7, 'Poetry and Politics', '2024-02-10', '2024-07-10',"5 Months", 'Poetry', 22, 'An exploration of the relationship between poetry and political expression.'),
(7, 'Romantic Poetry - Part II', '2024-03-01', '2024-08-01',"5 Months", 'Poetry', 21, 'A module focusing on the poetry of the Romantic period, including works by Wordsworth and Keats.'),
(7, 'Poetry of War', '2024-04-01', '2024-09-01',"5 Months", 'Poetry', 23, 'A look at the portrayal of war in poetry, from ancient texts to contemporary works.'),
(7, 'Narrative Poetry', '2024-05-01', '2024-10-01',"5 Months", 'Poetry', 24, 'A course exploring narrative structures in poetry, including ballads and epics.'),
(7, 'Poetry and Music', '2024-06-01', '2024-11-01',"5 Months", 'Poetry', 25, 'A module examining the relationship between poetry and music in various cultures.'),

(8, 'General Chemistry', '2024-01-10', '2024-06-10',"5 Months", 'Combined Science', 20, 'An introductory course covering the basics of chemical reactions, elements, and compounds.'),
(8, 'Basic Physics', '2024-02-10', '2024-07-10',"5 Months", 'Combined Science', 22, 'An introduction to the fundamental concepts of physics including motion, energy, and forces.'),
(8, 'Biological Science', '2024-03-01', '2024-08-01',"5 Months", 'Combined Science', 21, 'A foundational course on cell biology, genetics, and human anatomy.'),
(8, 'Earth Science', '2024-04-01', '2024-09-01',"5 Months", 'Combined Science', 23, 'An exploration of the Earth’s geology, oceans, and atmosphere.'),
(8, 'Scientific Investigation', '2024-05-01', '2024-10-01',"5 Months", 'Combined Science', 20, 'A module focused on scientific methods, experimental design, and data analysis.'),
(8, 'Environmental Science', '2024-06-01', '2024-11-01',"5 Months", 'Combined Science', 24, 'A course on ecosystems, biodiversity, and sustainability issues in the environment.'),

-- Physics
(9, 'Mechanics', '2024-01-10', '2024-06-10',"5 Months", 'Physics', 20, 'A course on classical mechanics, including motion, forces, and energy.'),
(9, 'Electromagnetism', '2024-02-10', '2024-07-10',"5 Months", 'Physics', 22, 'An introduction to electric fields, magnetic fields, and electromagnetism.'),
(9, 'Thermodynamics', '2024-03-01', '2024-08-01',"5 Months", 'Physics', 21, 'A module covering the laws of thermodynamics and their applications in physical systems.'),
(9, 'Waves and Optics', '2024-04-01', '2024-09-01',"5 Months", 'Physics', 23, 'A study of the properties of waves, including sound and light, and the nature of optical systems.'),
(9, 'Quantum Mechanics', '2024-05-01', '2024-10-01',"5 Months", 'Physics', 25, 'A course introducing the fundamental principles of quantum theory and its real-world applications.'),
(9, 'Modern Physics', '2024-06-01', '2024-11-01',"5 Months", 'Physics', 24, 'A course on the theory and applications of special relativity and quantum mechanics.'),

-- Biology
(10, 'Cell Biology', '2024-01-10', '2024-06-10',"5 Months", 'Biology', 20, 'A module covering the structure and function of cells, including cell division and organelles.'),
(10, 'Genetics and Evolution', '2024-02-10', '2024-07-10',"5 Months", 'Biology', 22, 'A course on inheritance patterns, genetic disorders, and the principles of evolution.'),
(10, 'Human Anatomy', '2024-03-01', '2024-08-01',"5 Months", 'Biology', 21, 'An introduction to the human body, including organ systems, tissues, and their functions.'),
(10, 'Ecology and Conservation', '2024-04-01', '2024-09-01',"5 Months", 'Biology', 23, 'A study of ecosystems, biodiversity, and conservation efforts to protect endangered species.'),
(10, 'Microbiology', '2024-05-01', '2024-10-01',"5 Months", 'Biology', 20, 'A course on microorganisms, including bacteria, viruses, and fungi, and their impact on health.'),
(10, 'Plant Biology', '2024-06-01', '2024-11-01',"5 Months", 'Biology', 24, 'A module focusing on plant structure, photosynthesis, and plant reproduction.'),

-- Chemistry
(11, 'Organic Chemistry', '2024-01-10', '2024-06-10',"5 Months", 'Chemistry', 20, 'A study of carbon-based compounds, focusing on functional groups and reaction mechanisms.'),
(11, 'Inorganic Chemistry', '2024-02-10', '2024-07-10',"5 Months", 'Chemistry', 22, 'An introduction to non-carbon chemistry, including periodic table trends and inorganic compounds.'),
(11, 'Physical Chemistry', '2024-03-01', '2024-08-01',"5 Months", 'Chemistry', 21, 'A course on the principles of thermodynamics, kinetics, and chemical equilibria.'),
(11, 'Analytical Chemistry', '2024-04-01', '2024-09-01',"5 Months", 'Chemistry', 23, 'A module on techniques and methods for analyzing chemical substances.'),
(11, 'Biochemistry', '2024-05-01', '2024-10-01',"5 Months", 'Chemistry', 25, 'A course that explores the chemistry of biological molecules and biochemical reactions.'),
(11, 'Environmental Chemistry', '2024-06-01', '2024-11-01',"5 Months", 'Chemistry', 24, 'A study of the role of chemistry in environmental issues such as pollution and sustainability.'),

-- History
(12, 'Ancient Civilizations', '2024-01-10', '2024-06-10',"5 Months", 'History', 20, 'A module focusing on early human societies and their contributions to civilization.'),
(12, 'Medieval History', '2024-02-10', '2024-07-10',"5 Months", 'History', 22, 'An exploration of the Middle Ages, covering feudalism, religion, and major conflicts.'),
(12, 'Modern European History', '2024-03-01', '2024-08-01',"5 Months", 'History', 21, 'A study of European history from the Renaissance to the present day.'),
(12, 'World Wars', '2024-04-01', '2024-09-01',"5 Months", 'History', 23, 'A detailed analysis of the causes, events, and aftermath of World War I and II.'),
(12, 'History of the Americas', '2024-05-01', '2024-10-01',"5 Months", 'History', 24, 'A course on the political, social, and economic history of North and South America.'),
(12, 'The Cold War', '2024-06-01', '2024-11-01',"5 Months", 'History', 25, 'An in-depth study of the political, military, and ideological conflict between the United States and the Soviet Union.'),

-- Geography
(13, 'Physical Geography', '2024-01-10', '2024-06-10',"5 Months", 'Geography', 20, 'An introduction to the physical features of the Earth, including landforms and weather patterns.'),
(13, 'Human Geography', '2024-02-10', '2024-07-10',"5 Months", 'Geography', 22, 'A study of human societies and their relationship with the environment.'),
(13, 'Urban Geography', '2024-03-01', '2024-08-01',"5 Months", 'Geography', 21, 'A module focused on the growth and development of cities, including urban planning.'),
(13, 'Geographic Information Systems', '2024-04-01', '2024-09-01',"5 Months", 'Geography', 23, 'An introduction to GIS technology and its applications in mapping and data analysis.'),
(13, 'Environmental Geography', '2024-05-01', '2024-10-01',"5 Months", 'Geography', 24, 'A course on the human impact on the environment, including deforestation and climate change.'),
(13, 'Climatology', '2024-06-01', '2024-11-01',"5 Months", 'Geography', 25, 'A module on the study of climates and the factors that influence weather patterns.'),

-- Religious Studies
(14, 'World Religions', '2024-01-10', '2024-06-10',"5 Months", 'Religious Studies', 20, 'A module on the major world religions, including Christianity, Islam, Hinduism, and Buddhism.'),
(14, 'Ethics and Morality', '2024-02-10', '2024-07-10',"5 Months", 'Religious Studies', 22, 'An exploration of ethical issues from a religious perspective.'),
(14, 'Philosophy of Religion', '2024-03-01', '2024-08-01',"5 Months", 'Religious Studies', 21, 'A study of philosophical arguments for and against the existence of God.'),
(14, 'Religious Texts', '2024-04-01', '2024-09-01',"5 Months", 'Religious Studies', 23, 'A detailed study of sacred texts such as the Bible, Quran, and Bhagavad Gita.'),
(14, 'Theology', '2024-05-01', '2024-10-01',"5 Months", 'Religious Studies', 24, 'A course on the systematic study of the nature of the divine and religious beliefs.'),
(14, 'Religion and Society', '2024-06-01', '2024-11-01',"5 Months", 'Religious Studies', 25, 'An exploration of the relationship between religion and social issues such as gender, politics, and conflict.'),

-- Criminology
(15, 'Introduction to Criminology', '2024-01-10', '2024-06-10',"5 Months", 'Criminology', 20, 'An introductory course covering the basic concepts of criminology and criminal justice.'),
(15, 'Criminal Law', '2024-02-10', '2024-07-10',"5 Months", 'Criminology', 22, 'A study of criminal law, including types of crimes and their legal consequences.'),
(15, 'Social Control and Deviance', '2024-03-01', '2024-08-01',"5 Months", 'Criminology', 21, 'An exploration of social control mechanisms and the concept of deviance in society.'),
(15, 'Penology', '2024-04-01', '2024-09-01',"5 Months", 'Criminology', 23, 'A course on punishment and rehabilitation in the criminal justice system.'),
(15, 'Criminal Profiling', '2024-05-01', '2024-10-01',"5 Months", 'Criminology', 24, 'A study of the techniques used in criminal profiling to understand and catch offenders.'),
(15, 'Crime and Society', '2024-06-01', '2024-11-01',"5 Months", 'Criminology', 25, 'A course exploring the social factors contributing to crime and the impact on society.');



INSERT INTO emergency_contact (student_id, full_name, relationship, phone, email)
VALUES
(1, 'John Doe Sr.', 'Parent', '0123456789', 'johndoe.sr@email.com'),
(2, 'Jane Smith', 'Parent', '0123456790', 'janesmith@email.com'),
(3, 'Michael Green', 'Guardian', '0123456791', 'michael.green@email.com'),
(4, 'Susan White', 'Other Family Member', '0123456792', 'susan.white@email.com'),
(5, 'Robert Brown', 'Spouse', '0123456793', 'robert.brown@email.com'),
(6, 'Emily Taylor', 'Friend', '0123456794', 'emily.taylor@email.com'),
(7, 'David Black', 'Parent', '0123456795', 'david.black@email.com'),
(8, 'Laura Harris', 'Guardian', '0123456796', 'laura.harris@email.com'),
(9, 'William Scott', 'Other Family Member', '0123456797', 'william.scott@email.com'),
(10, 'Mary Young', 'Spouse', '0123456798', 'mary.young@email.com'),
(11, 'Andrew Walker', 'Parent', '0123456799', 'andrew.walker@email.com'),
(12, 'Olivia Hall', 'Friend', '0123456800', 'olivia.hall@email.com'),
(13, 'Thomas Allen', 'Other Family Member', '0123456801', 'thomas.allen@email.com'),
(14, 'Charlotte King', 'Guardian', '0123456802', 'charlotte.king@email.com'),
(15, 'James Adams', 'Parent', '0123456803', 'james.adams@email.com'),
(16, 'Helen White', 'Spouse', '0123456804', 'helen.white@email.com'),
(17, 'Brian Martin', 'Other Family Member', '0123456805', 'brian.martin@email.com'),
(18, 'Jessica Nelson', 'Parent', '0123456806', 'jessica.nelson@email.com'),
(19, 'Peter Carter', 'Friend', '0123456807', 'peter.carter@email.com'),
(20, 'Monica Moore', 'Guardian', '0123456808', 'monica.moore@email.com'),
(21, 'Steven Clark', 'Parent', '0123456809', 'steven.clark@email.com'),
(22, 'Barbara Perez', 'Other Family Member', '0123456810', 'barbara.perez@email.com'),
(23, 'Daniel Young', 'Spouse', '0123456811', 'daniel.young@email.com'),
(24, 'Rachel White', 'Friend', '0123456812', 'rachel.white@email.com'),
(25, 'Katherine Harris', 'Guardian', '0123456813', 'katherine.harris@email.com'),
(26, 'Franklin Williams', 'Parent', '0123456814', 'franklin.williams@email.com'),
(27, 'Megan Moore', 'Other Family Member', '0123456815', 'megan.moore@email.com'),
(28, 'George Davis', 'Parent', '0123456816', 'george.davis@email.com'),
(29, 'Sophia Jackson', 'Spouse', '0123456817', 'sophia.jackson@email.com'),
(30, 'Benjamin Lee', 'Friend', '0123456818', 'benjamin.lee@email.com'),
(31, 'Lily Roberts', 'Guardian', '0123456819', 'lily.roberts@email.com'),
(32, 'Henry Carter', 'Parent', '0123456820', 'henry.carter@email.com'),
(33, 'Violet Scott', 'Other Family Member', '0123456821', 'violet.scott@email.com'),
(34, 'Chris Martinez', 'Spouse', '0123456822', 'chris.martinez@email.com'),
(35, 'Sarah Perez', 'Guardian', '0123456823', 'sarah.perez@email.com'),
(36, 'Jack Walker', 'Parent', '0123456824', 'jack.walker@email.com'),
(37, 'Deborah Lee', 'Friend', '0123456825', 'deborah.lee@email.com'),
(38, 'Charlotte White', 'Other Family Member', '0123456826', 'charlotte.white@email.com'),
(39, 'Mark Nelson', 'Spouse', '0123456827', 'mark.nelson@email.com'),
(40, 'Peter King', 'Guardian', '0123456828', 'peter.king@email.com'),
(41, 'Eleanor Wright', 'Parent', '0123456829', 'eleanor.wright@email.com'),
(42, 'Alice Young', 'Other Family Member', '0123456830', 'alice.young@email.com'),
(43, 'Thomas Harris', 'Parent', '0123456831', 'thomas.harris@email.com'),
(44, 'Liam Adams', 'Spouse', '0123456832', 'liam.adams@email.com'),
(45, 'Paula Scott', 'Friend', '0123456833', 'paula.scott@email.com'),
(46, 'Olivia Lee', 'Other Family Member', '0123456834', 'olivia.lee@email.com'),
(47, 'David Walker', 'Parent', '0123456835', 'david.walker@email.com'),
(48, 'Sophie Green', 'Spouse', '0123456836', 'sophie.green@email.com'),
(49, 'Henry Thomas', 'Guardian', '0123456837', 'henry.thomas@email.com'),
(50, 'Joseph Allen', 'Parent', '0123456838', 'joseph.allen@email.com'),
(51, 'Clara Walker', 'Other Family Member', '0123456839', 'clara.walker@email.com'),
(52, 'Eva White', 'Spouse', '0123456840', 'eva.white@email.com'),
(53, 'Dylan Nelson', 'Friend', '0123456841', 'dylan.nelson@email.com'),
(54, 'Isaac Brown', 'Guardian', '0123456842', 'isaac.brown@email.com'),
(55, 'Nina Scott', 'Parent', '0123456843', 'nina.scott@email.com'),
(56, 'Grace Lee', 'Spouse', '0123456844', 'grace.lee@email.com'),
(57, 'Paul Davis', 'Other Family Member', '0123456845', 'paul.davis@email.com'),
(58, 'Ava Walker', 'Parent', '0123456846', 'ava.walker@email.com'),
(59, 'Sophia Williams', 'Friend', '0123456847', 'sophia.williams@email.com');


INSERT INTO room (number, capacity, type, facilities)
VALUES
(101, 30, 'Classroom', 'Whiteboard, Projector, Chairs, Desks'),
(102, 40, 'Classroom', 'Whiteboard, Projector, Chairs, Desks, Air Conditioning'),
(103, 20, 'Classroom', 'Whiteboard, Projector, Chairs'),
(104, 100, 'Lecture Hall', 'Projector, Stage, Chairs, Microphone, Audio System'),
(105, 50, 'Lecture Hall', 'Projector, Stage, Microphone, Chairs, Air Conditioning'),
(106, 25, 'Workshop', 'Workbenches, Tools, Whiteboard, Projector, Chairs'),
(107, 30, 'Workshop', 'Workbenches, Tools, Projector, Chairs, Power Outlets'),
(108, 10, 'Lab', 'Computers, Whiteboard, Projector, Chairs, Laboratory Equipment'),
(109, 12, 'Lab', 'Computers, Whiteboard, Projector, Laboratory Equipment'),
(110, 15, 'Lab', 'Whiteboard, Projector, Laboratory Equipment, Computers'),
(111, 20, 'Tutorial Session', 'Whiteboard, Chairs, Projector'),
(112, 25, 'Tutorial Session', 'Whiteboard, Chairs, Projector, Air Conditioning'),
(113, 35, 'Tutorial Session', 'Whiteboard, Chairs, Projector, Whiteboard Markers'),
(114, 40, 'Classroom', 'Whiteboard, Chairs, Projector, Desks, Heating'),
(115, 60, 'Lecture Hall', 'Projector, Stage, Chairs, Microphone, Air Conditioning'),
(116, 50, 'Classroom', 'Whiteboard, Projector, Desks, Air Conditioning'),
(117, 30, 'Workshop', 'Workbenches, Tools, Whiteboard, Chairs'),
(118, 20, 'Lab', 'Laboratory Equipment, Whiteboard, Projector'),
(119, 12, 'Lab', 'Laboratory Equipment, Projector, Computers'),
(120, 30, 'Lecture Hall', 'Projector, Chairs, Microphone, Air Conditioning');


INSERT INTO session (session_date, start_time, end_time, module_id, staff_id, number)
VALUES
-- January 2024
('2024-01-01', '09:00:00', '11:00:00', 1, 2, 101),
('2024-01-01', '11:30:00', '13:30:00', 2, 4, 102),
('2024-01-02', '09:00:00', '11:00:00', 3, 5, 103),
('2024-01-02', '13:00:00', '15:00:00', 4, 7, 104),
('2024-01-03', '10:00:00', '12:00:00', 5, 8, 105),
('2024-01-03', '14:00:00', '16:00:00', 6, 3, 106),
('2024-01-04', '09:00:00', '11:00:00', 7, 10, 107),
('2024-01-04', '11:30:00', '13:30:00', 8, 12, 108),
('2024-01-05', '09:00:00', '11:00:00', 9, 14, 109),
('2024-01-05', '14:00:00', '16:00:00', 10, 15, 110),
('2024-01-06', '10:00:00', '12:00:00', 11, 16, 111),
('2024-01-06', '13:30:00', '15:30:00', 12, 17, 112),
('2024-01-07', '09:00:00', '11:00:00', 13, 18, 113),
('2024-01-08', '09:00:00', '11:00:00', 14, 19, 114),
('2024-01-09', '09:00:00', '11:00:00', 15, 20, 115),
('2024-01-10', '10:00:00', '12:00:00', 16, 21, 116),
('2024-01-11', '09:00:00', '11:00:00', 17, 22, 117),
('2024-01-12', '13:00:00', '15:00:00', 18, 23, 118),
('2024-01-13', '09:00:00', '11:00:00', 19, 24, 119),
('2024-01-14', '14:00:00', '16:00:00', 20, 25, 120),

-- February 2024
('2024-02-01', '09:00:00', '11:00:00', 1, 2, 101),
('2024-02-01', '11:30:00', '13:30:00', 2, 4, 102),
('2024-02-02', '09:00:00', '11:00:00', 3, 5, 103),
('2024-02-02', '13:00:00', '15:00:00', 4, 7, 104),
('2024-02-03', '10:00:00', '12:00:00', 5, 8, 105),
('2024-02-04', '14:00:00', '16:00:00', 6, 3, 106),
('2024-02-05', '09:00:00', '11:00:00', 7, 10, 107),
('2024-02-06', '11:00:00', '13:00:00', 8, 12, 108),
('2024-02-07', '10:00:00', '12:00:00', 9, 14, 109),
('2024-02-08', '13:00:00', '15:00:00', 10, 15, 110),
('2024-02-09', '09:00:00', '11:00:00', 11, 16, 111),
('2024-02-10', '14:00:00', '16:00:00', 12, 17, 112),
('2024-02-11', '09:00:00', '11:00:00', 13, 18, 113),
('2024-02-12', '14:00:00', '16:00:00', 14, 19, 114),
('2024-02-13', '09:00:00', '11:00:00', 15, 20, 115),
('2024-02-14', '10:00:00', '12:00:00', 16, 21, 116),
('2024-02-15', '13:00:00', '15:00:00', 17, 22, 117),
('2024-02-16', '09:00:00', '11:00:00', 18, 23, 118),
('2024-02-17', '11:00:00', '13:00:00', 19, 24, 119),
('2024-02-18', '14:00:00', '16:00:00', 20, 25, 120),

-- March 2024
('2024-03-01', '09:00:00', '11:00:00', 1, 2, 101),
('2024-03-02', '11:00:00', '13:00:00', 2, 4, 102),
('2024-03-03', '09:00:00', '11:00:00', 3, 5, 103),
('2024-03-04', '13:00:00', '15:00:00', 4, 7, 104),
('2024-03-05', '10:00:00', '12:00:00', 5, 8, 105),
('2024-03-06', '11:00:00', '13:00:00', 6, 3, 106),
('2024-03-07', '09:00:00', '11:00:00', 7, 10, 107),
('2024-03-08', '13:00:00', '15:00:00', 8, 12, 108),
('2024-03-09', '09:00:00', '11:00:00', 9, 14, 109),
('2024-03-10', '10:00:00', '12:00:00', 10, 15, 110),
('2024-03-11', '13:00:00', '15:00:00', 11, 16, 111),
('2024-03-12', '14:00:00', '16:00:00', 12, 17, 112),
('2024-03-13', '09:00:00', '11:00:00', 13, 18, 113),
('2024-03-14', '11:00:00', '13:00:00', 14, 19, 114),
('2024-03-15', '13:00:00', '15:00:00', 15, 20, 115),
('2024-03-16', '09:00:00', '11:00:00', 16, 21, 116),
('2024-03-17', '11:00:00', '13:00:00', 17, 22, 117),
('2024-03-18', '09:00:00', '11:00:00', 18, 23, 118),
('2024-03-19', '13:00:00', '15:00:00', 19, 24, 119),
('2024-03-20', '10:00:00', '12:00:00', 20, 25, 120); 



INSERT INTO feedback (rating, comments, session_id)
VALUES
-- January 2024
('Excellent', 'The session was very engaging and informative. I enjoyed the interactive elements.', 1),
('Good', 'The content was useful, but the room was a bit cramped.', 2),
('Average', 'The session was okay, but could have had more real-world examples.', 3),
('Poor', 'The lecture lacked clarity, and I couldnt follow the topic well.', 4),
('Excellent', 'Great lecture! The instructor was very clear and answered all questions.', 5),
('Good', 'The material was interesting, but the pace was too fast.', 6),
('Excellent', 'The session was excellent! Learned a lot of new concepts.', 7),
('Good', 'Overall good, but the room temperature was too low.', 8),
('Average', 'The session felt rushed, and I would have liked more time for questions.', 9),
('Poor', 'I didnt find the session helpful. It was too theoretical.', 10),
('Excellent', 'Really engaging session, the staff was very knowledgeable.', 11),
('Good', 'It was good, but the room acoustics made it hard to hear at times.', 12),
('Average', 'The session could have been more interactive, as I was just listening most of the time.', 13),
('Poor', 'The session was poorly organized, and we didnt cover all the planned material.', 14),
('Excellent', 'Very informative and enjoyable session. The staff was great!', 15),

-- February 2024
('Good', 'The session was good but could have included more practical examples.', 16),
('Average', 'I found the session somewhat difficult to follow. The pace was slow.', 17),
('Poor', 'The room was overcrowded, and the session was not engaging at all.', 18),
('Excellent', 'I learned a lot today. The instructor was very clear and friendly.', 19),
('Good', 'Good session, but the slides were a bit hard to read.', 20),
('Excellent', 'The session exceeded my expectations. Very informative and interactive.', 21),
('Average', 'I found the session useful, but the instructor could have been more organized.', 22),
('Poor', 'The session didnt provide enough examples or case studies to make the material relevant.', 23),
('Excellent', 'The session was great! Clear explanations and engaging activities.', 24),
('Good', 'The content was solid, but the session felt a bit too long.', 25),
('Average', 'The session had useful content, but there were too many distractions in the room.', 26),
('Excellent', 'Fantastic session! Very well structured and easy to follow.', 27),
('Good', 'It was good overall, but there was a lot of repetition in the material.', 28),
('Poor', 'I struggled to understand the concepts presented. Could have used more visuals.', 29),
('Excellent', 'A really insightful session! The staff explained everything clearly.', 30),

-- March 2024
('Good', 'Good session, but the technology in the room didnt work properly.', 31),
('Average', 'The session was informative, but the room was too cold.', 32),
('Poor', 'Not a great session. It lacked depth and real-world application.', 33),
('Excellent', 'One of the best sessions so far! The staff was very knowledgeable and approachable.', 34),
('Good', 'The session was good, but I would have liked more opportunities for discussion.', 35),
('Excellent', 'Loved the session! The instructor kept it engaging and answered all questions thoroughly.', 36),
('Good', 'The content was helpful, but the room wasnt ideal for the class size.', 37),
('Average', 'The session was okay, but I found some parts confusing. More examples would help.', 38),
('Poor', 'I couldnt really follow the lecture. The explanations werent clear.', 39),
('Excellent', 'Great session, really informative. The staff did an excellent job.', 40),
('Good', 'Good, but the session felt a bit rushed. Could use more time for questions.', 41),
('Average', 'The session was alright, but it was difficult to stay focused due to distractions.', 42),
('Poor', 'The session was not very engaging. I found it difficult to concentrate.', 43),
('Excellent', 'Very enjoyable session, with great examples and interaction with the class.', 44),
('Good', 'Good content, but I feel like it could have been covered more thoroughly.', 45);

---INSERT FOR STUDENT_FEEDBACK needed---
INSERT INTO student_feedback (feedback_id, student_id)
VALUES
    (1, 1),   
    (2, 2),   
    (3, 3),   
    (4, 4),   
    (5, 5),   
    (6, 6),   
    (7, 7),   
    (8, 8),   
    (9, 9),  
    (10, 10), 
    (11, 11), 
    (12, 12), 
    (13, 13),
    (14, 14), 
    (15, 15), 
    (16, 16),
    (17, 17), 
    (18, 18), 
    (19, 19), 
    (20, 20), 
    (21, 21), 
    (22, 22), 
    (23, 23), 
    (24, 24), 
    (25, 25), 
    (26, 26), 
    (27, 27), 
    (28, 28), 
    (29, 29),
    (30, 30), 
    (31, 31), 
    (32, 32), 
    (33, 33), 
    (34, 34), 
    (35, 35), 
    (36, 36); 

-- -------------------------
-- Useful Queries
-- -------------------------
SELECT
    b.name AS "Branch Name",
    s.name AS "Student First Name",
    s.lname AS "Student Last Name",
    s.email AS "Email",
    s.phone AS "Phone",
    s.dob AS "Date of Birth"
FROM
    student s
JOIN branch b ON s.branch_id = b.branch_id
ORDER BY b.name, s.lname;
--This query is used to see all students grouped by which branch of SES they attend--


CREATE VIEW TopRatedSessions AS
SELECT
    s.session_id AS "Session ID",
    f.rating AS "Feedback Rating",
    f.comments AS "Students Comments"
FROM
    session s
JOIN 
    feedback f ON s.session_id = f.session_id
WHERE
    f.rating = 'Excellent';

SELECT * FROM TopRatedSessions;
--This query is used to see the best rated sessions and relevant information for those sessions--


CREATE VIEW StudentEngagement AS
SELECT 
    st.student_id AS "Student ID",
    CONCAT(st.name, ' ', st.lname) AS "Student Name",
    COUNT(DISTINCT sf.feedback_id) AS "Sessions Attended"
FROM 
    student st
JOIN 
    student_feedback sf ON st.student_id = sf.student_id
GROUP BY 
    st.student_id
ORDER BY 
    "Sessions Attended" DESC;

SELECT * FROM StudentEngagement;

CREATE VIEW ModuleDuration AS 
SELECT
    c.name AS "Course",
    b.name AS "Branch",
    m.name AS "Module",
    m.subject_area AS "Subject",
    AGE(m.end_date, m.start_date) AS "Duration"
FROM
    course c
JOIN
    branch b ON b.branch_id = c.branch_id
JOIN 
    module m ON c.course_id = m.module_id
ORDER BY
    b.name, m.name, "Duration";

SELECT 
    s.session_id AS "Session ID",
    COUNT(DISTINCT sf.student_id) AS "Attendance",
    COUNT(f.feedback_id) AS "Total Feedback",
    AVG(CASE 
            WHEN f.rating = 'Excellent' THEN 4
            WHEN f.rating = 'Good' THEN 3
            WHEN f.rating = 'Average' THEN 2
            WHEN f.rating = 'Poor' THEN 1
            ELSE 0
        END) AS "Average Rating"
FROM 
    session s
LEFT JOIN 
    feedback f ON s.session_id = f.session_id
LEFT JOIN 
    student_feedback sf ON f.feedback_id = sf.feedback_id
GROUP BY 
    s.session_id
ORDER BY
    "Average Rating" DESC;




--SELECT
--    s.session_id,
--    COUNT(DISTINCT sf.student_id) AS "Attendance",
--    SUM(CASE WHEN f.rating = 'Excellent' THEN 1 ELSE 0 END) AS "Excellent Feedback",
--    SUM(CASE WHEN f.rating = 'Good' THEN 1 ELSE 0 END) AS "Good Feedback",
--    SUM(CASE WHEN f.rating = 'Average' THEN 1 ELSE 0 END) AS "Average Feedback",
--    SUM(CASE WHEN f.rating = 'Poor' THEN 1 ELSE 0 END) AS "Poor Feedback"
--FROM
--    session s 
--LEFT JOIN 
--    feedback f ON s.session_id = f.session_id
--LEFT JOIN
--   student_feedback sf ON f.feedback_id = sf.feedback_id
--GROUP BY 
--    s.session_id;


-- -------------------------
-- Security
-- -------------------------
CREATE ROLE branch_manager;
CREATE ROLE module_leader;
CREATE ROLE lecturer;
CREATE ROLE staff;
CREATE ROLE student;

-- Grant permissions for managers
GRANT SELECT, INSERT, UPDATE, DELETE ON branch TO branch_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON staff TO branch_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON staff_assignments TO branch_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON course TO branch_manager;
GRANT SELECT, UPDATE ON module TO branch_manager;  

-- Grant permissions for module leaders
GRANT SELECT, UPDATE ON module TO module_leader;
GRANT SELECT, UPDATE ON course TO module_leader;
GRANT SELECT ON session TO module_leader;
GRANT SELECT, UPDATE ON staff_assignments TO module_leader; 

-- Grant permissions for lecturers and staff
GRANT SELECT, UPDATE ON session TO lecturer;
GRANT SELECT, UPDATE ON feedback TO lecturer;
GRANT SELECT ON student_feedback TO lecturer;
GRANT SELECT ON staff TO lecturer;  --reference purposes only

GRANT SELECT, UPDATE ON session TO staff;
GRANT SELECT, UPDATE ON feedback TO staff;
GRANT SELECT ON student_feedback TO staff;

-- Grant permissions for Students
GRANT SELECT ON session TO student;
GRANT SELECT ON course TO student;
GRANT SELECT ON feedback TO student;
GRANT INSERT ON student_feedback TO student;

--Staff assignments control--
GRANT SELECT, UPDATE, DELETE ON staff_assignments TO branch_manager;


-- ------------------
-- Functions Library
-- ------------------

-- create duration for dates using update on functions (needs testing) (will finish in the morning am knackered)
CREATE OR REPLACE FUNCTION update_duration_date()
   RETURNS TRIGGER 
   LANGUAGE plpgsql
  AS
$$
BEGIN
    NEW.duration = concat(EXTRACT(DAY FROM NEW.end_date - NEW.start_date), ' ', 'Days Remaining');
    RETURN NEW;
END;
$$;

CREATE TRIGGER update_duration_dates_tg 
AFTER INSERT OR UPDATE OF start_date, end_date
ON module
FOR EACH ROW
EXECUTE PROCEDURE update_duration_date();
-- Testing func:
-- When start_date < end_date


-- attending within room will use function to select all relevant student_id's and aggregate them
-- create get_register function that lists all

/*
-- testing duration column --
CREATE TABLE module (
    module_id SERIAL PRIMARY KEY NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    duration TEXT    
);

CREATE OR REPLACE FUNCTION update_duration_date()
   RETURNS TRIGGER 
   LANGUAGE plpgsql
  AS
$$
BEGIN
    NEW.duration = concat(
        EXTRACT(MONTH FROM (NEW.end_date - NEW.start_date)),
        EXTRACT(DAY FROM (NEW.end_date - NEW.start_date))
    );
    RETURN NEW;
END;
$$;

CREATE TRIGGER update_duration_dates_tg 
BEFORE INSERT OR UPDATE OF start_date, end_date
ON module
FOR EACH ROW
EXECUTE PROCEDURE update_duration_date();

INSERT INTO module (start_date, end_date)
VALUES
('2024-01-10', '2024-06-10'),
('2024-02-15', '2024-07-15'),
('2024-03-01', '2024-08-01'),
('2024-04-01', '2024-09-01'),
('2024-05-10', '2024-10-10'),
('2024-06-15', '2024-11-15'),

-- Applied Mathematics
('2024-02-10', '2024-07-10'),
('2024-03-01', '2024-08-01'),
('2024-04-05', '2024-09-05'),
('2024-05-01', '2024-10-01'),
('2024-06-01', '2024-11-01'),
('2024-07-01', '2024-12-01');

INSERT INTO module (start_date, end_date)
VALUES
('2024-10-18', '2024-12-18');
*/