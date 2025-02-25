use Examination_system
--Proc to add Question (MCQ)
 CREATE  PROCEDURE SP_Add_MCQ_Question
    @Q_Body NVARCHAR(MAX),
    @Grade INT,
    @Crs_Id INT,
    @Option1 NVARCHAR(MAX),
    @Option2 NVARCHAR(MAX),
    @Option3 NVARCHAR(MAX),
    @Option4 NVARCHAR(MAX),
    @CorrectOption INT
AS
BEGIN
    DECLARE @QuestionId INT;

    -- Insert the question into Correct_Answer table
    INSERT INTO Question(Correct_Answer,Q_Body, Type, Grade, Crs_Id)
    VALUES ( @CorrectOption,@Q_Body, 'MCQ', @Grade, @Crs_Id);

    -- Get the ID of the newly inserted question
    SET @QuestionId = SCOPE_IDENTITY();



    -- Insert the options into the Option table with manually incremented Op_Id
    INSERT INTO Options(Op_Id, Q_Id, Op_Body)
    VALUES 
        ( 1, @QuestionId, @Option1),
        ( 2, @QuestionId, @Option2),
        ( 3, @QuestionId, @Option3),
        ( 4, @QuestionId, @Option4);

END;


--test

EXEC SP_Add_MCQ_Question 
    @Q_Body = 'What is the capital of France?',
    @Grade = 2,
    @Crs_Id = 1,
    @Option1 = 'Berlin',
    @Option2 = 'London',
    @Option3 = 'Paris',
    @Option4 = 'Rome',
    @CorrectOption = 3;

	------------------------------------------------------------------------------
	--Proc Add Question 
 CREATE or ALTER PROCEDURE SP_Add_TF_Question
    @Q_Body NVARCHAR(MAX),
    @Grade INT,
    @Crs_Id INT,
    @CorrectOption INT
AS
BEGIN
    DECLARE @QuestionId INT;

    -- Insert the question into Correct_Answer table
    INSERT INTO Question(Correct_Answer,Q_Body, Type, Grade, Crs_Id)
    VALUES ( @CorrectOption,@Q_Body, 'TF', @Grade, @Crs_Id);

END;

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--Proc to Generate Exam 

CREATE OR ALTER PROCEDURE SP_Create_Exam
    @Ex_Name NVARCHAR(255),
    @Crs_Id INT,
    @Number_Of_MCQ INT,
    @Number_Of_TF INT
AS
BEGIN
    DECLARE @ExamId INT;

    -- Step 1: Create a new exam and insert it into the Exam table
    INSERT INTO Exam (Ex_Name, Grade, Crs_Id)
    VALUES (@Ex_Name, 100, @Crs_Id);

    -- Get the ExamId of the newly inserted exam
    SET @ExamId = SCOPE_IDENTITY();

    -- Step 2: Select and insert MCQ questions (randomly) into the Exam_Questions table
    INSERT INTO Exam_Questions (Q_Id, Ex_Id)
    SELECT TOP (@Number_Of_MCQ) Q_Id, @ExamId
    FROM Question
    WHERE Crs_Id = @Crs_Id AND Type = 'MCQ'
    ORDER BY NEWID();  -- Random selection

    -- Step 3: Select and insert TF questions (randomly) into the Exam_Questions table
    INSERT INTO Exam_Questions (Q_Id, Ex_Id)
    SELECT TOP (@Number_Of_TF) Q_Id, @ExamId
    FROM Question
    WHERE Crs_Id = @Crs_Id AND Type = 'TF'
    ORDER BY NEWID();  -- Random selection
END;


--test 
EXEC SP_Create_Exam 
    @Ex_Name = 'Final Exam - Live JavaScript', 
    @Crs_Id = 1,  
    @Number_Of_MCQ = 10,  
    @Number_Of_TF = 5;  


SELECT * FROM Exam WHERE Ex_Name =  'Final Exam - Live JavaScript';

SELECT *  FROM  
Exam_Questions  ex_q join Question q
on ex_q.Q_Id=q.Q_Id
join Exam ex
on ex.Exam_ID=ex_q.Ex_Id

WHERE Ex_Id =2;

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

--Proc To add Student Answers

CREATE OR ALTER PROCEDURE SP_Submit_Student_Answers
    @St_Id INT,
    @Ex_Id INT,
    @Q_Id INT,
    @Answer INT
AS
BEGIN
    -- Insert the student's answer into the Student_Answers table
    INSERT INTO Student_Answers (St_Id, Ex_Id, Q_Id, Answer)
    VALUES (@St_Id, @Ex_Id, @Q_Id, @Answer);
