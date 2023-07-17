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

-- Part 2

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
    (1, 'Ivan', 'Sidorov', 1, 500),
    (2, 'Ivan', 'Ivanov', 2, 1000),
    (3, 'Arni', 'Paramonov', 2, NULL),
    (4, 'Petr', 'Petrov', 3, 2000),
    (5, 'Sveta', 'Svetikova', NULL, 1500),
    (6, 'Sidor', 'Sidorov', 1, 1650),
    (7, 'Andrey', 'Petrov', 2, 1700),
    (8, 'Ben', 'Brown', 1, 1200);

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


CREATE VIEW employee_view AS
SELECT company.name,
       e.last_name,
       e.salary,
       COUNT(e.id) OVER (),
       max(e.salary) OVER (),
       rank() OVER (partition by company.name ORDER BY e.salary nulls first )
FROM company
LEFT JOIN employee e
    ON company.id = e.company_id
ORDER BY company.name;

SELECT * FROM employee_view
WHERE name = 'Facebook';

CREATE MATERIALIZED VIEW m_employee_view AS
SELECT company.name,
       e.last_name,
       e.salary,
       COUNT(e.id) OVER (),
       max(e.salary) OVER (),
       rank() OVER (partition by company.name ORDER BY e.salary nulls first )
FROM company
         LEFT JOIN employee e
                   ON company.id = e.company_id
ORDER BY company.name;

REFRESH MATERIALIZED VIEW m_employee_view;

ALTER TABLE IF EXISTS employee
ADD COLUMN gender INT;

UPDATE employee
SET gender = 0
WHERE id < 5;

UPDATE employee
SET gender = 1
WHERE id >= 5;

ALTER TABLE IF EXISTS employee
ALTER COLUMN gender SET NOT NULL ;

ALTER TABLE IF EXISTS employee
DROP COLUMN gender;

-- Part 2. Practice
DROP DATABASE flight_repository;
CREATE DATABASE flight_repository;

CREATE TABLE airport
(
  code CHAR(3) PRIMARY KEY ,
  country  VARCHAR(256) NOT NULL ,
  city VARCHAR(256) NOT NULL
);

CREATE TABLE aircraft
(
    id SERIAL PRIMARY KEY ,
    model VARCHAR(128) NOT NULL
);

CREATE TABLE seat
(
  aircraft_id INT REFERENCES aircraft(id) ,
  seat_no VARCHAR(4) NOT NULL ,
  PRIMARY KEY (aircraft_id, seat_no)
);

CREATE TABLE flight
(
    id BIGSERIAL PRIMARY KEY ,
    flight_no VARCHAR(16) NOT NULL ,
    departure_date TIMESTAMP NOT NULL ,
    departure_airport_code CHAR(3) REFERENCES airport(code) NOT NULL ,
    arrival_date TIMESTAMP NOT NULL ,
    arrival_airport_code CHAR(3) REFERENCES airport(code) NOT NULL ,
    aircraft_id INT REFERENCES aircraft(id) NOT NULL ,
    status VARCHAR(32) NOT NULL
);

CREATE TABLE ticket
(
  id BIGSERIAL PRIMARY KEY ,
  passenger_no VARCHAR(32) NOT NULL ,
  passenger_name VARCHAR(128) NOT NULL ,
  flight_id BIGINT REFERENCES flight(id) NOT NULL ,
  seat_no VARCHAR(4) NOT NULL ,
  cost NUMERIC(8, 2)
);

CREATE UNIQUE INDEX unique_flight_id_seat_no_idx ON ticket (flight_id, seat_no);

INSERT INTO airport (code, country, city)
VALUES  ('MNK', 'Беларусь', 'Минск'),
        ('LDN', 'Англия', 'Лондон'),
        ('MSK', 'Россия', 'Москва'),
        ('BSL', 'Испания', 'Барселона');

INSERT INTO aircraft (model)
VALUES ('Боинг 777-300'),
       ('Боинг 737-300'),
       ('Аэробус А320-200'),
       ('Суперджет-100');

