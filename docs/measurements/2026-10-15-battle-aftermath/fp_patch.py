import io
p = r"A:\GDS\demo\.worktrees\mm2neg\scripts\simulation\state_fingerprint.gd"
s = io.open(p, encoding="utf-8").read()
for a, b in [('buf.append("T|%d|pop=%d|minor=%d|prisoner=%d|task=%s|', 'buf.append("T|%d|pop=%d|minor=%d|task=%s|'),
             ('t.team_id, t.population, t.minor_population, t.prisoner_population, t.current_task,', 't.team_id, t.population, t.minor_population, t.current_task,')]:
    assert s.count(a) == 1; s = s.replace(a, b)
io.open(p, "w", encoding="utf-8", newline="").write(s); print("patched")
