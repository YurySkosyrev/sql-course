## Введение
Общая структура БД:
![alt text](img/dbms.jpg "dbms")

SQL (Standart Query Language) - язык для взаимодействия с реляционными БД.

Базы данных:

- предназначены для **долговременного** хранения информации
- Позволяют быстро находить нужные данные, так как обладают встроенными системами поиска
- **Реляционные БД** используют табличную структуру для хранения данных, а для работы с ними используется язык SQL

Реляционные - так как между таблицами есть взаимосвязь (relation)

СУБД (система управления базой данных) - приложение которое может выполнять CRUD операции с файлами (каталогами БД) на жестком диске. Организует работу с БД и добавляет дополнительную функциональность.

Каждая СУБД обладает своими отличиями, например, встроенными типами данных.

Так же каждая СУБД снабжена своим процедурным языком программирования и позволяет записывать хранимые процедуры. В современной разработке это не так распространено, потому, что вся логика в основном находится в backend-приложении.

## Подключение к БД

При обращении к сайту в браузере по имени, мы на самом деле обращаемся к ip-адресу. Чтобы не запоминать все адреса была введена DNS (domain name system), по сути это ассоциативный массив из имени сайта и его ip.

На одной машине может быть развернуто несколько приложений, и каждое из них резервирует свой порт.

По умолчанию 80 для http, 443 для https, поэтому при переходе на сайты достаточно ввести только название сайта.

## DDL & DML

![alt text](img/ddl_dml.jpg "dbms")

```sql
CREATE DATABASE company_repository; - создать БД
DROP DATABASE company_repository; - удалить БД
```

Всегда при создании новой БД создаются три sсhema: public, information_schema, pg_catalog.

Schema по умолчанию - public

information_schema, pg_catalog - конфигурационные схемы (аналог JDK, использование классов Math, Array) 
information_schema - информация о таблицах в БД.
pg_catalog - агрегирующие функции, кастомные типы данных.

schema по аналогии с Java - это пакет. Служит для логического разделения таблиц.

При создании таблицы схема указвается через .

```sql
CREATE TABLE company_storage.company (
    id INT PRIMARY KEY ,
    name VARCHAR UNIQUE NOT NULL ,
    date DATE NOT NULL CHECK ( date > '1995-01-01' AND date < '2020-01-01')
);
```

Constraints - ограничения в таблице поддерживающие целостность данных:

- NOT NULL
- UNIQUE - значение уникальное
- CHECK 
- PRIMARY KEY == UNIQUE NOT NULL может быть только один
- FOREIGN KEY

Constraints можно указывать не только после названия колонки, но и в конце, перечисляя в скобках названия колонок, к которым он относится

```sql
    PRIMARY KEY(id, name)
```

