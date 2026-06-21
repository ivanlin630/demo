# 統一決策框架 sub-project A — 經濟定居/生產隊納統一引擎（履約脫 0）

> 承 `2026-06-21-unified-decision-engine-design.md`（sub-project 1：引擎 + 商隊切片 done, merge `9c66a7e`）。
> 本 spec = foundational arc **第二個子專案**：把經濟「生產/定居」域接上同一個 `DecisionEngine`。商隊已接；本塊讓**生產隊也走引擎**，閉經濟環。
> roadmap 來源：`handbacks/2026-06-21-session-handoff-6.md` 下一步表 row A（建議最先做）。

## 病（為何做這個）

sub-project 1 治好商隊精神分裂（TC1 震盪消失），但 **world_sim 履約仍 0%**。完整 trace 真根：

- 商隊（已走引擎）會出門巡市集、找掛單。
- **但下單的生產/定居隊還在舊 `_assign_member_tasks` / `_evaluate_solo` 流程**：被 `_can_trade` 拉去 `TASK_TRADE`（`_merchant_trade_target` 給非本地市集 tile），或 `TASK_MANUFACTURE` 的 `move_target` 飄離據點。
- 結果：賣方不在自己掛單的市集 tile → 商隊到舊位置 **撲空**（`interaction_system` 的 `_resolve_market` 要求買賣雙方 **同 tile co-location**，賣方飄走就不成交）。

= 同一個框架債的另一面：經濟有兩端，只統一了買端（商隊），賣端（生產隊）還在舊系統各自 latch → co-location 撲空 → 履約 0。

## 架構決策：最小切片（生產域接同引擎，非新引擎）

**不新增決策層**。沿用 sub-project 1 的 `DecisionEngine.decide()` / `DecisionOptions` / `DecisionTerms` / `DecisionContext`。本塊只做三件事：

1. **擴 `uses_unified`**：加 `TAG_PRODUCE`。生產隊 macro 決策改走引擎，舊生產者對 produce 隊全 skip（單一 owner，bar #1）。
2. **角色正確化 `applicable()`**：讓生產隊（有據點）原地賣，不被拉去 roam-trade。
3. **建設 bootstrap guard**：無據點生產隊能先建據點，不被困。

下單（`tick_team_orders` 自動 cadence）**不動**——它獨立於決策切片，生產隊納引擎後仍自動掛賣單。**無新「下單」option**。

### 三鐵律對映（不變）
- **bar #1 一隊一連貫決策**：produce 隊單一 owner = 引擎；舊流程全 skip。
- **bar #2 加行為=加 row**：本塊**不加新 option**（生產/建設/駐守/覓食/survival 已存在），只調 `applicable` 守衛。consolidate/faction-duty 進引擎 = sub-project B 各加 row。
- **bar #4 連貫≠同質**：權重仍 leader 人格 derive（不動 `w_term`）。
- **bar #5 講得出為何**：`decide` term 分解不變。

## 改動細節

### 1. `uses_unified` 擴 produce
`faction_ai_system.gd`：
```
func uses_unified(team: TeamData) -> bool:
    return team.tags.has(TeamData.TAG_MERCHANT) or team.tags.has(TeamData.TAG_PRODUCE)
```
- 兩條路徑皆已 gate：`_assign_member_tasks`（line ~793）+ `_evaluate_solo`（line ~1006）。加 tag 即兩路徑同時生效。
- produce 隊舊分支（`_can_manufacture`/`_can_trade`/consolidate/faction-duty）對它們不再執行（被 `if uses_unified: …; continue` 攔下）。

### 2. `applicable()` 角色正確化
`decision/options.gd`，現況守衛問題：
- **貿易**：現 `if ctx.has_goods or ctx.has_arb`。生產隊有貨就會選貿易 → 棄據點 roam → 撲空因。
  **改**：貿易 = **roam-trade，只給無自家據點隊**（商隊）。加守衛 `not ctx.has_own_outpost`（賣方原地掛單賣，不親自巡市集）。
- **建設**：現 `if ctx.has_own_outpost`（與生產/駐守同 gate）。**錯**——無據點生產隊拿不到建設 → 被困（只剩覓食/survival）。
  **改**：建設 = **無據點時可 bootstrap**（`not ctx.has_own_outpost` 或可升級），無據點生產隊 → 建設 → 取得據點 → 駐守/生產。
- **生產 / 駐守**：維持 `has_own_outpost`。

結果矩陣：
| 隊型 | has_own_outpost | 候選 option |
|---|---|---|
| 商隊（無據點） | false | 貿易 / 覓食 / survival |
| 生產隊（有據點） | true | 生產 / 建設(升級) / 駐守 / 覓食 / survival |
| 生產隊（無據點，bootstrap） | false | 建設(建據點) / 覓食 / survival |

