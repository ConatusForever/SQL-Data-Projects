-- Northwind Data Analysis

--1. Show the first name, last name, and hire data of all United States-based employees with the title of Sales Representative.

select
	FirstName, LastName, HireDate, Country
from Employees
where Country ='USA' and Title ='Sales Representative'


go

--2. In the Suppliers table, show the SupplierID, ContactName, and ContactTitle for those Suppliers whose ContactTitle is not Marketing Manager.

select SupplierID,
		ContactName,
		ContactTitle
from Suppliers
where ContactTitle <> 'Marketing Manager'

go

--3. Show the ProductID and ProductName for products where ProductName includes "queso".

select productId,
	productName
from Products
where productname like '%queso%'

go

-- 4. How many customers do we have?

select
	count(customerId) as TotalCustomers
	from customers 

go

-- 5. For each product, show the associated supplier along with the product name and product ID.

select 
	p.ProductID,
	p.productName,
	s.CompanyName

from Products as p
left join Suppliers as s
on p.SupplierID = s.SupplierID

go

-- 6. In the Customers table, show the total number of customers per country and city. Sort results in descending order.

select 
	Country,
	City,
	count(*) as TotalCustomers
from Customers
group by Country, City
order by TotalCustomers desc

go

/*
7. What products do we have that needs to be reordered. 
Using the fields UnitsInStock and ReorderLevel, where UnitesInStock is less than or equal to the ReorderLevel. Sort results by the ProductID.
*/

select 
	ProductID,
	ProductName,
	UnitsInStock,
	ReorderLevel
from Products
where UnitsInStock <= ReorderLevel
order by productId asc


-- 8. Using ShipCountry, return the top three countries with the highest average freight. Sort in descending order.

select
	top 3
	ShipCountry,
	AVG(freight) as avgFreight
from orders
group by ShipCountry
order by avgFreight desc


-- 9. There are a few customers who haven't placed an order. Show these customers.

select  c.CustomerID as customerCustomerID,
		o.CustomerID as orderCustomerID
from Orders as o
full outer join customers as c
on o.customerId = c.customerId
where o.CustomerID is null

go

/*
10. We want to know who our VIP customers are. VIP customers are whose who have made 1 order with a total value (not including a discount) equal to or greater than $10,000. 
Only focus on orders placed in 2016.
*/


select 
		c.CustomerID,
		c.CompanyName,
		o.orderID,
		sum(unitprice *quantity-discount) as sales
from orderDetails as od
left join Orders as o
on od.OrderID = o.OrderID
left join Customers as c
on o.CustomerID = c.CustomerID
where year(OrderDate) = 2016 
group by c.CustomerID, c.CompanyName, o.OrderID
having sum(unitprice *quantity-discount) > 10000

order by sales desc

go

/*
11. One of the salespeople has come to you with a request.
She thinks that she accidentally entered a line item twice on an order, each time with a different ProductID, but the exact same quantity.
She remembers that the quantity was 60 or more. Show all the OrderIDs with line items that match this, in order of OrderID.
*/

select o.orderId
from orders as o
left join OrderDetails as od
on o.OrderID = od.OrderID
where Quantity = 60

go

/*
12. The VP of sales, has been doing some more thinking some more about the problem of late orders. 
He realizes that just looking at the number of orders arriving late for each salesperson isn't a good idea.
It needs to be compared to the total number of orders per salesperson. We want results like the following:
*/

select o.EmployeeID,
	e.LastName,
	count(*) as AllOrders,
	sum(case when o.RequiredDate <= o.shippedDate then 1 else 0 end) as LateOrders
from Orders as o
left join Employees as e
on o.EmployeeID = e.EmployeeID
group by o.EmployeeID, e.LastName
order by o.EmployeeID

go

/*
13. The VP of sales would like to do a sales campaign for existing customers. He'd like to categorize customers into groups, based on how much they ordered in 2016.
Then, depending on which group the customer is in, he will target the customer with different sales materials.

The customer grouping categories are 0 to 1,000, 1,000 to 5,000, 5,000 to 10,000, and over 10,000. So, if the total dollar amount of the customer’s purchases in that year were between 0 to 1,000, they would be in the “Low” group. A customer with purchase from 1,000 to 5,000 would be in the “Medium” group, and so on.

Order the results by CustomerID.

*/


select 
	o.CustomerID,
	c.CompanyName,
	sum(od.unitPrice * quantity) as OrderAmount,
	case 
		when sum(od.unitPrice * quantity) >= 0 and sum(od.unitPrice * quantity) < 1001 then 'Low'
		when sum(od.unitPrice * quantity) >= 1001 and sum(od.unitPrice * quantity) < 5001 then 'Medium'
		when sum(od.unitPrice * quantity) >= 5001 and sum(od.unitPrice * quantity) < 10001 then 'High'
		when sum(od.unitPrice * quantity) > 10000 then 'very high'
		end as  CustomerGroup
from orders as o
left join OrderDetails as od
on o.OrderID = od.OrderID
left join customers as c
on c.CustomerID = o.CustomerID
where year(OrderDate) = 2016
group by o.CustomerID, c.CompanyName
order by c.CompanyName asc

go

/*
14.Some salespeople have more orders arriving late than others. 
Maybe they're not following up on the order process, and need more training.
Which salespeople have the most orders arriving late?
*/

select o.EmployeeID,
		e.LastName,
		sum(case when o.requiredDate <= o.shippedDate then 1 else 0 end) as LateOrders
from orders as o
left join Employees as e
on e.EmployeeID = o.EmployeeID
group  by o.EmployeeID, e.LastName
having sum(case when o.requiredDate <= o.shippedDate then 1 else 0 end) >0 
order by LateOrders desc

go