END;

--test 


EXEC SP_Submit_Student_Answers @St_Id = 1, @Ex_Id = 2, @Q_Id = 1, @Answer = 2;
EXEC SP_Submit_Student_Answers @St_Id = 1, @Ex_Id = 2, @Q_Id = 2, @Answer = 3;
EXEC SP_Submit_Student_Answers @St_Id = 1, @Ex_Id = 2, @Q_Id = 3, @Answer = 1;
EXEC SP_Submit_Student_Answers @St_Id = 1, @Ex_Id = 2, @Q_Id = 4, @Answer = 4;
EXEC SP_Submit_Student_Answers @St_Id = 1, @Ex_Id = 2, @Q_Id = 5, @Answer = 2;
EXEC SP_Submit_Student_Answers @St_Id = 1, @Ex_Id = 2, @Q_Id = 6, @Answer = 1;
EXEC SP_Submit_Student_Answers @St_Id = 1, @Ex_Id = 2, @Q_Id = 7, @Answer = 3;
EXEC SP_Submit_Student_Answers @St_Id = 1, @Ex_Id = 2, @Q_Id = 8, @Answer = 4;
EXEC SP_Submit_Student_Answers @St_Id = 1, @Ex_Id = 2, @Q_Id = 9, @Answer = 4;
EXEC SP_Submit_Student_Answers @St_Id = 1, @Ex_Id = 2, @Q_Id = 10, @Answer = 4;
----------------------------------------------------------
--proc to correct the exam 
CREATE OR ALTER PROCEDURE SP_Correct_Student_Answers
    @St_Id INT,
    @Ex_Id INT
AS
BEGIN
    DECLARE @TotalQuestions INT, @CorrectAnswers INT, @Score FLOAT;

    -- Count total questions in the exam
    SELECT @TotalQuestions = COUNT(*) 
    FROM Exam_Questions 
    WHERE Ex_Id = @Ex_Id;

    -- Count correct answers
    SELECT @CorrectAnswers = COUNT(*)
    FROM Student_Answers SA
    INNER JOIN Question Q ON SA.Q_Id = Q.Q_Id
    WHERE SA.St_Id = @St_Id 
          AND SA.Ex_Id = @Ex_Id 
          AND SA.Answer = Q.Correct_Answer;

    -- Calculate the score as a percentage
    SET @Score = (CAST(@CorrectAnswers AS FLOAT) / @TotalQuestions) * 100;

    -- Display the student's score
    PRINT 'Student ID: ' + CAST(@St_Id AS NVARCHAR) + ', Exam ID: ' + CAST(@Ex_Id AS NVARCHAR) + ', Score: ' + CAST(@Score AS NVARCHAR);
END;

--test 


EXEC SP_Correct_Student_Answers @St_Id = 1, @Ex_Id = 2;
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
--Insert Student
CREATE PROCEDURE AddStudent
    @FName VARCHAR(50),
    @LName VARCHAR(50),
    @Gender VARCHAR(50) = NULL,
    @DoB DATE = NULL,
    @Email VARCHAR(50) = NULL,
    @Password VARCHAR(50) = NULL,
    @Dept_Id INT = NULL
AS
BEGIN
    INSERT INTO Student (FName, LName, Gender, DoB, Email, Password, Dept_Id)
    VALUES (@FName, @LName, @Gender, @DoB, @Email, @Password, @Dept_Id);
END;
--test
EXEC AddStudent @FName = 'Ahmed', @LName = 'Ali', @Gender = 'Male', @DoB = '2000-01-01', @Email = 'ahmed.ali@example.com', @Password = 'password123', @Dept_Id = 1;
----------------------------------------------------------------------------------
---Update Student
use Examination_system
CREATE PROCEDURE UpdateStudent
    @Std_id INT,
    @FName VARCHAR(50) = NULL,
    @LName VARCHAR(50) = NULL,
    @Gender VARCHAR(50) = NULL,
    @DoB DATE = NULL,
    @Email VARCHAR(50) = NULL,
    @Password VARCHAR(50) = NULL,
    @Dept_Id INT = NULL
AS
BEGIN
    UPDATE Student
    SET FName = ISNULL(@FName, FName),
        LName = ISNULL(@LName, LName),
        Gender = ISNULL(@Gender, Gender),
        DoB = ISNULL(@DoB, DoB),
        Email = ISNULL(@Email, Email),
        Password = ISNULL(@Password, Password),
        Dept_Id = ISNULL(@Dept_Id, Dept_Id)
    WHERE Std_id = @Std_id;