INSERT INTO seat (aircraft_id, seat_no)
SELECT id, s.column1
FROM aircraft
    CROSS JOIN (VALUES ('A1'), ('A2'), ('B1'), ('B2'), ('C1'), ('C2'), ('D1'), ('D2') ORDER BY 1) s;

INSERT INTO flight (flight_no, departure_date, departure_airport_code, arrival_date, arrival_airport_code, aircraft_id, status)
VALUES
('MN3002', '2020-06-14T14:30', 'MNK', '2020-06-14T18:07', 'LDN', 1, 'ARRIVED'),
('MN3002', '2020-06-16T09:15', 'LDN', '2020-06-16T13:00', 'MNK', 1, 'ARRIVED'),
('BC2801', '2020-07-28T23:25', 'MNK', '2020-07-29T02:43', 'LDN', 2, 'ARRIVED'),
('BC2801', '2020-08-01T11:00', 'LDN', '2020-08-01T14:15', 'MNK', 2, 'DEPARTED'),
('TR3103', '2020-05-03T13:10', 'MSK', '2020-05-03T18:38', 'BSL', 3, 'ARRIVED'),
('TR3103', '2020-05-10T07:15', 'BSL', '2020-05-10T12:44', 'MSK', 3, 'CANCELLED'),
('CV9927', '2020-09-09T18:00', 'MNK', '2020-09-09T19:15', 'MSK', 4, 'SCHEDULED'),
('CV9927', '2020-09-19T08:55', 'MSK', '2020-09-19T10:05', 'MNK', 4, 'SCHEDULED'),
('QS8712', '2020-12-18T03:35', 'MNK', '2020-12-18T06:46', 'LDN', 2, 'ARRIVED');

INSERT INTO ticket (passenger_no, passenger_name, flight_id, seat_no, cost)
VALUES ('112233', 'Иван Иванов', 1, 'A1', 200),
       ('23234A', 'Петр Петров', 1, 'B1', 180),
       ('SS988D', 'Светлана Светикова', 1, 'B2', 175),
       ('QYASDE', 'Андрей Андреев', 1, 'C2', 175),
       ('POQ234', 'Иван Кожемякин', 1, 'D1', 160),
       ('898123', 'Олег Рубцов', 1, 'A2', 198),
       ('555321', 'Екатерина Петренко', 2, 'A1', 250),
       ('QO23OO', 'Иван Розмаринов', 2, 'B2', 225),
       ('9883IO', 'Иван Кожемякин', 2, 'C1', 217),
       ('123UI2', 'Андрей Буйнов', 2, 'C2', 227),
       ('SS988D', 'Светлана Светикова', 2, 'D2', 277),
       ('EE2344', 'Дмитрий Трусцов', 3, 'А1', 300),
       ('AS23PP', 'Максим Комсомольцев', 3, 'А2', 285),
       ('322349', 'Эдуард Щеглов', 3, 'B1', 99),
       ('DL123S', 'Игорь Беркутов', 3, 'B2', 199),
       ('MVM111', 'Алексей Щербин', 3, 'C1', 299),
       ('ZZZ111', 'Денис Колобков', 3, 'C2', 230),
       ('234444', 'Иван Старовойтов', 3, 'D1', 180),
       ('LLLL12', 'Людмила Старовойтова', 3, 'D2', 224),
       ('RT34TR', 'Степан Дор', 4, 'A1', 129),
       ('999666', 'Анастасия Шепелева', 4, 'A2', 152),
       ('234444', 'Иван Старовойтов', 4, 'B1', 140),
       ('LLLL12', 'Людмила Старовойтова', 4, 'B2', 140),
       ('LLLL12', 'Роман Дронов', 4, 'D2', 109),
       ('112233', 'Иван Иванов', 5, 'С2', 170),
       ('NMNBV2', 'Лариса Тельникова', 5, 'С1', 185),
       ('DSA586', 'Лариса Привольная', 5, 'A1', 204),
       ('DSA583', 'Артур Мирный', 5, 'B1', 189),
       ('DSA581', 'Евгений Кудрявцев', 6, 'A1', 204),
       ('EE2344', 'Дмитрий Трусцов', 6, 'A2', 214),
       ('AS23PP', 'Максим Комсомольцев', 6, 'B2', 176),
       ('112233', 'Иван Иванов', 6, 'B1', 135),
       ('309623', 'Татьяна Крот', 6, 'С1', 155),
       ('319623', 'Юрий Дувинков', 6, 'D1', 125),
       ('322349', 'Эдуард Щеглов', 7, 'A1', 69),
       ('DIOPSL', 'Евгений Безфамильная', 7, 'A2', 58),
       ('DIOPS1', 'Константин Швец', 7, 'D1', 65),
       ('DIOPS2', 'Юлия Швец', 7, 'D2', 65),
       ('1IOPS2', 'Ник Говриленко', 7, 'C2', 73),
       ('999666', 'Анастасия Шепелева', 7, 'B1', 66),
       ('23234A', 'Петр Петров', 7, 'C1', 80),
       ('QYASDE', 'Андрей Андреев', 8, 'A1', 100),
       ('1QAZD2', 'Лариса Потемнкина', 8, 'A2', 89),
       ('5QAZD2', 'Карл Хмелев', 8, 'B2', 79),
       ('2QAZD2', 'Жанна Хмелева', 8, 'С2', 77),
       ('BMXND1', 'Светлана Хмурая', 8, 'В2', 94),
       ('BMXND2', 'Кирилл Сарычев', 8, 'D1', 81),
       ('SS988D', 'Светлана Светикова', 9, 'A2', 222),
       ('SS978D', 'Андрей Желудь', 9, 'A1', 198),
       ('SS968D', 'Дмитрий Воснецов', 9, 'B1', 243),
       ('SS958D', 'Максим Гребцов', 9, 'С1', 251),
       ('112233', 'Иван Иванов', 9, 'С2', 135),
       ('NMNBV2', 'Лариса Тельникова', 9, 'B2', 217),
       ('23234A', 'Петр Петров', 9, 'D1', 189),
       ('123951', 'Полина Зверева', 9, 'D2', 234);

