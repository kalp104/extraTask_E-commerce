-- create table query

create table students (
    studentId serial primary key,
    studentName varchar(100),
    dateofBirth date,
    gender varchar(10),
    enrollmentDate date,
    major varchar(100) 
);
create table courses (
    courseId serial primary key,
    courseName varchar(100),
    department varchar(100),
    credits int 
);
create table professors (
    professorId serial primary key,
    professorName varchar(100),
    department varchar(100) 
);
create table enrollments (
    enrollmentId serial primary key,
    studentId int references students(studentid),
    courseId int references courses(courseid),
    enrollmentDate date 
);
create table grades (
    gradeId serial primary key,
    studentId int references students(studentid),
    courseId int references courses(courseid),
    grade varchar(50),
    semester varchar(50)
);
create table departments (
    departmentId serial primary key,
    departmentName varchar(100),
    dean varchar(100)
);
create table attendance (
    attendanceId serial primary key,
    studentId int references students(studentid),
    courseId int references courses(courseid),
    date date,
    status varchar(10)
);


-- insert into table

INSERT INTO Students (StudentName, DateOfBirth, Gender, EnrollmentDate, Major) VALUES
('kalp pandya', '2003-04-10', 'Male', '2023-08-01', 'Computer Science'),
('jaymin prajapati', '2003-07-21', 'Male', '2022-09-01', 'Mathematics'),
('smit patel', '2003-01-10', 'Male', '2023-08-01', 'Computer Science'),
('aary shah', '2003-11-30', 'Female', '2023-08-01', 'Physics'),
('andrew babu', '2003-06-25', 'Male', '2021-09-01', 'AI');

INSERT INTO Departments (DepartmentName, Dean) VALUES
('AI','Dr. robert pattinson'),
('Computer Science', 'Dr. Bruce Wayne'),
('Mathematics', 'Dr. Peter Parker'),
('Physics', 'Dr. Matt Murdockk'),
('Biology', 'Dr. Robert downy jr'),
('History', 'Dr. clark kent');

INSERT INTO Professors (ProfessorName, Department) VALUES
('Dr. Joker', 'Computer Science'),
('Dr. Ghost Rider', 'Mathematics'),
('Dr. Venom', 'Physics'),
('Dr. strange', 'Biology'),
('Dr. ping', 'History');

INSERT INTO Courses (CourseName, Department, Credits) VALUES
('AI', 'Computer Science', 3),
('Database Systems', 'Computer Science', 3),
('Machine Learning', 'Computer Science', 4),
('Linear Algebra', 'Mathematics', 3),
('Quantum Mechanics', 'Physics', 4),
('World History', 'History', 3);

INSERT INTO Enrollments (StudentID, CourseID, EnrollmentDate) VALUES
(5, 6, '2024-01-20'),
(1, 1, '2024-01-10'),
(1, 2, '2024-01-10'),
(2, 3, '2024-01-12'),
(3, 1, '2024-01-15'),
(4, 4, '2024-01-20');

INSERT INTO Grades (StudentID, CourseID, Grade, Semester) VALUES
(5, 6, 'B', 'Fall 2023'),
(1, 1, 'A', 'Fall 2023'),
(1, 2, 'B', 'Fall 2023'),
(2, 3, 'C', 'Fall 2023'),
(3, 1, 'A', 'Spring 2024'),
(4, 4, 'D', 'Spring 2024');

INSERT INTO Attendance (StudentID, CourseID, Date, Status) VALUES
(1, 1, '2024-02-10', 'Present'),
(1, 2, '2024-02-10', 'Absent'),
(2, 3, '2024-02-10', 'Present'),
(3, 1, '2024-02-11', 'Present'),
(4, 4, '2024-02-11', 'Absent');


-- select query
select * from students
select * from courses
select * from professors
select * from enrollments
select * from grades
select * from departments
select * from attendance

-- drop table students
-- drop table courses
-- drop table professors
-- drop table enrollments
-- drop table grades
-- drop table departments
-- drop table attendance

-- 1. Retrieve the average grade for each course. 
-- • Calculate the average grade received by students in each course. 
-- select * from courses
-- select * from grades
select c.courseId, c.courseName,round(
	avg(
		case when g.grade = 'A' then 5.0
		     when g.grade = 'B' then 4.0
		     when g.grade = 'C' then 3.0
		     when g.grade = 'D' then 2.0
		     when g.grade = 'E' then 1.0
		     when g.grade = 'F' then 0.0
		end
	)
,2) as avg_grade
from courses c 
join grades g  
on c.courseId = g.courseId
group by c.courseId, c.courseName
order by avg_grade desc