END;

--test
EXEC UpdateStudent @Std_id = 1, @FName = 'Mohamed', @Email = 'mohamed.ali@example.com';
----------------------------------------------------------------------------------------
--Delete Student
CREATE or Alter PROCEDURE DeleteStudent
    @Std_id INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Student_Answers WHERE St_Id = @Std_id)
    BEGIN
        PRINT 'Can`t Delete this Student';
        RETURN;
    END;

    DELETE FROM Student
    WHERE Std_id = @Std_id;

    PRINT 'Delete Success';
END;


EXEC DeleteStudent @Std_id = 1;
-------------------------------------------------------------------------------------
--Get student by Id
CREATE PROCEDURE GetStudentById
    @Std_id INT
AS
BEGIN
    SELECT * FROM Student
    WHERE Std_id = @Std_id;
END;

--test
EXEC GetStudentById @Std_id = 1;

-------------------------------------------------------------------------------------------
--Get All Student
CREATE or alter PROCEDURE GetAllStudents
AS
BEGIN
    SELECT * FROM Student;
END;
--test
EXEC GetAllStudents;
--------------------------------------------------------------------------------------------
--Insert Exam
CREATE or alter PROCEDURE AddExam
    @Ex_Name VARCHAR(50),
    @Grade INT,
    @Crs_ID INT
AS
BEGIN
    INSERT INTO Exam (Ex_Name, Grade, Crs_ID)
    VALUES (@Ex_Name, @Grade, @Crs_ID);
END;
--test
EXEC AddExam @Ex_Name = 'Final Exam', @Grade = 100, @Crs_ID = 2;

----------------------------------------------------------------------------------------------
--Update Exam
CREATE or alter PROCEDURE UpdateExam
    @Exam_ID INT,
    @Ex_Name VARCHAR(50) = NULL,
    @Grade INT = NULL,
    @Crs_ID INT = NULL
AS
BEGIN
    UPDATE Exam
    SET Ex_Name = ISNULL(@Ex_Name, Ex_Name),
        Grade = ISNULL(@Grade, Grade),
        Crs_ID = ISNULL(@Crs_ID, Crs_ID)
    WHERE Exam_ID = @Exam_ID;
END;
--test
EXEC UpdateExam @Exam_ID = 1, @Ex_Name = 'Final Exam', @Grade = 150;

---------------------------------------------------------------------------------------------

CREATE or ALTER PROCEDURE DeleteExam
    @Exam_ID INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Student_Answers WHERE Ex_Id = @Exam_ID)
    BEGIN
        PRINT 'Can`t Delete This Exam';
        RETURN;
    END;

    DELETE FROM Exam
    WHERE Exam_ID = @Exam_ID;

    PRINT 'Delete Success';
END;
--test
EXEC DeleteExam @Exam_ID = 2;
------------------------------------------------------------------------------------
--Get ExamBy Id
CREATE or alter  PROCEDURE GetExamById
    @Exam_ID INT
AS
BEGIN
    SELECT * FROM Exam
    WHERE Exam_ID = @Exam_ID
END
--test
EXEC GetExamById @Exam_ID = 1;
-------------------------------------------------------------------------------------
--Get All Exams
CREATE PROCEDURE GetAllExams
AS
BEGIN
    SELECT * FROM Exam;
END;
--test
EXEC GetAllExams;
-------------------------------------------------------------------------------------
--Insert Question to Exam
CREATE PROCEDURE AddQuestionToExam
    @Q_Id INT,
    @Ex_Id INT
AS
BEGIN
    INSERT INTO Exam_Questions (Q_Id, Ex_Id)
    VALUES (@Q_Id, @Ex_Id);
END;

--test
EXEC AddQuestionToExam @Q_Id = 1, @Ex_Id = 1;
---------------------------------------------------------------------------------------
--Update Exam Question
CREATE PROCEDURE UpdateQuestionAndExam
    @Old_Q_Id INT, 
    @Old_Ex_Id INT, 
    @New_Q_Id INT,  
    @New_Ex_Id INT 
AS
BEGIN
    UPDATE Exam_Questions
    SET Q_Id = @New_Q_Id,
        Ex_Id = @New_Ex_Id
    WHERE Q_Id = @Old_Q_Id AND Ex_Id = @Old_Ex_Id;
