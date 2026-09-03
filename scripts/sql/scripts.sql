-- объекты, строительство которых планируется завершить в 2026-2030 годах в Москве

select * 
from construction_objects 
where ((planned_year between 2026 and 2030) and (region_id = 1))

-- сводка по застройщикам, в каком состоянии сколько у них объектов

select 
	developer_id, build_status, COUNT(build_status) 
from (with planned as (
	select object_id, make_date(planned_year, (planned_quarter - 1) * 3 + 1, 1) as planned_date, 
	developer_id, region_id
	from construction_objects 
),
actual as (
	select object_id, status, valid_from as real_date
	from object_status_history
	where status = 'введён'
)
select p.object_id, p.planned_date, p.developer_id, p.region_id, a.real_date, 
	case when p.planned_date >= a.real_date then 'Введён вовремя'
	when p.planned_date < a.real_date then 'Введён с задержкой'
	when p.planned_date < current_timestamp then 'Будет введён с задержкой' 
	else 'Не введён'
	end as build_status
from planned p
left join actual a on p.object_id = a.object_id) 
group by developer_id, build_status
order by developer_id, build_status;

-- топ-10 регионов по введенной жилой площади

with area as (select region_id, ROUND(AVG(living_area)) as round_area
	from monthly_stats 
	group by region_id
	)
select  r.name, a.round_area
from area a 
left join regions r on r.region_id = a.region_id
order by round_area desc
limit 10;

-- отношение введенной площади к количеству парковочных мест по регионам (т.е. при каком количестве введенных квадратных метров появлялось 1 парковочное место)

with parking as ( 
	select region_id, 
	SUM(parking_cnt) as sum_parking, 
	SUM(living_area) as sum_area
	from monthly_stats 
	where month_date >= '2024-01-01' and month_date  <= '2025-12-01'
	group by region_id
)
select r.name, (p.sum_area / nullif(p.sum_parking, 0)) as division
from parking p 
left join regions r on p.region_id = r.region_id
where ((p.sum_area / nullif(p.sum_parking, 0)) < 1000)
order by division;

-- отношение количества квартир к количеству парковочных мест (чем меньше - тем больше парковок на одну квартиру)

with aparts as ( 
	select region_id, 
	SUM(apartments_count) as sum_aparts
	from quarterly_completions 
	where year >= 2024 and year <= 2025
	group by region_id
), parking as (
	select region_id,
	sum(parking_cnt) as sum_parking
	from monthly_stats 
	where month_date >= '2024-01-01' and month_date  <= '2025-12-01'
	group by region_id
)
select r.name, round(a.sum_aparts::numeric / nullif(p.sum_parking, 0), 3) as division
from aparts a 
left join regions r 
	on a.region_id = r.region_id
left join parking p
	on p.region_id = a.region_id
where p.sum_parking > 0
order by division;

-- регионы, в которых за 2024 введено больше 1000 парковочных мест

select region_id, sum(parking_cnt) as sum_parking
from monthly_stats
where extract(year from month_date) = 2024
group by region_id having sum(parking_cnt) > 1000;

-- статистика количества построенных домов в Москве по годам (в случае, если за год их больше 100)

select year, sum(buildings_count) as buildings_cnt
from quarterly_completions 
where region_id = 1
group by year 
having sum(buildings_count ) > 100
order by sum(buildings_count) desc;

-- топ-10 регионов по вводу жилой площади по каждому году

with yearly as (select region_id, year, sum(total_living_area) as total_area
	from quarterly_completions 
	group by region_id, year), 
	ranked as ( select region_id, year, total_area, 
		dense_rank() over (partition by year order by total_area desc) as rank
	from yearly)
select * 
from ranked 
where rank <= 10;

-- иерархия регионов

with first_level as (with recursive districts as (
	select district_id, name, parent_id, 0 as level
	from federal_districts 
	where parent_id is null
	
	union
	
	select fd.district_id, fd.name, fd.parent_id, d.level + 1
	from federal_districts fd
	join districts d on d.district_id = fd.parent_id) 
select * 
from districts)
select fl.district_id, fl.name, fl.parent_id, fl.level, r.name
from first_level fl
left join regions r on 
fl.district_id = r.district_id;

-- прирост построенных объектов за месяц в разбивке по регионам

select month_date, region_id, obj_cnt, 
lag(obj_cnt) over (partition by region_id order by month_date), 
obj_cnt - lag(obj_cnt) over (partition by region_id order by month_date) as diff
from monthly_stats;

-- разница введенной площади за текущий и следующий квартал в разбивке по регионам

select year, quarter, region_id, total_living_area, 
lead(total_living_area) over (partition by region_id order by year, quarter), 
total_living_area  - lead(total_living_area) over (partition by region_id order by year, quarter) as diff
from quarterly_completions;

-- застройщики, у которых объектов по количеству больше, чем в среднем

 select developer_id, count(*) as cnt
 from construction_objects 
 group by developer_id
 having count(*) > (select avg(cnt) from (select count(*) as cnt from construction_objects group by developer_id)); 
 
 -- доля однокомнатных квартир по месяцам и регионам
 
 select r.name, p.month_date, p.type, p.procent 
 from (select ms.stats_id, ms.month_date, ms.region_id, atb.type, round(atb.apt_count::numeric / (select sum(apt_count) from apartment_type_breakdown where stats_id = ms.stats_id), 3) as procent
    from monthly_stats ms
    join apartment_type_breakdown atb on ms.stats_id = atb.stats_id 
    where atb.type = '1к') p
 join regions r on r.region_id = p.region_id
 order by procent desc;

 -- количество строящихся объектов в 2026 году по округам
 
 select fd.name, t.cnt 
 from (select r.district_id, sum(b.cnt) as cnt
 	from (select region_id, sum(obj_cnt) as cnt
 	from monthly_stats
 	where extract(year from month_date) = 2026
 	group by region_id) b
 join regions r on r.region_id = b.region_id
 group by r.district_id) t
 join federal_districts fd on t.district_id = fd.district_id
 order by cnt desc;
 
 -- все застройщики, ИНН которых начинается с 1
 
 select * 
 from  developers
 where inn::text like '1%';
 