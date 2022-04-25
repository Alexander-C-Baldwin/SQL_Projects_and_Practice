# inner joins
use BIA6314;

-- Write a query to select the current salary for all employees. Include the name and salary in the output.

select employees.first_name as 'First Name',
       employees.last_name as 'Last Name',
       format(salaries.salary,2) as 'Annual Salary'
  from employees join
       salaries on employees.emp_no = salaries.emp_no
 where salaries.to_date = '9999-01-01';
       
-- Write a query to select the current salary for all employees in the Marketing Department. Include the
-- department name, employee name, employee number, and current salary in the output.

select departments.dept_name as 'Department',
	   employees.emp_no as 'Employee #',
       employees.first_name as 'First Name',
       employees.last_name as 'Last Name',
       format(salaries.salary,2) as 'Annual Salary'
  from employees join
	   dept_emp on employees.emp_no = dept_emp.emp_no join
       departments on dept_emp.dept_no = departments.dept_no join
       salaries on employees.emp_no = salaries.emp_no
 where salaries.to_date = '9999-01-01'
   and dept_emp.to_date = '9999-01-01'
   and departments.dept_name = 'Marketing';

-- Write a query to show the average current salary for male and female employees. Include the gender
-- and the average in the output.

select employees.gender as 'Gender',
       format(avg(salaries.salary),2) as 'Average Salary'
  from employees join
       salaries on employees.emp_no = salaries.emp_no
 where salaries.to_date = '9999-01-01'
group by employees.gender;

-- Write a query that shows the current managers of all the departments. Include the manager name and
-- the department name in the output.

select employees.first_name as 'Manager First Name',
       employees.last_name as 'Manager Last Name',
       departments.dept_name as 'Department Name'
  from employees join
       dept_manager on employees.emp_no = dept_manager.emp_no join
       departments on departments.dept_no = dept_manager.dept_no
 where dept_manager.to_date = '9999-01-01';

-- Write a query that shows all the managers of the Customer Service department over time. Sort the
-- output by the start date (from_date) in ascending order. Include the department name, manager name
-- and the from and to dates in the output.

select departments.dept_name as 'Department Name',
       employees.first_name as 'Manager First Name',
       employees.last_name as 'Manager Last Name',
       dept_manager.from_date as 'Manager from date',
       dept_manager.to_date as 'Manager End date'
  from employees join
       dept_manager on employees.emp_no = dept_manager.emp_no join
       departments on dept_manager.dept_no = departments.dept_no
 where departments.dept_name = 'Customer Service'
order by dept_manager.from_date;

-- Write a query that shows the current salary for all employees in the Research department and the
-- Development Department. Sort the data in Descending order by salary. Include name, department and
-- salary in the output.

select employees.first_name as 'Employee First Name',
       employees.last_name as 'Employee Last Name',
       salaries.salary as 'Current salary',
       departments.dept_name as 'Department'
  from employees join
       dept_emp on dept_emp.emp_no = employees.emp_no join
       departments on dept_emp.dept_no = departments.dept_no join
       salaries on employees.emp_no = salaries.emp_no
where salaries.to_date = '9999-01-01'
  and dept_emp.to_date = '9999-01-01'
  and (departments.dept_name = 'Research'
   or departments.dept_name = 'Development')
order by salaries.salary DESC;

select * from departments;


# outer joins

use classicmodels;


# customers that have orders that haven't shipped

select customers.customerName as 'Customer',
	   orders.orderNumber as 'Order Number'
  from customers, orders
  where customers.customerNumber = orders.customerNumber
    and orders.shippedDate is null;


# products that haven't sold

select products.productCode as 'Product Code', 
	   products.productName as 'Product Name', 
       products.productDescription as 'Product Description'
  from products left join orderdetails on products.productCode = orderdetails.productCode
 where orderdetails.productCode is Null;
 
# alternate for above

select products.productCode as 'Product Code', 
	   products.productName as 'Product Name', 
       products.productDescription as 'Product Description'
  from products
where not exists (select * from orderdetails where products.productCode = orderdetails.productCode);



#employees without any customers assigned to them - outer join.

select concat(employees.lastName, ', ', employees.firstName) as 'Employee Name'
  from employees left join customers on employees.employeeNumber = customers.salesRepEmployeeNumber
 where customers.salesRepEmployeeNumber is Null;


#employees without any customers assigned to them - subquery

select concat(employees.lastName, ', ', employees.firstName) as 'Employee Name'
  from employees
  where not exists (select * from customers where customers.salesRepEmployeeNumber = employees.employeeNumber);



# total number of orders per customer

select customers.customerName as 'Customer', 
       count(orders.orderNumber) as 'Number of Orders'
  from customers left join orders on customers.customerNumber = orders.customerNumber
group by customers.customerName;

