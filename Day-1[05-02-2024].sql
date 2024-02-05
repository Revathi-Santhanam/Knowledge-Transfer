-- Table and Database creation
-------------------------------

CREATE DATABASE IF NOT EXISTS sample;

-- To find number of procedures

SHOW PROCEDURE STATUS WHERE db = 'sample';

USE sample;

-- CREATING employee table
CREATE TABLE IF NOT EXISTS employees(
employee_id INT PRIMARY KEY,
first_name	varchar(25),
last_name	varchar(25),
email		varchar(25),
phone_number	varchar(15),
hire_date	date,
job_id		varchar(25),
salary		INT,
commission_pct	decimal(5,2),
manager_id		INT,
department_id	INT
);

-- CREATING Departments table
CREATE TABLE IF NOT EXISTS departments(
department_id		INT PRIMARY KEY,
department_name		varchar(25),
manager_id			INT,
location_id			INT
);

-- creating jobs table
CREATE TABLE IF NOT EXISTS jobs (
    job_id VARCHAR(10) PRIMARY KEY,
    job_title VARCHAR(35),
    min_salary DECIMAL(6,0),
    max_salary DECIMAL(6,0)
);

------------------------------------------------------------------------------------------------------------------

-- creating foreign key
ALTER TABLE employees ADD CONSTRAINT fk_dept FOREIGN KEY(department_id) REFERENCES departments(department_id);
ALTER TABLE employees ADD CONSTRAINT fk_job FOREIGN KEY(job_id) REFERENCES jobs(job_id);



-- INSERT statements for employees table
INSERT INTO employees VALUES
(100, 'John', 'Doe', 'john.doe@gmail.com', '7876787678', '1986-01-01', '1', 50000, 0.05, NULL, 4),
(101, 'Jane', 'Smith', 'jane.smith@gmail.com', '9898898987', '2002-02-01', '2', 40000, 0.03, 100, 4),
(102, 'David', 'Johnson', 'david.johnson@gmail.com', '6565676757', '1997-03-15', '3', 35000, 0.02, 100, 4),
(103, 'George', 'David', 'david.george@gmail.com', '7878767689', '2000-03-15', '1', 45000, 0.05, NULL, 1),
(104, 'Adan', 'Smith', 'jane.adan@gmail.com', '8787676768', '1995-03-15', '4', 35000, 0.03, 103, 1),
(105, 'Claire', 'Joe', 'joe.claire@gmail.com', '6789876589', '1988-03-15', '3', 30000, 0.02, 103, 1),
(106, 'Ray', 'Chan', 'chan.ray@gmail.com', '9875676787', '1900-03-15', '1', 45000, 0.05, NULL, 1),
(107, 'Harry', 'Haran', 'haran.harry@gmail.com', '6776678987', '1980-03-15','5' , 35000, 0.03, 106, 1),
(108, 'Anisha', 'Yash', 'yash.anisha@gmail.com', '9898987878', '1990-03-15', '6', 30000, 0.02, 106, 1),
(109, 'Kiran', 'Fred', 'fred.kiran@gmail.com', '9898987878', '1990-03-15', '1', 40000, 0.05, NULL, 1),
(110, 'Anisha', 'Yash', 'yash.anisha@gmail.com', '9898987878', '1990-03-15', '7', 30000, 0.03, 109, 1);

-- INSERT statements for departments table
INSERT INTO departments VALUES
(1, 'Sales', 103, 1),
(2, 'Finance', 106, 2),
(3, 'Human Resources', 109, 3),
(4, 'IT', 100, 4);

INSERT INTO jobs (job_id, job_title, min_salary, max_salary)
VALUES
    ('1', 'Manager', 40000, 50000),
    ('2', 'Developer', 35000, 60000),
    ('3', 'Analyst', 30000, 55000),
    ('4', 'Supervisor', 35000, 55000),
    ('5', 'Accountant', 35000, 55000),
    ('6', 'Clerk', 30000, 55000),
    ('7', 'Assistant', 30000, 55000);

SELECT * FROM employees;

----------------------------------------------------------------------------------------------------------------------------------
-- 1.Write a PL/SQL procedure to display the total number of employees hired each year between 1985 and 2000. 
--Return the result in tabular format.
==============================================================================================================================


DELIMITER &&

