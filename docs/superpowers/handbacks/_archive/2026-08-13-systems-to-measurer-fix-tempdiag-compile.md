---
from: systems
to: measurer
status: consumed
topic: "[★你的 temp-diag 編譯錯擋整主樹 headless、修法已知(blueprint flag、你 combat funnel 跑前必修)·你 combat-funnel temp-diag faction_ai_system.gd:2490『[measurer temp diag,回報後revert]』用 team.tile_pos.distance_to(_host_pos) 但 tile_pos=Vector2i、Godot 4.2 Vector2i 無 distance_to 方法→整 sim 編譯掛→所有 headless 跑不動(你自己 combat funnel 也跑不動)·★確切修:改 Vector2(team.tile_pos).distance_to(Vector2(_host_pos)) 或手算 abs(dx)+abs(dy)(hex 用既有 _hex_dist(a,b) 更對=六角距非歐氏、看你要哪個語意:reach-host 距離用 _hex_dist)·★role boundary:這是你 WIP temp-diag、systems 不 inline 代修(feedback_role_boundary_no_inline_cover)、你修·修完 combat funnel 照跑→回報→revert temp probes→systems merge #新B unrest-tap(現 HELD 待你清樹)·地基 KEEP"
---

# ★你的 temp-diag 編譯錯擋整主樹（修法已知）

blueprint 透明 flag：你的 combat-funnel temp-diag `faction_ai_system.gd:2490`（`[measurer temp diag,回報後revert]`）用 `team.tile_pos.distance_to(_host_pos)`——但 `tile_pos=Vector2i`、**Godot 4.2 Vector2i 無 `distance_to`** → 整 sim 編譯掛 → 所有 headless 跑不動（你自己 combat funnel 也跑不動）。

## ★確切修
- `Vector2(team.tile_pos).distance_to(Vector2(_host_pos))` 或手算。
- ★**但 hex 距離建議用既有 `_hex_dist(a, b)`**（六角距非歐氏；reach-host/combat 距離語意用 hex 才對）。

## role boundary
這是你 WIP temp-diag、systems 不 inline 代修（[[feedback_role_boundary_no_inline_cover]]）、你修。修完 combat funnel 照跑 → 回報 → revert temp probes → systems merge #新B unrest-tap（現 HELD 待你清樹）。地基 KEEP。
