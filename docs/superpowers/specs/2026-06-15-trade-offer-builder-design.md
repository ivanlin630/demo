# 物物交換 offer-builder 交易介面 — Design

> 日期：2026-06-15
> 議題：玩測 U12 — 玩家要的不是 auto-trade（系統自動算互補轉移），而是**互動交易介面：出價 / 買 / 賣**。sim 已有 offer-based 後端（`submit_trade_offer({player_gives, player_wants})` + `_local_value` 估值 + `_execute_transfer` 轉移），**缺的是「建 offer 的 UI」+ 暴露雙方清單/估值的 DTO**。
>
> 建物物交換 offer-builder：選「我給」(貨/幣) + 「我要」(貨/幣) + 數量 → 即時公平天平 + NPC 接受預估 → 送出 → accept/reject。買=給幣要貨、賣=給貨要幣、以物易物=貨換貨，**同一介面三用**。

## 設計核心（分層乾淨，守 UI 邊界）

| 層 | 內容 | 狀態 |
|---|---|---|
| **API/sim（UI-agnostic 契約）** | §1 `get_trade_session` DTO（雙方可交易清單 + 每項估值 + 當前 offer 公平度）；§3 後端 `submit_trade_offer`/`_local_value`/`_execute_transfer` | DTO 新增；後端**已存在** |
| **UI（text_ui）** | §2 offer-builder 渲染 + 輸入（選 item/qty、顯天平、送出） | 新增 |

**所有交易邏輯（估值/公平/轉移）在 API/sim 層；UI 只渲染 DTO + 經 bridge 送 command。** 未來換圖形 UI reuse API/sim 不動。

## 不變量

- **同格才交易**：trade 須 `player.tile_pos == target.tile_pos`（invariants，既有 gate）。
- **UI 只經 player API**：offer-builder 讀 `get_trade_session` DTO + 送 `submit_trade_offer` command，**不直存 WorldState、零交易邏輯**。
- **守恆**：交易 = 雙向轉移（既有 `_execute_transfer`），不憑空生滅；coin 不新增。
- **NPC accept/reject（不 counter）**：玩家送 offer → NPC 接受或拒絕；要調就改 offer 再送（YAGNI，無議價往返）。

## 1. API 層：`get_trade_session` DTO（`player_query_api` / `mapper`）

新 query `get_trade_session(state, target_id)` → DTO：
```
{
  "feasible": bool,              # 同格 + target 可交易
  "player_items": [{grade, qty, unit_value}],   # 玩家可給（resources 中可交易項）
  "target_items": [{grade, qty, unit_value}],   # NPC 可給（target resources）
  "offer": { "gives": {grade:qty}, "wants": {grade:qty} },  # 當前建構中 offer（從 player_state 回讀）
  "give_value": float, "want_value": float,     # 天平兩端（Σ unit_value × qty）
  "npc_would_accept": bool,      # 用 NPC offer 評估邏輯預估
}
```
- **估值沿用既有供需定價（不新增機制）**：`unit_value = InteractionSystem._local_value(team, grade)` = `BASE_PRICE × (1 + 供需比)` → 通膨/通縮 = per-team 稀缺度 emergent（囤積壓價/稀缺抬價）。
- **whose value（明確）**：
  - `player_items[].unit_value` = **玩家隊** `_local_value`（玩家視角）；`target_items[].unit_value` = **NPC** `_local_value`。
  - `npc_would_accept` / 公平判定 = 用 **NPC 的** `_local_value`（NPC 按自身稀缺度決定收不收）。
  - 兩邊值並列 → 玩家看到「兩地供需差 = 套利空間」（把你富的賣給缺它的隊）。
- `npc_would_accept` = 跑既有 offer 評估抽成的純函數（見風險：與 submit 同一真相）。
- 可交易項 = `InteractionSystem.BASE_PRICE.keys()` ∩ team.resources（有量者）+ coin。

## 2. UI 層：offer-builder（`text_ui_main` 交易模式）

`_build_trade_str` 改為 offer-builder（讀 `get_trade_session` DTO）：
- 兩欄：**我給**（player_items + 當前 gives）/ **我要**（target_items + 當前 wants），各列 `[n] grade ×qty (值V)`。
- 輸入：選一項 → 數字輸入 qty → 加進 `player_state.trade_offer.gives`/`wants`（依在哪欄）。
- 顯**天平**：`給 ΣV  ⇄  要 ΣV` + `NPC 預估：✓接受 / ✗拒絕`。
- `[Enter]` 送 `submit_trade_offer`（既有）→ feedback accept/reject；`[C]` 清 offer；`[Esc]` 離開。
- 分頁沿用 `_interact_page` 模式（清單可能 >9）。

買賣以此達成：要 coin 項=賣、給 coin 項=買、貨對貨=以物易物。

## 3. sim 後端（reuse，不動）

`submit_trade_offer(state, target_id, {player_gives, player_wants})`：NPC 評估（`_local_value` 比值 + 個性）→ accept 則 `_execute_transfer` 雙向轉移、reject 則回拒。**本 spec 不改**；僅確認其 NPC 接受判定可被 §1 `npc_would_accept` 預估複用（抽純函數或共用門檻）。

## 風險

- **NPC 接受判定複用**：`get_trade_session.npc_would_accept` 需與 `submit_trade_offer` 實際接受邏輯一致（否則預估騙人）。實作：抽 `InteractionSystem.evaluate_offer(state, from, to, gives, wants) -> bool` 純函數，DTO 預估與 submit 都呼它（單一真相）。
- **可交易項白名單**：限 `BASE_PRICE` 有定價的資源 + coin（無價資源不可交易，避免估值 0 漏洞）。
- **UI 邊界**：offer-builder 零交易邏輯，全經 DTO/command。
- **守恆**：`_execute_transfer` 既有雙向；新增不碰。整合測跑 coin_eq=0。
- **範圍**：主要 UI + DTO，後端已備 → 不分 phase。offer 清單 >9 用既有分頁。
- **counter-offer / 多輪議價**：不做（YAGNI）。

## 測試

- API：`get_trade_session` headless — 同格回 feasible+雙方清單+估值；非同格 not_feasible；offer 公平度 give/want_value 正確；`npc_would_accept` 與 `submit_trade_offer` 結果一致（同一純函數）。
- UI flow（ui_flow harness）：注入同格 NPC+貨 → 建 offer（加 gives/wants）→ trade str 顯天平 + 接受預估 → submit → accept/reject feedback。
- 整合：交易後 coin_eq delta=0（守恆）。
