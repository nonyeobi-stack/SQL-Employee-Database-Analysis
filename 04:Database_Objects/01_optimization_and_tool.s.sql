/* Database Engineering & Performance Optimization 
   PURPOSE: Building tools to make the database faster and easier to use. 
   TECHNIQUES: Views, Stored Procedure, Functions, and Indexes. 
*/

-- Creating Views to acts as shortcuts instead of typing out complex queries everyday -- 

CREATE OR REPLACE VIEW v_current_employees AS
    SELECT 
    s1.emp_no AS 'Employee Number',
    s.salary AS 'Employee Salary',
    s.from_date AS 'Contract Start Date',
    s.to_date AS 'Contract End Date'
FROM
    salaries s
        JOIN
    (SELECT 
        emp_no, MAX(from_date) AS from_date
    FROM
        salaries
    GROUP BY emp_no) s1 ON s.emp_no = s1.emp_no
WHERE
    s.to_date > SYSDATE()
        AND s.from_date = s1.from_date;
-- This virtual table stays updated automatically. To use this view run:
   SELECT * FROM v_current_employees;
   
   
CREATE OR REPLACE VIEW v_current_manager_salary AS
    SELECT 
    d.dept_no AS 'Department Number',
    d.dept_name AS 'Department Name',
    e.first_name AS 'Dept Manager First Name',
    e.last_name AS 'Dept Manager Last Name',
    s.salary AS 'Dept Manager Salary'
FROM
    dept_manager dm
        JOIN
    employees e ON dm.emp_no = e.emp_no
        JOIN
    salaries s ON dm.emp_no = s.emp_no
        JOIN
    departments d ON dm.dept_no = d.dept_no
WHERE
    dm.to_date = '9999-01-01'
        AND s.to_date = '9999-01-01';
-- To use this view run:
SELECT * FROM v_current_manager_salary;


/* AUTOMATION: Building Stored Procedure to automate repetitive lookups. 
   Think of this as a button: you provide an employee id,
   and the database runs a full history report of that person 
*/ 

DELIMITER $$ 

CREATE PROCEDURE emp_salary_history (IN p_emp_no INTEGER) 
BEGIN 
    
    SELECT 
        e.first_name, e.last_name, s.salary, s.from_date, s.to_date 
	FROM 
        employees e
           JOIN 
		salaries s ON e.emp_no = s.emp_no 
	WHERE 
        e.emp_no = p_emp_no;
        
END $$

DELIMITER ;
-- To invoke this procedure, run: CALL emp_salary_history('input your desired employee number');
-- e.g 
CALL emp_salary_history(11000);


DELIMITER $$ 

CREATE PROCEDURE emp_avg_salary (IN p_emp_no INTEGER) 
BEGIN 

    SELECT 
        e.first_name, 
        e.last_name, 
        AVG(s.salary) as avg_salary 
	FROM 
        employees e 
           JOIN 
		salaries s ON e.emp_no = s.emp_no 
	WHERE 
        e.emp_no = p_emp_no
	GROUP BY e.emp_no;
        
END $$ 

DELIMITER ;

-- Let ivnoke this procedure 
CALL emp_avg_salary(11000);


DELIMITER $$

CREATE PROCEDURE emp_info (IN p_emp_no INT, OUT p_salary DECIMAL(10,2), OUT p_dept_name VARCHAR(25))
BEGIN

    SELECT 
        s.salary, d.dept_name 
	INTO p_salary, p_dept_name FROM
        employees e
          JOIN 
		salaries s ON e.emp_no = s.emp_no
          JOIN 
		dept_emp de ON e.emp_no = de.emp_no
          JOIN 
		departments d ON de.dept_no = d.dept_no
    WHERE e.emp_no = p_emp_no
      AND s.to_date = '9999-01-01'
      AND de.to_date = '9999-01-01'
    LIMIT 1; -- Ensures only the single latest record is captured
    
END$$

