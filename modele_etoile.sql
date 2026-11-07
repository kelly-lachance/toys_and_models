-- =============================================================
-- Toys & Models : création et alimentation du modèle en étoile
-- Base source : toys_and_models (MySQL)
-- 2 tables de faits : fait_ventes (grain : ligne de commande),
--                     fait_payment (grain : paiement client)
-- 3 dimensions SQL : dim_customers, dim_produit, dim_employee
-- (dim_date est créée dans Power Query, côté Power BI)
-- =============================================================

DROP TABLE IF EXISTS fait_ventes;
DROP TABLE IF EXISTS fait_payment;
DROP TABLE IF EXISTS dim_customers;
DROP TABLE IF EXISTS dim_produit;
DROP TABLE IF EXISTS dim_employee;

CREATE TABLE dim_customers (
customerNumber INT NOT NULL PRIMARY KEY,
CustomerName varchar(50) NOT NULL,
country varchar(50) NOT NULL,
creditLimit decimal(10,2)
);

INSERT INTO dim_customers (customerNumber, CustomerName, country, creditLimit)
SELECT c.customerNumber, c.customerName, c.country, c.creditLimit
FROM customers c;


CREATE TABLE dim_produit (
productCode VARCHAR(15) PRIMARY KEY,
productName VARCHAR(70) NOT NULL,
productLine VARCHAR(50) NOT NULL,
productVendor VARCHAR(50) NOT NULL,
quantityInStock SMALLINT,
buyPrice DECIMAL (10,2) NOT NULL
);
INSERT INTO dim_produit
(productCode, productName, productLine, productVendor, quantityInStock, buyPrice)
SELECT productCode, 
       productName, 
       productLine, 
       productVendor, 
       quantityInStock, 
       buyPrice
FROM products;

CREATE TABLE dim_employee (PRIMARY KEY (employeeNumber)) AS
SELECT e.employeeNumber,e.lastName AS LastName, e.firstName  AS FirstName, e.jobTitle, o.officeCode, o.city AS officeCity,o.state AS officeState, o.country AS officeCountry, o.territory  AS officeTerritory
FROM employees AS e
JOIN offices AS o ON o.officeCode = e.officeCode;

CREATE TABLE fait_ventes (
orderNumber INT NOT NULL,
productCode VARCHAR(15) NOT NULL,
customerNumber INT NOT NULL,
employeeNumber INT NOT NULL,
orderDate DATE NOT NULL,
shippedDate DATE,
requiredDate DATE,
status VARCHAR(15) NOT NULL,
quantityOrdered INT NOT NULL,
priceEach DECIMAL(10,2) NOT NULL,
chiffre_affaire DECIMAL(10,2),
PRIMARY KEY (orderNumber, productCode),
FOREIGN KEY (productCode) REFERENCES dim_produit(productCode),
FOREIGN KEY(customerNumber) REFERENCES dim_customers(customerNumber),
FOREIGN KEY (employeeNumber) REFERENCES dim_employee(employeeNumber)
);

INSERT INTO fait_ventes (orderNumber, productCode, customerNumber, employeeNumber, orderDate, shippedDate, requiredDate, status, quantityOrdered, priceEach, chiffre_affaire)
SELECT o.orderNumber, dp.productCode, c.customerNumber, de.employeeNumber, o.orderDate, o.shippedDate, o.requiredDate, o.status,  od.quantityOrdered, od.priceEach, ROUND(od.quantityOrdered * od.priceEach,2) AS chiffre_affaire
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN customers c ON c.customerNumber = o.customerNumber
JOIN dim_produit dp ON dp.productCode = od.productCode
JOIN dim_employee de ON de.employeeNumber = c.salesRepEmployeeNumber
;

CREATE TABLE fait_payment (
    customerNumber  INT           NOT NULL,
    checkNumber     VARCHAR(50)   NOT NULL,
    paymentDate     DATE          NOT NULL,
    amount          DECIMAL(10,2) NOT NULL,
    employeeNumber  INT           ,
    PRIMARY KEY (customerNumber, checkNumber),
    FOREIGN KEY (customerNumber) REFERENCES dim_customers(customerNumber),
    FOREIGN KEY (employeeNumber) REFERENCES dim_employee(employeeNumber)
);

INSERT INTO fait_payment (customerNumber, checkNumber, paymentDate, amount, employeeNumber)
SELECT pa.customerNumber,
       pa.checkNumber,
       pa.paymentDate,
       pa.amount,
       c.salesRepEmployeeNumber
FROM payments pa
JOIN customers c ON c.customerNumber = pa.customerNumber;
