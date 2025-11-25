

DROP DATABASE IF EXISTS supplierdb;
CREATE DATABASE supplierdb;
USE supplierdb;


CREATE TABLE Supplier (
    sid INT PRIMARY KEY,
    sname VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE Parts (
    pid INT PRIMARY KEY,
    pname VARCHAR(50),
    color VARCHAR(20)
);

CREATE TABLE Catalog (
    sid INT,
    pid INT,
    cost DECIMAL(10,2),
    PRIMARY KEY (sid, pid),
    FOREIGN KEY (sid) REFERENCES Supplier(sid),
    FOREIGN KEY (pid) REFERENCES Parts(pid)
);


INSERT INTO Supplier VALUES
(1, 'Acme Widget Suppliers', 'Bangalore'),
(2, 'Global Parts Co', 'Delhi'),
(3, 'Prime Supplies', 'Mumbai');

INSERT INTO Parts VALUES
(101, 'Bolt', 'red'),
(102, 'Nut', 'blue'),
(103, 'Screw', 'red'),
(104, 'Washer', 'green');

INSERT INTO Catalog VALUES
(1, 101, 15.50),
(1, 102, 10.00),
(1, 103, 25.00),
(2, 101, 17.00),
(2, 104, 5.00),
(3, 102, 8.00),
(3, 103, 30.00);




SELECT DISTINCT p.pname
FROM Parts p
JOIN Catalog c ON p.pid = c.pid;


SELECT s.sname
FROM Supplier s
WHERE NOT EXISTS (
    SELECT * FROM Parts p
    WHERE NOT EXISTS (
        SELECT * FROM Catalog c
        WHERE c.sid = s.sid AND c.pid = p.pid
    )
);


SELECT s.sname
FROM Supplier s
WHERE NOT EXISTS (
    SELECT * FROM Parts p
    WHERE p.color = 'red'
    AND NOT EXISTS (
        SELECT * FROM Catalog c
        WHERE c.sid = s.sid AND c.pid = p.pid
    )
);


SELECT p.pname
FROM Parts p
JOIN Catalog c1 ON p.pid = c1.pid
JOIN Supplier s ON s.sid = c1.sid
WHERE s.sname = 'Acme Widget Suppliers'
AND NOT EXISTS (
    SELECT * FROM Catalog c2
    WHERE c2.pid = p.pid AND c2.sid <> s.sid
);


SELECT DISTINCT c.sid
FROM Catalog c
JOIN (
    SELECT pid, AVG(cost) AS avg_cost
    FROM Catalog
    GROUP BY pid
) avgc
ON c.pid = avgc.pid
WHERE c.cost > avgc.avg_cost;

SELECT p.pname, s.sname, c.cost
FROM Parts p
JOIN Catalog c ON p.pid = c.pid
JOIN Supplier s ON s.sid = c.sid
WHERE c.cost = (
    SELECT MAX(c2.cost)
    FROM Catalog c2
    WHERE c2.pid = p.pid
);




SELECT p.pname, s.sname, c.cost
FROM Catalog c
JOIN Parts p ON p.pid = c.pid
JOIN Supplier s ON s.sid = c.sid
WHERE c.cost = (SELECT MAX(cost) FROM Catalog);

SELECT s.sname
FROM Supplier s
WHERE NOT EXISTS (
    SELECT *
    FROM Parts p
    JOIN Catalog c ON p.pid = c.pid
    WHERE p.color = 'red' AND c.sid = s.sid
);


SELECT s.sname, SUM(c.cost) AS total_value
FROM Supplier s
JOIN Catalog c ON s.sid = c.sid
GROUP BY s.sid, s.sname;


SELECT s.sname
FROM Supplier s
JOIN Catalog c ON s.sid = c.sid
WHERE c.cost < 20
GROUP BY s.sid, s.sname
HAVING COUNT(c.pid) >= 2;


SELECT p.pname, s.sname, c.cost
FROM Catalog c
JOIN Parts p ON p.pid = c.pid
JOIN Supplier s ON s.sid = c.sid
WHERE c.cost = (
    SELECT MIN(c2.cost)
    FROM Catalog c2
    WHERE c2.pid = c.pid
);


CREATE OR REPLACE VIEW SupplierPartCount AS
SELECT s.sid, s.sname, COUNT(c.pid) AS total_parts
FROM Supplier s
LEFT JOIN Catalog c ON s.sid = c.sid
GROUP BY s.sid, s.sname;


CREATE OR REPLACE VIEW MostExpensiveSupplierPerPart AS
SELECT p.pid, p.pname, s.sname, c.cost
FROM Parts p
JOIN Catalog c ON p.pid = c.pid
JOIN Supplier s ON s.sid = c.sid
WHERE c.cost = (
    SELECT MAX(c2.cost)
    FROM Catalog c2
    WHERE c2.pid = p.pid
);

DELIMITER $$
CREATE TRIGGER prevent_low_cost
BEFORE INSERT ON Catalog
FOR EACH ROW
BEGIN
    IF NEW.cost < 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cost cannot be less than 1';
    END IF;
END $$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER set_default_cost
BEFORE INSERT ON Catalog
FOR EACH ROW
BEGIN
    IF NEW.cost IS NULL THEN
        SET NEW.cost = 50;
    END IF;
END $$
DELIMITER ;