END;
--test
EXEC UpdateQuestionAndExam @Old_Q_Id = 1, @Old_Ex_Id = 1, @New_Q_Id = 2, @New_Ex_Id = 2;
----------------------------------------------------------------------------------------
--Remove Question From Exam
CREATE PROCEDURE RemoveQuestionFromExam
    @Q_Id INT,
    @Ex_Id INT
AS
BEGIN
    DELETE FROM Exam_Questions
    WHERE Q_Id = @Q_Id AND Ex_Id = @Ex_Id;
END;
--test
EXEC RemoveQuestionFromExam @Q_Id = 1, @Ex_Id = 1;
---------------------------------------------------------------------------------------
--Get Questions By Exam
CREATE PROCEDURE GetQuestionsByExam
    @Ex_Id INT
AS
BEGIN
    SELECT q.*
    FROM Question q
    JOIN Exam_Questions eq ON q.Q_Id = eq.Q_Id
    WHERE eq.Ex_Id = @Ex_Id;
END;
--test
EXEC GetQuestionsByExam @Ex_Id = 1;
-------------------------------------
--Get All Exam Questions
CREATE PROCEDURE GetAllExamQuestions
AS
BEGIN
    SELECT eq.Q_Id, eq.Ex_Id, q.Q_Body, e.Ex_Name
    FROM Exam_Questions eq
    JOIN Question q ON eq.Q_Id = q.Q_Id
    JOIN Exam e ON eq.Ex_Id = e.Exam_ID;
END;
--test
EXEC GetAllExamQuestions;

--------------------------------------------------------------------------------------
--Insert Instructor
CREATE PROCEDURE AddInstructor
    @FName VARCHAR(50),
    @LName VARCHAR(50),
    @Gender VARCHAR(50) = NULL,
    @Email VARCHAR(50) = NULL,
    @Salary MONEY = NULL,
    @Password VARCHAR(50) = NULL,
    @Dept_Id INT = NULL
AS
BEGIN
    INSERT INTO Instructor (FName, LName, Gender, Email, Salary, Password, Dept_Id)
    VALUES (@FName, @LName, @Gender, @Email, @Salary, @Password, @Dept_Id);
END;
--test
EXEC AddInstructor @FName = 'Ahmed', @LName = 'Ali', @Gender = 'Male', @Email = 'ahmed.ali@example.com', @Salary = 5000, @Password = 'password123', @Dept_Id = 1;
--------------------------------------------------------------------------------------------
--Update Instructor
CREATE PROCEDURE UpdateInstructor
    @Ins_Id INT,
    @FName VARCHAR(50) = NULL,
    @LName VARCHAR(50) = NULL,
    @Gender VARCHAR(50) = NULL,
    @Email VARCHAR(50) = NULL,
    @Salary MONEY = NULL,
    @Password VARCHAR(50) = NULL,
    @Dept_Id INT = NULL
AS
BEGIN
    UPDATE Instructor
    SET FName = ISNULL(@FName, FName),
        LName = ISNULL(@LName, LName),
        Gender = ISNULL(@Gender, Gender),
        Email = ISNULL(@Email, Email),
        Salary = ISNULL(@Salary, Salary),
        Password = ISNULL(@Password, Password),
        Dept_Id = ISNULL(@Dept_Id, Dept_Id)
    WHERE Ins_Id = @Ins_Id;
END;
--test
EXEC UpdateInstructor @Ins_Id = 1, @FName = 'Mohamed', @Email = 'mohamed.ali@example.com';

-----------------------------------------------------------------------------------------
--Delete Instructor
CREATE or ALTER PROCEDURE DeleteInstructor
    @Ins_Id INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Department WHERE Dept_Manger = @Ins_Id)
    BEGIN
        PRINT 'Can`t Delete This Instrucor';
        RETURN;
    END;

    DELETE FROM Instructor
    WHERE Ins_Id = @Ins_Id;

    PRINT 'Delete Success';
END;
--test
EXEC DeleteInstructor @Ins_Id = 1;
-------------------------------------------------------------------------------------
--Get Instructor By Id
CREATE PROCEDURE GetInstructorById
    @Ins_Id INT
AS
BEGIN
    SELECT * FROM Instructor
    WHERE Ins_Id = @Ins_Id;
END;
--test
EXEC GetInstructorById @Ins_Id = 1;
------------------------------------------------------------------------------------
--Get All Instructors
CREATE PROCEDURE GetAllInstructors
AS
BEGIN
    SELECT * FROM Instructor;
END;
--test
EXEC GetAllInstructors;
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
--Student_Courses table--

