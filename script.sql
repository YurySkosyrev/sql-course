CREATE DATABASE company_repository;
DROP DATABASE company_repository;

CREATE SCHEMA company_storage;

CREATE TABLE company_storage.company
(
    id   INT PRIMARY KEY,
    name VARCHAR UNIQUE NOT NULL,
    date DATE           NOT NULL CHECK ( date > '1995-01-01' AND date < '2020-01-01')
);

INSERT INTO company (id, name, date)
VALUES (1, 'Google', '2001-01-01'),
(2, 'Apple', '2002-09-02'),
(3, 'Facebook', '1995-02-01');

DROP TABLE employee;
CREATE TABLE employee
(
    id         INT PRIMARY KEY,
    first_name VARCHAR(128) NOT NULL ,
    last_name  VARCHAR(128) NOT NULL ,
    salary     INT,
    company_id INT REFERENCES company(id),
    UNIQUE (first_name, last_name)
);

SELECT DISTINCT
    first_name AS f_name,
    last_name AS l_name,
    salary
FROM employee AS empl
ORDER BY first_name, salary DESC
LIMIT 2
OFFSET 2;

UPDATE employee
SET company_id = 2,
    salary = 1000
WHERE id = 1
RETURNING id, first_name || ' ' || last_name as fio; -- поддерживается не всеми СУБД