-- 2. Find the top 5 students with the highest GPA. 
-- • Identify the students with the best overall performance based on their grades. 
-- select * from students
-- select * from grades
select s.studentId, s.studentName, round(
avg(
	case when g.grade = 'A' then 5.0
		     when g.grade = 'B' then 4.0
		     when g.grade = 'C' then 3.0
		     when g.grade = 'D' then 2.0
		     when g.grade = 'E' then 1.0
		     when g.grade = 'F' then 0.0
	end
)
,2) as avg_grade from students s
join grades g
on s.studentId = g.studentId
group by s.studentId
order by avg_grade desc
limit 5

-- 3. Count the number of students enrolled in each major. 
-- • Determine how many students are pursuing each major.
select 
    major, 
    count(*) as studentCount
from students
group by major
order by studentCount desc;

-- 4. Identify the courses with the highest student enrollment. 
-- • Find out which courses are the most popular among students. 
select c.courseId, c.courseName, count(e.studentId) as enrolled
from enrollments e 
join courses c 
on e.courseId = c.courseId
group by c.courseId
order by enrolled desc
limit 5

-- 5. Calculate the student retention rate. 
-- • Determine the percentage of students who continue beyond their first year. 
select (count(distinct s.studentId) / (select count(*) from students)) * 100 as retention
from enrollments e 
join students s on e.studentId = s.studentId
where e.enrollmentDate > s.enrollmentDate + interval '1 year'
		
-- 6. Find the professors teaching the most courses. 
-- • Identify which professors are handling the highest number of courses. 
select p.professorName, count(c.CourseID) as courseCount
from Courses c
join Professors p 
on c.department = p.department
group by p.professorID, p.professorName
order by courseCount desc
limit 5

-- 7. List students who have failed more than one course. 
-- • Identify students who received an "F" in multiple courses. 
select g.studentID, s.studentName, count(*) as failures
from grades g
join students s 
on g.studentId = s.studentId
where g.grade = 'F'
group by g.studentId, s.studentName
having count(*) > 1

-- 8. Analyze semester-wise student performance trends. 
-- • Track changes in students' average grades across different semesters. 
select semester, 
round(
	avg(
	case when grade = 'A' then 5.0
		 when grade = 'B' then 4.0
		 when grade = 'C' then 3.0
		 when grade = 'D' then 2.0
		 when grade = 'E' then 1.0
		 when grade = 'F' then 0.0
	end
	)
, 2) as avgGpa
from grades
group by semester
order by semester

-- 9. Calculate the percentage of students passing each course. 
-- • Find out how many students received passing grades (A, B, or C) for each course. 
select c.courseId, c.courseName, round(
	(count(
		case 
			when grade in ('A','B','C') then 1 
		end
	) / count(*)) * 100
,2) as passed
from grades g
join courses c
on g.courseId = c.courseId
group by c.courseId

-- 10. Find students who changed their major after enrollment. 
-- • Identify students who switched from one major to another. 
select studentid, count(distinct major) as majors
from students
group by studentid
having count(distinct major) > 1;


-- 11. Determine the course completion rate. 
-- • Calculate how many students completed each course versus those who dropped 
-- out. 
select c.courseId, c.courseName, round(
	(count(g.studentId) * 100) / count(e.studentId)
,2) as complete 
from enrollments e
left join grades g 
on e.studentId = g.studentId
join courses c 
on e.courseId = c.courseId
group by c.courseId

-- 12. Identify professors whose students have the highest average grades. 
-- • Find professors whose students perform the best academically. 
select p.professorId, p.professorName,round(
	avg(
		case  
		 when grade = 'A' then 5.0
		 when grade = 'B' then 4.0
		 when grade = 'C' then 3.0
		 when grade = 'D' then 2.0
		 when grade = 'E' then 1.0
		 when grade = 'F' then 0.0
		end
	)
,2) as avgGpa
from grades g
join courses c 
on g.courseId = c.courseId
join professors p 
on p.Department = p.Department
group by p.professorId
order by avgGpa desc
limit 5

-- 13. Calculate the attendance rate for each student. 
-- • Find out how often each student attends their enrolled courses. 
select s.StudentName, round(
	(count(
			case 
				when a.status = 'Present' then 1 
			end
		  ) / count(*)
	) * 100
,2)
from attendance a 
join students s 
on a.studentId = s.studentId
group by s.studentName

-- 14. Identify the most frequently skipped courses. 
-- • Determine which courses have the highest absentee rates. 
select c.courseName, round(
	(
		count(
			case 
				when a.status = 'Absent' then 1 
			end
		) / count (*) 
	) * 100
,2) as absents
from attendance a
join courses c 
on a.courseId = c.courseId
group by c.courseName
order by absents
limit 2

-- 15. Find the department with the highest student enrollment. 
-- • Identify which university department has the most students.
select d.departmentName, count(s.studentId) as studentCount
from students s
join departments d 
on s.major = d.departmentName
group by d.departmentName
order by studentCount desc
limit 1