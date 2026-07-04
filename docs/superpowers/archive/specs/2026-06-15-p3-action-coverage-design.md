# P3 全動作覆蓋 — Design

> 日期：2026-06-15
> 議題：UI 動作覆蓋審計（registered actions vs 玩家可達路徑）。比對 `player_command_system` registry 與 text_ui 可達性（hardcode literal + `_build_available_actions` 動態選單 + 面板）後，找出 **6 個 registered + NPC 在用、但玩家無 UI 路徑** 的孤兒動作。本 spec 補齊，達成對稱性（玩家能做 NPC 能做的）。

## 審計結果

排除假陽性：`refresh_targets`（零 caller，死碼，本 spec 不碰）、`respond_aid_request`（走 forced_interaction 自動進場路徑，已可達）。

真孤兒 6 個：

| 動作 | 缺口 | 後端（已存在） | 歸群 |
|---|---|---|---|
| `deposit_to_storage` | 玩家無法把資源存腳下公庫 | 讀 `storage_res`/`storage_amount`，gate `tile.outpost_owner==pt_id`，cap 經 `OutpostSystem._get_storage_cap` | A 公庫面板 |
| `withdraw_from_storage` | 玩家無法從公庫取回 | 同上反向 | A 公庫面板 |
| `build_facility` | outpost 蓋設施 | `_action_build_facility`（outpost-context） | B outpost 面板 |
| `abandon_outpost` | 棄前哨（別於 demolish） | `_action_abandon_outpost`（pt 自家 outpost） | B outpost 面板 |
| `invite_settle` | 邀居民團定居 outpost | `_action_invite_settle(target_id)`（team-target） | D get_available_actions emit |
| `extract_treasury` | faction 國庫提幣到本隊 | 讀 `extract_ratio`(0,1]，呼 `FactionAISystem._extract_treasury` | C faction 面板 |
| `recruit_anon` | 招目標隊匿名人口（`recruit`=招募，變體） | `_action_recruit_anon(target_id)`（team-target） | D get_available_actions emit |

## 設計核心（分層乾淨，守 UI 邊界 — 同 trade/B4）

**所有動作邏輯在 API/sim 層（後端 6 個全現成，本 spec 不改後端邏輯）；UI 只渲染 DTO + 經 bridge 送 command。** 對稱性：全是 NPC 已用機制補玩家路徑，無玩家專屬。

## 不變量

- **UI 只經 player API**：面板讀 query DTO + 送 execute_action command，零直存 WorldState、零邏輯。
- **守恆**：deposit/withdraw、extract_treasury 皆既有雙向轉移，不憑空生滅。整合測 coin_eq/food 守恆。
- **公庫 gate**：deposit/withdraw 僅 `tile.outpost_owner == 玩家隊`（後端既有 gate）→ 面板 feasible 須反映此。
- **team-target gate**：invite_settle/recruit_anon 為對目標隊動作，沿用同格可見目標（既有互動前提）。

## A. 公庫面板（新，最高頻）

生存迴路核心：玩家現在連把食物丟自家公庫都做不到。

**DTO** `map_storage_panel(state)`（新 mapper + `query_storage_panel` + bridge facade）：
```
{
  "feasible": bool,            # 玩家隊在自家 outpost tile 上
  "reason": String,           # 不可用原因（非自家 outpost）
  "stored": [{res, qty, cap}], # 公庫現況 + 各 res 容量
  "team_res": [{res, qty}],   # 我方隊可存資源（BASE_PRICE 項 + food/material 等）
}
```
- `cap` 經 `OutpostSystem._get_storage_cap(tile, res)`（需公開存取或 mapper 內 new 一個 OutpostSystem 呼叫；同 _local_value 模式）。
- feasible = 腳下 tile 存在且 `outpost_owner == 玩家隊`。

