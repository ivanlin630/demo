"""掛單押貨負對照：python neg_moe.py <tree> <n> apply"""
import sys, io
NEG = {
 "n1": ("拿掉玩家隊判斷 ⇒ E4＋E5", [
   ("scripts/simulation/order_system.gd",
    "\t\t\t\tif _owner != -1 and _owner == state.get_player_team_id():",
    "\t\t\t\tif _owner != -1:")]),
 "n2": ("release_order_escrow 不發事件 ⇒ P1 事件格、E1、E2", [
   ("scripts/simulation/order_system.gd",
    "\t\t\t\t\tWorldEvents.emit(state, \"goods_returned\", [_owner], true,",
    "\t\t\t\t\tif false: WorldEvents.emit(state, \"goods_returned\", [_owner], true,")]),
 "n3": ("待領列改讀全部 owner ⇒ P1 只列自己的格", [
   ("scripts/simulation/player_query_api.gd",
    "\t\t\tif int(c.get(\"owner_team\", -1)) != pt.team_id:\n\t\t\t\tcontinue\n\t\t\tclaims.append(",
    "\t\t\tclaims.append(")]),
 "n4": ("判斷式改回 .possessed ⇒ P1 事件格", [
   ("scripts/simulation/order_system.gd",
    "\t\t\t\tif _owner != -1 and _owner == state.get_player_team_id():",
    "\t\t\t\tif _owner != -1 and state.teams.has(_owner) and (state.teams[_owner] as TeamData).possessed:")]),
}
tree, n, mode = sys.argv[1], sys.argv[2], sys.argv[3]
desc, cuts = NEG[n]
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