--Insert a New Record

CREATE PROCEDURE AddStudentCourse
    @St_Id INT,
    @Crs_Id INT,
    @Enroll_date DATE
AS
BEGIN
    INSERT INTO student_courses (St_Id, Crs_Id, Enroll_date)
    VALUES (@St_Id, @Crs_Id, @Enroll_date);
END;

---------------------------------------------------------------
--Update an Existing Record

CREATE PROCEDURE UpdateStudentCourse
    @St_Id INT,
    @Crs_Id INT,
    @Enroll_date DATE
AS
BEGIN
    UPDATE student_courses
    SET Enroll_date = @Enroll_date
    WHERE St_Id = @St_Id AND Crs_Id = @Crs_Id;
END;

---------------------------------------------------------------------
--Delete a Record

CREATE PROCEDURE DeleteStudentCourse
    @St_Id INT,
    @Crs_Id INT
AS
BEGIN
    DELETE FROM student_courses
    WHERE St_Id = @St_Id AND Crs_Id = @Crs_Id;
END;

------------------------------------------------------------------
--Retrieve Records

--a) Get all enrollments

CREATE PROCEDURE GetAllStudentCourses
AS
BEGIN
    SELECT * FROM student_courses;
END;

--b) Get enrollments for a specific student:

CREATE PROCEDURE GetCoursesByStudent
    @St_Id INT
AS
BEGIN
    SELECT * FROM student_courses WHERE St_Id = @St_Id;
END;

--c) Get students enrolled in a specific course:

CREATE PROCEDURE GetStudentsByCourse
    @Crs_Id INT
AS
BEGIN
    SELECT * FROM student_courses WHERE Crs_Id = @Crs_Id;
END;

------------------------------------------------------------------

--Student_Exams table--

--Insert a New Record

CREATE PROCEDURE AddStudentExam
    @Ex_Id INT,
    @Std_Id INT
AS
BEGIN
    INSERT INTO Student_Exams (Ex_Id, Std_Id)
    VALUES (@Ex_Id, @Std_Id);
END;

---------------------------------------------------------------

--Update an Existing Record

CREATE PROCEDURE UpdateStudentExam
    @Old_Ex_Id INT,
    @Old_Std_Id INT,
    @New_Ex_Id INT,
    @New_Std_Id INT
AS
BEGIN
    UPDATE Student_Exams
    SET Ex_Id = @New_Ex_Id, Std_Id = @New_Std_Id
    WHERE Ex_Id = @Old_Ex_Id AND Std_Id = @Old_Std_Id;
END;

---------------------------------------------------------------

--Delete a Record

CREATE PROCEDURE DeleteStudentExam
    @Ex_Id INT,
    @Std_Id INT
AS
BEGIN
    DELETE FROM Student_Exams
    WHERE Ex_Id = @Ex_Id AND Std_Id = @Std_Id;
END;

--------------------------------------------------------

--Retrieve Records

--a) Get all student-exam records:

CREATE PROCEDURE GetAllStudentExams
AS
BEGIN
    SELECT * FROM Student_Exams;
END;

--b) Get all exams a student is registered for:

CREATE PROCEDURE GetExamsByStudent
    @Std_Id INT
AS
BEGIN
    SELECT * FROM Student_Exams WHERE Std_Id = @Std_Id;
END;

--c) Get all students registered for a specific exam:

CREATE PROCEDURE GetStudentsByExam
    @Ex_Id INT
AS
BEGIN
    SELECT * FROM Student_Exams WHERE Ex_Id = @Ex_Id;
END;

------------------------------------------------------------------------

--Student_Answers table--

--Insert a New Answer

CREATE PROCEDURE AddStudentAnswer
    @St_Id INT,
    @Ex_Id INT,
    @Q_Id INT,
    @Answer NVARCHAR(MAX)
AS
BEGIN
    INSERT INTO Student_Answers (St_Id, Ex_Id, Q_Id, Answer)
    VALUES (@St_Id, @Ex_Id, @Q_Id, @Answer);
END;

-----------------------------------------------------

--Update an Answer

CREATE PROCEDURE UpdateStudentAnswer
    @St_Id INT,
    @Ex_Id INT,
    @Q_Id INT,
    @Answer NVARCHAR(MAX)
AS
BEGIN
    UPDATE Student_Answers
    SET Answer = @Answer
    WHERE St_Id = @St_Id AND Ex_Id = @Ex_Id AND Q_Id = @Q_Id;
END;

------------------------------------------------------------------

--Delete an Answer

