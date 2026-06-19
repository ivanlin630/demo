# G3 情報→決策 — 系統 HOW 設計

> 配對藍圖 WHAT spec `2026-06-19-g3-info-decision-design.md`。系統解 §10 移交 HOW + seam + 子 spec 拆解。WHAT 不在此 drift。
> 走查依據（已量）：`team_intel[receiver][target]` = 單 entry；`message_system:222-224` confidence-max **覆蓋**（§3 要改的銷毀矛盾點）；11 檔讀 team_intel；`RelationGraph`(G2a)/`known_reputations` 在；已有 `inquiry_system.gd`（查狀態）。

## 0. 承重決策：schema 遷移風險（11 reader）→ accessor seam 先行

`team_intel[r][t]` single→multi-claim 是 G3 核心，但 **11 檔直讀** = 改儲存波及全部。框架債正解：**先包單一 accessor `BeliefSystem`，11 reader 全改走它（行為保留），再換儲存（藏 accessor 後）**。schema 改不波及 reader = de-risk。這是整個 G3 的 HOW 主軸。

## 1. 子 spec 拆解（依賴序）

| 子 spec | 依賴 | 範圍 |
|---|---|---|
| **G3a belief accessor seam** | 無 | `BeliefSystem.best_estimate/uncertainty/claims` 包 team_intel；遷 11 reader。**行為保留**（accessor 暫回現單值語義）。基礎 de-risk。 |
| **G3b multi-claim 儲存** | G3a | accessor 後換多 sourced claim（值/源/時效/可信度/失真,不覆蓋）；message 停覆蓋改 append；best_estimate 聚合 + uncertainty(claim 分歧)；上限/剪枝/LOD。 |
| **G3c 可信度 + 身份信任 + 技能識破** | G3b、G2a | 類型基準表×身份信任(RelationGraph `trust` 邊,動態更新)×跳數×時效；信假/生疑/裁決(技能 vs 計謀)；觀察吃技能(源頭親見也錯)。 |
| **G3d 決策讀 belief + 查證迴路** | G3b/c | 威脅/外交/攻擊/遷徙改讀 best+uncertainty；不確定→scout(vision Tier0)→親見壓謊；莽者跳過被誘殺。事件謠言(team_known)同套。 |

G3a/b 不依賴 G1d（已 merged 無妨）。RelationGraph trust 邊(G3c)依賴 G2a(merged)。

## 2. G3a — belief accessor seam（基礎）

### BeliefSystem（單一 accessor）
```
BeliefSystem.best_estimate(state, observer_id, target_id) -> Dictionary   # 現語義：回現 team_intel[obs][tgt] 單 entry（含 value/confidence/tick）
BeliefSystem.uncertainty(state, observer_id, target_id) -> float          # G3a 暫回固定(0 或 1-confidence)；G3b 換 claim 分歧
BeliefSystem.claims(state, observer_id, target_id) -> Array               # G3a 暫回 [單 entry]；G3b 換多 claim
BeliefSystem.has_belief(state, observer_id, target_id) -> bool
```
### 遷移
11 reader（faction_ai/strategic_ai/threat_assessment/diplomatic_ai/vision/interaction/player_command/player_api_mapper/sim_runner/inquiry/message）的 `state.team_intel[r][t]` 直讀 → 改 `BeliefSystem.*`。**行為保留**（accessor 回現單值）。寫入端（message_system 寫 team_intel）暫不動（G3b 改）。回歸：全綠、零行為變（reader 等價）。

## 3. G3b — multi-claim 儲存

### schema（藏 accessor 後）
`team_intel[r][t]` single dict → **`Array` of claim**：
```
{ "value": Variant, "source_id": int, "source_type": String, "tick": int,
  "credibility": float, "distorted": bool }
```
- **message 寫入改 append claim**（停 :222-224 confidence-max 覆蓋）。同 source 更新該 source 的 claim（不跨 source 覆蓋）→ 保留多源 → 可比對察矛盾。
- **真值不隨行**：失真在傳播 copy 改寫，原值不傳（既有 distort 機制，確認寫的是 copy）。
- `best_estimate` = 可信度加權聚合（或最高可信 claim）；`uncertainty` = claim 值分歧度（高分歧→高不確定）。
- **上限/LOD/剪枝**（§10 perf）：每 (r,t) cap N claim（剪最老/最低可信）；遠區/低 LOD NPC 聚合或不存（cap 每 observer 總 claim 數）。TEST VALUE。
- **事件謠言 team_known 比照**：同套 claim 模型處理事件型謠言（§3「事件謠言是主味」）→ team_known message 也走可信度/多源（G3b 對齊或 G3c/d 接）。

