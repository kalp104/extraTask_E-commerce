-- create table
CREATE TABLE Customers (
    CustomerID SERIAL PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Country VARCHAR(50),
    SignupDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Products (
    ProductID SERIAL PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50),
    Price DECIMAL(10,2) NOT NULL,
    StockQuantity INT NOT NULL
);

CREATE TABLE Orders (
    OrderID SERIAL PRIMARY KEY,
    CustomerID INT REFERENCES Customers(CustomerID),
    OrderDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    TotalAmount DECIMAL(10,2) NOT NULL,
    Status VARCHAR(20) 
);

CREATE TABLE OrderDetails (
    OrderDetailID SERIAL PRIMARY KEY,
    OrderID INT REFERENCES Orders(OrderID) ,
    ProductID INT REFERENCES Products(ProductID),
    Quantity INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL
);

CREATE TABLE Payments (
    PaymentID SERIAL PRIMARY KEY,
    OrderID INT REFERENCES Orders(OrderID) ,
    PaymentDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PaymentMethod VARCHAR(50),
    Amount DECIMAL(10,2) NOT NULL
);

-- insert into table
INSERT INTO Customers (CustomerName, Email, Country, SignupDate) VALUES
('Kalp', 'kalp@gmail.com', 'India', '2024-01-01 10:15:00'),
('Jaymin', 'jaymin@gmail.com', 'USA', '2024-02-15 14:45:00'),
('Rishi', 'rishi@gmail.com', 'Australia', '2024-03-10 08:30:00'),
('Smit', 'smit@gmail.com', 'India', '2024-04-05 12:20:00'),
('Jyot', 'jyot@gmail.com', 'Germany', '2024-05-20 18:00:00');

INSERT INTO Products (ProductName, Category, Price, StockQuantity) VALUES
('Laptop', 'Electronics', 800.00, 50),
('Smartphone', 'Electronics', 500.00, 100),
('T-Shirt', 'Clothing', 20.00, 200),
('Jeans', 'Clothing', 40.00, 150),
('Headphones', 'Electronics', 100.00, 75),
('Tablet', 'Electronics', 300.00, 60),
('Sneakers', 'Footwear', 60.00, 80),
('Backpack', 'Accessories', 45.00, 90),
('Watch', 'Accessories', 150.00, 40),
('Camera', 'Electronics', 700.00, 30);

INSERT INTO Orders (CustomerID, OrderDate, TotalAmount, Status) VALUES
(1, '2024-06-01 12:30:00', 1300.00, 'Delivered'),
(2, '2024-06-05 09:20:00', 540.00, 'Shipped'),
(3, '2024-06-10 15:00:00', 60.00, 'Delivered'),
(4, '2024-06-15 18:45:00', 800.00, 'Cancelled'),
(5, '2024-06-20 11:10:00', 140.00, 'Delivered');

INSERT INTO OrderDetails (OrderID, ProductID, Quantity, Price) VALUES
(1, 1, 1, 800.00),
(1, 2, 1, 500.00),
(2, 2, 1, 500.00),
(2, 3, 2, 20.00),
(3, 4, 1, 40.00),
(3, 3, 1, 20.00),
(4, 6, 1, 300.00),
(4, 7, 2, 60.00),
(5, 8, 1, 45.00),
(5, 9, 1, 150.00);

INSERT INTO Payments (OrderID, PaymentDate, PaymentMethod, Amount) VALUES
(1, '2024-06-02 15:00:00', 'Credit Card', 1300.00),
(2, '2024-06-06 10:30:00', 'PayPal', 540.00),
(3, '2024-06-11 12:00:00', 'Bank Transfer', 60.00),
(5, '2024-06-21 14:20:00', 'Cash', 140.00);

-- select from the table
select * from Customers;
select * from Payments;
select * from OrderDetails;
select * from Orders;
select * from Products;


-- 1. Query: Total Sales Per Product Category 
-- Find the total revenue generated for each product category.
   select p.category, sum(o.quantity*o.price) as sales 
   from OrderDetails o
   join Products p on p.productId = o.productId
   join Orders r on  o.orderId = r.orderId
   where r.status = 'Delivered'
   group by p.category order by sales desc

-- 2. Query: Top 5 Customers by Total Spending 
-- Identify the top 5 customers who have spent the most on delivered orders. 
   select c.CustomerName, sum(o.totalAmount) as spend
   from orders o 
   join customers c on o.customerId = c.customerId
   where o.status = 'Delivered'
   group by c.CustomerName
   limit 5
   
-- 3. Query: Monthly Sales Growth Rate 
-- Compute the month-over-month sales growth percentage. 
   select date_trunc('month', orderDate) as month, sum(totalAmount) as growth
   from orders 
   where status = 'Delivered'
   group by month
   order by month;

-- 4. Query: Average Order Value (AOV) Per Customer 
-- Find the average amount spent per order by each customer.
   select c.customerName, avg(o.totalAmount) as avg_amount 
   from orders o 
   join customers c on o.customerId = c.customerId
   where o.status = 'Delivered'
   group by c.customerName  

-- 5. Query: Products with Low Stock 
-- Identify products where the stock quantity is below a given threshold. 
   select productName, stockQuantity
   from products 
   where stockQuantity < (select avg(StockQuantity) from Products);

-- 6. Query: Most Frequently Purchased Products 
-- Find the top 10 most frequently ordered products. 
   select p.productName, sum(d.quantity) as frequent_purchased
   from products p 
   join orderDetails d on p.productId = d.productId
   group by p.productName
   order by frequent_purchased desc
   limit 10

-- 7. Query: Customer Retention Analysis 
-- Calculate the percentage of customers who placed another order within 90 days of their first order. 
   select 
   round((count(distinct customerid) * 100.0) / (select count(distinct customerId) from customers), 2) as retention
   from orders
   where customerid in (
   select customerId 
   from orders 
   group by customerId 
   having max(orderDate) - min(orderDate) <= interval '90 days'
   and count(orderId) > 1
   );

-- 8. Query: Revenue Contribution of Each Payment Method 
-- Determine the percentage of total revenue generated by each payment method. 
   select paymentMethod, 
   sum(amount) as totalRevenue, 
   round((sum(amount) / (select sum(amount) from payments)) * 100, 2) AS revenue_percent
   from payments
   group by paymentMethod
   order by revenue_percent desc;
   
-- 9. Query: Order Processing Time Analysis 
-- Find the average time taken for an order to move from ‘Pending’ to ‘Delivered’ status. 
   select round(avg(extract(day from (p.paymentDate - o.orderDate))), 2) AS AvgTime
   from orders o
   join payments p on o.orderID = p.orderID
   where o.status = 'Delivered';

-- 10. Query: Repeat Customer Rate 
-- Calculate the percentage of customers who have made more than one purchase.
   select 
   round((count(distinct customerid) * 100.0) / (select count(distinct customerId) from orders where status = 'Delivered'), 2) 
   as customerRate
   from orders
   where status = 'Delivered'
   group by customerId
   having count(orderId) > 1;
