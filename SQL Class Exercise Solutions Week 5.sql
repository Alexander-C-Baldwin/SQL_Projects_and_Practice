-- Employees with no customers assigned - outer join

select concat(employees.lastName, ', ', employees.firstName) as 'Employee Name'
  from employees left join customers on employees.employeeNumber = customers.salesRepEmployeeNumber
 where customers.salesRepEmployeeNumber is Null;


#employees without any customers assigned to them - subquery

select concat(employees.lastName, ', ', employees.firstName) as 'Employee Name'
  from employees
  where not exists (select * from customers where customers.salesRepEmployeeNumber = employees.employeeNumber);
  
 -- Create a view that stores the total order amount of an order
 
 create or replace view TotalOrder as 
 select orderdetails.orderNumber,
        sum(orderdetails.quantityOrdered * orderdetails.priceEach) as 'OrderTotal'
   from orderdetails
group by orderdetails.orderNumber;
   
select * from TotalOrder;   

-- order amount for all orders made by Land of Toys in 2004.

select customers.customerName as 'Customer Name',
       orders.orderDate as 'Order Date',
       format(TotalOrder.OrderTotal,2) as 'Order Total'
  from customers join
       orders on customers.customerNumber = orders.customerNumber join
       TotalOrder on TotalOrder.orderNumber = orders.orderNumber
 where customers.customerName = 'Land of Toys Inc.'
   and year(orders.orderDate) = 2004;
   
-- most popular product line

-- playing around to get a feel for the data.

select sum(orderdetails.quantityOrdered) as 'Qty',
       productlines.productLine as 'Product Line'
  from orderdetails join 
       products on orderdetails.productCode = products.productCode join
       productlines on productlines.productLine = products.productLine
group by productlines.productLine
order by Qty DESC;

-- do the view

create or replace view LineSuccess as 
select sum(orderdetails.quantityOrdered) as 'Qty',
       productlines.productLine as 'ProductLine'
  from orderdetails join 
       products on orderdetails.productCode = products.productCode join
       productlines on productlines.productLine = products.productLine
group by productlines.productLine
order by Qty DESC;

-- get max from view

select max(Qty),ProductLine from LineSuccess;

