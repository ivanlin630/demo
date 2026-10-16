"""7b 負對照：python neg_7b.py <tree> <n> apply|only"""
import sys, io
NEG = {
 "n1": ("屠村迴圈改回 remove_member（散）⇒ B1", "_b7,_a10", [
   ("scripts/simulation/encounter_system.gd",
    "\t\tkilled_named.append(kill_named(state, resident, pid))",
    "\t\tstate.remove_member(resident, pid)\n\t\tkilled_named.append(p.person_name)")]),
 "n2": ("_force_occupy 放回兩成 kill_random ⇒ B2", "_b7", [
   ("scripts/simulation/encounter_system.gd",
    "\t# ★7b：強佔＝易主＋居民留（藍圖：舊「兩成」沒有來源，拿掉）\n",
    "\tAnonTierSystem.kill_random(resident, resident.population - int(float(resident.population) * 0.8), \"occupy\")\n")]),
 "n3": ("稽核改回 continue ⇒ B4", "_b7", [
   ("scripts/simulation/invariant_audit.gd",
    "\t\t\tout.append(\"懸空 P%d team_id=%d 隊已不存在（活人）\" % [pid, p.team_id])\n\t\t\tcontinue",
    "\t\t\tcontinue")]),
 "n4": ("resolve_encounter_end 不呼 kill_named、只 remove_member ⇒ B3", "_b7", [
   ("scripts/simulation/encounter_system.gd",
    "\t\t\tvar dn: String = kill_named(state, t, u[\"person_id\"])",
    "\t\t\tstate.remove_member(t, u[\"person_id\"], false)\n\t\t\tvar dn: String = \"\"")]),
}
tree, n, mode = sys.argv[1], sys.argv[2], sys.argv[3]
desc, only, cuts = NEG[n]
if mode == "only":
    print(only); sys.exit(0)
for f, old, new in cuts:
    p = tree + "/" + f
    t = io.open(p, encoding="utf-8", newline="").read()
    o, nw = old, new
    if "\r\n" in t:
        o, nw = old.replace("\n", "\r\n"), new.replace("\n", "\r\n")
    if t.count(o) != 1:
        sys.stdout.buffer.write(("PATCH_FAIL %s %s count=%d\n" % (n, f, t.count(o))).encode("utf-8")); sys.exit(2)
    io.open(p, "w", encoding="utf-8", newline="").write(t.replace(o, nw))
sys.stdout.buffer.write(("PATCHED %s：%s\n" % (n, desc)).encode("utf-8"))
