insert into roomclass (room_class_id, adult_count, child_count, comfort_level)
values (1, 1, 0, 'standard'),
       (2, 1, 1, 'standard'),
       (3, 2, 0, 'standard'),
       (4, 2, 0, 'studio'),
       (5, 3, 2, 'family'),
       (6, 2, 0, 'deluxe');

insert into rooms (room_number, floor_number, room_class_id)
values (11, 1, 1),
       (12, 1, 2),
       (21, 2, 1),
       (22, 2, 2),
       (23, 2, 2),
       (24, 2, 3),
       (25, 2, 3),
       (31, 3, 4),
       (32, 3, 5),
       (41, 4, 6),
       (42, 4, 6);

insert into employees (employee_id, employee_name)
values (1, 'Slava Marlow'),
       (2, 'Ударница из кис-кис'),
       (3, 'Аня Тейлор-Джой');

insert into employeeserverooms (room_number, employee_id)
values (11, 3),
       (12, 3),
       (21, 1),
       (22, 1),
       (23, 1),
       (24, 1),
       (25, 1),
       (31, 2),
       (32, 2),
       (41, 2),
       (42, 2);

insert into roomcost (room_class_id, cost_from, cost_to, room_cost)
values (1, date '15-12-2020', date '22-01-2021', 1500),
       (2, date '15-12-2020', date '22-01-2021', 2000),
       (3, date '15-12-2020', date '22-01-2021', 2500),
       (4, date '15-12-2020', date '22-01-2021', 3500),
       (5, date '15-12-2020', date '22-01-2021', 5000),
       (6, date '15-12-2020', date '22-01-2021', 4000),
       (1, date '23-01-2021', date '15-04-2021', 1400),
       (2, date '23-01-2021', date '15-04-2021', 1900),
       (3, date '23-01-2021', date '15-04-2021', 2400),
       (4, date '23-01-2021', date '15-04-2021', 3400),
       (5, date '23-01-2021', date '15-04-2021', 4900),
       (6, date '23-01-2021', date '15-04-2021', 3900);

insert into roominventory (item_id, item_name, item_cost)
values (1, 'Шкаф в Нарнию', 6000),
       (2, 'Кровать одноместная', 3000),
       (3, 'Кровать двуместная', 4500),
       (4, 'Тумбочка', 1000),
       (5, 'Холодильник', 3200),
       (6, 'Телевизор', 4000),
       (7, 'Статуя Ежика из смешариков', 7000);

insert into inventoryquantity (room_class_id, item_id, item_quantity)
values (1, 2, 1),
       (2, 2, 2),
       (3, 2, 2),
       (4, 3, 1),
       (5, 3, 1),
       (5, 2, 3),
       (6, 3, 1),
       (6, 7, 1),
       (5, 6, 1),
       (6, 6, 1),
       (5, 5, 1),
       (6, 5, 1),
       (6, 1, 1);

insert into clients (client_id, passport_series, passport_number, client_name)
values (1, '1960', '123335', 'Поттер'),
       (2, '1980', '123335', 'Поттер'),
       (3, '1981', '123334', 'Джинни Уизли'),
       (4, '1979', '123532', 'Гермиона Грейнджер'),
       (5, '1926', '123334', 'Тот-Кого-Нельзя-Называть');

insert into roomusing (room_using_id, room_number, client_id, used_from, used_to, room_status)
values (1, 12, 1, date '20-12-2020', date '04-01-2021', 'rented'),
       (2, 12, 3, date '25-01-2021', date '30-01-2021', 'booked'),
       (3, 42, 5, date '29-12-2020', date '26-01-2021', 'rented'),
       (4, 23, 4, date '03-01-2021', date '25-01-2021', 'rented'),
       (5, 22, 2, date '14-01-2021', date '30-01-2021', 'rented');

insert into contracts (contract_id, date_of_signing, room_using_id)
values (1, date '19-12-2020', 1),
       (2, date '29-12-2020', 3),
       (3, date '20-11-2020', 4),
       (4, date '20-11-2020', 5);

insert into services (service_id, service_name, service_cost)
values (1, 'Дементор', 300),
       (2, 'Бузинная палочка', 1700),
       (3, 'Крестраж', 700),
       (4, 'Карта Мародеров', 650),
       (5, 'Разговор со змеей по теоефону', 150);

insert into quantity (contract_id, service_id, quantity)
values (1, 1, 14),
       (2, 2, 1),
       (2, 3, 7),
       (1, 4, 1),
       (1, 5, 1),
       (2, 5, 2);
