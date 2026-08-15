create table developers (
	developer_id integer primary key,
	name text not null unique,
	ogrn bigint not null unique,
	inn bigint not null unique
);


create table federal_districts (
	district_id integer primary key,
	name text unique not null,
	parent_id integer
);

create table regions (
	region_id integer primary key,
	name text unique not null,
	oktmo integer unique not null,
	district_id integer references federal_districts(district_id) not null 
);

create table monthly_stats (
	stats_id integer primary key,
	month_date date not null,
	region_id integer references regions(region_id) not null,
	obj_cnt integer not null,
	total_area integer not null,
	living_area integer not null,
	parking_cnt integer not null
);

create table apartment_type_breakdown (
	stats_id integer references monthly_stats(stats_id) not null,
	type text not null, check (type in ('1к', '2к', '3к', '4к+')),
	apt_count integer not null,
	primary key (stats_id, type)
);

create table quarterly_completions (
	region_id integer references regions(region_id) not null,
	year integer not null,
	quarter integer not null, check (quarter in (1, 2, 3, 4)),
	buildings_count integer not null,
	apartments_count integer not null,
	total_living_area integer not null,
	primary key (region_id, year, quarter)
);

create table construction_objects (
	object_id integer primary key not null,
	developer_id integer references developers(developer_id) not null,
	region_id integer references regions(region_id) not null,
	planned_year integer not null,
	planned_quarter integer not null, check (planned_quarter in (1, 2, 3, 4))
);


create table object_status_history (
	object_id integer references construction_objects(object_id) not null,
	status text not null, check (status in ('запланирован', 'строится', 'введён')),
	valid_from date not null,
	valid_to date,
	is_current boolean not null,
	primary key (object_id, valid_from)
);


