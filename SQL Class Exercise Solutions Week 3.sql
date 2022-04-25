-- minimum current salary (to_date) = '9999-01-01'
-- remember to always format last

select format(min(salaries.salary),0) as 'Minimum Salary'
  from salaries
 where salaries.to_date = '9999-01-01';

-- max current salar
  
select format(max(salaries.salary),0) as 'Maximum Current Salary'
  from salaries
 where salaries.to_date = '9999-01-01';
 
 -- to get counts per dept, we use group by
 
 select dept_emp.dept_no as 'Department #',
        count(*) 		as 'Head Count'
   from dept_emp
  where dept_emp.to_date = '9999-01-01'
group by dept_emp.dept_no;

-- aggregate function (count) with where clause

select count(*) as "number over 100k"
  from salaries
 where salaries.to_date = '9999-01-01'
   and salaries.salary > 100000;
   
-- another example with count/where
   
 select count(*) as "Number of Female Employees"
   from employees
  where employees.gender = 'F';

-- one way using floor to group

select concat(floor(salaries.salary/10000), 
              '0,000 - ', 
              floor(salaries.salary/10000),
              '9,999') as 'Salary Level', 
	   count(*)
 from salaries
 where salaries.to_date = '9999-01-01'
 group by floor(salaries.salary/10000);
  
-- spot check above results for testing purposes
  
select count(*) 
  from salaries 
 where salaries.salary between 40000 and 49999
   and salaries.to_date = '9999-01-01';
   
select count(*) 
  from salaries 
  where salaries.salary between 100000 and 109999
    and salaries.to_date = '9999-01-01';