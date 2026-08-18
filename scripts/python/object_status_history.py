import pandas as pd
import numpy as np

constructions_objects = pd.read_csv('building_database/tables/construction_objects.csv')
object_status_history = pd.DataFrame(columns=['object_id', 'status', 'valid_from', 'valid_to', 'is_current'])
for i in range(len(constructions_objects)):
    id, dev_id, reg_id, year, quarter = constructions_objects.iloc[i]
    abs_month = year * 12 + (quarter - 1) * 3 + 1
    abs_month_complete = abs_month + np.random.randint(-6, 18)
    abs_month_build = abs_month_complete - np.random.randint(6, 48)
    abs_month_start = abs_month_build - np.random.randint(3, 18)

    actual_year_complete = abs_month_complete // 12
    actual_month_complete = abs_month_complete % 12
    if actual_month_complete == 0:
        actual_month_complete = 12
        actual_year_complete -= 1

    actual_year_build = abs_month_build // 12
    actual_month_build = abs_month_build % 12
    if actual_month_build == 0:
            actual_month_build = 12
            actual_year_build -= 1

    actual_year_start = abs_month_start // 12
    actual_month_start = abs_month_start % 12
    if actual_month_start == 0:
            actual_month_start = 12
            actual_year_start -= 1

    today = pd.Timestamp.today()
    rows = []
    start_date = pd.Timestamp(year=actual_year_start, month=actual_month_start, day=1)
    build_date = pd.Timestamp(year=actual_year_build, month=actual_month_build, day=1)
    complete_date = pd.Timestamp(year=actual_year_complete, month=actual_month_complete, day=1)
    if (today < build_date):
        rows.append({'object_id': id, 'status': 'запланирован', 'valid_from': start_date, 'valid_to': None, 'is_current': True})
    elif (today < complete_date):
        rows.append({'object_id': id, 'status': 'запланирован', 'valid_from': start_date, 'valid_to': build_date, 'is_current': False})
        rows.append({'object_id': id, 'status': 'строится', 'valid_from': build_date, 'valid_to': None, 'is_current': True})
    else:
        rows.append({'object_id': id, 'status': 'запланирован', 'valid_from': start_date, 'valid_to': build_date, 'is_current': False})
        rows.append({'object_id': id, 'status': 'строится', 'valid_from': build_date, 'valid_to': complete_date, 'is_current': False})
        rows.append({'object_id': id, 'status': 'введён', 'valid_from': complete_date, 'valid_to': None, 'is_current': True})
        
        
    object_status_history = pd.concat([object_status_history, pd.DataFrame(rows)], ignore_index=True)
 
object_status_history.to_csv('object_status_history.csv', index=False)



