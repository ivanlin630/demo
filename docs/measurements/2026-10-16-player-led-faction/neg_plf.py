"""負對照：在釘死的 detached tree 上各拔一刀。用法：python neg_plf.py <tree> <n> apply|list
每一刀＝(檔, 舊字串, 新字串) 若干組 + BED_ONLY 子集。apply 前 tree 必須乾淨（git checkout 還原）。"""
import sys, io
NEG = {
 "n1": ("改法1 return 拔掉 ⇒ F1", "_world_a", [
   ("scripts/simulation/faction_ai_system.gd",
    "\tif state.is_player_led(f):\n\t\tif Probe.enabled: Probe.bump(\"faction.goals_rebuild_player_led\")",
    "\tif false and state.is_player_led(f):\n\t\tif Probe.enabled: Probe.bump(\"faction.goals_rebuild_player_led\")")]),
 "n2": ("strategic 清除拔掉（三處共用那支＋入勢力那刀）⇒ F4a/F4b/F4c", "_world_a,_f4b", [
   ("scripts/data/world_state.gd",
    "\t\tif t != null and not t.strategic_assignments.is_empty():\n\t\t\tt.strategic_assignments.clear()",
    "\t\tif false and t != null and not t.strategic_assignments.is_empty():\n\t\t\tt.strategic_assignments.clear()"),
   ("scripts/data/world_state.gd",
    "\t\tif is_player_led(factions[fid]) and not team.strategic_assignments.is_empty():",
    "\t\tif false and is_player_led(factions[fid]) and not team.strategic_assignments.is_empty():")]),
 "n3": ("外交入口拔掉 ⇒ F3", "_world_a", [
   ("scripts/simulation/diplomatic_ai_system.gd",
    "\tif self_team.player_controlled:\n\t\tif Probe.enabled: Probe.bump(\"diplo.skip_player_controlled\")",
    "\tif false and self_team.player_controlled:\n\t\tif Probe.enabled: Probe.bump(\"diplo.skip_player_controlled\")")]),
 "n4": ("betray continue 拔掉 ⇒ F7", "_world_b", [
   ("scripts/simulation/faction_ai_system.gd",
    "\t\t\t\tif member_team.player_controlled:\n\t\t\t\t\tif Probe.enabled: Probe.bump(\"betray.skip_player_controlled\")",
    "\t\t\t\tif false and member_team.player_controlled:\n\t\t\t\t\tif Probe.enabled: Probe.bump(\"betray.skip_player_controlled\")")]),
 "n5": ("十支 continue 拔掉 ⇒ F5/F5b/F5c", "_world_a,_world_b,_world_c", [
   ("scripts/simulation/faction_ai_system.gd",
    "\t\tif team.player_controlled:\n\t\t\tif Probe.enabled: Probe.bump(\"side.skip_player_controlled\")",
    "\t\tif false and team.player_controlled:\n\t\t\tif Probe.enabled: Probe.bump(\"side.skip_player_controlled\")")]),
 "n6": ("precheck 不呼 block_reason ⇒ S1", "_s1", [
   ("scripts/simulation/player_command_system.gd",
    "\tvar why: String = subjugate_block_now(state)\n\tif why != \"\":",
    "\tvar why: String = \"\"\n\tif why != \"\":"),
   ("scripts/ui/encounter_view.gd",
    "_post_combat_hint(res, PlayerCommandSystem.subjugate_block_now(state))",
    "_post_combat_hint(res, \"\")")]),
 "n7": ("action 不驗結果 ⇒ S1b", "_s1", [
   ("scripts/simulation/player_command_system.gd",
    "\tif pt_now == null or pt_now.faction_id == -1 or loser.faction_id != pt_now.faction_id:",
    "\tif false and (pt_now == null or pt_now.faction_id == -1 or loser.faction_id != pt_now.faction_id):")]),
 "n8": ("subjects 不補＋停點不加 ⇒ S2／S4", "_s2,_s4", [
   ("scripts/simulation/npc_combat_system.gd",
    "\"faction\": str(fid), \"loser_team\": loser_id,",
    "\"faction\": str(fid),"),
   ("scripts/simulation/world_events.gd",
    "\t\"famine_crossed\", \"subjugate\"]",
    "\t\"famine_crossed\"]")]),
 "n9": ("set_team_faction 不 erase ⇒ S3", "_s3", [
   ("scripts/data/world_state.gd",
    "\t\tif player_id != -1:\n\t\t\t_erase_hostile_on_join(team, fid, reason)",
    "\t\tif false and player_id != -1:\n\t\t\t_erase_hostile_on_join(team, fid, reason)")]),
 "n10": ("投降做後驗拔掉 ⇒ S4a/S4b/S4c", "_s4", [
   ("scripts/simulation/player_command_system.gd",
    "\tif w2 != null and w2.faction_id != -1 and pt.faction_id == w2.faction_id:\n\t\treturn \"\"",
    "\tif true or (w2 != null and w2.faction_id != -1 and pt.faction_id == w2.faction_id):\n\t\treturn \"\"")]),
}
tree, n, mode = sys.argv[1], sys.argv[2], sys.argv[3]
desc, only, cuts = NEG[n]
if mode == "only":
    print(only); sys.exit(0)
if mode == "desc":
    print(desc); sys.exit(0)
for f, old, new in cuts:
    p = tree + "/" + f
    t = io.open(p, encoding="utf-8", newline="").read()
    o = old.replace("\n", "\r\n") if "\r\n" in t and old.replace("\n", "\r\n") in t else old
    nw = new.replace("\n", "\r\n") if o != old else new
    c = t.count(o)
    if c != 1:
        print("PATCH_FAIL %s %s count=%d" % (n, f, c)); sys.exit(2)
    io.open(p, "w", encoding="utf-8", newline="").write(t.replace(o, nw))
print("PATCHED %s：%s" % (n, desc))
