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

create type comfort_level_type as enum ('standard', 'studio', 'family', 'deluxe');
create type room_status_type as enum ('booked', 'rented');

create table if not exists RoomClass
(
    room_class_id int                not null primary key,
    adult_count   int                not null,
    child_count   int                not null,
    comfort_level comfort_level_type not null
);

create table if not exists Rooms
(
    room_number   int not null primary key,
    floor_number  int not null,
    room_class_id int not null,
    foreign key (room_class_id) references RoomClass (room_class_id)
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
    foreign key (room_number) references Rooms (room_number),
    foreign key (employee_id) references Employees (employee_id)
);

create table if not exists RoomCost
(
    room_class_id int       not null,
    cost_from     timestamp not null,
    cost_to       timestamp not null,
    room_cost     int       not null,
    primary key (room_class_id, cost_from, cost_to),
    foreign key (room_class_id) references RoomClass (room_class_id)
);

create table if not exists RoomInventory
(
    item_id    int         not null primary key,
    item_name  varchar(30) not null,
    item_cost  int         not null
);

create table if not exists InventoryQuantity
(
    room_class_id int not null,
    item_id       int not null,
    item_quantity int not null,
    primary key (room_class_id, item_id),
    foreign key (room_class_id) references RoomClass (room_class_id),
    foreign key (item_id) references RoomInventory (item_id)
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
    used_from     timestamp        not null,
    used_to       timestamp        not null,
    room_status   room_status_type not null,
    foreign key (room_number) references Rooms (room_number),
    foreign key (client_id) references Clients (client_id)
);

create table if not exists Contracts
(
    contract_id     int       not null primary key,
    date_of_signing timestamp not null,
    room_using_id   int       not null,
    foreign key (room_using_id) references RoomUsing (room_using_id)
);

create table if not exists Services
(
    service_id   int         not null primary key,
    service_name varchar(30) not null,
    service_cost int         not null
);

create table if not exists Quantity
(
    contract_id int not null,
    service_id  int not null,
    quantity    int not null,
    primary key (contract_id, service_id),
    foreign key (contract_id) references Contracts (contract_id),
    foreign key (service_id) references Services (service_id)
);

