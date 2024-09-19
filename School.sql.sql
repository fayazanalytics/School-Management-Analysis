-- Section 1: Consider the scenario when school management wants to evaluate which employee will get the next promotion based on their time in school, 
-- their designation along with their performance (which they evaluate based on feedback from students or their parents.)

-- Calculate the total employees belonging to each age/age-group.

SELECT Employee_since - YEAR(Employee_Birthdate) AS JoiningAge, COUNT(*) AS Total_Employees 
FROM employee_d 
GROUP BY Employee_since - YEAR(Employee_Birthdate);

-- Calculate the min and max of age of employees.

SELECT MIN(2023 - YEAR(Employee_Birthdate)) AS MinAge, 
MAX(2023 - YEAR(Employee_Birthdate)) AS MaxAge 
FROM employee_d ;

-- Identify the time spent by employees in school grouped by their designation.

SELECT Employee_designation, SUM(2023 - Employee_since) AS TotalTimeSpent 
FROM employee_d 
GROUP BY Employee_designation;

-- Total number of feedbacks for an employee on employee id.

SELECT Employee_Id, COUNT(*) AS Total_Feedbacks 
FROM ratings_d 
GROUP BY Employee_Id;

-- Average rating of an employee having at least 3 feedbacks.

SELECT employee_id, AVG(Rating) AS Avg_ratings 
FROM ratings_d 
GROUP BY employee_id 
HAVING COUNT(*) >= 3;

-- Section 2: School wants to determine if they have to divide a class to create more sections or they have to merge multiple sections into one based on their strength. 
-- (If there are too many students in class then it would create chaos in class while if there are less students then it will be a waste of resources for school).

-- Identify the total number of students by Class_id

SELECT Class_Id, COUNT(*) AS Total_Students 
FROM student_d 
GROUP BY Class_Id;

-- Identify the total number of students by Class_Id and Student_Class

SELECT Class_Id, Student_Class, COUNT(*) AS Total_Students 
FROM student_d 
GROUP BY Class_Id, Student_Class;

-- School provides bus services to different locations of Delhi-NCR for employees and students. 
-- School management wants to optimize the bus services in a way that we get no seat left in buses and everybody gets picked up.

-- Total number of employees by Employee designation

SELECT Employee_designation, COUNT(*) AS Total_Employees 
FROM employee_d 
GROUP BY Employee_designation;

-- Total number of students by each city

SELECT Student_City, COUNT(*) AS Total_Students 
FROM student_d 
GROUP BY Student_City;

-- Section 2: Consider the scenario that the school is hosting an annual event where they will be distributing the prizes to students for various things. 
-- For instance, best performer in studies or sports or arts or some extra-curricular activities.

-- Class 9A and 10B students from Delhi are fantastic musicians and just gave an outstanding performance in a national level event. Get the name of the students.

SELECT Student_Name 
FROM student_d 
WHERE (Class_Id = 9 AND Student_Class = 'A' AND Student_City = 'Delhi') 
OR (Class_Id = 10 AND Student_Class = 'B' AND Student_City = 'Delhi');

-- Professor from Gurgaon who has been with us since 2006 and 2020 has been a fantastic duo to carry out the science projects on state level with school students and got a prize from the state CM. 
-- Get the name of professors.

SELECT Employee_Name 
FROM employee_d 
WHERE Employee_designation = 'Professor' 
AND Employee_City = 'Gurgaon' 
AND Employee_since IN (2006, 2020);

-- School management wants to identify professor info who are currently mapped to a course.

SELECT e.Employee_Id, e.Employee_Name 
FROM employee_d AS e 
LEFT JOIN course_d AS c ON e.Employee_Id = c.Professor_Id 
WHERE c.Professor_Id IS NULL;

-- School management wants to identify the class teachers to give them proper resources.
-- Get the total professors that are currently a class teacher.

SELECT COUNT(*) AS TotalClassTeachers 
FROM employee_d AS e 
JOIN class_d AS c ON e.Employee_Id = c.ClassTeacher;

