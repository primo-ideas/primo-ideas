# Game clips for the landing page

The Star Racer and Dronoids cards on https://primo-ideas.xyz/ show a short looping clip instead
of a screenshot: `/var/www/html/assets/star-racer.mp4` and `dronoids.mp4`, 10 s each, H.264 with
no sound, with a WebP of their first frame as the poster (`star-racer.webp`, `dronoids.webp`).
The page plays them muted and looped; for a visitor who asked for reduced motion they stay on
the poster and play only while the pointer is over the card.

Both were recorded on 2026-11-12 on Windows, from local builds only: nothing touches the
production servers or the shared Dronoids world.

## Tools

- `tools/record-window.ps1` (this repo) records one window with ffmpeg's `gfxcapture` filter
  (Windows.Graphics.Capture). It works on GPU-rendered windows, where `gdigrab` shows black,
  and keeps working when the window is partly covered. Started with `-Exe attach:<name>`, it
  films the largest window of the running processes of that name.
- ffmpeg comes from Python: `python -m pip install imageio-ffmpeg`, then
  `python -c "import imageio_ffmpeg as f; print(f.get_ffmpeg_exe())"` gives its path.
- The screen is 1366x768, so the games run in a 1152x648 window, which fits.

## Dronoids

In `~/repos/dronoids`, after `cargo build --release`. Offline sector, the first factory placed
automatically, 40 minutes fast-forwarded, then scripted clicks build six more factories around
it (the Factory button, then a spot), set the speed to x4 (two clicks on x1) and deselect (a
click on empty space). Launch it from Git Bash: started by PowerShell's `Start-Process`, the
game ignored the building clicks.

```bash
C=""; f=30; for xy in 380,190 780,190 330,430 820,440 576,120 576,530; do C="$C --click 422,620@$f --click $xy@$((f+10))"; f=$((f+30)); done
```

```bash
./target/release/dronoids.exe --offline normal --ais 6 --seed 7 --land --bonuses --ticks 2400 --size 1152,648 $C --click 1040,22@300 --click 1040,22@310 --click 1000,590@330 &
```

```bash
pwsh -NoProfile -File ~/repos/primo-ideas/tools/record-window.ps1 -Exe attach:dronoids -Out dronoids-raw.mp4 -Seconds 18 -Warmup 12
```

`--screenshot out.png --after 25` instead of the recording shows the framing first.

## Star Racer

In `~/repos/star-racer`, with the debug build (`cargo build --workspace`; the dev profile runs
Bevy at full speed). A local server on a spare port, then five clients on the drifting autopilot
in one lobby that starts at five players: four small ones, then the one filmed, at 1152x648.
Start each client only once the previous one is in the lobby (watch the server log for
`player joined the lobby`): clients connecting at the same moment each open a lobby of their own.

```bash
./target/debug/star-racer-server.exe --port 18080 --ratings /tmp/ratings.ron > server.log 2>&1 &
```

```bash
common="--server ws://127.0.0.1:18080/ws --lobby Showcase --track skyway --laps 3 --min-players 5 --autopilot-drift --volume 0"
```

```bash
./target/debug/star-racer-client.exe $common --nickname Racer2 --identity /tmp/sr-id-2 --window-size 400x224 &
```

(the same for Racer3, Racer4 and Racer5, each with its own `--identity`), then:

```bash
./target/debug/star-racer-client.exe $common --nickname Primo --identity /tmp/sr-id-1 --window-size 1152x648 &
```

```bash
pwsh -NoProfile -File ~/repos/primo-ideas/tools/record-window.ps1 -Exe attach:star-racer-client -Out star-racer-raw.mp4 -Seconds 60 -Warmup 0 -KeepRunning
```

A minute covers the end of a race, the results and the next start. The clip begins as the
starting lights come on (34.4 s into that recording) and runs through the launch of the pack.

## Cutting the loop

`$F` is the ffmpeg path. The clip takes `L` seconds from `S`, and its last `D` seconds fade into
its first frame, so the loop has no jump. Star Racer: `S=34.4 L=10 D=0.6`, scaled to 960x540,
CRF 27. Dronoids: `S=1.0 L=10 D=0.8`, cropped to the colony (`crop=820:512:140:80`), scaled to
800x500, CRF 25.

```bash
"$F" -y -i star-racer-raw.mp4 -filter_complex "[0:v]trim=start=34.4:duration=10.6,setpts=PTS-STARTPTS,scale=960:540:flags=lanczos,setsar=1,split[a][b];[a]trim=start=0.6,setpts=PTS-STARTPTS[m];[b]trim=duration=0.6,setpts=PTS-STARTPTS[h];[m][h]xfade=transition=fade:duration=0.6:offset=9.4,format=yuv420p[v]" -map "[v]" -an -c:v libx264 -profile:v high -preset slow -crf 27 -r 30 -movflags +faststart star-racer.mp4
```

```bash
"$F" -y -i star-racer.mp4 -frames:v 1 -c:v libwebp -quality 75 star-racer.webp
```

Then upload both files to `/var/www/html/assets/` (see [README](README.md)).
