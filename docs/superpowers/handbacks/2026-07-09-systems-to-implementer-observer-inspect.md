---
from: systems
to: implementer
status: consumed
topic: 實作 observer inspect 擴充（隊全資源 + 據點 inspect，read-only，並行 A2c-1）
---

# 實作工單：observer inspect 擴充

spec（已鎖，reviewer CLEAN + null-deref 阻塞修完）：`docs/superpowers/specs/2026-07-09-observer-inspect-expand.md`

## 在哪做
**新 worktree** `feat/observer-inspect`（base origin/main；與 A2c-1 `feat/machine-A2c1` 不同子系統，並行互不擋）。

## 做什麼（照 spec，4 檔，全 read-only）
1. `observer_query_api.gd`：+`_nonzero_resources`；`query_team` +`resources_nonzero`；+`query_outpost`；+`_owner_faction_of`（★雙 null guard，spec D2a）。
2. `observer_bridge.gd`：+`query_outpost` wrapper。
3. `observer_inspect_panel.gd`：`_render_detail` +資源行；+`select_tile`/`_render_outpost_detail`（★sentinel 互斥契約，spec D2c，寫進 code）。
4. `observer_main.gd`：接 `_map.tile_selected` → `_inspect.select_tile`。

## 驗（spec §驗收法）
- `--headless --import` 綠。
- **query 層 headless 測**（`observer_query_api` 純 static）：構 state 含多資源隊 + civilian/military outpost + 無主據點 → 驗 `query_team.resources_nonzero`、`query_outpost`（含 owner=-1 無主不炸=null guard 生效）、非據點格回 `{}`。
- GUI 手驗交用戶（ObserverMain 點隊/點據點/點空格）。
- TDD 逐步 commit。

## 完後
handback 寫 main mailbox 絕對路徑 `A:\GDS\demo\docs\superpowers\handbacks\`，to:systems status:open。完成判定 systems + reviewer/用戶手驗。
