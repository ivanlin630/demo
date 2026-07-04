# 絕境驅動多元生存行為 — Design

> 日期：2026-06-14
> 議題：狩獵唯一 subsistence + 村修 後量測隔離出真因 — 玩家流民隊（team0，求生欲 0.9 / 義氣 0.4，不兇不義）**餓死在富足村旁卻從不投靠/定居**（Settle/投靠 = 0）。根因：`_trigger_survival` 的選項是**個性閘**（殘忍/好戰→掠奪、義氣+信義>1.2→投靠），不夠兇也不夠義氣的求生型流民**沒有任何活路** → 只剩狩獵/乞討 → 餵不飽成隊（狩獵不隨人數放大）→ 餓死。且「定居/紮營」根本不在 survival 選單。
>
> 用戶要求：流浪者行為**多元**（如既有 AI 的掠奪/乞討），投靠只是其一。本 spec 把 survival cascade 從「個性閘」改「**絕境放寬閘 × 個性偏好**」+ 補紮營選項。

## 設計核心

- **觸發門檻不動**：survival 仍只在剩糧 `< WARNING_DAYS(3)` 觸發、`< URGENCY_DAYS(1)` 為 urgent（既有）。有產出/緩衝高的正常 team 永不誤觸（糧天數一直高）。**本 spec 不放寬觸發，只改觸發後的選項邏輯。**
- **雙軸**：**desperation（warning/urgent，既有兩級）調選單寬度**；**values 調偏好排序**（先試哪個）。
- **warning（1–3 天）= 個性主導**：依 values 偏好試對應選項（≈現狀，但補紮營）。
- **urgent（<1 天）= 解閘人人有活路**：個性門檻（兇/義氣）下放近 0，全選單開（高傲也投靠、膽小也搶、求生欲驅動紮營/投靠），values 只決定**先試順序**。解 team0 餓死。
- **新增「紮營」選項**：野心/獨立 + 鄰近無主可農地 → 認領建 crude camp（civilian L1，極低成本）→ 開始 collect → 止流浪。
- **圖利掠奪不動**：`_evaluate_prosperity_attack`（野心/貪婪/好戰，idle 即評，無 faction/糧況閘）獨立並存 — 流浪盜匪不餓也劫掠，照舊。本 spec 只動**求生**掠奪的閘。

## 不變量

- **觸發不放寬**：survival 進入條件維持 `days_left < WARNING_DAYS`；正常/有產出 team 不因本 spec 進求生流程。
- **每個求生 task 有釋放**：紮營/投靠/掠奪/乞討/狩獵 釋放走既有 `_evaluate_survival` hysteresis（糧恢復 ≥ `SURVIVAL_RECOVER_DAYS` 脫離），防 latch（W5 教訓）。
- **紮營守恆**：認領**無主**（outpost_owner==-1）tile；建材本地（施工團自身，極低/0），不憑空、不動他人資產（遵 invariants 建造守恆）。
- **對稱**：NPC 與玩家走同一 cascade（玩家求生由玩家決策，但 AI 邏輯同源）。
- **圖利掠奪獨立**：prosperity-attack 路徑不受 desperation 設計限制。

## 1. desperation × values cascade 重構

`_trigger_survival(state, team, severity)`（severity = "warning"/"urgent"，既有傳入）改為：

```gdscript
# 既有前置（不動）：正在蓋農田不中斷；有 own outpost → 回家（Path 1）
# 以下為「無 own outpost / 無法回家」的求生分流，改 desperation × values：

# 計算個性偏好分數（每選項一個 0~1 傾向，由 values 算）
#   loot_pref   = f(殘忍, 好戰, 貪婪)
#   join_pref   = f(義氣, 信義, 求生欲)        # 慕強/合群 → 投靠
#   camp_pref   = f(野心, 求生欲, 統領)         # 獨立自立 → 紮營
#   beg_pref    = f(求生欲) - 兜底永遠可乞
#   hunt 隨時可墊（腳下/鄰格有 game）

# 門檻：warning 用個性門檻（現值）；urgent 門檻近 0（解閘）
var gate_mult: float = 1.0 if severity == "warning" else 0.0   # urgent 解閘

# 依 pref 由高到低嘗試，每項檢查「可行性 + (門檻 × gate_mult)」：
#   loot : 有 prey + loot_pref > LOOT_GATE×gate_mult
#   join : 有可投靠鄰村/勢力 + join_pref > JOIN_GATE×gate_mult
#   camp : 有無主可農鄰地 + camp_pref > CAMP_GATE×gate_mult
#   hunt : 有 wild_game（不受 gate；隨時墊）
#   beg  : 有施主（兜底）
# 第一個通過的 → TaskArbiter.try_set(..., PRIO_SURVIVAL)；全失敗 → release idle（既有）
```

