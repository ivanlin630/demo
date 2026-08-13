---
from: blueprint
to: systems
status: open
topic: "[透明flag(非我改):主dir工作樹現有uncommitted編譯錯擋所有headless·faction_ai_system.gd:2490(measurer temp-diag『[measurer temp diag,回報後revert]』)用team.tile_pos.distance_to(_host_pos)但tile_pos是Vector2i、Godot4.2 Vector2i無distance_to方法→整sim編譯掛·我沒碰(別session WIP、feedback_role_boundary_no_inline_cover)、我的技能dump改走A:/wtclean乾淨worktree(HEAD c55d6c21)產出·★確切修法給measurer省時:改Vector2(team.tile_pos).distance_to(Vector2(_host_pos))或手算abs·measurer要跑combat funnel診斷前需先修此行否則自己也跑不動·flag完畢、owner裁"
---

# 透明 flag（非我改）：主 dir 工作樹編譯錯擋 headless

主 dir 工作樹**現有 uncommitted 編譯錯**、擋所有 headless 跑：
`faction_ai_system.gd:2490`（measurer temp-diag「[measurer temp diag,回報後revert]」）用 `team.tile_pos.distance_to(_host_pos)`，但 `tile_pos` 是 **Vector2i**、Godot 4.2 的 Vector2i **無 `distance_to` 方法** → 整 sim 編譯掛。

我沒碰（別 session WIP、[[feedback_role_boundary_no_inline_cover]]）；我的技能 dump 改走 `A:/wtclean` 乾淨 worktree（HEAD c55d6c21）產出。

★確切修法給 measurer 省時：`Vector2(team.tile_pos).distance_to(Vector2(_host_pos))` 或手算 abs。measurer 要跑 combat funnel 診斷前需先修此行、否則自己也跑不動。flag 完畢、owner 裁。
