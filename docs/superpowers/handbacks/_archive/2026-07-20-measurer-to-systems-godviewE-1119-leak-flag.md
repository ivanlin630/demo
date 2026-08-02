---
from: measurer
to: systems
status: consumed
topic: "[godview-E out-of-scope leak 確認·faction_ai:1119 讀 live 他隊位] implementer flag 的 1119 我量測時確認:`_hex_dist(leader_team.tile_pos, state.teams[target_id].tile_pos) < 999` = 讀 live target tile_pos 算距離 gate(loose <999)。非本 slice E R²-scoped 4-site(E1/E2/E3/E5)。可能 leak(決策憑 live 距離)或 legit reachability。另 1625 已標 gate-ok(probe bookkeeping 非決策)。呈報你評估歸不歸下批 god-view audit。"
measured_at_head: 62697e6c
---

# godview-E out-of-scope leak flag：faction_ai:1119

量 Slice E 時 grep-audit 確認 implementer flag 的殘 leak：

- **`faction_ai:1119`**：`and _hex_dist(leader_team.tile_pos, state.teams[target_id].tile_pos) < 999` —— 讀 **live** `state.teams[target_id].tile_pos` 算距離 gate。
  - `< 999` 極 loose（幾乎恆真）→ 可能是近-noop reachability，也可能真 leak（決策憑 live 距離，非 belief）。
  - **不在 Slice E R²-scoped 4-site 內**（E1/E2/E3/E5 已 belief-化）。
- 對照 **`faction_ai:1625`**：`_hex_dist(team.tile_pos, state.teams[_rt].tile_pos) > DISPATCH_DIST_THRESHOLD` 已標 `gate-ok: probe bookkeeping 記帳非決策` → legit。

## 呈報
1119 是 Slice E 4-site 外唯一殘 live-pos 決策讀。你評估：
- 若 leak（決策路）→ 歸下批 god-view audit slice 收。
- 若 legit reachability（<999 loose 只擋跨圖無限遠）→ 標 gate-ok 存檔。
非本 slice scope，我不越界，呈報你裁。raw：Slice E grep（`docs/measurements/2026-07-20-godviewE-*`）。
