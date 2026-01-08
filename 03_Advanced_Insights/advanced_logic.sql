/* Advanced Business Intelligence 
   TECHNIQUES: joins, Unions, subqueries, CASE Statements, CTEs, Window Functions, and Null Handling.
*/

/*	RELATIONAL MAPPING: Utilizing multi table joins and nested Subqueries to synthesie data across the relational schema. 
	This process transforms fragmented table data into a comprehensive dataset for reporting */

SELECT 
    d.dept_name, e.gender, AVG(s.salary) AS avg_salary
FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
        JOIN
    dept_emp de ON de.emp_no = e.emp_no
        JOIN
    departments d ON d.dept_no = de.dept_no
GROUP BY d.dept_no , e.gender
HAVING avg_salary > 70000
ORDER BY d.dept_no;

SELECT 
    d.dept_name, e.gender, AVG(salary)
FROM
    salaries S
        JOIN
    employees e ON s.emp_no = e.emp_no
        JOIN
    dept_emp de ON de.emp_no = e.emp_no
        JOIN
    departments d ON de.dept_no = d.dept_no
GROUP BY d.dept_no , e.gender
ORDER BY de.dept_no;

SELECT 
    YEAR(de.from_date) AS calendar_year,
    e.gender,
    COUNT(e.emp_no) AS num_of_employees
FROM
    employees e
        JOIN
    dept_emp de ON e.emp_no = de.emp_no
GROUP BY calendar_year , e.gender
HAVING calendar_year >= 1990
ORDER BY calendar_year;
    
SELECT 
    t.emp_no,
    t.title,
    (SELECT 
            AVG(s.salary)
        FROM
            salaries s
        WHERE
            s.emp_no = t.emp_no) AS avg_salary
FROM
    (SELECT 
        emp_no, title
    FROM
        titles t
    WHERE
        t.title = 'Staff'
            OR t.title = 'Engineer') t
ORDER BY avg_salary DESC;

SELECT 
    e.first_name, e.last_name
FROM
    employees e
WHERE
    EXISTS( SELECT 
            *
        FROM
            dept_manager dm
        WHERE
            dm.emp_no = e.emp_no
		ORDER BY emp_no);
        
SELECT 
    *
FROM
    employees e
WHERE
    EXISTS( SELECT 
            t.title
        FROM
            titles t
        WHERE
            t.emp_no = e.emp_no
                AND t.title = 'Assistant Engineer');
                
SELECT 
    e.first_name, e.last_name
FROM
    employees e
WHERE
    e.emp_no IN (SELECT 
            dm.emp_no
        FROM
            dept_manager dm);
            
SELECT 
    *
FROM
    dept_manager dm
WHERE
    dm.emp_no IN (SELECT 
            emp_no
        FROM
            employees
        WHERE
            hire_date BETWEEN '1990-01-01' AND '1995-01-01');
            
-- Retrieving data about the currently employed workers in the company --


SELECT 
    s1.emp_no, s.salary, s.from_date, s.to_date
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
        
        
-- Retrieving the first ever contract that each employee signed for the company --

        
SELECT 
    s1.emp_no, s.salary, s.from_date, s.to_date 
FROM 
    salaries s 
       JOIN 
	(SELECT 
        emp_no, MIN(from_date) AS from_date 
	FROM 
        salaries 
	GROUP BY emp_no) s1 ON s.emp_no = s1.emp_no 
WHERE 
    s.from_date = s1.from_date;
    
-- DATA CONSOLIDATION: Using UNION and UNION ALL to merge datasets from different periods or categories -- 

SELECT 
    e.emp_no,
    e.first_name,
    e.last_name,
    NULL AS dept_no,
    NULL AS from_date
FROM
    employees e
WHERE
    e.emp_no = 10001 
UNION ALL SELECT 
    NULL AS emp_no,
    NULL AS first_name,
    NULL AS last_name,
    m.dept_no,
    m.from_date
FROM
    dept_manager m;
    
SELECT 
    *
FROM
    (SELECT 
        e.emp_no,
            e.first_name,
            e.last_name,
            NULL AS dept_no,
            NULL AS from_date
    FROM
        employees e
    WHERE
        last_name = 'Denis' UNION SELECT 
        NULL AS emp_no,
            NULL AS first_name,
            NULL AS last_name,
            m.dept_no,
            m.from_date
    FROM
        dept_manager m) AS a
