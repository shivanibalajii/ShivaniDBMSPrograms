
SHOW DATABASES;

CREATE DATABASE BankDB;
USE BankDB;



CREATE TABLE Branch (
    branch_name VARCHAR(50) PRIMARY KEY,
    branch_city VARCHAR(50),
    assets REAL
);

CREATE TABLE BankAccount (
    accno INT PRIMARY KEY,
    branch_name VARCHAR(50),
    balance REAL,
    FOREIGN KEY (branch_name) REFERENCES Branch(branch_name)
);

CREATE TABLE BankCustomer (
    customer_name VARCHAR(50) PRIMARY KEY,
    customer_street VARCHAR(100),
    customer_city VARCHAR(50)
);

CREATE TABLE Depositer (
    customer_name VARCHAR(50),
    accno INT,
    PRIMARY KEY (customer_name, accno),
    FOREIGN KEY (customer_name) REFERENCES BankCustomer(customer_name),
    FOREIGN KEY (accno) REFERENCES BankAccount(accno)
);

CREATE TABLE Loan (
    loan_number INT PRIMARY KEY,
    branch_name VARCHAR(50),
    amount REAL,
    FOREIGN KEY (branch_name) REFERENCES Branch(branch_name)
);


INSERT INTO Branch VALUES
('SBI_ResidencyRoad', 'Bangalore', 50000000),
('SBI_MG_Road', 'Bangalore', 35000000),
('SBI_Indiranagar', 'Bangalore', 20000000),
('SBI_Chennai_Central', 'Chennai', 45000000),
('SBI_Hyderabad_Main', 'Hyderabad', 30000000);

INSERT INTO BankAccount VALUES
(101, 'SBI_ResidencyRoad', 250000),
(102, 'SBI_ResidencyRoad', 500000),
(103, 'SBI_MG_Road', 150000),
(104, 'SBI_Chennai_Central', 800000),
(105, 'SBI_Hyderabad_Main', 120000),
(106, 'SBI_ResidencyRoad', 900000),
(107, 'SBI_Indiranagar', 300000),
(108, 'SBI_Indiranagar', 600000),
(109, 'SBI_Hyderabad_Main', 700000),
(110, 'SBI_MG_Road', 400000);

INSERT INTO BankCustomer VALUES
('Ravi', 'Church Street', 'Bangalore'),
('Sneha', 'MG Road', 'Bangalore'),
('Arjun', 'Residency Road', 'Bangalore'),
('Meena', 'Anna Nagar', 'Chennai'),
('Kiran', 'Banjara Hills', 'Hyderabad'),
('Deepa', 'Koramangala', 'Bangalore'),
('Rajesh', 'Adyar', 'Chennai');

INSERT INTO Depositer VALUES
('Ravi', 101),
('Ravi', 102),
('Sneha', 103),
('Arjun', 106),
('Meena', 104),
('Kiran', 105),
('Deepa', 107),
('Deepa', 108),
('Kiran', 109),
('Rajesh', 110);

INSERT INTO Loan VALUES
(201, 'SBI_ResidencyRoad', 1000000),
(202, 'SBI_MG_Road', 1500000),
(203, 'SBI_Indiranagar', 500000),
(204, 'SBI_Chennai_Central', 1200000),
(205, 'SBI_Hyderabad_Main', 700000);




SELECT branch_name, (assets/100000) AS 'assets in lakhs'
FROM Branch;


SELECT D.customer_name, B.branch_name, COUNT(D.accno) AS num_accounts
FROM Depositer D
JOIN BankAccount B ON D.accno = B.accno
GROUP BY D.customer_name, B.branch_name
HAVING COUNT(D.accno) >= 2;


CREATE VIEW BranchLoanSummary AS
SELECT branch_name, SUM(amount) AS total_loan_amount
FROM Loan
GROUP BY branch_name;

SELECT * FROM BranchLoanSummary;


SELECT * FROM BankCustomer
WHERE customer_city = 'Bangalore';


SELECT * FROM BankAccount
WHERE balance > 100000;


SELECT branch_city, SUM(assets) AS total_assets
FROM Branch
GROUP BY branch_city;


SELECT B.branch_name, SUM(A.balance) AS total_deposits
FROM Branch B
JOIN BankAccount A ON B.branch_name = A.branch_name
GROUP BY B.branch_name;


SELECT D.customer_name, COUNT(D.accno) AS account_count
FROM Depositer D
GROUP BY D.customer_name
HAVING COUNT(D.accno) > 1;


SELECT D.accno, C.customer_name, C.customer_city, A.balance, A.branch_name
FROM Depositer D
JOIN BankCustomer C ON D.customer_name = C.customer_name
JOIN BankAccount A ON D.accno = A.accno;


SELECT branch_name, AVG(amount) AS avg_loan_amount
FROM Loan
GROUP BY branch_name;


SELECT DISTINCT D.customer_name
FROM Depositer D
JOIN BankAccount A ON D.accno = A.accno
WHERE A.branch_name IN (SELECT DISTINCT branch_name FROM Loan);


SELECT D.customer_name, SUM(A.balance) AS total_balance
FROM Depositer D
JOIN BankAccount A ON D.accno = A.accno
GROUP BY D.customer_name
ORDER BY total_balance DESC
LIMIT 3;


SELECT branch_name, SUM(balance) AS total_deposits
FROM BankAccount
GROUP BY branch_name
HAVING SUM(balance) = (
    SELECT MAX(total_deposits)
    FROM (
        SELECT SUM(balance) AS total_deposits
        FROM BankAccount
        GROUP BY branch_name
    ) AS temp
);