關鍵：**urgent 時 gate_mult=0 → 所有 pref>0 的選項都可行**（人人有活路）；values 仍決定**嘗試順序** → emergent 多元。warning 維持個性門檻（兇者才搶、義氣才投靠）。

> 數值（各 *_GATE、pref 公式權重）= TEST VALUE，量測 tune。

## 2. 紮營（squat-settle）新選項

求生 cascade 內，`camp` 分支：

```gdscript
# 找鄰近無主（outpost_owner==-1）可農 tile（plains/forest，避 mountain）
# 設 TASK 赴該地；到達後（interaction/arrival）建 crude camp：
#   tile.outpost_type="civilian"; outpost_level=1; outpost_owner=team_id
#   建材：施工團自身（極低成本 TEST VALUE，反映流民搭棚）；無則仍可立（求生豁免，crude）
#   tile_food_init 小（種子糧）+ resource_cap 同抬（沿用 tile_food_init bug 修）
# 之後該團 collect_resources 走 outpost 路徑（脫離無據點狩獵）→ 止流浪
```

效果：野心/獨立的流民絕境時自建據點 → 從遊牧獵人轉定居 → 後續可走 W4 develop。

> 防濫建：gated by camp_pref（野心/獨立）+ 無主可農地 + survival 觸發（<3 天）。一般充足 team 不觸發 → 不會遍地建村。量測觀察建村率。

## 3. 既有選項對齊

- **掠奪**（survival）：Path 2 邏輯併入 cascade 的 loot 分支，門檻改 `LOOT_GATE×gate_mult`。
- **投靠**：原 `義氣+信義>1.2` 改 `join_pref > JOIN_GATE×gate_mult`，urgent 解閘。
- **乞討**：兜底（pref 永>0），但仍需施主存在。
- **狩獵**：Path 3.5（找 wild_game 格）保留，作隨時可墊的食物源（不受 gate）。

## 風險（給實作者）

- **勿膨脹成戰略引擎**：全在 `_trigger_survival` 重構 + 一個 camp-build helper。pref 公式用簡單 values 線性組合，非多層決策樹。
- **觸發不可放寬**：嚴守 `days_left < WARNING_DAYS` 才進；測試須含「正常高糧 team 不觸發 survival」。
- **紮營濫建/守恆**：建村率量測；建材守恆（本地/0，認領無主地）；coin_eq delta=0。
- **latch**：新選項全須走既有釋放（糧恢復脫離），勿造永久 sticky（W5）。
- **數值全 TEST VALUE**：跑 2 年 multi 量測 — 重點：team0-like 求生型流民有活路（不餓死）、行為分佈多元（loot/join/camp/beg/hunt 都出現）、正常 team 不誤觸、建村率合理、守恆 0。
- **injury/medicine 不併入**（狩獵受傷 → 醫療需求為另案，避免本 spec 膨脹）。

## 測試

- 單元：求生型流民（不兇不義，warning）依 pref 選到可行選項；urgent 解閘（高傲隊也能投靠、無 prey 無施主時紮營）；正常高糧 team 不觸發 survival；紮營建 crude camp（無主可農地、守恆）；各選項糧恢復釋放。
- 整合：`game_sim_multi` 3 config × 2 年 — survival_start team0 不餓死（有活路）、行為分佈多元（grep loot/join/camp/beg）、正常 team 無誤觸、建村率合理、coin_eq delta=0、無新增 SCRIPT ERROR。
