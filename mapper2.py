#!/usr/bin/env python3

import sys
import re

# Increase the field size limit
#sys.field_size_limit(sys.maxsize)

# Regular expression pattern to split the line by delimiter and capture the required fields
pattern = re.compile(r'\u0001(?=([^\"]*\"[^\"]*\")*[^\"]*$)')

counter = 0
counter2 = 0

for line in sys.stdin:
    counter2 += 1
    
    values = line.split("\x01")
#    print(values)
    if len(values) > 21:
        try:
            developer_id = values[-1].strip()
            rating = float(values[3])
            rating_count = int(values[4])
            released_date = values[13].strip('" ')

            if rating_count < 1000 or released_date == "~":
                continue

            try:
                year = int(released_date.split(",")[1].strip(' "'))
            except ValueError:
                continue

            print("%s,%s\t%f\t%d\t1" % (developer_id, year, rating, rating_count))
            counter += 1

        except ValueError:
            continue

#print(f"Processed records to output: {counter}", file=sys.stderr)
#print(f"Processed records: {counter2}", file=sys.stderr)
