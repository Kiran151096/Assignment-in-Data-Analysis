USE classicmodels;

-- Que 1) a. Fetch the employee number, first name and last name of those employees who are working as Sales Rep reporting to employee with employeenumber 1102

SELECT * FROM employees;
SELECT employeeNumber, firstname, lastname
FROM employees
WHERE jobTitlE = 'Sales Rep' AND reportsTo = 1102;

-- b. Show the unique productline values containing the word cars at the end from the products table.

SELECT * FROM productlines;
SELECT productLine
FROM productlines
WHERE productLine LIKE '%cars';  

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Que 2) CASE STATEMENTS for Segmentation
Select * from customers; 
select customerNumber,customerName, 
case 
  when COUNTRY IN ('USA','CANADA') THEN 'North America' 
  when COUNTRY IN ('UK','FRANCE','GERMANY') THEN 'Europe'
  else 'other'
END 
as CustomerSegment from customers;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Que 3) Group By with Aggregation functions and Having clause, Date and Time functions
-- a. Using the OrderDetails table, identify the top 10 products (by productCode) with the highest total order quantity across all orders.

SELECT * FROM orderdetails;
SELECT 
    productCode,
    SUM(quantityOrdered) AS total_ordered
FROM orderdetails
GROUP BY productCode
ORDER BY total_ordered DESC
LIMIT 10;

-- b. Company wants to analyse payment frequency by month. Extract the month name from the payment date to count the total number of payments for each month and include only those months with a payment count exceeding 20. Sort the results by total number of payments in descending order.  (Refer Payments table). 
   SELECT * FROM payments; 
 SELECT 
    MONTHNAME(paymentDate) AS payment_month, 
    COUNT(customerNumber) AS num_payments
FROM Payments
GROUP BY payment_month
HAVING COUNT(customerNumber) > 20
ORDER BY num_payments DESC;  

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Que 4) CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default
-- a. Create a table named Customers to store customer information. Include the following columns:

CREATE TABLE Customers1 (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20)
);

SELECT customer_id, first_name, last_name, email, phone_number
FROM Customers1;

-- b. Create a table named Orders to store information about customer orders. Include the following columns:
 
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,    
    customer_id INT,                              
    order_date DATE,                              
    total_amount DECIMAL(10,2),                
    FOREIGN KEY (customer_id) REFERENCES Customers1(customer_id),  
    CHECK (total_amount > 0)                      
);
SELECT * FROM Orders1;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Que 5)  JOINS
-- a. List the top 5 countries (by order count) that Classic Models ships to. (Use the Customers and Orders tables)
SELECT 
    c.country,
    COUNT(o.orderNumber) AS order_count
FROM 
    Customers c
JOIN 
    Orders o ON c.customerNumber = o.customerNumber
GROUP BY 
    c.country
ORDER BY 
    order_count DESC
LIMIT 5;
 
 -- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- Que 6) Create a table project with below fields.

CREATE TABLE project(
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    Gender ENUM('Male', 'Female') NOT NULL,
    ManagerID INT
);

SELECT * FROM project;
INSERT INTO project VALUES(1,"Pranaya","Male",3);
INSERT INTO project VALUES(2,"Priyanka","Female",1);
INSERT INTO project VALUES(3,"Pretty","Female",NULL);
INSERT INTO project VALUES(4,"Anurag","Male",1);
INSERT INTO project VALUES(5,"Sambit","Male",1);
INSERT INTO project VALUES(6,"Rajesh","Male",3);
INSERT INTO project VALUES(7,"Hina","Female",3);

SELECT * FROM project;
--  Find out the names of employees and their related managers.
SELECT 
   e1.FullName AS Manager_Name,
   e2.FullName AS Emp_Name
FROM project e1
JOIN project e2 ON e1.EmployeeID = e2.ManagerID
ORDER BY Manager_Name;

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Que 7)  a. Create table facility. Add the below fields into it.

CREATE TABLE facility (
    Facility_ID INT,
    Name VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100)
);
SELECT * FROM facility;

-- i) Alter the table by adding the primary key and auto increment to Facility_ID column.

ALTER TABLE facility
MODIFY COLUMN Facility_ID INT AUTO_INCREMENT PRIMARY KEY;

desc facility;

-- ii) Add a new column city after name with data type as varchar which should not accept any null values.

ALTER TABLE facility
ADD COLUMN City VARCHAR(100) NOT NULL AFTER Name;

desc facility;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Que 8) Views in SQL
-- a. Create a view named product_category_sales that provides insights into sales performance by product category. This view should include the following information:
-- productLine: The category name of the product (from the ProductLines table).

-- total_sales: The total revenue generated by products within that category (calculated by summing the orderDetails.quantity * orderDetails.priceEach for each product in the category).

-- number_of_orders: The total number of orders containing products from that category.


CREATE VIEW product_category_sales AS
SELECT 
    pl.productLine, 
    SUM(od.quantityOrdered * od.priceEach) AS total_sales,
    COUNT(DISTINCT o.orderNumber) AS number_of_orders
FROM 
    productlines pl
JOIN 
    products p ON pl.productLine = p.productLine