-- Get the id and name of professors who are currently a class teacher.

SELECT e.Employee_Name, e.Employee_Id 
FROM employee_d AS e 
JOIN class_d AS c ON e.Employee_Id = c.ClassTeacher;

-- Find the total Assignments and paper by each class teacher in a class.

SELECT c.ClassTeacher, SUM(co.Course_Assignments) AS TotalAssignments, SUM(co.Course_Paper) AS TotalPapers 
FROM course_d as co 
JOIN class_d AS c ON c.Class_Id = co.Class_Id 
GROUP BY c.ClassTeacher;

-- School management wants to know the employees having the birth date on the same day to plan for the leaves they provide to employees. 
-- Check which of the 2 employees in Employee_d table have a birth date on the same day.

SELECT E1.Employee_Name, E2.Employee_Name 
FROM employee_d AS E1, employee_d AS E2 
WHERE E1.Employee_Id != E2.Employee_Id 
AND E1.Employee_Birthdate = E2.Employee_Birthdate;

-- Get the TOP 2 employees' names and their ratings (who got the best overall ratings from students).

SELECT Employee_Name, AVG(Rating) AS Avg_Rating 
FROM ratings_d AS r 
JOIN employee_d AS e ON r.Employee_Id = e.Employee_Id 
GROUP BY r.Employee_Id, Employee_Name 
ORDER BY Avg_Rating DESC 
LIMIT 2;

-- Section 3: Let’s suppose the school wants to open up career counselling sessions for students. 
-- For that, they will not have professionals from industry guiding the students, 
-- but also professors having good bonding with students along with professors for administrative work.

-- Get the professors that aren’t involved in any courses as of now.

SELECT * 
FROM employee_d as e 
WHERE Employee_designation = 'Professor' 
AND Employee_Id NOT IN (SELECT DISTINCT Professor_Id FROM course_d);

-- Professors are busy with assignments and papers they have given to students and may not have the time to attend counselling. 
-- Get the employee name where the average paper >=3 and assignments >20.
SELECT * 
FROM employee_d AS e 
WHERE EXISTS (
    SELECT 1 
    FROM course_d AS c 
    WHERE e.Employee_Id = c.Professor_Id 
    GROUP BY c.Professor_Id 
    HAVING AVG(c.Course_Assignments) > 20 
    AND AVG(c.Course_Paper) >= 3
);

-- Get the employees with more than 2 students ratings.
SELECT * 
FROM employee_d as e 
WHERE EXISTS (
    SELECT r.Employee_Id 
    FROM ratings_d AS r 
    WHERE e.Employee_Id = r.Employee_Id 
    GROUP BY r.Employee_Id 
    HAVING count(r.Student_Id) >= 2
);

-- Get the employees with an average rating of more than 4 and are rated by more than 3 students.
SELECT * 
FROM employee_d as e 
WHERE EXISTS (
    SELECT r.Employee_Id 
    FROM ratings_d AS r 
    WHERE e.Employee_Id = r.Employee_Id 
    GROUP BY r.Employee_Id 
    HAVING COUNT(Student_Id) > 3 
    AND AVG(Rating) >= 4
);

#Consider the scenario that a School has to fund different societies within the school. 
#They have to identify certain characteristics of each society in order to determine the allocation of funds.

-- a) What is the Society_Id with the highest number of students and what is the number of students associated with it?

SELECT Society_Id, COUNT(Student_Id) AS Count_Stu
FROM Society_Fact_d
GROUP BY Society_Id
ORDER BY Society_Id, Count_Stu
DESC LIMIT 1 ;

-- b) What is the Society_Id of the students with the highest number of awards and what is the number of awards associated with it?

SELECT Society_Id, 
SUM(Awards_won) AS Total_Awards 
FROM Society_Fact_d
GROUP BY Society_Id 
ORDER BY Total_Awards DESC LIMIT 1;

