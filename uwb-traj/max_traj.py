import ast
import csv
import re
import sys

import numpy as np


f = sys.argv[1]
if not f.endswith('.log'):
    print("Must be a log file")
    sys.exit(0)
name = f.split('observer_')[-1].split('.log')[0]

logs = open(f, 'rt')
maxpsi = -5
maxind = 0
for line in logs:
    if 'Filtered Psi' in line:
        log_str = line.split('Filtered Psi')[1]
        index = log_str.split(':')[0]
        psi = log_str.split(':')[1]
        psi = ast.literal_eval(psi.strip())
        if maxpsi < psi:
            maxpsi = psi
            maxind = index

print(f"{f}: {maxind}: {maxpsi}")

