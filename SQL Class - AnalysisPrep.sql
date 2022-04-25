
/*
SQL class Analysis Prep

When we start do analysis, we are likely going to go back and denormalize
our data to make it easier to report on. 

I created a base view with some potentially interesting information we 
might want to look at later. With a view, I can always go back and add
additional fields if I want to and not have to rethink the joins/where 
clauses too much.

Let's start with just current employees. I thought it might be interesting
to get their current salary and compare it to their original salary and
maybe do a regression or something or other as a demonstration.

*/  

use bia6314;

create or replace view currentEmployees as
select employees.emp_no,
	   employees.first_name,
       employees.last_name,
       employees.gender,
	   dept_emp.dept_no,
       departments.dept_name,
       salaries.salary
  from employees join 
       salaries on employees.emp_no = salaries.emp_no join
       dept_emp on employees.emp_no = dept_emp.emp_no join
       departments on departments.dept_no = dept_emp.dept_no
 where salaries.to_date = '9999-01-01' 
   and dept_emp.to_date = '9999-01-01';
 
 select count(*) from currentEmployees;
 
-- This dropped our count of total employees so the way this dataset
-- works is to not have a "current" record in dept_emp when an employee
-- is no longer at the company.  Let's check that to make sure.
-- user our friend the outer join

select employees.emp_no 
  from employees left join currentEmployees on
       employees.emp_no = currentEmployees.emp_no
 where currentEmployees.emp_no is null
 order by employees.emp_no;
  
select * from employees
order by employees.emp_no;

select * from dept_emp where dept_emp.emp_no = 10008;
  
  
/*

I'll come back to this. This is looking for the starting salary (min)
in the department the employee is currently assigned to. Maybe turn 
this into another view later?

*/

select salaries.emp_no,
	   min(salaries.to_date)
  from salaries join
       dept_emp on salaries.emp_no = dept_emp.emp_no
 where dept_emp.to_date = '9999-01-01'
group by salaries.emp_no;

/*
for testing purposes I'm going to want to make sure I'm getting the 
minimum salary from the current department. To do that, I'll have to 
identify someone who's changed departments.

If I select all the employee numbers from the dept_emp table and group by
the emp_no I'll get one record back for each employee. Using the HAVING
clause (we didn't cover in class) I can then pull out those that have more
than one record returned indicating they're in the dept_emp table more than
once.
*/
select dept_emp.emp_no
   from dept_emp
 group by dept_emp.emp_no
 having count(*) > 1;
 
 select * from dept_emp
  where dept_emp.emp_no = 10010;
 
 select * from dept_emp
  where dept_emp.emp_no = 10018;

 select * from dept_emp
  where dept_emp.emp_no = 10029;
 
 
-- that returned a list so let's check one and see if they actually worked
-- in multiple departments and if so let's see if we can get the start/end
-- pair for their current dept.

select * from dept_emp
where dept_emp.emp_no = 10010;

select * from salaries 
where salaries.emp_no = 10010;

-- emp 10010 has been in 2 depts, d004 (11/96 - 6/2000) and d006 (6/2000 - now)
-- emp 1010 has 6 different salaries from 96 to now

-- can I figure out what their start date was by joining dept_emp and salaries.

select salaries.from_date as 'SalStart',
       salaries.to_date as 'SalEnd',
       dept_emp.from_date as 'DeptStart',
	   dept_emp.to_date as 'DeptEnd',
       salaries.salary,
       dept_emp.dept_no,
       departments.dept_name
  from salaries join
       dept_emp on salaries.emp_no = dept_emp.emp_no join
       departments on departments.dept_no = dept_emp.dept_no
 where salaries.emp_no = 10010;
  
/*
With the above I get a bunch of duplicated data as I don't have a way of 
matching a dept date to a salary date. Basically a cartesian product because I'm
returning all rows from salaries * all rows from dept_emp


Back to this one. Maybe I can use it as a sub-query to limit rows for 
only current employees and only their information for their starting
salary. The subquery is the same query i did at approx line 61.

*/