ORDER BY - a.emp_no DESC;

/* Assigning employee number 110022 as a manager to all employees from 10001 to 10020,
   and employee number 110039 as a manager to all employees from 10021 to 10040 */ 
   
   SELECT 
    A.*
FROM
    (SELECT 
        e.emp_no,
            MIN(de.dept_no) AS department_code,
            (SELECT 
                    emp_no
                FROM
                    dept_manager
                WHERE
                    emp_no = 110022) AS manager_id
    FROM
        employees e
    JOIN dept_emp de ON e.emp_no = de.emp_no
    WHERE
        e.emp_no <= '10020'
    GROUP BY e.emp_no
    ORDER BY e.emp_no) A 
UNION SELECT 
    B.*
FROM
    (SELECT 
        e.emp_no,
            MIN(de.dept_no) AS department_code,
            (SELECT 
                    emp_no
                FROM
                    dept_manager
                WHERE
                    emp_no = 110039) AS manager_id
    FROM
        employees e
    JOIN dept_emp de ON e.emp_no = de.emp_no
    WHERE
        e.emp_no > 10020
    GROUP BY e.emp_no
    ORDER BY e.emp_no
    LIMIT 20) B;
		
/* CONDITIONAL LAGIC & DATA CLEANING: Using case statements for labeling, 
while implementing IFNULL() and COALESCE() to handle missing entries in the dataset. 
*/

SELECT 
    e.gender,
    d.dept_name,
    ROUND(AVG(s.salary), 2) AS avg_salary,
    CASE
        WHEN de.from_date < '1998-01-01' THEN 'Before'
        ELSE 'On or After'
    END AS jan_1_1998
FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
        JOIN
    dept_emp de ON s.emp_no = de.emp_no
        JOIN
    departments d ON de.dept_no = d.dept_no
WHERE
    de.from_date >= '1990-01-01'
GROUP BY d.dept_no , e.gender , jan_1_1998
ORDER BY d.dept_no ASC;


SELECT 
    emp_no,
    salary,
    CASE
        WHEN from_date BETWEEN '1970-01-01' AND '1981-12-31' THEN ROUND(salary * 6.5, 2)
        WHEN from_date BETWEEN '1990-01-01' AND '1999-12-31' THEN ROUND(salary * 2.8, 2)
    END AS inflation_adjusted_salary,
    from_date,
    to_date
FROM
    salaries;
    
SELECT 
    e.emp_no,
    e.first_name,
    e.last_name,
    CASE
        WHEN MAX(de.to_date) >= '2026-01-01' THEN 'Currently working'
        ELSE 'No longer with the company'
    END AS current_status
FROM
    employees e
        JOIN
    dept_emp de ON e.emp_no = de.emp_no
GROUP BY e.emp_no , e.first_name , e.last_name;

SELECT 
    e.emp_no,
    e.first_name,
    e.last_name,
    de.dept_no,
    CASE
        WHEN (de.to_date) > SYSDATE() THEN 'Is still employed'
        ELSE 'Not an employee anymore'
    END AS current_employee
FROM
    dept_emp de
        JOIN
    employees e ON de.emp_no = e.emp_no;
    
SELECT 
    dm.emp_no,
    e.first_name,
    e.last_name,
    e.hire_date,
    (MAX(s.salary) - MIN(s.salary)) AS salary_difference,
    CASE
        WHEN
            MAX(s.salary) - MIN(s.salary) < 10000
                AND MAX(s.salary) - MIN(s.salary) > 0
        THEN
            'Insignificant'
        WHEN MAX(s.salary) - MIN(s.salary) > 10000 THEN 'Significant'
        ELSE 'Salary decreased'
    END AS manager_salary_raised
FROM
    dept_manager dm
        JOIN
    employees e ON dm.emp_no = e.emp_no
        JOIN
    salaries s ON e.emp_no = s.emp_no
GROUP BY s.emp_no , e.first_name , e.last_name , e.hire_date
ORDER BY dm.emp_no;

-- The employee database is properly cleaned, so let create a duplicate table to handle missing entries using the IFNULL() and COALESCE() function --

CREATE TABLE departments_dup
(
   dept_no CHAR(4) NULL,
   dept_name VARCHAR(30) NULL
);

