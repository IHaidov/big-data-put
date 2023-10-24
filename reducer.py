#!/usr/bin/env python2

import sys

current_key = None
total_rating = 0.0
total_rating_count = 0
app_count = 0

#print("dev_id year total_rating total_rating_count app_count")
for line in sys.stdin:
    line = line.strip()
    developer_year, rating, rating_count, app = line.split("\t")

    rating = float(rating)
    rating_count = int(rating_count)
    app = int(app)

    if current_key == developer_year:
        total_rating += rating
        total_rating_count += rating_count
        app_count += app
    else:
        if current_key:
            dev_id, year = current_key.split(",")
            print("%s\t%s\t%f\t%d\t%d" % (dev_id, year, total_rating, total_rating_count, app_count))

        total_rating = rating
        total_rating_count = rating_count
        app_count = app
        current_key = developer_year

if current_key == developer_year:
    dev_id, year = current_key.split(",")
    print("%s\t%s\t%f\t%d\t%d" % (dev_id, year, total_rating, total_rating_count, app_count))
