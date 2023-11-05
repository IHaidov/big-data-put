#!/usr/bin/env python3

import sys
import csv
csv.field_size_limit(sys.maxsize)

reader = csv.reader(sys.stdin,delimiter = "\x01")

for values in reader:
    if len(values) < 16:
        continue  

    developer_id = values[-1]
    rating = values[3]  
    rating_count = values[4]
    released_date = values[13]
    #print(">>>%s %s %s %s"%(developer_id, rating, rating_count, released_date))
    if rating == "null" or rating_count == "null" or released_date == "null":
        #print("<< %s"%(developer_id))
        continue

    try:
        rating = float(rating)
        rating_count = int(rating_count)
        year = released_date.split(",")[1].strip()

    except ValueError:
        continue

    if rating_count >= 1000:
        print("%s,%s\t%f\t%d\t1" % (developer_id, year, rating, rating_count))
