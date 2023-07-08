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

DROP TABLE company;
DROP TABLE employee;

CREATE TABLE company (
    id SERIAL PRIMARY KEY,
    name VARCHAR(128) NOT NULL
);

CREATE TABLE employee (
    id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(128),
    last_name VARCHAR(128),
    company_id INT REFERENCES company(id)
);



SELECT c.name, employee.first_name || employee.last_name as fio
FROM employee
INNER JOIN company c on c.id = employee.company_id;