CREATE PROCEDURE DeleteStudentAnswer
    @St_Id INT,
    @Ex_Id INT,
    @Q_Id INT
AS
BEGIN
    DELETE FROM Student_Answers
    WHERE St_Id = @St_Id AND Ex_Id = @Ex_Id AND Q_Id = @Q_Id;
END;

------------------------------------------------------------------------

--Retrieve Answers

--a) Get all student answers:

CREATE PROCEDURE GetAllStudentAnswers
AS
BEGIN
    SELECT * FROM Student_Answers;
END;

--b) Get answers for a specific student in an exam:

CREATE PROCEDURE GetAnswersByStudentExam
    @St_Id INT,
    @Ex_Id INT
AS
BEGIN
    SELECT * FROM Student_Answers
    WHERE St_Id = @St_Id AND Ex_Id = @Ex_Id;
END;

--c) Get all students' answers for a specific exam question:

CREATE PROCEDURE GetAnswersByQuestion
    @Ex_Id INT,
    @Q_Id INT
AS
BEGIN
    SELECT * FROM Student_Answers
    WHERE Ex_Id = @Ex_Id AND Q_Id = @Q_Id;
END;

-------------------------------------------------------------
-------------------------------------------------------------
--Insert Course
CREATE PROCEDURE AddCourse
    @Crs_Name VARCHAR(50)
AS
BEGIN
    INSERT INTO Course (Crs_Name)
    VALUES (@Crs_Name);
END;
--test
EXEC AddCourse @Crs_Name = 'Database Systems';

--------------------------------------------------------------------------------
--Update Course
CREATE PROCEDURE UpdateCourse
    @Crs_Id INT,
    @Crs_Name VARCHAR(50) = NULL
AS
BEGIN
    UPDATE Course
    SET Crs_Name = ISNULL(@Crs_Name, Crs_Name)
    WHERE Crs_Id = @Crs_Id;
END;
--test
EXEC UpdateCourse @Crs_Id = 1, @Crs_Name = 'Advanced Database Systems';
---------------------------------------------------------------------------------

--Delete Course
create or Alter PROCEDURE DeleteCourse
    @Crs_Id INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Student_Courses WHERE Crs_Id = @Crs_Id)
    BEGIN
        PRINT 'Can`t Delete this Course';
        RETURN;
    END;

    DELETE FROM Course
    WHERE Crs_Id = @Crs_Id;

    PRINT 'Delete Success';
END;
---test
EXEC DeleteCourse @Crs_Id = 1;
---------------------------------------------------------------------------------

--Get Course By Id
CREATE PROCEDURE GetCourseById
    @Crs_Id INT
AS
BEGIN
    SELECT * FROM Course
    WHERE Crs_Id = @Crs_Id;
END;
--test
EXEC GetCourseById @Crs_Id = 1;
--------------------------------------------------------------------------------

--Get All Courses
CREATE PROCEDURE GetAllCourses
AS
BEGIN
    SELECT * FROM Course;
END;
--test
EXEC GetAllCourses;

------------------------------------------------------------------------------


--Add Department
CREATE PROCEDURE AddDepartment
    @Dept_Name VARCHAR(50),
    @Dept_Location VARCHAR(50) = NULL,
    @Dept_Manger INT = NULL,
    @Manger_hiredate DATE = NULL
AS
BEGIN
    INSERT INTO Department (Dept_Name, Dept_Location, Dept_Manger, Manger_hiredate)
    VALUES (@Dept_Name, @Dept_Location, @Dept_Manger, @Manger_hiredate);
END;
--test
EXEC AddDepartment @Dept_Name = 'Computer Science', @Dept_Location = 'Building A', @Dept_Manger = 1, @Manger_hiredate = '2023-01-01';

-------------------------------------------------------------------------------------
--Update Department
CREATE PROCEDURE UpdateDepartment
    @Dept_id INT,
    @Dept_Name VARCHAR(50) = NULL,
    @Dept_Location VARCHAR(50) = NULL,
    @Dept_Manger INT = NULL,
    @Manger_hiredate DATE = NULL
AS
BEGIN
    UPDATE Department
    SET Dept_Name = ISNULL(@Dept_Name, Dept_Name),
        Dept_Location = ISNULL(@Dept_Location, Dept_Location),
        Dept_Manger = ISNULL(@Dept_Manger, Dept_Manger),
        Manger_hiredate = ISNULL(@Manger_hiredate, Manger_hiredate)
    WHERE Dept_id = @Dept_id;
