import pandas as pd


regions = pd.read_csv('building_database/tables/regions.csv')
quarterly_completions = pd.read_csv('region_analysis.csv')

quarterly_completions['clear_name'] = quarterly_completions['region_name'].str.replace('Город ', '').str.replace('Еврейская АО', 'Еврейская автономная область').str.replace('Ханты-Мансийский АО - Югра', 'Ханты-Мансийский автономный округ — Югра').str.replace(' - Кузбасс', '').str.replace('Республика Северная Осетия', 'Алания').str.replace('АО', 'автономный округ').str.lower().str.strip()
regions['name'] = regions['name'].str.replace('Республика Северная Осетия — Алания', 'Алания').str.replace(' (без автономного округа)', '').str.replace(' (без автономных округов)', '').str.lower()

quarterly_completions = quarterly_completions.merge(regions[['name', 'region_id']], how='left', left_on='clear_name', right_on='name')[['region_id', 'year', 'quarter', 'buildings_count', 'apartments_count','total_living_area']].dropna()
quarterly_completions['apartments_count'] = quarterly_completions['apartments_count'].astype(int)

quarterly_completions = quarterly_completions[['region_id', 'year', 'quarter', 'buildings_count', 'apartments_count','total_living_area']]
quarterly_completions.to_csv('quartery_completions.csv', index=False)