DELIMITER ;
-- Call the procedure with an ID and tell it where to save the result
CALL emp_info(13000, @v_salary, @v_dept);
-- Then select the variables to see the double output
SELECT @v_salary AS latest_salary, @v_dept AS current_department;


/* CUSTOM TOOLS: User Defined Functions. 
   Creating custom math tools for the database
*/ 

DELIMITER $$

CREATE FUNCTION f_emp_avg_salary() RETURNS DECIMAL(10,2)
DETERMINISTIC NO SQL READS SQL DATA 

 BEGIN 
	 DECLARE v_avg_salary DECIMAL(10,2);

     SELECT AVG(s.salary)
     INTO v_avg_salary 
	 FROM
         employees e 
           JOIN 
		salaries s ON e.emp_no = s.emp_no
	WHERE 
        e.gender = 'F';
        
    RETURN v_avg_salary; 
    
END $$ 

DELIMITER ;
-- To use this function, simply run:
SELECT f_emp_avg_salary() AS female_avg_pay;


DELIMITER $$

CREATE FUNCTION emp_avg_salary(p_emp_no INTEGER) RETURNS DECIMAL(10,2)
DETERMINISTIC NO SQL READS SQL DATA 

 BEGIN 
	 DECLARE v_avg_salary DECIMAL(10,2);

     SELECT AVG(s.salary)
     INTO v_avg_salary 
	 FROM
         employees e 
           JOIN 
		salaries s ON e.emp_no = s.emp_no
	WHERE 
        e.emp_no = p_emp_no;
        
    RETURN v_avg_salary; 
    
END $$ 

DELIMITER ;
-- To use this simply run
SELECT v_emp_avg_salary(13000);


DELIMITER $$ 

CREATE FUNCTION emp_info(p_first_name VARCHAR(75), p_last_name VARCHAR(75)) 
RETURNS DECIMAL(10,2) 
DETERMINISTIC NO SQL READS SQL DATA 

BEGIN 
     DECLARE v_max_from_date DATE;
	DECLARE v_salary DECIMAL(10,2); 
    
    SELECT 
        MAX(from_date) 
	INTO v_max_from_date 
    FROM 
        employees e 
          JOIN 
		salaries s ON e.emp_no = s.emp_no 
	WHERE 
        e.first_name = p_first_name AND 
          e.last_name = p_last_name;
	
    SELECT 
        s.salary 
	INTO v_salary 
    FROM 
        salaries s
          JOIN 
		employees e ON s.emp_no = e.emp_no 
	WHERE 
        e.first_name = p_first_name AND 
          e.last_name = p_last_name AND 
            s.from_date = v_max_from_date; 
	
    RETURN v_salary;
    
END $$ 

DELIMITER ;
-- To use this function run: SELECT emp_info('emp_first_name','emp_last_name')
-- e.g
SELECT emp_info('Georgi','Facello');


/* Database Indexing. Searching through large database can be slow. 
   I added indexes, so the database will jump straight to the right page instead of reading the whole data collection 
*/ 

CREATE INDEX i_composite
ON employees(first_name, last_name); 

CREATE INDEX i_hire_date ON 
employees(hire_date);

CREATE INDEX i_salary ON 
salaries(salary);

CREATE INDEX i_composite_date ON 
dept_emp(from_date, to_date);


/* QUALITY CONTROL: Triggers. 
   Setting up triggers to act as automatic guards. To prevent data entry mistake
*/ 

BEFORE INSERT 
DELIMITER $$ 

CREATE TRIGGER before_salary_insert 
BEFORE INSERT ON salaries 
FOR EACH ROW 
BEGIN 
    IF NEW.salary < 0 THEN 
       SET NEW.salary = 0;
	END IF; 
END $$ 

DELIMITER ;

BEFORE UPDATE 
DELIMITER $$ 

CREATE TRIGGER trig_upd_salary 
BEFORE UPDATE ON salaries
FOR EACH ROW 
BEGIN 
    IF NEW.salary < 0 THEN 
       SET NEW.salary = OLD.salary;
	END IF; 
END $$

DELIMITER ;