select salaries.emp_no as 'EmpNo',
	           min(salaries.from_date) as 'StartSalary' 
		  from salaries join
               dept_emp on salaries.emp_no = dept_emp.emp_no
         where dept_emp.to_date = '9999-01-01'
           and dept_emp.emp_no = 10010
		   and salaries.emp_no = 10010;

select salaries.emp_no as 'EmpNo',
	           salaries.from_date as 'StartSalary' 
		  from salaries join
               dept_emp on salaries.emp_no = dept_emp.emp_no
         where dept_emp.to_date = '9999-01-01'
           and dept_emp.emp_no = 10100
		   and salaries.emp_no = 10100;



select employees.emp_no,
	   SalHist.StartSalary
  from employees join
       (select salaries.emp_no as 'EmpNo',
	           min(salaries.from_date) as 'StartSalary' 
		  from salaries join
               dept_emp on salaries.emp_no = dept_emp.emp_no
         where dept_emp.to_date = '9999-01-01'
      group by salaries.emp_no) as SalHist on employees.emp_no = SalHist.EmpNo
 where employees.emp_no = 10010
   and SalHist.EmpNo = 10010;
 
 /*
 No joy, no easy way to combine salary and dept_emp. No guarantee that a salary
 occurs at any particular dept assignment. I'll need to see if I can get a range
 of dates on their current department and then find salaries that are between
 the begin/end dates.
 */


Select dept_emp.emp_no,
	   dept_emp.dept_no,
	   dept_emp.from_date as 'DeptStart',
       dept_emp.to_date as 'DeptEnd'
  from dept_emp
 where dept_emp.to_date = '9999-01-01';

-- use our test case again.

Select dept_emp.emp_no,
	   dept_emp.dept_no,
	   dept_emp.from_date as 'DeptStart',
       dept_emp.to_date as 'DeptEnd'
  from dept_emp
 where dept_emp.to_date = '9999-01-01'
   and dept_emp.emp_no = 10010;
 
 -- that gives me the date range for salaries while in a dept. Let's see if i can
 -- figure out how to do that.
 
 -- let's try a view
 
create or replace view deptAssign as
Select dept_emp.emp_no,
	   dept_emp.dept_no,
	   dept_emp.from_date as 'DeptStart',
       dept_emp.to_date as 'DeptEnd'
  from dept_emp
 where dept_emp.to_date = '9999-01-01';
 
select * from deptAssign;

select * from deptAssign where emp_no = 10010;

-- now let's try a correlated subquery to link salaries to department assignment
-- dates 
 
select salaries.emp_no,
		salaries.from_date as 'SalStart',
        salaries.to_date as 'SalEnd',
        salaries.salary
   from salaries join
        deptAssign on salaries.emp_no = deptAssign.emp_no
  where salaries.to_date > (select deptAssign.DeptStart
                                from deptAssign
							   where deptAssign.emp_no = salaries.emp_no)
    and salaries.emp_no = 10010;
    
select * from dept_emp
 where dept_emp.emp_no = 10010;

select * from salaries
 where salaries.emp_no = 10010;
    
    
-- may be onto something. That seemed to work for 10010 
-- Let's look at some other test cases.

select * from dept_emp where emp_no = 10018;

select * from salaries where emp_no = 10018;
 
select salaries.emp_no,
		salaries.from_date as 'SalStart',
        salaries.to_date as 'SalEnd',
        salaries.salary
   from salaries join
        deptAssign on salaries.emp_no = deptAssign.emp_no
  where salaries.to_date > (select deptAssign.DeptStart
                                from deptAssign
							   where deptAssign.emp_no = salaries.emp_no)
    and salaries.emp_no = 10018;
    
select * from dept_emp
 where dept_emp.emp_no = 10029;

select * from salaries
 where salaries.emp_no = 10029;
 
-- works here too, one more.

select salaries.emp_no,
		salaries.from_date as 'SalStart',
        salaries.to_date as 'SalEnd',
        salaries.salary
   from salaries join
        deptAssign on salaries.emp_no = deptAssign.emp_no
  where salaries.to_date > (select deptAssign.DeptStart
                                from deptAssign
							   where deptAssign.emp_no = salaries.emp_no)
    and salaries.emp_no = 10029;
    