**UI 新 mode**（鍵 `[G]倉`，加 MODE_KEYMAP + 頂層入口）：
- 兩欄：「存入（我方→公庫）」列我方 res `[n] res ×qty`；「取出（公庫→我方）」列公庫 res `[n] res ×qty/cap`。
- 選項 → 數量輸入（沿用 `_input_mode` numeric）→ 設 `set_player_input("storage_res", res)` + `set_player_input("storage_amount", qty)` → 送 `deposit_to_storage` 或 `withdraw_from_storage`。
- 分頁沿用既有 `_*_page` 模式（res 種類多時）。
- `[Esc]` 離開。feedback 用 `_set_feedback`。

## B. outpost 面板擴（既有面板加列）

`map_outpost_panel` 已存在、`_handle_outpost_mode`/`_build_outpost_str` 已存在（現有 upgrade_farming/manufacturing/upgrade_outpost/demolish_outpost 列）。加 2 列：
- `build_facility`（蓋設施）— 若需選設施類型，沿用數量/選項輸入；否則單鍵送出。
- `abandon_outpost`（棄前哨）— 單鍵，**破壞性**→ 送出前面板顯確認提示（二次按鍵）。

DTO 加這 2 動作可用性旗標（feasible/reason，依後端條件）；handler 加對應鍵。

## C. faction 面板擴（既有面板加列）

`map_faction_panel`/`_handle_faction_mode`/`_build_faction_str` 已存在。加 1 列：
- `extract_treasury`（國庫提幣）— 選項 → 比例輸入（0,1] → `set_player_input("extract_ratio", r)` → 送 `extract_treasury`。
- 僅 faction leader 可見（依後端權限；DTO feasible 反映）。

## D. team-target 動作 → `get_available_actions` emit（最小）

`PlayerCommandSystem.get_available_actions(state, target_id)` 現回 `[ignore, attack, trade?, propose_alliance?, demand_tribute?, extort?, recruit?, gather_intel]`。加兩條件 emit：
- `recruit_anon`：coin ≥ 成本 且目標有匿名人口可招（依 `_recruit_anon_internal` 前提）時 append。**注意與 `recruit` 區別**：label 需分明（如「招募匿名」vs「招募」），避免玩家混淆 — 二者並列時於 `_action_label` 已有區分（recruit=招募/recruit_anon=招募匿名）。
- `invite_settle`：目標為可定居居民團 且玩家擁有當地 outpost 時 append。

自動經既有 `_build_available_actions` Layer 4（team_actions 迴圈）surface 到互動選單 → 零新 UI。

## 風險

- **公庫 cap 存取**：`OutpostSystem._get_storage_cap` 私有 → 加公開 wrapper（同 `local_value` 模式）供 DTO。
- **abandon vs demolish 混淆**：兩者並存於 outpost 面板，label/提示須分明（abandon=棄置保留地物？demolish=拆除）；確認後端語意差異後寫清 label。
- **破壞性確認**：abandon_outpost / extract_treasury(高比例) 加二次確認，防誤觸。
- **recruit_anon/recruit 並列**：互動選單同時出現須 label 清楚，避免玩家不知差異。
- **守恆**：deposit→withdraw 來回 coin_eq=0；extract_treasury 國庫減==隊增。整合測驗。
- **UI 邊界**：全經 DTO/command，零直存。
- **範圍/YAGNI**：不重排面板版面，只加列；公庫面板可獨立小面板，不塞進 outpost 面板（職責分離）。

## 測試

- A 公庫：headless `map_storage_panel` DTO（自家 outpost feasible+stored/team_res；非自家 not_feasible）；deposit→withdraw 守恆（coin_eq/food delta=0）；ui_flow 進倉→存→取→feedback。
- B outpost：ui_flow 進 outpost 面板→build_facility/abandon 列可見→送→feedback；abandon 二次確認。
- C faction：ui_flow extract_treasury 比例輸入→送→國庫減隊增。
- D：headless `get_available_actions` 對合格目標含 recruit_anon/invite_settle；ui_flow 互動選單可見可選。
- 全跑 headless/ui_logic/ui_flow 無新 SCRIPT ERROR、新測綠。

## 分群實作順序（plan）

1. **A 公庫面板**（最高頻、全新、最大塊）
2. **D get_available_actions emit**（最小、零 UI）
3. **B outpost 面板擴**
4. **C faction 面板擴**

後端全備 → 不分 phase，單一 plan 多 task。