CREATE PROCEDURE TotalEmployeesHiredPerYear()
BEGIN
    DECLARE start_year INT DEFAULT 1985;
    DECLARE end_year INT DEFAULT 2000;
    DECLARE current_year INT;
    DECLARE total_employees_count INT;  -- Move the declaration outside the loop
    
    -- Temporary table to store the result
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_result (
        hire_year INT,
        total_employees INT
    );

    SET current_year = start_year;

    -- Loop through each year
    WHILE current_year <= end_year DO
        -- Reset the variable for storing the total number of employees hired in the current year
        SET total_employees_count = 0;

        -- Calculate the total number of employees hired in the current year
        SELECT COUNT(*) INTO total_employees_count
        FROM employees
        WHERE YEAR(hire_date) = current_year;

        -- Insert the result into the temporary table
        INSERT INTO temp_result (hire_year, total_employees) VALUES (current_year, total_employees_count);

        -- Move to the next year
        SET current_year = current_year + 1;
    END WHILE;

    -- Display the result
    SELECT * FROM temp_result;

    -- Drop the temporary table
    DROP TEMPORARY TABLE IF EXISTS temp_result;

END &&

DELIMITER ;

-- calling procedure 1.

CALL TotalEmployeesHiredPerYear();

--------------------------------------------------------------------------------------------------------------------------------

-- 2.Write a PL/SQL procedure to count number of employees in department 4 and check whether this department have any 
--vacancies or not. There are 40 vacancies in this department.
=================================================================================================================================

DELIMITER &&

CREATE PROCEDURE CheckDepartmentVacancies()
BEGIN
    -- Declare a variable to store the total number of employees
    DECLARE tot_emp INT;
    
    -- Calculate the total number of employees in department 3
    SELECT COUNT(*) INTO tot_emp
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    WHERE e.department_id = 3;

    -- Display the result of the employee count
    SELECT CONCAT('The employees in department 3: ', tot_emp) AS result;
    
    -- Check if there are no vacancies or some vacancies in department 4
    IF tot_emp >= 40 THEN
        SELECT 'There are no vacancies in department 4.' AS result;
    ELSE
        SELECT 'There are some vacancies in department 4.' AS result;
    END IF;
END &&

DELIMITER ;

-- calling procedure 2.

CALL CheckDepartmentVacancies();

---------------------------------------------------------------------------------------------------------------------------------
--3.Write a procedure to update the salary of a specific employee by 8% if the salary exceeds the mid range of the salary against this job and update up to mid range 
--if the salary is less than the mid range of the salary, and display a suitable message.
==================================================================================================================================

DELIMITER &&

CREATE PROCEDURE UpdateEmployeeSalary()
BEGIN
    DECLARE emp_min_salary DECIMAL(6,0);
    DECLARE emp_max_salary DECIMAL(6,0);
    DECLARE emp_mid_salary DECIMAL(6,2);
    DECLARE tmp_salary DECIMAL(6,2);
    DECLARE tmp_emp_id INT DEFAULT 167;
    DECLARE tmp_emp_name VARCHAR(25);

    -- Get min_salary and max_salary for the job of the employee 
    SELECT min_salary, max_salary
    INTO emp_min_salary, emp_max_salary
    FROM jobs
    WHERE job_id = (SELECT job_id
                    FROM employees
                    WHERE employee_id = tmp_emp_id);

    -- Calculate mid-range
    SET emp_mid_salary := (emp_min_salary + emp_max_salary) / 2;

    -- Get salary and first_name of the given employee
    SELECT salary, first_name
    INTO tmp_salary, tmp_emp_name
    FROM employees
    WHERE employee_id = tmp_emp_id;

    -- Update salary
    IF tmp_salary < emp_mid_salary THEN
        UPDATE employees
        SET salary = emp_mid_salary
        WHERE employee_id = tmp_emp_id;
    ELSE
        UPDATE employees
        SET salary = salary + salary * 0.08
        WHERE employee_id = tmp_emp_id;
    END IF;

    -- Display message
    IF tmp_salary > emp_mid_salary THEN
        SELECT CONCAT('The employee ', tmp_emp_name, ' ID ', CAST(tmp_emp_id AS CHAR),
                      ' works in salary ', CAST(tmp_salary AS CHAR),
                      ' which is higher than mid-range of salary ', CAST(emp_mid_salary AS CHAR)) AS message;
    ELSEIF tmp_salary < emp_mid_salary THEN
        SELECT CONCAT('The employee ', tmp_emp_name, ' ID ', CAST(tmp_emp_id AS CHAR),
                      ' works in salary ', CAST(tmp_salary AS CHAR),
                      ' which is lower than mid-range of salary ', CAST(emp_mid_salary AS CHAR)) AS message;
    ELSE
        SELECT CONCAT('The employee ', tmp_emp_name, ' ID ', CAST(tmp_emp_id AS CHAR),
                      ' works in salary ', CAST(tmp_salary AS CHAR),
                      ' which is equal to the mid-range of salary ', CAST(emp_mid_salary AS CHAR)) AS message;
    END IF;
END &&

DELIMITER ;

-- calling procedure 3.

CALL UpdateEmployeeSalary();





