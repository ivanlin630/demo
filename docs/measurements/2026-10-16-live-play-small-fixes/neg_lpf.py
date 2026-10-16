"""真玩小修負對照：python neg_lpf.py <tree> <n> apply|only"""
import sys, io
NEG = {
 "n1": ("forced_label 不呼 block_reason ⇒ J2", "_j", [
   ("scripts/simulation/player_api_mapper.gd",
    "\t\t\t\tif _why != \"\":\n\t\t\t\t\treturn \"收留（不可：%s）\" % _why",
    "\t\t\t\tif false and _why != \"\":\n\t\t\t\t\treturn \"收留（不可：%s）\" % _why")]),
 "n2": ("_accept_join_request 改回 merge_teams（只搬匿名×容量比例）⇒ J1", "_j", [
   ("scripts/simulation/player_command_system.gd",
    "\tvar r: Dictionary = SubteamSystem.absorb_whole_team(state, pt, from_team)",
    "\tvar _p0: int = pt.population\n\tSubteamSystem.new().merge_teams(state, pt.team_id, from_id)\n\tvar r: Dictionary = {\"ok\": true, \"moved\": pt.population - _p0}")]),
 "n3": ("拿掉轉俘虜那一步 ⇒ J1b 俘虜格", "_j", [
   ("scripts/simulation/subteam_system.gd",
    "\tfor g in absorbed.captive_groups:\n\t\tabsorber.captive_groups.append(g)\n\tabsorbed.captive_groups.clear()",
    "\tpass")]),
 "n4": ("成員頁自己算期望餉 ⇒ P3", "_p", [
   ("scripts/simulation/player_api_mapper.gd",
    "\t\t\t\"fair_salary\":  SalarySystem.fair_salary(m),",
    "\t\t\t\"fair_salary\":  4.0,")]),
 "n5": ("T 鍵不決定預設側 ⇒ K1", "_k", [
   ("scripts/ui/text_ui_main.gd",
    "\t\t\t\t_interact_pane = _default_interact_pane()   # ★關→開：預設側（spec live-play-small-fixes §三）",
    "\t\t\t\tpass")]),
 "n6": ("空項不回句 ⇒ K2／K3", "_k", [
   ("scripts/ui/text_ui_main.gd",
    "\t_set_feedback(false, \"%s這一側沒有第 %d 項（Tab 換側）\" % [",
    "\tif false: _set_feedback(false, \"%s這一側沒有第 %d 項（Tab 換側）\" % [")]),
 "n7": ("看到排入佇列的 ok 就關（舊行為）⇒ T1", "_t", [
   ("scripts/ui/text_ui_main.gd",
    "\t\tif bool(r.get(\"queued\", false)):\n\t\t\t_trade_wait_seq = int(r.get(\"seq\", -1))",
    "\t\tif bool(r.get(\"queued\", false)):\n\t\t\t_trade_mode = false; _trade_target_id = -1; _trade_page = 0")]),
 "n8": ("判準改回 pending_trade_target ⇒ T1b", "_t", [
   ("scripts/ui/text_ui_main.gd",
    "\t\tif _trade_wait_seq != -1 and int(r.get(\"seq\", 0)) == _trade_wait_seq:\n\t\t\t_trade_wait_seq = -1\n\t\t\tif bool(r.get(\"ok\", false)) and _trade_mode:",
    "\t\tif _trade_wait_seq != -1 and int(r.get(\"seq\", 0)) == _trade_wait_seq:\n\t\t\t_trade_wait_seq = -1\n\t\t\tif not _bridge.get_state().player_state.has(\"pending_trade_target\") and _trade_mode:")]),
 "n9": ("頂列先拿隊名（順序錯）⇒ H1／H2", "_h", [
   ("scripts/ui/text_ui_view.gd",
    "const TOP_DROP_ORDER: Array = [\"home\", \"camp\", \"team\", \"pop\", \"food\"]",
    "const TOP_DROP_ORDER: Array = [\"team\", \"home\", \"camp\", \"pop\", \"food\"]")]),
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