-- Кто летел позавчера на рейсе Минск - Лондон на месте B1

SELECT * FROM ticket
JOIN flight f on f.id = ticket.flight_id
WHERE seat_no = 'B1' AND
      f.departure_airport_code = 'MNK' AND
      f.arrival_airport_code = 'LDN' AND
      f.departure_date::date = (now() - interval '2 days')::date;


SELECT INTERVAL '2 years 1 days';
SELECT (now() - interval '2 years 1 days');
SELECT (now() - interval '2 days')::date;
SELECT (now() - interval '2 years 1 days')::time;

ALTER TABLE flight
RENAME COLUMN departure_airport_code TO departure_airport_code;

-- Сколько мест осталось незанятых на рейсе MN3002 2020-06-14

select t2.count - t1.count AS free_seat
    FROM
(select f.aircraft_id, count(t.id)
from ticket t
join flight f on f.id = t.flight_id
where flight_no = 'MN3002'AND
      departure_date::date = '2020-06-14'
GROUP BY aircraft_id) AS t1
JOIN
(
SELECT aircraft_id, count(*)
FROM seat
JOIN aircraft a on seat.aircraft_id = a.id
GROUP BY aircraft_id
) AS t2
ON t1.aircraft_id = t2.aircraft_id;

select count(t.id)
from ticket t
         join flight f on f.id = t.flight_id
where flight_no = 'MN3002';

SELECT EXISTS(select 1 from ticket where id = 2000);

SELECT s.seat_no
FROM seat s
WHERE aircraft_id = 1
  AND NOT EXISTS(
        SELECT t.seat_no
        from ticket t
                 join flight f on f.id = t.flight_id
        where flight_no = 'MN3002'
          AND departure_date::date = '2020-06-14'
      AND s.seat_no = t.seat_no
    );

-- Какие 2 перелета были самые длительные за все время?

SELECT f.id,
       f.arrival_date,
       f.departure_date,
       f.arrival_date - f.departure_date
