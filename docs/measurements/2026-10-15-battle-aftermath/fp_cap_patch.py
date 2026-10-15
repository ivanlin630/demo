import io
p = r"A:\GDS\demo\.worktrees\mm2neg\scripts\simulation\anon_tier_system.gd"
s = io.open(p, encoding="utf-8").read()
a = '	var budget: int = ManpowerSystem.captive_room(state, winner)\n'
b = '	var budget: int = maxi(FactionAISystem.effective_pop_cap(state, winner) - winner.population - total_captives(winner), 0)\n'
assert s.count(a) == 1; s = s.replace(a, b)
io.open(p, "w", encoding="utf-8", newline="").write(s); print("cap patched")