END;
--test
EXEC UpdateDepartment @Dept_id = 1, @Dept_Name = 'Information Technology', @Dept_Location = 'Building B';

--------------------------------------------------------------------------------------

--Delete Department
create or Alter PROCEDURE DeleteDepartment
    @Dept_id INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Student WHERE Dept_Id = @Dept_id)
    BEGIN
        PRINT 'Can`t Delete This Department';
        RETURN;
    END;

    DELETE FROM Department
    WHERE Dept_id = @Dept_id;

    PRINT 'Delete Success';
END;

EXEC DeleteDepartment @Dept_id = 1;
--------------------------------------------------------------------------------------
--Get Department By Id
CREATE PROCEDURE GetDepartmentById
    @Dept_id INT
AS
BEGIN
    SELECT * FROM Department
    WHERE Dept_id = @Dept_id
END
--test
EXEC GetDepartmentById @Dept_id = 1;
---------------------------------------------------------------------------------
CREATE PROCEDURE GetAllDepartments
AS
BEGIN
    SELECT * FROM Department;
END;
--test
EXEC GetAllDepartments;

----------------------------------------------------------------------------------------

--Add Option
CREATE PROCEDURE AddOption
    @Op_Id INT,
    @Q_Id INT,
    @Op_Body VARCHAR(100)
AS
BEGIN
    INSERT INTO Options (Op_Id, Q_Id, Op_Body)
    VALUES (@Op_Id, @Q_Id, @Op_Body);
END;
--test
EXEC AddOption @Op_Id = 1, @Q_Id = 1, @Op_Body = 'Option A';

--------------------------------------------------------------------------
--Update Option
CREATE PROCEDURE UpdateOption
    @Op_Id INT,
    @Q_Id INT,
    @Op_Body VARCHAR(100) = NULL
AS
BEGIN
    UPDATE Options
    SET Op_Body = ISNULL(@Op_Body, Op_Body)
    WHERE Op_Id = @Op_Id AND Q_Id = @Q_Id;
END;
--test
EXEC UpdateOption @Op_Id = 1, @Q_Id = 1, @Op_Body = 'Updated Option A';

---------------------------------------------------------------------------------
--Delete Option
CREATE PROCEDURE DeleteOption
    @Op_Id INT,
    @Q_Id INT
AS
BEGIN
    DELETE FROM Options
    WHERE Op_Id = @Op_Id AND Q_Id = @Q_Id;
END;
--test
EXEC DeleteOption @Op_Id = 1, @Q_Id = 1;

---------------------------------------------------------------------------------
--Get Option By Id
CREATE PROCEDURE GetOptionById
    @Op_Id INT,
    @Q_Id INT
AS
BEGIN
    SELECT * FROM Options
    WHERE Op_Id = @Op_Id AND Q_Id = @Q_Id;
END;
--test
EXEC GetOptionById @Op_Id = 1, @Q_Id = 1;

--------------------------------------------------------------------------------
--Get Options By Question
CREATE PROCEDURE GetOptionsByQuestion
    @Q_Id INT
AS
BEGIN
    SELECT * FROM Options
    WHERE Q_Id = @Q_Id;
END;
--test
EXEC GetOptionsByQuestion @Q_Id = 1;

-----------------------------------------------------------------------------
--Get All Options
CREATE PROCEDURE GetAllOptions
AS
BEGIN
    SELECT * FROM Options;
END;
--test
EXEC GetAllOptions;

------------------------------------------------------------------------------
--Add Instructor Course
CREATE PROCEDURE AddInstructorCourse
    @Ins_Id INT,
    @Crs_Id INT
AS
BEGIN
    INSERT INTO Instructor_Courses (Ins_Id, Crs_Id)
    VALUES (@Ins_Id, @Crs_Id);
END;
--test
EXEC AddInstructorCourse @Ins_Id = 1, @Crs_Id = 1;


-----------------------------------------------------------------------------
--Update Instructor Course
CREATE PROCEDURE UpdateInstructorCourse
    @Old_Ins_Id INT,  
    @Old_Crs_Id INT,  
    @New_Ins_Id INT,  
    @New_Crs_Id INT
as	
BEGIN
    UPDATE Instructor_Courses
    SET Ins_Id = @New_Ins_Id,
        Crs_Id = @New_Crs_Id
    WHERE Ins_Id = @Old_Ins_Id AND Crs_Id = @Old_Crs_Id
END
--test
EXEC UpdateInstructorCourse @Old_Ins_Id = 1, @Old_Crs_Id = 1, @New_Ins_Id = 2, @New_Crs_Id = 2;

