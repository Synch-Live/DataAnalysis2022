## NYC UWB logs

This folder contains logs collected by the UWB system (`1-logs`), scripts to extract them as trajectories and prepare them for studying their emergence and collective properties, robust extracted trajectories (`3-traj`) and plots.

### Format

The `1-logs` folder contains  the original log files from the `observer` with the date and UTC timestamp of when the experiment was started in the filename.

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

To show how many Psi data points are in a file (e.g. for how many frames the experiment has run)
```sh
grep 'Unfiltered Psi' 1-logs/*.log | tac | sort -u -t: -k1,1
```

> [!NOTE]
> All experiments without any trajectory data or with less than 300 data points should be excluded.

### `game_data.csv`

Information extracted from the logs, such as the limits of the play area, the number of players, the number of frames where all players were present etc are in the `game_data.csv` file.

### Pipeline

1. First foreach file in `1-logs` the lines containing `XYZ` are extracted to a file in `2-xyz-logs`

```sh
foreach f in 1-logs/*; do grep XYZ $f >  2-xyz-logs/${f##*/}; done
```

2. Then each file in `2-xyz-logs` is processed with the Python script `proc_traj.py` into numpy arrays in `3-traj`.

```sh
foreach f in 2-xyz-logs/*; do python proc_traj.py $f; done
```

> [!IMPORTANT]
> The Z-axis is currently being removed by this script, and the positions are being normalised to unit square.

The shape of the numpy array resulting from the processing should match `(duration, players, 2)`.
The arrays have been plotted in the same folder `trajectories.py plot --filename traj.npy` from [Synch.Live](https://github.com/mearlboro/Synch.Live/blob/main/python/camera/tools/trajectories.py).

> [!IMPORTANT]
> The game duration and number of players for that game in `game_data.csv` is given by the trajectory array obtained above.

3. Optionally, files in `3-traj` can be converted to text format to be plotted by the `pyflocks` library [animate utility](https://github.com/mearlboro/flocks/blob/main/util/animate.py).



#### Processing logs

We can see robust localisation with a drop in the number of players per line only at the start of each game. Logs are in `proc_traj.log`

### Other Notes

* unless otherwise stated below, logs with no or less than 300 positions have been removed
* 20240206-224523, 20240206-235923, 20240207-000801 are mostly empty, all XY positions are at 0, so they  are not included in this analysis
* 20240207-192351 has 5 players, and the first player is always static at position 0,0,0 


