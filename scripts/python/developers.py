import pandas as pd

data = pd.read_csv('developers_domrf.csv')
clear_data = data[['developer_id', 'developer_name', 'developer_inn', 'developer_ogrn']].drop_duplicates().rename(columns={
        'developer_name': 'name',
        'developer_inn': 'inn',
        'developer_ogrn': 'ogrn'
    })

clear_data.to_csv('developers.csv', index=False)