-------------------------------------------------------------------------
--DeleteInstructor Course
CREATE PROCEDURE DeleteInstructorCourse
    @Ins_Id INT,
    @Crs_Id INT
AS
BEGIN
    DELETE FROM Instructor_Courses
    WHERE Ins_Id = @Ins_Id AND Crs_Id = @Crs_Id;
END;
--test
EXEC DeleteInstructorCourse @Ins_Id = 1, @Crs_Id = 1;

---------------------------------------------------------------------
--Get Courses By Instructor
CREATE PROCEDURE GetCoursesByInstructor
    @Ins_Id INT
AS
BEGIN
    SELECT c.*
    FROM Course c
    JOIN Instructor_Courses ic ON c.Crs_Id = ic.Crs_Id
    WHERE ic.Ins_Id = @Ins_Id;
END;
--test
EXEC GetCoursesByInstructor @Ins_Id = 1;

------------------------------------------------------------------------
--Get Instructors By Course
CREATE PROCEDURE GetInstructorsByCourse
    @Crs_Id INT
AS
BEGIN
    SELECT i.*
    FROM Instructor i
    JOIN Instructor_Courses ic ON i.Ins_Id = ic.Ins_Id
    WHERE ic.Crs_Id = @Crs_Id;
END;
--test
EXEC GetInstructorsByCourse @Crs_Id = 1;

-----------------------------------------------------------------------------
--Get All Instructor Courses
CREATE PROCEDURE GetAllInstructorCourses
AS
BEGIN
    SELECT ic.Ins_Id, ic.Crs_Id, i.FName, i.LName, c.Crs_Name
    FROM Instructor_Courses ic
    JOIN Instructor i ON ic.Ins_Id = i.Ins_Id
    JOIN Course c ON ic.Crs_Id = c.Crs_Id;
END;
--test
EXEC GetAllInstructorCourses;

-------------------------------------------------------------------------------
--Add Question
CREATE PROCEDURE AddQuestion
    @Correct_Answer INT = NULL,
    @Q_Body VARCHAR(150),
    @Type VARCHAR(3),
    @Grade INT,
    @Crs_Id INT
AS
BEGIN
    INSERT INTO Question (Correct_Answer, Q_Body, Type, Grade, Crs_Id)
    VALUES (@Correct_Answer, @Q_Body, @Type, @Grade, @Crs_Id);
END;
--test
EXEC AddQuestion @Correct_Answer = 1, @Q_Body = 'What is SQL?', @Type = 'MCQ', @Grade = 10, @Crs_Id = 1;

---------------------------------------------------------------------------------
--Update Question
CREATE PROCEDURE UpdateQuestion
    @Q_Id INT,
    @Correct_Answer INT = NULL,
    @Q_Body VARCHAR(150) = NULL,
    @Type VARCHAR(3) = NULL,
    @Grade INT = NULL,
    @Crs_Id INT = NULL
AS
BEGIN
    UPDATE Question
    SET Correct_Answer = ISNULL(@Correct_Answer, Correct_Answer),
        Q_Body = ISNULL(@Q_Body, Q_Body),
        Type = ISNULL(@Type, Type),
        Grade = ISNULL(@Grade, Grade),
        Crs_Id = ISNULL(@Crs_Id, Crs_Id)
    WHERE Q_Id = @Q_Id;
END;
--test
EXEC UpdateQuestion @Q_Id = 1, @Q_Body = 'What is a database?', @Grade = 15;

---------------------------------------------------------------------------------
--Delete Question
CREATE or Alter PROCEDURE DeleteQuestion
    @Q_Id INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Student_Answers WHERE Q_Id = @Q_Id)
    BEGIN
        PRINT 'Can`t Delete This Question';
        RETURN;
    END;

    DELETE FROM Question
    WHERE Q_Id = @Q_Id;

    PRINT 'Delete Success';
END;
--test
EXEC DeleteQuestion @Q_Id = 1;

------------------------------------------------------------------------------------
--Get Question By Id
CREATE PROCEDURE GetQuestionById
    @Q_Id INT
AS
BEGIN
    SELECT * FROM Question
    WHERE Q_Id = @Q_Id;
END;
--test
EXEC GetQuestionById @Q_Id = 1;

--------------------------------------------------------------
--Get All Questions
CREATE PROCEDURE GetAllQuestions
AS
BEGIN
    SELECT * FROM Question;
END;
--test
EXEC GetAllQuestions;
