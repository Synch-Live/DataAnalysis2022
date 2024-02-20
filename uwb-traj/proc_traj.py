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
num_players = max(line.count('],') + 1 for line in logs)
logs.close()

# process line by line, each line has following structure
# 19:25:18.216 XYZ [[2.27, 4.89, 1.44], [2.21, 2.84, 1.2]]\n
traj = []; t = 0

logs = open(f, 'rt')
skip = 0
for line in logs:
    t += 1

    n = line.count('],') + 1
    if n < num_players:
        print(f"{f}: Missing {num_players - n} player trajectories on line {t}")
        skip += 1
        continue

    traj_str = line.split('XYZ ')[1][:-1]
    match = re.fullmatch(r"[\d\s\[\].,-]+", traj_str)
    if not match or match.span()[1] != len(traj_str):
        print(f"{f}: Wrong format in eval: {traj_str}")
        continue

    pos = ast.literal_eval(traj_str)
    traj.append(pos)
logs.close()

traj_arr = np.array(traj)
# TODO: in future iterations, may want to keep the z-axis!
traj_arr = np.delete(traj_arr, 2, 2)

# trim end of the gameplay by dumping everything after the last psi > 3
df = open('games_data.csv')
data = csv.DictReader(df)
t_psi = [ d for d in data if d['name'] == name ][0]['psi_duration']
t_psi = int(t_psi) if t_psi else 0
df.close()
if t_psi:
    traj_arr = traj_arr[:t_psi - skip + 1]

print(f"{f}: Processed logs into trajectory array of shape {traj_arr.shape}")

# constrain positions by play area and normalise to unit square
df = open('games_data.csv')
data = csv.DictReader(df)
game_data = [ d for d in data if d['name'] == name ][0]
area_x, area_y = float(game_data['area_x']), float(game_data['area_y'])
df.close()

traj_arr[:, :, 0] = traj_arr[:, :, 0].clip(0, area_x) / area_x
traj_arr[:, :, 1] = traj_arr[:, :, 1].clip(0, area_y) / area_y

# dump array
name = f"3-traj-2d/{name}"
np.save(name, traj_arr)

