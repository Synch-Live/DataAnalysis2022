## NYC UWB logs

This folder contains logs collected by the UWB system (`1-logs`), scripts to extract them as trajectories and prepare them for studying their emergence and collective properties, robust extracted trajectories (`3-traj`) and plots.

### Format

The `1-logs` folder should contain the original log files from the `observer` with the date and UTC timestamp of when the experiment was started in the filename.

At initialisation, the  UWB system reports the size of the play area in the logs.

    uwb=namespace(playarea_meters=namespace(x=5.8, y=7.6, z=2),

The XY coordinates from each initialisation log are extracted and used to normalise the positions to the unit square.

Each position is reported in the following format, 12 times every second (12FPS):

    hh:mm:ss.mmm XYZ [ [x1, y1, z1], ... [xn, yn, zn] ]

where the timestamp is in UTC, `XYZ` is a string (currently used by scripts to extract all lines that include positions), and positions are in metres.

Each position line is succeeded by two lines of logs reporting the filtered and unfiltered realtime $\Psi$ value for those positions. The first 180 unfiltered values should always be -5.

Example:

    23:13:35.820 Unfiltered Psi 182: 1.361031890190849
    23:13:35.821 Filtered Psi 182: -5.0
    23:13:35.854 XYZ [[-32.5, -2.2, -1.54], [-6.09, -2.79, -0.37], [-0.23, -0.05, -0.01], [-52.49, 73.32, -1.76]]


To show log files that have any position data:
```sh
grep -rl XYZ 1-logs | sort
```

To show how many trajectories with _any_ $\Psi$ data points are in a file (e.g. for how many frames the recording has run, `total_duration`)
```sh
grep 'Unfiltered Psi' 1-logs/*.log | tac | sort -u -t: -k1,1
```

> [!NOTE]
> All experiments without any trajectory data or with less than 300 data points should be excluded.

To show log files with _any_ $\Psi$ greater than 3 in a given game:

```sh
grep -Erl 'Filtered Psi [0-9]+: ([3-9][.][0-9]+)' 1-logs/
```

To show the last occurence of a $\Psi$ greater than 3, i.e. `psi_duration`:
```sh
grep -E 'Filtered Psi [0-9]+: ([3-9][.][0-9]+)' 1-logs/*.log | tac | sort -u -t: -k1,1
```


### `game_data.csv`

Information extracted from the logs, such as the limits of the play area, the number of players, the number of frames where all players were present etc are in the `game_data.csv` file.

The information to fill `game_data` was gathered manually by browsing the file or running the commands above. A full `game_data` is needed to run the Python script in step 2 below.

### Pipeline

1. First foreach file in `1-logs` the lines containing `XYZ` are extracted to a file in `2-xyz-logs`

```sh
foreach f in 1-logs/*; do grep XYZ $f >  2-xyz-logs/${f##*/}; done
```

2. Then each file in `2-xyz-logs` is processed with the Python script `proc_traj.py` into numpy arrays in `3-traj-2d`.

```sh
foreach f in 2-xyz-logs/*; do python proc_traj.py $f; done
```

> [!IMPORTANT]
> The Z-axis is currently being removed by this script, and the positions are being normalised to unit square.

The shape of the numpy array resulting from the processing should match `(duration, players, 2)`. Note that this is not the same duration as `total_duration` or `psi_duration`, as some data points may have been skipped due to failure in tracking, or removed from the end due to not being associated with a useful value of $\Psi$.
The arrays have been plotted in the same folder using `trajectories.py` from [Synch.Live](https://github.com/mearlboro/Synch.Live/blob/main/python/camera/tools/trajectories.py).

```sh
foreach f in 3-logs/*; do python trajectories.py plot --filename $f; done
```

> [!NOTE]
> Some experiments were kept running after participants were no longer following the task. Therefore duration of a game refers to `psi_duration` rather than `total_duration`.


3. To calculate $\Psi$ for the extracted trajectories, the numpy files can simply be passed to `emergence.py` from [Synch.Live](https://github.com/mearlboro/Synch.Live/blob/main/python/camera/core/emergence.py). This ensures the same running calculator is used. The output is saved as numpy arrays in `psi`.

```sh
foreach f in 3-traj-2d/*.npy; do python emergence.py --filename $f; done
```

Note the following parameters were used:

```python
SAMPLE_THRESHOLD = 180
PSI_START = -5
psi_buffer_size = 60
observation_window_size = 720
use_local = False
```

4. The notebook `playground.ipynb` loads game data, creates dataframes, and visualises the value of $\Psi$ over time.

5. Optionally, files in `3-traj` can be converted to text format to be plotted by the `pyflocks` library [animate utility](https://github.com/mearlboro/flocks/blob/main/util/animate.py).




#### Processing logs

We can see robust localisation with a drop in the number of players per line only at the start of each game. Logs are in `proc_traj.log`

### Other Notes

* unless otherwise stated below, logs with no or less than 300 positions have been removed
* 20240206-224523, 20240206-235923, 20240207-000801 are mostly empty, all XY positions are at 0, so they  are not included in this analysis
* 20240207-192351 has 5 players, and the first player is always static at position 0,0,0


