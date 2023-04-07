import os
import csv
import pandas as pd
import subprocess

FRAMERATE = 12
START_THRESHOLD = FRAMERATE * 15
BLOCK_LEN_SEC = 10
BLOCK_LEN_FRAMES = FRAMERATE * BLOCK_LEN_SEC

groups = pd.read_csv('../setup/groups_data.csv')
groups = groups[groups.Notes != 'Pointwise MI'][groups.Notes != 'ERROR']

for g in groups.Group:
    if os.path.exists(f"1-orig/{g}.avi") and os.path.exists(f"../psi/{g}-psi.csv"):
        # leave sufficient leeway for the -0.5 not to affect median, drop first frames
        start  = int(groups[groups.Group==g]['Filter buffer (frames)'] / 3 * 2 + START_THRESHOLD)
        gameplay_length = int(groups[groups.Group==g]['Duration (frames)'])
        length = gameplay_length - start + 1
        # dump the last incomplete block as it likely contains raibow animation,
        # and is difficult to extract trajectories, of if the last block is very small,
        # also dump the last complete block
        blocks, rem = divmod(length, BLOCK_LEN_FRAMES)
        if rem <= 20:
            blocks -= 1
            rem += BLOCK_LEN_FRAMES

        # so far operating in frames, switch to seconds for ffmpeg
        ss = int(start / FRAMERATE)
        t  = blocks * BLOCK_LEN_SEC

        print(f"Will process group {g} which has a gameplay of {gameplay_length / FRAMERATE} s ({gameplay_length} frames) in {blocks} blocks (remainder {rem} frames) to get a video of {t} s")

        command = f"ffmpeg -to {ss + t} -i 1-orig/{g}.avi -ss {ss} -c copy 2-trim/{g}.mp4"
        subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)

