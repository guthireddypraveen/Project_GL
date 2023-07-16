CREATE SCHEMA Travego;

USE Travego;


-- Problem Statement
-- In this project you have to do the following activities…
-- ●Create the two tables
-- ●Insert data in these tables 
-- ●Retrieve the data from these tables based on the requirements mentioned below

CREATE TABLE Passenger (
  Passenger_id INT PRIMARY KEY,
  Passenger_name VARCHAR(255) NOT NULL,
  Category VARCHAR(255) NOT NULL,
  Gender VARCHAR(10) NOT NULL,
  Boarding_City VARCHAR(255) NOT NULL,
  Destination_City VARCHAR(255) NOT NULL,
  Distance INT NOT NULL,
  Bus_Type VARCHAR(255) NOT NULL
);

CREATE TABLE Price (
  id INT PRIMARY KEY,
  Bus_type VARCHAR(255) NOT NULL,
  Distance INT NOT NULL,
  Price INT NOT NULL
);

select*from passenger;
select*from price;

INSERT INTO Passenger (Passenger_id, Passenger_name, Category, Gender, Boarding_City, Destination_City, Distance, Bus_Type)
VALUES (1, 'Sejal', 'AC', 'F', 'Bengaluru', 'Chennai', 350, 'Sleeper'),
       (2, 'Anmol', 'Non-AC', 'M', 'Mumbai', 'Hyderabad', 700, 'Sitting'),
       (3, 'Pallavi', 'AC', 'F', 'Panaji', 'Bengaluru', 600, 'Sleeper'),
       (4, 'Khusboo', 'AC', 'F', 'Chennai', 'Mumbai', 1500, 'Sleeper'),
       (5, 'Udit', 'Non-AC', 'M', 'Trivandrum', 'Panaji', 1000, 'Sleeper'),
       (6, 'Ankur', 'AC', 'M', 'Nagpur', 'Hyderabad', 500, 'Sitting'),
       (7, 'Hemant', 'Non-AC', 'M', 'Panaji', 'Mumbai', 700, 'Sleeper'),
       (8, 'Manish', 'Non-AC', 'M', 'Hyderabad', 'Bengaluru', 500, 'Sitting'),
       (9, 'Piyush', 'AC', 'M', 'Pune', 'Nagpur', 700, 'Sitting');

INSERT INTO Price (id, Bus_type, Distance, Price)
VALUES (1, 'Sleeper', 350, 770),
       (2, 'Sleeper', 500, 1100),
       (3, 'Sleeper', 600, 1320),
       (4, 'Sleeper', 700, 1540),
       (5, 'Sleeper', 1000, 2200),
       (6, 'Sleeper', 1200, 2640),
       (7, 'Sleeper', 1500, 2700),
       (8, 'Sitting', 500, 620),
       (9, 'Sitting', 600, 744),
       (10, 'Sitting', 700, 868),
       (11, 'Sitting', 1000, 1240),
       (12, 'Sitting', 1200, 1488),
       (13, 'Sitting', 1500, 1860);
       
select*from passenger;
select*from price;

-- TASK2
-- 2.(Medium) Perform read operation on the designed table created in the above task using SQL script. 
-- a.How many females and how many male passengers traveled a minimum distance of 600 KMs?

SELECT Gender, COUNT(*) as Total 
FROM Passenger 
WHERE Distance >= 600 
GROUP BY Gender;

-- b. Here's the SQL code to find the minimum ticket price of a Sleeper Bus:( MINIORICE-770)

SELECT MIN(Price) as MinPrice 
FROM Price 
WHERE Bus_type = 'Sleeper';

-- c. Here's the SQL code to select passenger names whose names start with the character 'S': SEJAL

SELECT Passenger_name 
FROM Passenger 
WHERE Passenger_name LIKE 'S%';

-- d. Here's the SQL code to calculate the price charged for each passenger and display Passenger name, Boarding City, Destination City, Bus_Type, and Price in the output:

SELECT p.Passenger_name, p.Boarding_City, p.Destination_City, p.Bus_Type, pr.Price 
FROM Passenger p 
JOIN Price pr ON p.Distance = pr.Distance AND p.Bus_Type = pr.Bus_type;

-- e. Here's the SQL code to find out the passenger name(s) and the ticket price for those who traveled 1000 KMs Sitting in a bus:

SELECT p.Passenger_name, pr.Price 
FROM Passenger p 
JOIN Price pr ON p.Bus_Type = pr.Bus_type AND p.Distance = pr.Distance 
WHERE p.Bus_Type = 'Sitting' AND p.Distance = 1000;

-- f. Here's the SQL code to find the Sitting and Sleeper bus charge for Pallavi to travel from Bangalore to Panaji:

SELECT p.Bus_Type, pr.Price 
FROM Passenger p 
JOIN Price pr ON p.Bus_Type = pr.Bus_type AND p.Distance = pr.Distance 
WHERE p.Passenger_name = 'Pallavi' AND p.Boarding_City = 'Panaji' AND p.Destination_City = 'Bengaluru';

-- g. Here's the SQL code to list the unique (non-repeated) distances from the "Passenger" table in descending order:

SELECT DISTINCT Distance 
FROM Passenger 
ORDER BY Distance DESC;

-- h. Here's the SQL code to display the passenger name and percentage of distance traveled by that passenger from the total distance traveled by all passengers without using user variables:

SELECT p.Passenger_name, CONCAT(ROUND((p.Distance / t.TotalDistance) * 100, 2), '%') AS DistancePercentage 
FROM Passenger p 
JOIN (SELECT SUM(Distance) AS TotalDistance FROM Passenger) t 
ORDER BY DistancePercentage DESC;
       
