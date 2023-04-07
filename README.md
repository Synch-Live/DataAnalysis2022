# Synch.Live: trajectory data analysis

This repository contains the videos, trajectories and emergence data from the
Synch.Live experiments performed on 18-19 June 2022.

## Experimental details

20 groups of at most 10 participants played Synch.Live for at most 10 minutes,
aiming to synchronise their lights according to the emergence of their movement.
In total, 195 persons participated in the experiment.
All participants were given the same instructions, available in `experiment/instructions.md`.
Details of the experimental setup for each group are available in `experiment/group_data.csv`.

The system used [Synch.Live1.0](https://github.com/Synch-Live/Synch.Live1.0)
with an Observer system running object detection and tracking with OpenCV.
The specific version used is [ca96cd7](https://github.com/Synch-Live/Synch.Live1.0/tree/ca96cd788f21d6e72dd51c5b9d176791e040a021).

All participants over 18 submitted the Davis empathetic perspective-taking
questionnaire before the experiment, and the Watts connectedness scale, alongside
with a free-form questionnaire, after the experiment. The questions asked are
available in `experiment/questionnaires`.

Finally, experimental reports written after each day are included in `experiment/reports/`.

## Media

The folder `video-traj/` contains gameplay recordings as seen by the Observer.
The original files are located in `video/1-orig`. A pipeline for trajectory
extraction is included in the folder, such that the trajectories are exported to
be compatible with the [`pyflocks` library](https://github.com/mearlboro/flocks).
Moreover, animations of the trajectories, exported with the same library, are
available as PNG images.

On a Linux or Mac system, the pipeline consists of the following steps:

1. **Trim**

The script `trim.py` uses the experimental details in `setup/group_data.csv`
to trim the first seconds of each video, used for training by the object tracker
and the information theoretic calculators, and the last seconds of the video,
which may not include any gameplay.

The trimming is done using `ffmpeg` on the videos in `1-orig`, with outputs in
`2-trim`.
The script opens a subprocess that runs the relevant `ffmpeg` command but can be
modified to simply print the command instead. Run as

```sh
$ python trim.py
```

The script should produce commands of the form:

```sh
ffmpeg -to $end_seconds -i 1-orig/$group.avi -ss $start_seconds -c copy 2-trim/$group.mp4
```

To check the duration of the resulting files, run

```
cd 2-trim
for f in *.mp4; do
    echo $f
    ffprobe -i $f 2>&1 | grep Duration | cut -d ' ' -f 4 | sed s/,//
done
```


2. **Extract trajectories**

The trajectories are to be extracted in real-time from the videos in `2-trim` to
`3-traj`. The resulting file is a `numpy` array for each video. The same object
detector and tracker as the experimental data is used by using the [`trajectories.py`
script](https://github.com/Synch-Live/Synch.Live1.0/blob/main/python/camera/tools/trajectories.py)
in the `camera.tools` module in Synch.Live.

For example, the below script can extract trajectories for all videos:

```sh
cd 2-trim
declare -a gs=('A2' 'A3' 'A4' 'A5' 'A6' 'A8' 'A9' 'A10' 'B1' 'B2' 'B3' 'B4' 'B5' 'B6' 'B7' 'B8' 'B9')
for f in "${gs[@]}"; do
    echo $f
    python -m camera.tools.trajectories track --filename "$f.mp4" --realtime --out ../3-traj
done
```

The `plot` command of the `trajectories.py` script can also be used to verify the
trajectories were extracted correctly, before moving to the next step.

Then, to format trajectories in the specific, text format expected by the `pyflocks`
library, the `totxt` command of the `trajectories.py` script is used:

```sh
cd 3-traj
declare -a gs=('A2' 'A3' 'A4' 'A5' 'A6' 'A8' 'A9' 'A10' 'B1' 'B2' 'B3' 'B4' 'B5' 'B6' 'B7' 'B8' 'B9')
for f in "${gs[@]}"; do
    echo $f
    python -m camera.tools.trajectories totxt --filename "$f.traj" --realtime --out ../4-txt
done
```


## References

Watts R, Kettner H, Geerts D, Gandy S, Kartner L, Mertens L, Timmermann C, Nour MM, Kaelen M, Nutt D, Carhart-Harris R, Roseman L. The Watts Connectedness Scale: a new scale for measuring a sense of connectedness to self, others, and world. Psychopharmacology (Berl). 2022 Nov;239(11):3461-3483. doi: 10.1007/s00213-022-06187-5. Epub 2022 Aug 8. PMID: 35939083; PMCID: PMC9358368.

Davis, Mark. (1983). Measuring individual differences in empathy: Evidence for a multidimensional approach. Journal of personalilty and social psychology. 44. 113-126. 10.1037/0022-3514.44.1.113.
