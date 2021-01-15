-- Все комнаты обслуживаемые сотрудником
select employee_name, room_number
from employees
         natural join employeeserverooms;

-- Этажи, где работает сотрудник
select distinct employee_name, floor_number
from employees
         natural join employeeserverooms
         natural join rooms;

-- Кто обслуживает номера deluxe
select distinct employee_name
from employees
         natural join
     employeeserverooms
         natural join
     (select room_number
      from rooms
               natural join roomclass
      where comfort_level = 'deluxe') as deluxe_rooms;

-- Полная информация о комнате
select floor_number, room_number, adult_count, child_count, comfort_level
from rooms
         natural join roomclass;

-- Текущая стоимость каждого номера
select *
from rooms
         natural join roomclass
         natural join roomcost
where now() between cost_from and cost_to;

-- Занятые номера
select room_number
from roomusing
where (now() between used_from and used_to)
  and room_status = 'rented';

-- Сотрудники обслуживающие занятные номера
select employee_name, room_number
from employees
         natural join
     employeeserverooms
         natural join
     (select room_number
      from roomusing
      where (now() between used_from and used_to)
        and room_status = 'rented') as rented_room;

-- Клиенты занимающие номера
select *
from clients
         natural join
     (select client_id
      from roomusing
      where (now() between used_from and used_to)
        and room_status = 'rented') as rented_owner;

-- Текущая стоимость свободных номеров
select *
from rooms
         natural join roomclass
         natural join roomcost
where now() between cost_from and cost_to;


-- Свободные номера в определенные даты todo

-- Полный интвентарь гостиницы
select item_name, item_quantity, item_cost
from inventoryquantity
         natural join roominventory;

-- Описание инвентаря комнаты
select item_name, item_quantity, item_cost
from inventoryquantity
         natural join roominventory
         natural join rooms
where room_number = 41;

-- Стоимость интвентаря комнаты
select room_number, sum(item_cost) as inventory_cost
from inventoryquantity
         natural join roominventory
         natural join rooms
group by room_number
order by room_number;

-- Все услуги оказанные по контракту
select service_name, quantity.quantity
from quantity
         natural join services
where contract_id = 2;

-- Все услуги оказанные по контракту с указанием стоимости
select service_name, quantity.quantity, service_cost
from quantity
         natural join services
where contract_id = 2;

-- Стоимость услуг по контракту
select contract_id, sum(service_cost * quantity.quantity)
from quantity
         natural join services
group by contract_id;

-- Число контрактов клиента
select client_id, count(client_id)
from contracts
         natural join roomusing
group by client_id;

-- Число незаконченных контрактов по клиенту
select client_id, count(contract_id)
from contracts
         natural join roomusing
where now() <= used_to
group by client_id;


-- Суммарный доход от клиента за все время todo

-- Стоимость комнаты по контракту
create or replace function count_room_cost(room_number int, used_from timestamp, used_to timestamp) returns int
as
$$
begin
    return 4;
end;
$$ language plpgsql;


-- select count_room_cost(
--                cast(3 as int),
--                cast(to_timestamp('17-12-20', 'DD-MM-YY') as timestamp),
--                cast(to_timestamp('31-12-20', 'DD-MM-YY') as timestamp)
--            )


-- todo: timestamp is ok?