-- Think we've got it. Now what?
-- just for giggles ran on the entire data set 45 seconds. Not great but
-- not terrible. Hopefully it doesn't get too much longer.

select salaries.emp_no,
		salaries.from_date as 'SalStart',
        salaries.to_date as 'SalEnd',
        salaries.salary
   from salaries join
        deptAssign on salaries.emp_no = deptAssign.emp_no
  where salaries.to_date > (select deptAssign.DeptStart
                                from deptAssign
							   where deptAssign.emp_no = salaries.emp_no);

-- I think we really only want the min and max, not the interims. 

-- this should get the starting salary

-- test case first

select salaries.emp_no,
	   min(salaries.from_date) as 'SalStart',
       salaries.to_date as 'SalEnd',
       salaries.salary
  from salaries join
       deptAssign on salaries.emp_no = deptAssign.emp_no
 where salaries.to_date > (select deptAssign.DeptStart
                               from deptAssign
                              where deptAssign.emp_no = salaries.emp_no)
   and salaries.emp_no = 10010
group by salaries.emp_no;

select salaries.emp_no,
	   min(salaries.from_date) as 'SalStart',
       salaries.to_date as 'SalEnd',
       salaries.salary
  from salaries join
       deptAssign on salaries.emp_no = deptAssign.emp_no
 where salaries.to_date > (select deptAssign.DeptStart
                               from deptAssign
                              where deptAssign.emp_no = salaries.emp_no)
group by salaries.emp_no;



-- 240,124 rows which matches our original employee count. There was much rejoicing.

-- let's make it a view now.

create or replace view startingSalaries as
select salaries.emp_no,
	   min(salaries.from_date) as 'SalStart',
       salaries.to_date as 'SalEnd',
       salaries.salary
  from salaries join
       deptAssign on salaries.emp_no = deptAssign.emp_no
 where salaries.to_date > (select deptAssign.DeptStart
                               from deptAssign
                              where deptAssign.emp_no = salaries.emp_no)
group by salaries.emp_no;

select count(*) from startingSalaries;
select count(*) from currentEmployees;

/*
Let's finalize the stuff
we want to present for data analysis retrieval.

For simplicity, let's try to combine the current employee and starting salary
view into one structure that we can dump into R/python.

by far the easiest, though not the most efficient, is to just use the two
views and create a new view/structure. It's easy as we already have the views.
It's inefficient as basically what we're doing is running three queries. One
for each of the base views, one for the final query. For speed of reporting, 
I'm going to create a new table that has all this data as it exists at the 
time of creation. Warehouses are usually not real-time but get snapshot
data updates over time. Speed and complexity are the primary reasons.
*/


select currentEmployees.emp_no as 'EmpNo',
	   currentEmployees.first_name as 'fName',
       currentEmployees.last_name as 'lName',
       currentEmployees.gender,
	   currentEmployees.dept_no as 'DeptNo',
       currentEmployees.dept_name as 'Department',
       currentEmployees.salary as 'CurrentSalary',
       startingSalaries.salary as 'StartingSalary'
  from currentEmployees join startingSalaries on 
       currentEmployees.emp_no = startingSalaries.emp_no;
       
       
-- Create table for the reporters to use.     

Create table salaryReport as
select currentEmployees.emp_no as 'EmpNo',
	   currentEmployees.first_name as 'fName',
       currentEmployees.last_name as 'lName',
       currentEmployees.gender,
	   currentEmployees.dept_no as 'DeptNo',
       currentEmployees.dept_name as 'Department',
       currentEmployees.salary as 'CurrentSalary',
       startingSalaries.salary as 'StartingSalary'
  from currentEmployees join startingSalaries on 
       currentEmployees.emp_no = startingSalaries.emp_no;
   
select count(*) from salaryReport;
select * from salaryReport where EmpNo = 10010;
select * from salaryReport order by EmpNo;

-- Since we did the table creation from a query it doesn't have a primary key. We'll add one.

alter table salaryReport add primary key (EmpNo);

select * from salaryReport;