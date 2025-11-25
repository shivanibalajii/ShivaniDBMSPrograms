show databases;
DROP DATABASE INSURANCE;
create database INSURANCES;
show databases;
use INSURANCES;
CREATE TABLE persons(
driver_id varchar(20) primary key,
name varchar(50),
address varchar(100)
);

CREATE TABLE ownns(
driver_id varchar(20),
reg_num varchar(20),
foreign key(driver_id) references persons(driver_id),
foreign key(reg_num) references car(reg_num)
);

CREATE TABLE cars(
reg_num varchar(20) primary key,
model varchar(20),
year int
);

CREATE TABLE accidents(
report_num int primary key,
accident_date varchar(20),
location varchar(50)
);

CREATE TABLE participant(
driver_id varchar(20),
reg_num varchar(20),
report_num int,
damage_amt int,
foreign key (driver_id) references persons(driver_id),
foreign key(reg_num) references car(reg_num),
foreign key(report_num) references accidents(report_num));

select* from persons;
insert into persons values ("AO1","RICHARD","Srinivas nagar");
insert into persons values("AO2","Pradeep","Rajaji nagar");
insert into persons values("AO3","Smith","ashok nagar");
insert into persons values("AO4","Venu","NR colony");
insert into persons values("AO5","Jhon","hanumath nagar");

select*from persons;

insert into cars values("KA052250","INDICA","1990");
insert into cars values("KA031181","LANCER","1957");
insert into cars values("KA095477","TOYOTA","1998");
insert into cars values("KA053408","HONDA","2008");
insert into cars values("KA041707","AUDI","2005");
select*from cARs;

insert into ownns values("A01","KA052250");
insert into ownns values("A02","KA053408");
insert into ownns values("A03","KA095477");
insert into ownns values("A04","KA031181");
insert into ownns values("A05","KA041702");
select*from ownns;

insert into accidents values(11,"01-JAN-03","MYSORE ROAD");
insert into accidents values(12,"02-FEB-04","SOUTH END CIRCLE");
insert into accidents values(13,"21-JAN-03","BULL TEMPLE ROAD");
insert into accidents values(14,"17-FEB-08","MYSORE ROAD");
insert into accidents values(15,"04-MAR-05","KANAKAPURA ROAD");
select*from accidents;

insert into participant values("AO1","KA052250",11,10000);
insert into participant values("AO2","KA053408",12,50000);
insert into participant values("AO3","KA095477",13,25000);
insert into participant values("AO4","KA031181",14,3000);
insert into participant values("AO5","KA041702",15,5000);
SELECT*FROM participant;
SELECT report_num, SUM(damage_amt) AS total_damage
FROM participant
GROUP BY report_num;

-- 1. Select accident date and location from accidents
SELECT accident_date, location FROM accidents;

-- 2. Select driver_id, name, and damage amount for damage_amt >= 25000 (using WHERE for join)
SELECT p.driver_id, ps.name, p.damage_amt
FROM participant p, persons ps
WHERE p.driver_id = ps.driver_id
  AND p.damage_amt >= 25000;

-- 3. Select driver_id, name, reg_num, and car model for all owned cars (using WHERE for joins)
SELECT o.driver_id, ps.name, o.reg_num, c.model
FROM ownns o, persons ps, cars c
WHERE o.driver_id = ps.driver_id
  AND o.reg_num = c.reg_num;

-- 4. Select detailed accident info joining accidents, participant, and persons tables
SELECT a.report_num, a.accident_date, a.location, p.driver_id, ps.name, p.reg_num, p.damage_amt
FROM accidents a, participant p, persons ps
WHERE a.report_num = p.report_num
  AND p.driver_id = ps.driver_id;

-- 5. Select report_num and total damage (group by report_num)
SELECT report_num, SUM(damage_amt) AS total_damage
FROM participant
GROUP BY report_num;

-- 6. Select driver_id and number of accidents where driver has more than 1 accident
SELECT driver_id, COUNT(report_num) AS num_accidents
FROM participant
GROUP BY driver_id
HAVING COUNT(report_num) > 1;


SELECT DISTINCT o.reg_num, c.model
FROM ownns o, cars c
WHERE o.reg_num = c.reg_num
  AND o.reg_num NOT IN (
    SELECT p.reg_num FROM participant p
  );


SELECT DISTINCT o.reg_num, c.model
FROM ownns o, cars c, participant p
WHERE o.reg_num = c.reg_num
  AND o.reg_num = p.reg_num(+)
  AND p.reg_num IS NULL;


SELECT DISTINCT o.reg_num, c.model
FROM ownns o, cars c, participant p
WHERE o.reg_num = c.reg_num
  AND p.reg_num = o.reg_num(+)
  AND p.reg_num IS NULL;


SELECT * FROM accidents a1
WHERE NOT EXISTS (
  SELECT 1 FROM accidents a2
  WHERE STR_TO_DATE(a2.accident_date, '%d-%b-%y') > STR_TO_DATE(a1.accident_date, '%d-%b-%y')
);







































































-- 9. Select driver_id and average damage amount
SELECT driver_id, AVG(damage_amt) AS avg_damage
FROM participant
GROUP BY driver_id;

-- 10. Update damage_amt to 25000 for specific reg_num and report_num
UPDATE participant
SET damage_amt = 25000
WHERE reg_num = 'KA053408'
  AND report_num = 12;

-- 11. Select driver_id, reg_num, report_num, damage_amt for max damage
SELECT driver_id, reg_num, report_num, damage_amt
FROM participant p1
WHERE damage_amt = (
  SELECT MAX(damage_amt)
  FROM participant
);

-- 12. Select reg_num, model, and sum of damage where total damage > 20000 (join with WHERE)
SELECT c.reg_num, c.model, SUM(p.damage_amt) AS total_damage
FROM participant p, cars c
WHERE p.reg_num = c.reg_num
GROUP BY c.reg_num, c.model
HAVING SUM(p.damage_amt) > 20000;

-- 13. Create view accident_summary with counts and sums using LEFT JOIN with WHERE clause
CREATE VIEW accident_summary AS
SELECT a.report_num, a.accident_date, a.location,
       COUNT(p.driver_id) AS num_participants,
       SUM(p.damage_amt) AS total_damage
FROM accidents a, participant p
WHERE a.report_num = p.report_num(+)
GROUP BY a.report_num, a.accident_date, a.location;

-- Note: (+) is Oracle-specific outer join notation. In standard SQL without ON or IN, it's hard to do LEFT JOIN.
-- Alternative: Use a UNION of accidents with and without participants, but that's more complex.

-- 14. Select everything from accident_summary
SELECT * FROM accident_summary;































































































































































