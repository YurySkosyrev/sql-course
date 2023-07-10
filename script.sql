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

CREATE DATABASE book_repository;

CREATE TABLE author (
  id SERIAL PRIMARY KEY ,
  first_name VARCHAR(128) NOT NULL ,
  last_name VARCHAR(128) NOT NULL
);

CREATE TABLE book
(
    id   BIGSERIAL PRIMARY KEY,
    name VARCHAR(128) NOT NULL ,
    year SMALLINT NOT NULL ,
    pages SMALLINT NOT NULL ,
    author_id INT REFERENCES author(id)
);

INSERT INTO author (first_name, last_name)
VALUES ('Кей', 'Хорстманн'),
       ('Стивен', 'Кови'),
       ('Тони', 'Роббинс'),
       ('Наполеон', 'Хилл'),
       ('Роберт', 'Кийосаки'),
       ('Дейл', 'Корнеги');

SELECT * FROM author;

insert into book (name, year, pages, author_id)
values ('Java. Библиотека профессионала. Том 1', 2010, 1102, (SELECT id FROM author WHERE last_name = 'Хорстманн')),
       ('Java. Библиотека профессионала. Том 2', 2012, 952, (SELECT id FROM author WHERE last_name = 'Хорстманн')),
       ('Java SE. Вводный курс', 2015, 203, (SELECT id FROM author WHERE last_name = 'Хорстманн')),
       ('7 навыков высокоэффективных людей', 1989, 356, (SELECT id FROM author WHERE last_name = 'Кови')),
       ('Разбуди в себе исполина', 1991, 576, (SELECT id FROM author WHERE last_name = 'Роббинс')),
       ('Думай и богатей', 1937, 336, (SELECT id FROM author WHERE last_name = 'Хилл')),
       ('Богатый папа, бедный папа', 1997, 352, (SELECT id FROM author WHERE last_name = 'Кийосаки')),
       ('Квадрант денежного потока', 1998, 368, (SELECT id FROM author WHERE last_name = 'Кийосаки')),
       ('Как перестать беспокоиться и начать жить', 1948, 368, (SELECT id FROM author WHERE last_name = 'Корнеги')),
       ('Как завоевать друзей и оказывать влияние на людей', 1939, 352, (SELECT id FROM author WHERE last_name = 'Корнеги'));

select * from book;

-- Выбрать название книги, год и автора

select
    b.name,
    b.year,
    (select first_name from author as a where a.id = b.author_id)
from book as b
order by b.year asc;

-- Выбрать книги, в которых количество страниц больше среднего

select * from book
where pages > (select avg(pages) from book);

-- Выбрать пять самых старых книг и посчитать сумму их страниц

SELECT SUM(pages) FROM
(SELECT * FROM book
ORDER BY year
LIMIT 5) AS b;

UPDATE book
SET pages = 777
WHERE id = 1;

-- Удалить автора, который написал самую большую книгу

DELETE FROM book
WHERE author_id = (SELECT author_id FROM book WHERE pages = (SELECT MAX(pages) FROM book))
RETURNING *;

DELETE FROM author
WHERE id = 1
RETURNING *;

--

DROP TABLE IF EXISTS employee_contact;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS company;
DROP TABLE IF EXISTS contact;

CREATE TABLE company
(
    id   INT PRIMARY KEY,
    name VARCHAR UNIQUE NOT NULL,
    date DATE           NOT NULL CHECK ( date > '1995-01-01' AND date < '2020-01-01')
);

CREATE TABLE employee
(
    id         BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(128),
    last_name  VARCHAR(128),
    company_id INT REFERENCES company (id),
    salary INT
);

CREATE TABLE contact
(
    id     BIGINT PRIMARY KEY,
    number VARCHAR(128) NOT NULL ,
    type   VARCHAR(128)
);

CREATE TABLE employee_contact
(
    employee_id INT REFERENCES employee (id),
    contact_id  INT REFERENCES contact (id),
    PRIMARY KEY (employee_id, contact_id)
);

INSERT INTO company (id, name, date)
VALUES (1, 'Google', '2001-01-01'),
       (2, 'Apple', '2002-10-29'),
       (3, 'Facebook', '1995-09-13'),
       (4, 'Amazon', '2005-06-17');

INSERT INTO employee (id, first_name, last_name, company_id, salary)
VALUES
    (1, 'Ivan', 'Sidorov', 1, 5),
    (2, 'Ivan', 'Ivanov', 2, 10),
    (3, 'Arni', 'Paramonov', 2, NULL),
    (4, 'Petr', 'Petrov', 3, 20),
    (5, 'Sveta', 'Svetikova', NULL, 15);

INSERT INTO contact (id, number, type)
VALUES
    (1, '234-56-78', 'домашний'),
    (2, '987-65-43', 'рабочий'),
    (3, '565-25-91', 'мобильный'),
    (4, '332-55-67', NULL),
    (5, '465-11-22', NULL);

INSERT INTO employee_contact (employee_id, contact_id)
VALUES (1, 1),
       (1, 2),
       (2, 2),
       (2, 3),
       (2, 4),
       (3, 5);

SELECT company.name, CONCAT(employee.first_name, ' ', employee.last_name) AS fio
FROM company, employee;



SELECT c.name, CONCAT(employee.first_name, ' ', employee.last_name) AS fio,
       ec.contact_id,
       CONCAT(c2.number, ' ', c2.type)
FROM employee
INNER JOIN company c
    ON c.id = employee.company_id
JOIN employee_contact ec
    ON employee.id = ec.employee_id
JOIN contact c2
    ON ec.contact_id = c2.id;

SELECT * FROM company
CROSS JOIN (SELECT COUNT(*) FROM employee) AS e;

SELECT c.name, e.first_name
FROM company AS c
LEFT JOIN employee e ON c.id = e.company_id;

SELECT company.name, COUNT(e.id)
FROM company
LEFT JOIN employee e ON company.id = e.company_id
GROUP BY company.id
HAVING COUNT(e.id) > 0;