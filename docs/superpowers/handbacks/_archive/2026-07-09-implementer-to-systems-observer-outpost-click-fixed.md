---
from: implementer
to: systems
status: consumed
topic: observer 據點點擊修完——根因=owner 駐隊佔格吞 tile_selected；team 詳情附據點段；待用戶重驗
---

# observer 據點 inspect 點擊 — 根因 + 修

worktree `feat/observer-inspect` @ `15b6de7`。

## 根因（確認，非 signal 斷）

`world_map_view.gd:274`：`tile_selected` **只在 `here.is_empty()`（該格無隊）才 emit**；否則走 `team_picked`（:283）。**多數據點被 owner 駐隊佔** → 點方塊 → 該格有隊 → `team_picked`（顯隊詳情、無據點資訊）→ `tile_selected` 永不觸 → **owned 據點無法 inspect**。正是 §順帶 spec 缺陷。

排除 signal-routing bug：team pick 走同一 `_unhandled_input`、同一 connect 機制且用戶手驗隊詳情 OK ∴ empty-tile 分支的 `tile_selected → select_tile → "此格無據點"` 必也通（同機制）。故用戶「點方塊無詳情」= 點到 owner 駐隊方塊落 team 路（舊 team 詳情不含據點），非 empty 路壞。

## 修（§順帶 修向 a：team 詳情附據點段）

`observer_inspect_panel._render_detail` team 分支：查該隊 `tile_pos` 據點，非空 → 附「─ 駐守據點 ─」段（類型/等級/擁有/駐軍/武器坊/資源）。`_outpost_lines` 抽共用（`select_tile` 直選 + team 附段）。

**兩路全覆蓋**：
- 據點上有隊（owned/駐隊）→ 點方塊=team_picked → 隊詳情**含駐守據點段**。✅ 新修
- 據點上無隊（無主 / owner 離場僅 garrison）→ 點格=empty → `tile_selected` → 據點詳情。✅ 原有
- 真空格 → `tile_selected` → 「此格無據點」。✅ 原有

未動 map input（`tile_selected` emit 條件是 world_map_view 既有語意，不擴 signal）。

## 閘
- `--headless --import` 無 error；query 測 **24/24 PASS**（query 層未動）。
- panel render 為 GUI（非 static，無法 headless 測）→ 交用戶手驗。

## 待用戶重驗
1. 點 owner 駐隊的據點方塊 → 隊詳情底部見「─ 駐守據點 ─」（誰的/多強/駐軍）。
2. 點無主據點格（若有）→ 據點詳情。
3. 點真空格 → 「此格無據點」。
4. 若 3 仍「完全無反應」（連字都不變）→ 回報，那才是 signal-routing runtime bug，我加 print 追（現判定 empty 路通）。

read-only 不動 sim。完成判定 systems + 用戶手驗。
