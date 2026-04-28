create database practice_one;
use practice_one;
-- ---------------------------------------stored procedure---------------------------------------------
CREATE TABLE students ( student_id INT PRIMARY KEY, student_name VARCHAR(100), marks INT );
INSERT INTO students VALUES (1, 'Ravi', 85), 
							(2, 'Priya', 92),
                            (3, 'Arjun', 70),
                            (4, 'Sneha', 95);
-- Create a stored procedure to display all student details
DELIMITER //
CREATE PROCEDURE stu_all()
begin 
select * from students;
end //
DELIMITER ;
call stu_all();

-- Write a procedure to return the average marks of all students.
DELIMITER //
CREATE PROCEDURE STU_AVG()
BEGIN
SELECT AVG(MARKS)  FROM STUDENTS;
END //
DELIMITER ;
CALL STU_AVG();

-- Write a procedure to display top N students based on marks.
DELIMITER //
CREATE PROCEDURE TOP_STU(IN N INT)
BEGIN
SELECT * FROM STUDENTS ORDER BY MARKS DESC LIMIT N;
END //
DELIMITER ;
CALL TOP_STU(1);

-- Write a procedure to check whether a student exists using student_id. Return 'Exists' or 'Not Exists'.
DELIMITER //
CREATE PROCEDURE STU_EXI(IN STU_ID INT)
BEGIN
	IF EXISTS(SELECT STUDENT_ID FROM STUDENTS WHERE STUDENT_ID = STU_ID ) THEN
		SELECT 'STUDENT EXISTS' AS MESSAGE;
    ELSE
		SELECT 'STUDENT DOES NOT EXISTS' AS MESSAGE;
	END IF;
END //
DELIMITER ;
CALL STU_EXI(8);

-- Write a procedure to delete a student using student_id.
DELIMITER //
CREATE PROCEDURE STU_DEL(IN N INT)
BEGIN
	DELETE FROM STUDENTS WHERE STUDENT_ID = N;
END //
DELIMITER ;
CALL STU_DEL(3);
SELECT * FROM STUDENTS;

-- Write a procedure to count how many students scored above average marks.
DELIMITER //
CREATE PROCEDURE STU_COUNT()
BEGIN
SELECT COUNT(*) FROM STUDENTS WHERE MARKS > (SELECT AVG(MARKS) FROM STUDENTS);
END //
DELIMITER ;
CALL STU_COUNT;

-- Write a procedure to increase marks of all students by a given percentage.
DELIMITER //
CREATE PROCEDURE IncreaseMarks(IN percent INT)
BEGIN
    UPDATE students
    SET marks = marks + (marks * percent / 100);
END //
DELIMITER ;
SET SQL_SAFE_UPDATES = 1;
CALL IncreaseMarks(100);

-- Write a procedure to print numbers from 1 to 5 using a loop.
DELIMITER //
CREATE PROCEDURE PRINT_NUM(IN N INT)
BEGIN
	DECLARE I INT DEFAULT 1;
    WHILE I <=N DO
		SELECT I;
    SET I = I+1;
	END WHILE;
END //
DELIMITER ;
CALL PRINT_NUM(5);

-- Write a procedure to print even numbers from 1 to N.
DELIMITER //
CREATE PROCEDURE EVE_NUMIN(IN N INT)
BEGIN
	DECLARE I INT DEFAULT 1;
    WHILE I<=N DO 
		SELECT I WHERE I % 2 = 0;
	SET I = I+1;
	END WHILE;
END //
DELIMITER ;
CALL EVE_NUMIN(10);

-- Write a procedure to calculate sum of numbers from 1 to N.
DELIMITER //
CREATE PROCEDURE SUM_NUMS(IN N INT)
BEGIN
	DECLARE I INT DEFAULT 1;
    DECLARE SUM INT DEFAULT 0;
    WHILE I <= N DO
		SET SUM = SUM + I;
		SET I = I+1;
    END WHILE;
		SELECT SUM;
END //
DELIMITER ;
CALL SUM_NUMS(10);
DROP PROCEDURE SUM_NUM;
DROP PROCEDURE SUM_NU;

-- Write a procedure to calculate factorial of a number.
DELIMITER //
CREATE PROCEDURE FAC_NUM(IN N INT)
BEGIN
	DECLARE I INT DEFAULT N;
    DECLARE PROD INT DEFAULT 1;
	WHILE I> 0 DO 
		SET PROD = PROD * I;
		SET I = I- 1;
	END WHILE;
		SELECT PROD AS PRODUCT;
END //
DELIMITER ;
CALL FAC_NUM(4);