JOIN 
    orderdetails od ON p.productCode = od.productCode
JOIN 
    orders o ON od.orderNumber = o.orderNumber
GROUP BY 
    pl.productLine;
    
SELECT * FROM product_category_sales;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Que 9) Stored Procedures in SQL with parameters
-- a. Create a stored procedure Get_country_payments which takes in year and country as inputs and gives year wise, country wise total amount as an output. Format the total amount to nearest thousand unit (K)

DELIMITER //
CREATE PROCEDURE Get_country_payments(IN Year INT, IN country VARCHAR(50))
BEGIN
    DECLARE Total_Amount DECIMAL(15, 2);
    SELECT SUM(p.amount) INTO Total_Amount
    FROM payments p
    JOIN customers c ON p.customerNumber = c.customerNumber
    WHERE YEAR(p.paymentDate) = Year
    AND c.country = country;
    SELECT 
		  Year,
          country,
         CONCAT(ROUND(Total_Amount / 1000), 'K') AS Total_Amount;
END //

DELIMITER ;

CALL Get_country_payments(2003,'France');
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Que 10)  Window functions - Rank, dense_rank, lead and lag

-- a) Using customers and orders tables, rank the customers based on their order frequency

WITH customer_order_count AS (
    SELECT c.customerName, 
        COUNT(o.orderNumber) AS order_count
    FROM customers c
    LEFT JOIN 
        orders o 
    ON 
        c.customerNumber = o.customerNumber
    GROUP BY 
        c.customerName
)

SELECT 
    customerName, 
    order_count,
    DENSE_RANK() OVER (ORDER BY order_count DESC) AS order_frequency_rnk
FROM customer_order_count
ORDER BY order_frequency_rnk;


-- b) Calculate year wise, month name wise count of orders and month over month (MoM) percentage change. Format the YoY values in no decimals and show in % sign.

WITH MonthlyOrders AS (
    SELECT
        YEAR(orderDate) AS Year,
        MONTHNAME(orderDate) AS Month,
        COUNT(orderNumber) AS Total_Orders,
        MONTH(orderDate) AS MonthNum
    FROM Orders
    GROUP BY Year, MonthNum, Month
)

SELECT Year, Month,Total_Orders,
    CONCAT(
        ROUND(
            CASE
                WHEN LAG(Total_Orders) OVER (ORDER BY Year, MonthNum) IS NULL OR LAG(Total_Orders) OVER (ORDER BY Year, MonthNum) = 0 THEN NULL
                ELSE ((Total_Orders - LAG(Total_Orders) OVER (ORDER BY Year, MonthNum)) / LAG(Total_Orders) OVER (ORDER BY Year, MonthNum)) * 100
            END,
            0
        ), '%'
    ) AS MoM_Change
FROM MonthlyOrders
ORDER BY Year, MonthNum;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Que 11) Subqueries and their applications
-- a. Find out how many product lines are there for which the buy price value is greater than the average of buy price value. Show the output as product line and its count.

SELECT productLine, COUNT(*) AS Total
FROM products
WHERE buyPrice > (
       SELECT AVG (buyPrice)
       FROM products
)
GROUP BY productLine
ORDER BY Total DESC;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Que12) ERROR HANDLING in SQL
--       Create the table Emp_EH. Below are its fields.
-- ●	EmpID (Primary Key)
-- ●	EmpName
-- ●	EmailAddress
-- Create a procedure to accept the values for the columns in Emp_EH. Handle the error using exception handling concept. Show the message as “Error occurred” in case of anything wrong.

CREATE TABLE Emp_EH (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(100),
    EmailAddress VARCHAR(100)
);
DELIMITER //

CREATE PROCEDURE InsertEmpDetails(
    IN p_EmpID INT,
    IN p_EmpName VARCHAR(100),
    IN p_EmailAddress VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- If an error occurs, display the error message
        SELECT 'Error occurred' AS ErrorMessage;
    END;

    -- Try to insert the values into the Emp_EH table
    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress)
    VALUES (p_EmpID, p_EmpName, p_EmailAddress);

END//

DELIMITER ;
CALL InsertEmpDetails(1, 'John Doe', 'john.doe@example.com');
SELECT * FROM Emp_EH;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Que 13) TRIGGERS

CREATE TABLE Emp_BIT (
    Name VARCHAR(100),
    Occupation VARCHAR(100),
    Working_date DATE,
    Working_hours INT
);

INSERT INTO Emp_BIT (Name, Occupation, Working_date, Working_hours) VALUES
('Robin', 'Scientist', '2020-10-04', 12),
('Warner', 'Engineer', '2020-10-04', 10),
('Peter', 'Actor', '2020-10-04', 13),
('Marco', 'Doctor', '2020-10-04', 14),
('Brayden', 'Teacher', '2020-10-04', 12),
('Antonio', 'Business', '2020-10-04', 11);

SELECT * FROM Emp_BIT;

DELIMITER //

CREATE TRIGGER before_insert_emp_bit
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
    IF NEW.Working_hours < 0 THEN
        SET NEW.Working_hours = ABS(NEW.Working_hours);  -- Convert negative hours to positive
    END IF;
END //

DELIMITER ;