-- c) What is the Society_Id that has the highest average ratio of Gold Medals to Awards won among all societies.
-- what is the along with the corresponding Gold Medal Winning ratio value.

SELECT Society_Id, AVG(GoldMedals / Awards_won) AS GOLDWINRATIO
FROM Society_Fact_d
GROUP BY Society_Id
HAVING ROUND(GOLDWINRATIO,1) = (
    SELECT ROUND(MAX(GOLDWINRATIO),1) AS MAXGOLD
   FROM (SELECT Society_Id, AVG(GoldMedals/Awards_won) AS GOLDWINRATIO
   FROM Society_Fact_d
   GROUP BY Society_Id)AS T );


-- d) What is Society_Id with the highest average ratio of Awards won to Participations among all societies. 
-- along with the corresponding Average Winning Per value?

SELECT SF.Society_Id, AVG(Awards_won / Participations) as AVG_WIN_PER
FROM Society_Fact_d as SF 
JOIN Society_Dim_d SD ON SD.Society_Id = SF.Society_Id
GROUP BY SF.Society_Id
HAVING ROUND(AVG_WIN_PER,1)  = 
(SELECT ROUND(MAX(AVG_WIN_PER),1) AS AVG_PER 
FROM 
(SELECT Society_Id,AVG(Awards_won / Participations) as AVG_WIN_PER
FROM Society_Fact_d AS SF 
GROUP BY Society_Id) AS T);

--- What is Society_Id with the lowest average ratio of Awards won to Participations among all societies, along with the corresponding Average Winning Per value? 

SELECT SF.Society_Id, AVG(Awards_won / Participations) AS Avg_Winning_Per 
FROM Society_Fact_d AS SF 
  JOIN Society_Dim_d AS SD ON SF.Society_Id = SD.Society_Id 
GROUP BY SF.Society_Id 
HAVING ROUND(Avg_Winning_Per, 1) = (
    SELECT ROUND(MIN(Avg_Winning_Per), 1) AS Avg_Per 
    FROM (SELECT Society_Id, 
          AVG(Awards_won / Participations) AS Avg_Winning_Per 
        FROM Society_Fact_d AS SF 
        GROUP BY Society_Id) AS T);
        

--- School also has a lot of administrative work. Let’s figure out how we can distribute that amongst the employees depending on their availability:

---  Identify the employees who aren’t involved with either in classes or any societies as of now

SELECT ED.*,
ED.Total_NA_Employees / T.Total_Employees AS NA_Employee_Fraction 
FROM (SELECT Employee_designation, COUNT(Employee_Id) AS Total_NA_Employees 
FROM employee WHERE Employee_Id NOT IN (SELECT DISTINCT Professor_Id FROM course) 
AND Employee_Id NOT IN (SELECT DISTINCT Employee_Id FROM Society_Fact) 
GROUP BY Employee_designation) AS ED JOIN (SELECT Employee_designation, COUNT(*) AS Total_Employees 
FROM employee 
GROUP BY Employee_designation) AS T ON ED.Employee_designation = T.Employee_designation;

---  Get the names of top 2 designation groups based on the above defined fraction. Arrange by designation if there is a tie.

SELECT ED.*, 
ED.Total_NA_Employees / T.Total_Employees AS NA_Employee_Fraction 
FROM (SELECT Employee_designation, COUNT(Employee_Id) AS Total_NA_Employees 
FROM employee WHERE Employee_Id NOT IN (SELECT DISTINCT Professor_Id FROM course) 
AND Employee_Id NOT IN (SELECT DISTINCT Employee_Id FROM Society_Fact)
GROUP BY Employee_designation) AS ED JOIN (SELECT Employee_designation, 
COUNT(*) AS Total_Employees 
FROM employee 
GROUP BY Employee_designation) AS T ON ED.Employee_designation = T.Employee_designation 
ORDER BY NA_Employee_Fraction 
DESC, Employee_designation LIMIT 2;

