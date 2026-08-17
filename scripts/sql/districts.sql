select * from federal_districts;


insert into federal_districts (district_id, name, parent_id) 
values (0, 'Россия', null),
(1, 'ЦФО', 0),
(2, 'СЗФО', 0),
(3, 'ЮФО', 0),
(4, 'СКФО', 0),
(5, 'ПФО', 0),
(6, 'УФО', 0),
(7, 'СФО', 0),
(8, 'ДВФО', 0);
