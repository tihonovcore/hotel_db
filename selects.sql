-- Сотрудник обслуживает комнату
select employee_name, room_number
from employees
         natural join
     employeeserverooms;

-- Этажи, где работает сотрудник
select distinct employee_name, floor_number
from employees
         natural join
     employeeserverooms
         natural join
     rooms;

-- Кто обслуживает номера deluxe
with deluxe (room_class_id) as (select room_class_id from roomclass where comfort_level = 'deluxe')
select distinct employee_name
from employees
         natural join
     employeeserverooms
         natural join
     rooms
         natural join
     Deluxe;

-- Текущая стоимость каждого номера
select room_number, room_cost
from rooms
         natural join
     roomcost
where now() between cost_from and cost_to;

-- Занятые номера
create or replace function rented_rooms()
    returns table
            (
                room_number int,
                client_id   int
            )
    language plpgsql
as
$$
begin
    return query select roomusing.room_number, roomusing.client_id
                 from roomusing
                 where now() between used_from and used_to
                   and room_status = 'rented';
end;
$$;

select * from rented_rooms();

-- Полная информация о комнате
select floor_number, room_number, adult_count, child_count, comfort_level
from rooms
         natural join
     roomclass;

-- Сотрудники обслуживающие занятные номера
select employee_name, room_number
from employees
         natural join
     employeeserverooms
         natural join
     (select * from rented_rooms()) as rented;

-- Клиенты, занимающие номера
select client_name, room_number
from clients
         natural join
     (select * from rented_rooms()) as rented;

-- Текущая стоимость свободных номеров
with free_rooms (room_number, room_class_id) as (
    select room_number, room_class_id
    from rooms
    where not exists(
            select *
            from roomusing
            where rooms.room_number = roomusing.room_number
              and now() between used_from and used_to
        )
)
select room_number, room_cost, comfort_level
from free_rooms
         natural join
     roomclass
         natural join
     roomcost
where now() between cost_from and cost_to
order by room_number;


-- Свободные номера в определенные даты
create or replace function free_rooms_between(free_from date, free_to date)
    returns table
            (
                room_number int
            )
    language plpgsql
as
$$
begin
    return query select rooms.room_number
                 from rooms
                 where not exists(
                         select *
                         from roomusing
                         where rooms.room_number = roomusing.room_number
                           and free_from not between used_from and used_to
                           and free_to not between used_from and used_to
                     );
end;
$$;

select * from free_rooms_between(date '13-01-21', date '13-02-21');

-- Полный инвентарь гостиницы
select item_name, item_quantity, item_cost
from roominventory
         natural join
     (
         select item_id, sum(item_quantity) as item_quantity
         from inventoryquantity
         group by item_id
     ) as count_inventory;

-- Описание инвентаря комнаты
create or replace function room_inventory(room int)
    returns table
            (
                item_name     varchar(30),
                item_quantity int,
                item_cost     int
            )
    language plpgsql
as
$$
begin
    return query select roominventory.item_name, inventoryquantity.item_quantity, roominventory.item_cost
                 from inventoryquantity
                          natural join
                      roominventory
                          natural join
                      rooms
                 where room_number = room;
end;
$$;

select * from room_inventory(41);

-- Стоимость инвентаря каждой комнаты
select room_number, sum(item_cost) as inventory_cost
from inventoryquantity
         natural join
     roominventory
         natural join
     rooms
group by room_number
order by room_number;

-- Все услуги оказанные по контракту
create or replace function services_by_contract(contract int)
    returns table
            (
                service_name varchar(30),
                quantity     int,
                service_cost int
            )
    language plpgsql
as
$$
begin
    return query select services.service_name, quantity.quantity, services.service_cost
                 from quantity
                          natural join
                      services
                 where contract_id = contract;
end;
$$;

select * from services_by_contract(2);

-- Стоимость услуг по контракту
create or replace function services_cost_by_contract(contract int) returns int
    language plpgsql
as
$$
begin
    return (
        select sum(service_cost * quantity.quantity)
        from quantity natural join services
        where contract_id = contract
        group by contract_id
    );
end;
$$;

select services_cost_by_contract(1);

-- Число контрактов клиента
select client_id, count(client_id)
from contracts
         natural join
     roomusing
group by client_id;

-- Число незаконченных контрактов по клиенту
select client_id, count(contract_id)
from contracts
         natural join
     roomusing
where now() <= used_to
group by client_id;

-- Стоимость комнаты по контракту
create or replace function count_room_cost(room int, rent_from date, rent_to date) returns int
    language plpgsql
as
$$
declare
    current_day date = rent_from;
    room_class  int  = (select room_class_id
                        from rooms
                        where room_number = room);
    cost_accum  int  = 0;
begin
    while current_day <= rent_to
        loop
            select cost_accum + (select room_cost
                                 from roomcost
                                 where room_class_id = room_class
                                   and current_day between cost_from and cost_to)
            into cost_accum;
            select current_day + interval '1 day' into current_day;
        end loop;

    return cost_accum;
end;
$$;

-- Стоимость контракта
create or replace function contract_cost(contract int) returns int
    language plpgsql
as
$$
declare
    ru_id     int;
    room      int;
    rent_from date;
    rent_to   date;
begin
    select room_using_id
    from contracts
    where contract_id = contract
    into ru_id;

    select room_number, used_from, used_to
    from roomusing
    where room_using_id = ru_id
    into room, rent_from, rent_to;

    return coalesce(services_cost_by_contract(contract), 0) + count_room_cost(room, rent_from, rent_to);
end;
$$;

select contract_cost(2);
