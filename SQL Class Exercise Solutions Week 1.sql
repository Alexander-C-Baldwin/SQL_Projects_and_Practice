/* SQL class solutions week 1 */

-- Create a table to track used cars. Data elements should include:
-- Year
-- Make eg. Toyota, Chevrolet, etc.
-- Model eg. Sedan, Pick-up, etc.
-- VIN
-- Mileage
-- Exterior Color
-- Interior Color
-- Carfax (y/n)
-- Transmission (automatic/manual)

Create Table UsedCars (
	ModelYear		Year			Not Null,
	Make			varchar(30)		Not Null,
    Model			varchar(30)		Not Null,
    VIN				varchar(30) PRIMARY KEY,  --  these are guaranteed unique so it's a good candidate for a primary key
    Mileage			int unsigned,
    ExteriorColor	Varchar(30),
    InteriorColor	varchar(30),
    CarFaxExists	enum('Y','N'), 
    Transmission	enum('Automatic','Manual')
    );
    
    
-- Write a query to select all the columns from the titles table

Select * from titles;

-- For all the below queries, make sure to provide easily readable column names.
-- Write a query to select the employee number and title from the titles table

Select emp_no as 'Employee Number',
       title  as 'Employee Title'
  from titles;


-- Write a query to select all the columns from the salaries table. Numbers should be formatted as
-- ##,###.## Calculate the weekly salary for each employee. Assume a 40 hour work week, 52 weeks per
-- year. 

select emp_no as 'Employee Number',
       format(salary,2) as 'Annual Salary',
       format(salary/52,2) as 'Weekly Salary',
       from_date as 'Effective Date',
       to_date as 'End Date'
  from salaries;
  
-- Write a query to select employee names and ages. Names should be formatted as first + space + last in
-- the same column. Age should be calculated in months.

select concat(first_name, ' ', last_name) as 'Employee Name',
	   timestampdiff(Month,birth_date,curdate()) as 'Age in Months'
  from employees;
  
-- Write a query to return the number of days elapsed since January 1, 2016.

select datediff(curdate(),'2016-01-01') as 'Days elapsed since January 1, 2016';

-- Write a query to return the current date/time in a format like this: 12:34PM Sunday April 17, 2016

select date_format(now(),'%h:%i%p %W %M %e, %Y');  -- KC is currently 5 hours behind UTC (universal time coordinated).

  
-- Write a query that returns the employee name in one column in all caps in this format: Lastname,
-- Firstname.


select upper(concat(last_name,', ', first_name)) as 'Employee Name'
  from employees;


-- Write a query that only returns the first word in the department name from the departments table. Eg.
-- “Customer Service” would only return “Customer”.

-- not all names have a space in them so I add one just in case using concat.

select rtrim(left(dept_name,instr(concat(dept_name,' '),' '))) as 'First Word of Department Name'
  from departments;

-- alternative solution and probably a bit easier, but you have to know about the 
-- substring_index function. With this function if you use -1 instead of 1, you get
-- the last word.

select substring_index(dept_name,' ',1)
  from departments;
    