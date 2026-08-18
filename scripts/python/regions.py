import pandas as pd

data = pd.read_csv('building_database/tables/data_housing_construction_dev.csv')

regions = data[['parent_object_name', 'parent_object_code']].drop_duplicates().reset_index(drop=True)
regions['region_id'] = regions.index + 1
regions = regions.rename(columns={
    'parent_object_name': 'name',
    'parent_object_code': 'oktmo'
})

region_ds = pd.read_csv('building_database/tables/region_districts.csv')
regions = regions.merge(region_ds[['oktmo', 'district_id']], how='left', left_on='oktmo', right_on='oktmo')
regions.to_csv('regions.csv', index=False)
