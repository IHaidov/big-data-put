#!/usr/bin/env python3

import sys
import csv

reader = csv.reader(sys.stdin)

for values in reader:
    if len(values) < 16:
        continue  

    developer_id = values[-1]
    rating = values[3]  
    rating_count = values[4].replace(",", "")  
    released_date = values[14]

    if not rating or not rating_count or not released_date:
        continue

    try:
        rating = float(rating)
        rating_count = int(rating_count)
        year = released_date.split(",")[1].strip()

    except ValueError:
        continue

    if rating_count >= 1000:
        print("%s,%s\t%f\t%d\t1" % (developer_id, year, rating, rating_count))