## 4. G3c — 可信度 + 身份信任 + 技能

### 可信度（§5 雙層×衰減）
`credibility = 類型基準(§5表) × 身份信任(source) × 跳數衰減 × 時效衰減`。
- 類型基準：親見>隊友>商旅>酒館>官方>書籍>流民（game-design 表，const）。
- **身份信任**：RelationGraph 加 **`trust` 邊型別**（G2a 縫吃新型別零核心改）；`trust(observer→source)` 動態——查證對→↑、錯/騙→↓。「這個 X 準不準」非類別。
- 跳數：既有 `strength *= 0.8`/hop；時效：tick 差衰減。
### 技能識破（§6 b3）
信假/生疑/裁決按 `我技能(偵查/計謀/戰術…) vs 對方計謀`分級（TEST VALUE 閾值）。**非單則 un-distort**（真值不隨行）；高計謀說謊家騙過多數。**觀察吃技能**：源頭 claim 正確性 = 觀察者相關技能函數（低技能親見也生錯 claim，高 confidence≠真值）。
### 身份信任更新迴路
查證（親見 Tier0）對照 claim → 對該 source 的 `trust` 邊 ±。

## 5. G3d — 決策讀 belief + 查證迴路

- 威脅/外交/攻擊目標/遷徙：從讀 `team_discovered`(可見性) → 讀 `BeliefSystem.best_estimate + uncertainty`。
- **風險調節**：個性(慎重)×不確定性 → 夠確定才動；矛盾大/沒把握 → 查證。
- **查證迴路**：不確定 → dispatch scout（復用 vision Tier0 親見）→ 真相浮現 → 動。莽者(低慎重)跳過 → 被假情報誘殺。scout 有成本（斥候被抓/餵假 = C 情報戰,OUT）。

## 6. §10 決策點對照
| §10 項 | HOW 裁定 |
|---|---|
| multi-claim schema + 上限/剪枝/LOD | G3b：claim Array，cap N/observer，剪老低可信，遠區聚合 |
| 失真模式擴充 | G3b/c：只補有 reader 的（designed:隱瞞/誇大/偏見） |
| 可信度計算 | G3c：類型×trust邊×跳數×時效 |
| 身份信任更新迴路 | G3c：RelationGraph `trust` 邊，查證對/錯回饋 |
| 技能 vs 計謀分級 | G3c：信假/生疑/裁決，TEST VALUE 閾值 |
| 查證 wiring | G3d：不確定→scout(vision Tier0) |
| 估值+不確定→風險調節 | G3d：個性×uncertainty |
| 決策接入面改讀 belief | G3d：威脅/外交/攻擊/遷徙 |
| 事件謠言同套 | G3b 對齊 team_known claim |
| 觀察吃技能 | G3c：源頭 claim 正確性=觀察技能函數 |
| trust 邊型別 | G3c：RelationGraph 加（縫吃新型別） |

## 7. invariants（隨子 spec）
- **belief 單一 accessor = `BeliefSystem`**：禁直讀 `team_intel`（多 claim 聚合/不確定性只經 accessor）。
- **真值不隨行**：失真寫傳播 copy，原 claim 不傳（資訊不對稱硬約束）。
- **多源不覆蓋**：claim 按 source 保留，禁 confidence-max 跨源覆蓋（否則矛盾無從察）。
- **trust 邊經 RelationGraph**：身份信任是 `trust` 型別邊，動態更新走查證迴路。
- **決策讀 belief 非 team_discovered**：威脅/外交/攻擊/遷徙讀 BeliefSystem（team_discovered 僅可見性,不作真值）。

## 8. 回歸閘（承藍圖 §11）
headless 1000+ tick 無錯 + coin_eq=0；行為可見：誘殺案例/慎重者查證/高技能識破/矛盾觸發 scout/線人信用漲跌。守恆不破。不用 multi drift。

## 9. 建議起手
**G3a accessor seam 先**（11 reader 遷移、行為保留、de-risk schema）→ G3b multi-claim（換儲存）→ G3c 可信度/信任/技能 → G3d 決策/查證。inquiry_system 現狀先查（§2 主動獲取 OUT，確認它沒搶跑）。
