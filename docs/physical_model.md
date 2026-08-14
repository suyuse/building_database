## construction_objects

| Колонка         | Тип     | Ограничения                          |
|-----------------|---------|--------------------------------------|
| object_id       | INTEGER | PK, NOT NULL                         |
| developer_id    | INTEGER | FK (developers.developer_id), NOT NULL |
| region_id       | INTEGER | FK (regions.region_id), NOT NULL     |
| planned_year    | INTEGER | NOT NULL                             |
| planned_quarter | INTEGER | NOT NULL, CHECK (planned_quarter BETWEEN 1 AND 4) |

## developers

| Колонка      | Тип     | Ограничения       |
|--------------|---------|-------------------|
| developer_id | INTEGER | PK, NOT NULL      |
| name         | TEXT    | NOT NULL, UNIQUE  |
| ogrn         | BIGINT  | NOT NULL, UNIQUE  |
| inn          | BIGINT  | NOT NULL, UNIQUE  |

## object_status_history

| Колонка    | Тип     | Ограничения                                                        |
|------------|---------|--------------------------------------------------------------------|
| object_id  | INTEGER | PK, FK (construction_objects.object_id), NOT NULL                  |
| status     | TEXT    | NOT NULL, CHECK (status IN ('запланирован', 'строится', 'введён')) |
| valid_from | DATE    | PK, NOT NULL                                                       |
| valid_to   | DATE    |                                                                    |
| is_current | BOOLEAN | NOT NULL                                                           |

## monthly_stats

| Колонка          | Тип     | Ограничения                        |
|------------------|---------|------------------------------------|
| stats_id         | INTEGER | PK, NOT NULL                       |
| month_dt         | DATE    | NOT NULL                           |
| region_id        | INTEGER | FK (regions.region_id), NOT NULL   |
| obj_cnt          | INTEGER | NOT NULL                           |
| total_area       | INTEGER | NOT NULL                           |
| living_area      | INTEGER | NOT NULL                           |
| elem_parking_cnt | INTEGER | NOT NULL                           |

## regions

| Колонка      | Тип     | Ограничения                                    |
|--------------|---------|------------------------------------------------|
| region_id    | INTEGER | PK, NOT NULL                                   |
| region_name  | TEXT    | NOT NULL, UNIQUE                               |
| region_code  | INTEGER | NOT NULL, UNIQUE                               |
| district_id  | INTEGER | FK (federal_districts.district_id), NOT NULL, CHECK (district_id BETWEEN 1 AND 8) |

## federal_districts

| Колонка       | Тип     | Ограничения                                    |
|---------------|---------|------------------------------------------------|
| district_id   | INTEGER | PK, NOT NULL, CHECK (district_id >= 0)         |
| district_name | TEXT    | NOT NULL, UNIQUE                               |
| parent_id     | INTEGER | FK (federal_districts.district_id)             |

## quarterly_completions

| Колонка           | Тип     | Ограничения                                  |
|-------------------|---------|----------------------------------------------|
| region_id         | INTEGER | PK, FK (regions.region_id), NOT NULL         |
| year              | INTEGER | PK, NOT NULL                                 |
| quarter           | INTEGER | PK, NOT NULL, CHECK (quarter BETWEEN 1 AND 4)|
| buildings_count   | INTEGER | NOT NULL                                     |
| apartments_count  | INTEGER | NOT NULL                                     |
| total_living_area | INTEGER | NOT NULL                                     |

## apartment_type_breakdown

| Колонка  | Тип     | Ограничения                                              |
|----------|---------|----------------------------------------------------------|
| stats_id | INTEGER | PK, FK (monthly_stats.stats_id), NOT NULL                |
| type     | TEXT    | PK, NOT NULL, CHECK (type IN ('1к', '2к', '3к', '4к+')) |
| count    | INTEGER | NOT NULL                                                 |
