# SQL-Employee-Database-Analysis

### **Project Overview**
This project demonstrates my ability to manage and analyze a large-scale relational database containing over **300,000 employee records**. I have built a complete ecosystem that moves from raw data setup to advanced automated reporting tools.

### **Project Directory Structure**
* **📂 Folder_01_Database_Setup**: Environment initialization and table structures.
* **📂 Folder_02_Data_Exploration**: Auditing data volume and checking for missing values.
* **📂 Folder_03_Advanced_Insights**: Ranking, salary benchmarking, and anomaly detection.
* **📂 Folder_04_Database_Objects**: Views, Stored Procedures, UDFs, Triggers, and Indexes.

### **💡 Featured Insight: Automated Pay Equity Audit**
I developed this query to automatically identify employees who fall outside the standard pay range (20% variance) for their specific department.

```sql
SELECT 
    emp_no, dept_name, salary, avg_salary,
    CASE 
        WHEN salary > (avg_salary * 1.2) THEN 'Above Market'
        WHEN salary < (avg_salary * 0.8) THEN 'Below Market'
        ELSE 'Within Market Range'
    END AS compensation_status
FROM (
    SELECT de.emp_no, d.dept_name, s.salary,
           AVG(s.salary) OVER(PARTITION BY de.dept_no) AS avg_salary
    FROM salaries s
    JOIN dept_emp de ON s.emp_no = de.emp_no
    JOIN departments d ON de.dept_no = d.dept_no
    WHERE s.to_date > SYSDATE() 
) a;
Through this project, I have proven that I can not only write complex SQL queries but also build the infrastructure that a modern data team needs to stay fast, accurate, and automated.
