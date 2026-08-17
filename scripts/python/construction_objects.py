import pandas as pd
import numpy as np


data = pd.read_csv('building_database/tables/data_housing_construction_dev.csv')

tmp = data[['object_name', 'parent_object_code']].drop_duplicates()
developers = pd.read_csv('building_database/tables/developers.csv')
regions = pd.read_csv('building_database/tables/regions.csv')

df = tmp.merge(
        developers[['developer_id', 'name']],
        how='inner', left_on='object_name', right_on='name').merge(         # не все названия застройщиков представлены в таблице developers (одна из причин - в таблице 
        regions[['region_id', 'oktmo']],                                    # developers названия часто "полные" (с указанием СЗ и названия региона))
        how='left', left_on='parent_object_code', right_on='oktmo'
    ).dropna()
                
n = len(df)

construction_objects = pd.DataFrame({
    'object_id': np.arange(1, n + 1),
    'developer_id': df['developer_id'],
    'region_id': df['region_id'],
    'planned_year': np.random.randint(2019, 2031, size=n),  
    'planned_quarter': np.random.randint(1, 5, size=n), 
})

construction_objects.to_csv('construction_objects.csv', index=False)