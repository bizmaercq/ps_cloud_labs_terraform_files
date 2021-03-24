import random
import time
from pprint import pprint
from datetime import date, timedelta, datetime
import pandas as pd
import json

sdate = date(2021,1,1)   # start date
edate = date(2021,2,1)   # end date

# The size of each step in days
day_delta = timedelta(days=1)

start_date = date(2021,1,1) 
end_date = date(2021,2,1)
date_range = [start_date + i*day_delta for i in range((end_date - start_date).days)]




for date_ in date_range:
    data = []
    for i in range(1000):
        data.append(
            {
                "relationship_manager_id": random.randint(1000, 1016), 
                "branch_id": random.randint(1, 10), 
                "date": str(date_),
                "customer_count": random.randint(20, 10000)
                }
                )
    with open(f'data/{date_}.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)