FROM flight f
ORDER BY (f.arrival_date - f.departure_date) DESC ;

-- Какая максимальная и минимальная продолжительность перелетов
-- между Минском и Лондоном и сколько было всего таких перелетов?

select first_value(f.arrival_date - f.departure_date) over (order by (f.arrival_date - f.departure_date) desc ) max_value,
       first_value(f.arrival_date - f.departure_date) over (order by (f.arrival_date - f.departure_date)) min_value,
       count(*) over ()
from flight f
join airport a on f.arrival_airport_code = a.code
join airport d on d.code = f.departure_airport_code
where a.city = 'Лондон'
and  d.city = 'Минск'
limit 1;

-- Какие имена встречаются чаще всего и какую долю числа всех пассажиров они составляют?

select t.passenger_name,
       count(*),
       round(100.0 * count(*)/(select COUNT(*) from ticket), 2)
from ticket t
group by t.passenger_name
order by 2 desc;

-- Вывести имена пассажиров, сколько всего каждый с таким именем купил билетов,
-- а также на сколько это количество меньше от того имени пассажира, кто купил билетов больше всего

select t1.*,
       first_value(t1.cnt) over () - t1.cnt
from (
select t.passenger_no,
       t.passenger_name,
       count(*) cnt
from ticket t
group by t.passenger_no, t.passenger_name
order by 3 desc) t1;

-- Вывести стоимость всех маршрутов по убыванию.
-- Отобразить разницу в стоимости между текущим и ближайшим в отсортированном списке маршрутами

select t1.*,
       COALESCE(lead(t1.sum_cost) over (order by t1.sum_cost), t1.sum_cost) - t1.sum_cost
from (
select t.flight_id,
       sum(t.cost) sum_cost
from ticket t
group by t.flight_id
order by 2 desc) t1;

CREATE UNIQUE INDEX unique_flight_id_seat_no_idx ON ticket (flight_id, seat_no);

explain select * from ticket;

select *
from pg_catalog.pg_class
where relname = 'ticket';

select
    avg(bit_length(passenger_no)/8),
    avg(bit_length(passenger_name)/8),
    avg(bit_length(seat_no)/8)
from ticket;

explain select flight_id, count(*)
from ticket
group by flight_id;

create table test1 (
  id BIGSERIAL PRIMARY KEY ,
  number1 INT NOT NULL ,
  number2 INT NOT NULL ,
  value VARCHAR(32) NOT NULL
);

insert into test1 (number1, number2, value)
select random() * generate_series,
       random() * generate_series,
       generate_series
from generate_series(1, 100000);

create index test1_number1_idx on test1(number1);
create index test1_number2_idx on test1(number2);

select relname,
       reltuples,
       relkind,
       relpages
from pg_catalog.pg_class
where relname LIKE 'test1%';

analyse test1;

explain
select *
from test1
where number1 < 1000
  and number2 > 80000
  and value = '12345';

create table test2
(
    id SERIAL PRIMARY KEY ,
    test1_id INT REFERENCES test1 (id) NOT NULL ,
    number1 INT NOT NULL ,
    number2 INT NOT NULL ,
    value VARCHAR(32) NOT NULL
);




create index test2_number1_idx on test2(number1);
create index test2_number2_idx on test2(number2);

explain analyse
select *
from test1
join test2 t on test1.id = t.test1_id
limit 100;

explain analyse
select *
from test1 t1
join test2 t2 on t1.id = t2.test1_id;

explain analyse
select *
from test1 t1
join (select * from test2 order by test1_id) t2 on t1.id = t2.test1_id;

create table audit
(
  id INT,
  table_name TEXT,
  date TIMESTAMP
);

create or replace function audit_function() returns trigger
language plpgsql
AS
$$
    begin
        insert into audit (id, table_name, date)
        values (new.id, tg_table_name, now());
        return null;
    end;
$$;

create trigger audit_aircraft_trigger
after update OR insert
ON aircraft
for each row
execute function audit_function();

insert into aircraft (model)
values ('New boing');