INSERT INTO departments_dup
SELECT 
    *
FROM 
    departments;
   
ALTER TABLE departments_dup
ADD COLUMN dept_manager VARCHAR(75);

INSERT INTO departments_dup
(
   dept_no
) VALUE 
( 
   'd011'
);

INSERT INTO departments_dup
(
   dept_name
) VALUE 
( 
   'Business Analyst'
);

SELECT 
    *
FROM
    departments_dup;

SELECT 
    dept_no,
    dept_name,
    IFNULL(dept_manager,
            'dept_manager_not_provided') AS dept_manager
FROM
    departments_dup;
    
SELECT 
    dept_no,
    dept_name,
    COALESCE(dept_manager, dept_name, 'N / A') AS dept_manager
FROM
    departments_dup
ORDER BY dept_no ASC;

SELECT 
    dept_no,
    dept_name,
    COALESCE('dept_manager_not_provided') AS manager_name 
FROM 
    departments_dup 
ORDER BY dept_no;
    
SELECT 
    IFNULL(dept_no, 'N / A') AS dept_no,
    IFNULL(dept_name,
            'department_name_not_provided') AS dept_name,
    COALESCE(dept_no, dept_name) AS dept_info
FROM
    departments_dup
ORDER BY dept_no ASC;

/* ANALYTICAL RANKING: Using CTEs for for modular code. 
   Leveraging Window Functions including RANK() and DENSE_RANK() to perform granular benchmarking of salaries within departments. 
   Additionaly I utilize LAG() and LEAD() to conduct time_series analysis, to track year-over-year salary changes and employee career progression patterns. 
*/

WITH cte AS (SELECT 
               AVG(salary) AS avg_salary 
			FROM 
               salaries) 
SELECT 
    SUM(CASE 
               WHEN s.salary > c.avg_salary THEN 1 
               ELSE 0 
		END) AS no_of_salary_above_avg,
	COUNT(s.salary) AS total_no_of_salary_contract 
FROM 
    salaries s 
	 JOIN 
	employees e ON s.emp_no = e.emp_no
	 JOIN 
	cte c;
    
WITH cte1 AS (SELECT 
                AVG(salary) AS avg_salary
			FROM 
                salaries),
	cte2 AS (SELECT 
                s.emp_no, MAX(s.salary) AS f_highest_salary 
			FROM 
                salaries s 
                  JOIN 
				employees e ON s.emp_no = e.emp_no AND e.gender = 'F'
			GROUP BY s.emp_no) 
SELECT 
    SUM(CASE 
           WHEN c2.f_highest_salary > c1.avg_salary THEN 1 
           ELSE 0 
		END) AS f_highest_salary_above_avg,
	COUNT(e.emp_no) AS total_no_of_female_contract,
    CONCAT(ROUND(SUM(CASE 
					   WHEN c2.f_highest_salary > c1.avg_salary THEN 1 
                       ELSE 0 END) / COUNT(e.emp_no) * 100, 2 ), '%') AS '% percentage'
FROM 
    employees e 
       JOIN 
	cte2 c2 ON c2.emp_no = e.emp_no 
       JOIN 
	cte1 c1;
    
-- Obtaining the salary values of each manager has signed a contract for, using the window function --

SELECT 
    dm.emp_no,
    s.salary,
    ROW_NUMBER() OVER () AS managers_total_contract,
    ROW_NUMBER() OVER (PARTITION BY emp_no ORDER BY salary ASC) As 
manager_contract 
FROM 
    dept_manager dm 
       JOIN 
	salaries s ON dm.emp_no = s.emp_no 
ORDER BY managers_total_contract, emp_no, salary ASC;

-- Retrieving the highest salary for each employee, using ROW_NUMBER() window function --

SELECT 
    a.emp_no,
    a.salary AS Max_salary 
FROM 
   (SELECT 
       emp_no,
       salary,
       ROW_NUMBER() OVER w AS row_num 
	FROM 
       salaries 
	WINDOW w AS (PARTITION BY emp_no ORDER BY salary DESC) ) a
WHERE a.row_num = 1;
    
-- Obtaining data about managers from the employees database -- 

