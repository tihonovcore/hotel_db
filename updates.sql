-- Добавить сотрудника
create or replace function add_employee(name varchar(50)) returns void
    language plpgsql
as
$$
declare
    new_id int;
begin
    select max(employee_id) + 1 from employees into new_id;
    insert into employees values (new_id, name);
end;
$$;

-- Удалить сотрудника
create or replace function delete_employee(id int) returns void
    language plpgsql
as
$$
begin
    delete from employees where employee_id = id;
end;
$$;

-- Прикрепить сотрудника к комнате
create or replace function change_room_person_in_charge(room int, employee int) returns bool
    language plpgsql
as
$$
begin
    if not exists(select * from employees where employee_id = employee)
    then
        return false;
    end if;

    if exists(select * from employeeserverooms where room_number = room)
    then
        update employeeserverooms set employee_id = employee where room_number = room;
    else
        insert into employeeserverooms values (room_number, employee_id);
    end if;

    return true;
end;
$$;

select change_room_person_in_charge(12, 3);

-- Добавить клиента
create or replace function add_client(name varchar(50), pass_se varchar(4), pass_no varchar(6)) returns bool
    language plpgsql
as
$$
declare
    new_id int;
begin
    if exists(select * from clients where passport_series = pass_se and passport_number = pass_no)
    then
        return false;
    end if;

    select max(client_id) + 1 from clients into new_id;
    insert into clients values (new_id, pass_se, pass_no, name);

    return true;
end;
$$;

select add_client('Драко Малфой', '1980', '548192');

-- Заключить контракт
create or replace function sign_contract(ru_id int) returns bool
    language plpgsql
as
$$
declare
    new_cid int;
begin
    if not exists(select * from roomusing where room_using_id = ru_id and room_status = 'booked')
    then
        return false;
    end if;

    update roomusing set room_status = 'rented' where room_using_id = ru_id;

    select max(contract_id) + 1 from contracts into new_cid;
    insert into contracts (contract_id, date_of_signing, room_using_id) values (new_cid, now(), ru_id);

    return true;
end;
$$;

-- Забронировать номер
create or replace function book_room(room int, client int, book_from date, book_to date) returns bool
    language plpgsql
as
$$
declare
    new_ru_id int;
begin
    if book_from > book_to
        or
       not exists(select * from clients where client_id = client)
        or
       not exists(select * from rooms where room_number = room)
        or
       exists(select *
              from roomusing
              where book_from between used_from and used_to
                 or book_to between used_from and used_to)
    then
        return false;
    end if;

    select max(room_using_id) + 1 from roomusing into new_ru_id;
    insert into roomusing (room_using_id, room_number, client_id, used_from, used_to, room_status)
    values (new_ru_id, room, client, book_from, book_to, 'booked');

    return true;
end;
$$;

-- Изменить даты брони
create or replace function change_booking_dates(ru_id int, new_book_from date, new_book_to date) returns bool
    language plpgsql
as
$$
begin
    if new_book_from > new_book_to
        or
       not exists(select * from roomusing where room_using_id = ru_id)
        or
       exists(
               select *
               from roomusing
               where room_using_id != ru_id
                 and (new_book_from between used_from and used_to or new_book_to between used_from and used_to)
       )
    then
        return false;
    end if;

    update roomusing set used_from = new_book_from, used_to = new_book_to where room_using_id = ru_id;

    return true;
end;
$$;

-- Отказ от брони
create or replace function drop_book(ru_id int) returns bool
    language plpgsql
as
$$
begin
    if exists(select * from roomusing where room_using_id = ru_id and room_status = 'booked')
    then
        delete from roomusing where room_using_id = ru_id;
        return true;
    end if;

    return false;
end;
$$;

-- Оказать услугу по контракту
create or replace function provide_service_for_contract(sid int, cid int, service_quantity int) returns bool
    language plpgsql
as
$$
declare
    old_quantity int default 0;
begin
    if service_quantity < 1
        or
       not exists(select * from services where service_id = sid)
        or
       not exists(select * from contracts where contract_id = cid)
    then
        return false;
    end if;

    select quantity.quantity from quantity
    where service_id = sid and contract_id = cid
    into old_quantity;

    if old_quantity != 0
    then
        update quantity
        set quantity = old_quantity + service_quantity
        where service_id = sid and contract_id = cid;
    else
        insert into quantity (contract_id, service_id, quantity)
        values (cid, sid, service_quantity);
    end if;

    return true;
end;
$$;

-- Добавить сервис
create or replace function add_service(name varchar(30), cost int) returns void
    language plpgsql
as
$$
declare
    new_id int;
begin
    select max(service_id) + 1 from services into new_id;
    insert into services (service_id, service_name, service_cost) values (new_id, name, cost);
end;
$$;

-- Изменить стоимость сервиса
create or replace function change_service_cost(id int, new_cost int) returns bool
    language plpgsql
as
$$
begin
    if not exists(select * from services where service_id = id)
    then
        return false;
    end if;

    update services set service_cost = new_cost where service_id = id;
end;
$$;
