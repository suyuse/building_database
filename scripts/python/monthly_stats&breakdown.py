import pandas as pd

df = pd.read_csv('building_database/tables/initial tables/apartments_monthly.csv')
regions = pd.read_csv('building_database/tables/regions.csv')

df['clear_name'] = df['region_desc'].str.replace(' город', '').str.replace('Ханты-Мансийский АО - Югра', 'Ханты-Мансийский автономный округ — Югра').str.replace(' - Кузбасс', '').str.replace('Северная Осетия - Алания Республика', 'Алания').str.replace(' Республика', '').str.replace('Республика ', '').str.lower().str.strip()
regions['clear_name'] = regions['name'].str.replace(' (без автономного округа)', '').str.replace(' (без автономных округов)', '').str.replace('Республика Северная Осетия — Алания', 'Алания').str.replace('Республика ', '').str.replace(' Республика', '').str.lower().str.strip()

monthly_stats = df.merge(regions[['clear_name', 'region_id']], how='left', left_on='clear_name', right_on='clear_name')
monthly_stats = monthly_stats.rename(columns={'month_dt': 'month_date', 'elem_parking_cnt' : 'parking_cnt'})
monthly_stats['stats_id'] = monthly_stats.index + 1

apt = monthly_stats.melt(
    id_vars=['stats_id'], value_vars=['elem_1k_cnt', 'elem_2k_cnt', 'elem_3k_cnt', 'elem_4k_cnt'], var_name='type', value_name='apt_count'
)
apt['type'] = apt['type'].map({
    'elem_1k_cnt': '1к', 'elem_2k_cnt': '2к', 'elem_3k_cnt': '3к', 'elem_4k_cnt': '4к+'
})

monthly_stats = monthly_stats[['stats_id', 'month_date', 'region_id', 'obj_cnt', 'total_area', 'living_area', 'parking_cnt']]

monthly_stats.to_csv('monthly_stats.csv', index=False)
apt.to_csv('apartment_type_breakdown.csv', index=False)