> 註：建設守衛需細分「無據點建新」vs「有據點升級」——`applicable_options` 守衛初版可二者皆收（有/無據點都候選建設），plan 階段定形。核心是**無據點隊必有建設候選**。

### 3. `DecisionContext` 補欄位（若需）
角色守衛靠 `has_own_outpost`（已有）。**初版不需新欄位**——`has_own_outpost` + 既有 term 足夠。若 plan 發現建設 bootstrap 需「可建 tile / 有材料」判斷，再補 `can_build` 欄位（複用既有 `_find_unowned_farmable_tile` / 材料檢查）。

### 4. 下單路徑確認（不改，僅驗）
`OrderSystem.tick_team_orders`（`faction_ai_system.gd:~554`，`_assign_tasks` 內）對所有隊跑，**不在決策切片內** → produce 隊納引擎後仍自動掛賣單。驗：produce 隊原地駐守時 `_register_on_board` 成功（需 `tile.outpost_owner == team_id` 且 `team.tile_pos == 據點`，駐守保證 co-location）。

## 切片邊界 + de-risk

- **首擴 = `TAG_PRODUCE`**：經濟另一端，最小可證履約閉環。
- **非 produce/merchant 隊**（軍隊/統領/宗教…）**舊系統原封不動**（零影響）。
- **空窗（接受，等 B 補進引擎，非回舊系統）**：
  - produce 隊 small-team consolidate-merge 暫掉 → 過渡期碎隊略增。
  - produce 隊偶發 faction-duty（徵收/外交/攻擊）暫掉 → 多由軍隊/統領隊做，produce 隊影響小。
  - 兩者 sub-project B「他域遷入」各加 Option row（合併/徵收/攻擊…）補回 = 升級進統一，非修舊。

## 驗收（S6 場景當收斂條件，落地立刻跑）

- **S6 履約脫 0**：world_sim ≥1000 tick，`[Market]` 成交常態出現、訂單履約 count > 0（脫 0 即過，平衡量後續）。
- **囤糧受 cap 封頂**：糧倉硬上限仍生效（WS-1 不退化）。
- **生產隊無新震盪**：produce 隊 task 不在 生產↔貿易↔駐守 高頻跳（承諾慣性生效）；抽樣一隊 commit ≥ 數天。
- **回歸不破**：TC1/4/6/7 仍過（商隊切片不退化）、headless 全綠、coin_eq=0、InvariantAudit 0。
- **撲空降**：商隊到市集找到 co-located 賣方比率上升（量測旗，非硬閘）。

驗收套件出處：藍圖 `framework-validation-suite` handback。

## 檔案

- 改 `scripts/simulation/faction_ai_system.gd`：`uses_unified` 加 `TAG_PRODUCE`。
- 改 `scripts/simulation/decision/options.gd`：`applicable()` 貿易加 `not has_own_outpost` 守衛、建設改 bootstrap-friendly 守衛。
- 改 `scripts/simulation/decision/decision_context.gd`：若需 `can_build` 欄位（plan 定）。
- 改 `scripts/debug/headless_test.gd` + world_sim config：S6 履約場景（生產隊 + 商隊 co-located 履約測）。

## 風險 + 緩解

- **生產隊無據點又建不了 → 被困覓食/survival**：建設 bootstrap guard（無據點必有建設候選）；plan 驗無據點 produce 隊能取得據點。
- **商隊仍撲空（賣方跳 survival/forage 離場）**：survival/覓食只在糧危機高權重；承諾慣性釘住駐守。非硬閘，量測旗驗撲空率降。
- **貿易守衛改動誤傷商隊**：商隊 `has_own_outpost=false` → 貿易仍候選（守衛 `not has_own_outpost` 對商隊為 true）。TC1/TC7 回歸驗商隊不退化。
- **空窗碎隊增（consolidate 掉）**：接受，過渡期；B 補合併 option。world_sim 觀測碎隊數，異常才提前處理。
- **不碰守恆**：本塊只改決策面（task 選擇 + applicable 守衛），不碰 resources/coin/state 池 → coin_eq/InvariantAudit 無關。

## 邊界 / 非本子專案

- consolidate-merge / faction-duty（徵收/外交/攻擊/掠奪/結盟/立國/scout/鑄幣）進引擎 = sub-project B「他域遷入」。
- Pattern B 所有權 banker = 另子專案。
- 全數值 TEST VALUE；平衡（履約率/成交量/碎隊數）落地後另調。

## 開放細節（plan 階段定）

- 建設守衛形：無據點建新 vs 有據點升級 是否分兩條 applicable 分支，或合一收。
- 是否需 `can_build` context 欄位（材料/可建 tile）。
- S6 world_sim config 具體形（隊數/tag/初始據點/距離 → 確保至少一組 produce↔merchant 能履約）。
- 撲空率量測旗的具體計法（co-located 成交 / 商隊到市集次數）。