-- Write a procedure to print all student names one by one using loop.
DELIMITER //
CREATE PROCEDURE PrintStudents()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total INT;
    SELECT COUNT(*) INTO total FROM students;
    WHILE i < total DO
        SELECT student_name
        FROM students
        LIMIT i, 1;
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;
call PrintStudents;

-- -------------------- TRIGGERS---------------------------------
CREATE TABLE employees_main (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    salary INT
);
CREATE TABLE employee_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    message VARCHAR(255)
);

-- Whenever a new employee is inserted into employees_main, automatically store a message in employee_log.
DELIMITER //
CREATE TRIGGER MES_EMP
AFTER INSERT ON employees_main 
FOR EACH ROW 
BEGIN 
	INSERT INTO EMPLOYEE_LOG(MESSAGE) VALUES (CONCAT('NEW EMPLOYEE ADDED:',NEW.EMP_NAME));
END //
DELIMITER ;
INSERT INTO EMPLOYEES_MAIN(EMP_ID,EMP_NAME,SALARY) VALUES (1,'KIRAN',1000000);
INSERT INTO EMPLOYEES_MAIN(EMP_ID,EMP_NAME,SALARY) VALUES (2,'RAHUL',500000000);
SELECT * FROM EMPLOYEE_LOG;

CREATE TABLE salary_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_name VARCHAR(100),
    old_salary INT,
    new_salary INT
);
-- Whenever an employee salary is updated, store the old salary and new salary in a log table.
DELIMITER //
CREATE TRIGGER after_salary_update
AFTER UPDATE
ON employees_main
FOR EACH ROW
BEGIN
    INSERT INTO salary_log(emp_name, old_salary, new_salary) VALUES (OLD.emp_name, OLD.salary, NEW.salary);
END //
DELIMITER ;
UPDATE EMPLOYEES_MAIN SET SALARY = 53405394 WHERE EMP_ID = 1;
select * FROM SALARY_LOG;

-- Do not allow inserting a record if salary is negative.
DELIMITER //
CREATE TRIGGER NEG_INSERT
BEFORE INSERT ON EMPLOYEES_MAIN
FOR EACH ROW
BEGIN 
		IF NEW.SALARY < 0 THEN  SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Salary cannot be negative';
        ELSE 
			INSERT INTO salary_log(emp_name, old_salary, new_salary) VALUES (NEW.emp_name, NEW.salary, NEW.salary);
		END IF;
END //
DELIMITER ;
INSERT INTO EMPLOYEES_MAIN(EMP_ID,EMP_NAME,SALARY) VALUES (3,'manas',-500000000);

-- Do not allow reducing an employee's salary.
DELIMITER //
CREATE TRIGGER RED_SALARY
BEFORE UPDATE ON EMPLOYEES_MAIN
FOR EACH ROW
BEGIN 
	IF NEW.SALARY < OLD.SALARY THEN SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'CANNOT REDUCE THE VALUE OF SALARY';
    END IF;
END //
DELIMITER ;
UPDATE EMPLOYEES_MAIN SET SALARY = '293723' WHERE EMP_ID =1;

-- If salary is less than 10000, automatically set it to 10000.
DELIMITER //
CREATE TRIGGER min_salary_set
BEFORE INSERT
ON employees_main
FOR EACH ROW
BEGIN
    IF NEW.salary < 10000 THEN
        SET NEW.salary = 10000;
    END IF;
END //
DELIMITER ;
INSERT INTO EMPLOYEES_MAIN(EMP_ID,EMP_NAME,SALARY) VALUES (4,'manas',5000);
SELECT * FROM employees_main;

-- If employee name is updated, log old and new name in employee_log.
DELIMITER //
CREATE TRIGGER log_name_change
AFTER UPDATE
ON employees_main
FOR EACH ROW
BEGIN
	IF OLD.EMP_NAME <> NEW.EMP_NAME THEN
    INSERT INTO EMPLOYEE_LOG(MESSAGE) VALUES (CONCAT('NAME CHANGED FROM ', OLD.EMP_NAME,' TO NEW NAME: ',NEW.EMP_NAME));
    END IF;
END //
DELIMITER ;
UPDATE EMPLOYEES_MAIN SET EMP_NAME='KUMAR' WHERE EMP_ID =4;
SELECT * FROM EMPLOYEE_LOG;

-- Do not allow salary to be increased more than double in a single update.
DELIMITER //
CREATE TRIGGER limit_salary_increase
BEFORE UPDATE
ON employees_main
FOR EACH ROW
BEGIN
    IF NEW.salary > OLD.salary * 2 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary increase too large';
    END IF;
END //
DELIMITER ;
