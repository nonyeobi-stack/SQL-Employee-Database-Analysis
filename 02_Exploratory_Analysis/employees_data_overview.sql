/*
PROJECT: Exploratory Data Analysis (EDA)
OBJECTIVE: To audit the dataset for quality and extract high-level summary statistics 
           regarding company demographics and departmental structure.
KEY SKILLS: 
- Data Aggregation (COUNT, AVG, SUM)
- Grouping & Filtering (GROUP BY, HAVING)
- Statistical Summaries
*/

use employees;

-- Retrieving all information about employees from the employees table --

SELECT 
   *
FROM 
   employees;
   
-- Retrieving all information from the employees table with specific conditions --

SELECT 
    *
FROM
    employees
WHERE
    first_name = 'Denis';
   
SELECT 
    *
FROM
    employees
WHERE
    first_name = 'Denis' AND gender = 'M';
    
SELECT 
    *
FROM
    employees
WHERE
    first_name = 'Denis'
        OR first_name = 'Elvis';

SELECT 
    *
FROM
    employees
WHERE
    last_name = 'Denis'
        AND (gender = 'M' OR gender = 'F');
    

SELECT 
    *
FROM
    employees
WHERE
    gender = 'F'
        AND (first_name = 'Kellie'
        OR first_name = 'Aruna');
        
SELECT 
    *
FROM
    employees
WHERE
    first_name = 'Katty'
        OR first_name = 'Mark'
        OR first_name = 'Nathan';
        
SELECT 
    *
FROM
    employees
WHERE
    first_name IN ('Catty' , 'Mark', 'Nathan');
   
SELECT 
    *
FROM
    employees
WHERE
    first_name NOT IN ('Catty' , 'Mark', 'Nathan');
    
SELECT 
    *
FROM
    employees
WHERE
    first_name LIKE ('Mar%');
    
SELECT 
   *
FROM
   employees 
WHERE 
   first_name LIKE ('%ar');
   
SELECT 
    *
FROM
    employees
WHERE
    first_name LIKE ('%Ar%');
   
SELECT 
    *
FROM
    employees
WHERE
    first_name LIKE ('Mar_');
   
SELECT 
    *
FROM
    employees
WHERE
    hire_date BETWEEN '1990-01-01' AND '2000-01-01';
    
SELECT 
    *
FROM
    employees
WHERE
    hire_date NOT BETWEEN '1990-01-01' AND '2000-01-01';


SELECT 
    *
FROM
    employees
WHERE
    first_name IS NOT NULL;
    
SELECT 
    *
FROM
    employees
WHERE
    first_name IS NULL;
    
SELECT 
    *
FROM
    employees
WHERE
    first_name <> 'Mark';
    
SELECT 
    *
FROM
    employees
WHERE
    hire_date > '2000-01-01';
    
SELECT 
    *
FROM
    employees
WHERE
    hire_date >= '2000-01-01';
    
SELECT 
    *
FROM
    employees
WHERE
    hire_date <= '1985-02-01';
    
-- Retrieving names of all departments from the department table where department number is between department no2 and department no5 --
    
SELECT 
    dept_name
FROM
    departments
WHERE
    dept_no BETWEEN 'd002' AND 'd005';
    
-- Retrieving data with no duplicate value --

SELECT DISTINCT
    emp_no, first_name, last_name
FROM
    employees;
    
    
/* DATA MAINTENANCE: Testing DML operations to ensure the database handles record updates and insertions correctly. */

INSERT INTO employees
(
    emp_no,
    birth_date,
    first_name,
    last_name,
    gender,
    hire_date
) VALUES
(
    999901,
    '1986-04-21',
    'Jojn',
    'Smith',
    'M',
    '2011-01-01'
);

UPDATE employees 
SET 
    first_name = 'Stella',
    last_name = 'Parkinson',
    birth_date = '1990-12-31',
    gender = 'F'
WHERE 
    emp_no = 999901;
    
/*SUMMARY STATISTICS: Using Aggregate functions and GROUP BY to identify staff distribution and baseline company pay scales. */

SELECT 
    first_name, COUNT(first_name) AS names_count
FROM 
    employees
WHERE 
    hire_date > '1999-01-01'
GROUP BY first_name
HAVING COUNT(first_name) < 200
ORDER BY first_name;

SELECT 
    emp_no
FROM 
    dept_emp
WHERE 
    from_date > '2000-01-01'
GROUP BY emp_no
HAVING COUNT(from_date) >1
ORDER BY emp_no;
        
SELECT 
    COUNT(salary >= 100000)
FROM
    salaries;
    
SELECT
    COUNT(*)
FROM 
    dept_manager;
    
SELECT 
    COUNT(*) AS salary_count
FROM
    salaries
WHERE
    salary >= 75000;
    
SELECT 
    first_name, COUNT(first_name) AS names_count
FROM
    employees
GROUP BY first_name
ORDER BY first_name DESC;

SELECT 
    salary, COUNT(emp_no) AS emp_with_same_salary
FROM
    salaries
WHERE
    salary > 80000
GROUP BY salary
ORDER BY salary;

SELECT 
    emp_no, AVG(salary) AS emp_avg_salary
FROM
    salaries
GROUP BY emp_no
HAVING AVG(salary) > 120000
ORDER BY emp_no;

SELECT 
    SUM(salary)
FROM 
    salaries;
    
SELECT 
    emp_no, MAX(salary)
FROM 
    salaries
GROUP BY emp_no;
   
SELECT 
    emp_no, MIN(salary)
FROM
    salaries
GROUP BY emp_no;

SELECT 
    AVG(salary)
FROM 
    salaries;
    
SELECT 
    ROUND(AVG(salary), 2)
FROM 
    salaries;
