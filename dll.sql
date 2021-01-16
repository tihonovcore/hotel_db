-- begin development time part
drop table if exists Quantity;
drop table if exists Services;
drop table if exists Contracts;
drop table if exists RoomUsing;
drop table if exists Clients;
drop table if exists EmployeeServeRooms;
drop table if exists Employees;
drop table if exists Rooms;
drop table if exists InventoryQuantity;
drop table if exists RoomInventory;
drop table if exists RoomCost;
drop table if exists RoomClass;

drop type if exists comfort_level_type;
drop type if exists room_status_type;
-- end development time part

create type comfort_level_type as enum ('standard', 'studio', 'family', 'deluxe');
create type room_status_type as enum ('booked', 'rented');

create table if not exists RoomClass
(
    room_class_id int                not null primary key,
    adult_count   int                not null,
    child_count   int                not null,
    comfort_level comfort_level_type not null,

    check ( adult_count >= 0 and child_count >= 0 )
);

create table if not exists Rooms
(
    room_number   int not null primary key,
    floor_number  int not null,
    room_class_id int not null,

    foreign key (room_class_id) references RoomClass (room_class_id) on update cascade on delete restrict
);

create table if not exists Employees
(
    employee_id   int         not null primary key,
    employee_name varchar(50) not null
);

create table if not exists EmployeeServeRooms
(
    room_number int not null primary key,
    employee_id int not null,

    foreign key (room_number) references Rooms (room_number) on update cascade on delete restrict,
    foreign key (employee_id) references Employees (employee_id) on update cascade on delete restrict
);

create table if not exists RoomCost
(
    room_class_id int  not null,
    cost_from     date not null,
    cost_to       date not null,
    room_cost     int  not null,

    primary key (room_class_id, cost_from),
    foreign key (room_class_id) references RoomClass (room_class_id) on update cascade on delete restrict,

    check ( cost_from < cost_to ),
    check ( room_cost > 0 )
);

create table if not exists RoomInventory
(
    item_id   int         not null primary key,
    item_name varchar(30) not null,
    item_cost int         not null,

    check ( item_cost > 0 )
);

create table if not exists InventoryQuantity
(
    room_class_id int not null,
    item_id       int not null,
    item_quantity int not null,

    primary key (room_class_id, item_id),
    foreign key (room_class_id) references RoomClass (room_class_id) on update cascade on delete restrict,
    foreign key (item_id) references RoomInventory (item_id) on update cascade on delete restrict,

    check ( item_quantity > 0 )
);

create table if not exists Clients
(
    client_id       int         not null primary key,
    passport_series varchar(4)  not null,
    passport_number varchar(6)  not null,
    client_name     varchar(50) not null,

    unique (passport_series, passport_number)
);

create table if not exists RoomUsing
(
    room_using_id int              not null primary key,
    room_number   int              not null,
    client_id     int              not null,
    used_from     date             not null,
    used_to       date             not null,
    room_status   room_status_type not null,

    foreign key (room_number) references Rooms (room_number) on update cascade on delete restrict,
    foreign key (client_id) references Clients (client_id) on update cascade on delete restrict,

    check ( used_from < used_to )
);

create table if not exists Contracts
(
    contract_id     int  not null primary key,
    date_of_signing date not null,
    room_using_id   int  not null,

    foreign key (room_using_id) references RoomUsing (room_using_id) on update cascade on delete restrict
);

create table if not exists Services
(
    service_id   int         not null primary key,
    service_name varchar(30) not null,
    service_cost int         not null,

    check ( service_cost > 0 )
);

create table if not exists Quantity
(
    contract_id int not null,
    service_id  int not null,
    quantity    int not null,

    primary key (contract_id, service_id),
    foreign key (contract_id) references Contracts (contract_id) on update cascade on delete restrict,
    foreign key (service_id) references Services (service_id) on update cascade on delete restrict,

    check ( quantity > 0 )
);

-- Согласно документации индексы на основные ключи добавляются автоматически

-- Индексы на внешние ключи

-- Сотрудник обслуживает комнату; Этажи, где работает сотрудник;
-- Кто обслуживает номера deluxe; Сотрудники обслуживающие занятные номера;
create index on employeeserverooms using btree (employee_id, room_number);

-- Прикрепить сотрудника к комнате;
create index on employeeserverooms using btree (room_number, employee_id);

-- Текущая стоимость каждого номера; Текущая стоимость свободных номеров;
create index on roomcost using hash (room_class_id);

-- Число контрактов клиента; Число незаконченных контрактов по клиенту
create index on contracts using hash (room_using_id);

-- Все услуги оказанные по контракту; Стоимость услуг по контракту;
-- Оказать услугу по контракту;
create index on quantity using btree (service_id, contract_id);
create index on quantity using btree (contract_id, service_id);

-- Забронировать номер
create index on roomusing using btree (room_number, client_id);
create index on roomusing using btree (client_id, room_number);

-- Стоимость инвентаря каждой комнаты
create index on inventoryquantity using btree (room_class_id, item_id);
create index on inventoryquantity using btree (item_id, room_class_id);

-- Эти индексы на внешние ключи почти не используются
create index on rooms using hash (room_class_id);