SELECT 
    d.dept_no,
    d.dept_name,
    dm.emp_no,
    s.salary,
    RANK() OVER w AS dept_salary_ranking,
    s.from_date AS salary_from_date,
    s.to_date AS salary_to_date,
    dm.from_date AS dept_manager_from_date,
    dm.to_date AS dept_manager_to_date
FROM 
    dept_manager dm 
       JOIN 
	salaries s ON dm.emp_no = s.emp_no AND s.from_date 
    BETWEEN dm.from_date AND dm.to_date AND s.to_date 
    BETWEEN dm.from_date AND dm.to_date
       JOIN 
	departments d ON d.dept_no = dm.dept_no
WINDOW w AS (PARTITION BY dm.dept_no ORDER BY s.salary DESC);

-- Retrieving employees contracts that have been signed atleast 4 years after hire date -- 

SELECT 
    e.emp_no,
    DENSE_RANK() OVER w AS employee_salary_ranking,
    s.salary,
    e.hire_date,
    (YEAR(s.from_date) - YEAR(e.hire_date)) AS years_from_start
FROM 
    employees e 
       JOIN 
	salaries s ON s.emp_no = e.emp_no 
AND YEAR(s.from_date) - YEAR(e.hire_date) >= 5 
WINDOW w AS(PARTITION BY e.emp_no ORDER BY s.salary DESC);

-- Retrieving only data for contract that have started prior to 1990 -- 

SELECT 
    e.emp_no,
    e.hire_date,
    s.from_date,
    s.salary,
    DENSE_RANK() OVER w AS emp_salary_ranking 
FROM 
    employees e 
      JOIN 
	salaries s ON e.emp_no = s.emp_no
    AND s.from_date < '1990-01-01' 
WINDOW w AS (PARTITION BY e.emp_no ORDER BY s.salary DESC)
ORDER BY e.emp_no ASC;

-- Tracking salary changes for an employee over time to see their pay raise vs their curent pay --

SELECT 
    emp_no,
    salary,
    LAG(salary) OVER w AS previous_salary,
    LEAD(salary) OVER w AS next_salary,
    salary - LAG(salary) OVER w AS salary_diff_current_previous,
    LEAD(salary) OVER w - salary AS salary_diff_next_current 
FROM 
    salaries 
WHERE 
    emp_no = 10001 
WINDOW w AS (ORDER BY salary);
    
SELECT 
    emp_no,
    salary,
    LAG(salary) OVER w AS previous_salary,
    LAG(salary,2) OVER w AS 1_before_previous_salary,
    LEAD(salary) OVER w AS next_salary,
    LEAD(salary,2) over W as 1_after_next_salary 
FROM 
    salaries 
WINDOW w AS (PARTITION BY emp_no ORDER BY salary);

-- Calculating the total payroll for each department as it grows (Running Total) and compare each employee's salary to the department mean.
--

SELECT 
    de.emp_no,
    d.dept_name,
    s.salary,
    AVG(s.salary) OVER(PARTITION BY d.dept_name) AS dept_avg_salary,
    SUM(s.salary) OVER(PARTITION BY d.dept_name ORDER BY s.from_date) AS running_dept_payroll,
    s.salary - AVG(s.salary) OVER(PARTITION BY d.dept_name) AS salary_vs_avg
FROM employees e
       JOIN 
	dept_emp de ON e.emp_no = de.emp_no
       JOIN 
	departments d ON de.dept_no = d.dept_no
       JOIN 
	salaries s ON e.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01';

-- Flaging employees based on their standing relative to the department average.--

SELECT 
    a.emp_no,
    a.dept_name,
    a.salary,
    a.avg_salary,
    CASE 
        WHEN a.salary > (a.avg_salary * 1.2) THEN 'Above_Market'
        WHEN a.salary < (a.avg_salary * 0.8) THEN 'Below_Market'
        ELSE 'Within_Market_Range'
    END AS compensation_status
FROM (SELECT 
        de.emp_no,
        d.dept_name, 
        s.salary,
        AVG(s.salary) OVER(PARTITION BY de.dept_no) AS avg_salary
    FROM salaries s
    JOIN dept_emp de ON s.emp_no = de.emp_no
    JOIN departments d ON de.dept_no = d.dept_no
    WHERE s.to_date > SYSDATE() 
      AND de.to_date > SYSDATE()
) a
ORDER BY a.dept_name, a.salary DESC;

