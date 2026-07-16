# Spec：wave2 序6 — faction member dispatch 溶入引擎（擴 uses_unified）

> arc wave2 主幹（audit 標「高收斂動主幹」）。承融合模式。**溶=融合非刪**。北極星：faction 成員決策=遭遇/決策統一評估的收斂主軸。系統 owner。

## 1. 目標
**現況違憲**（constitution-audit 序6）：`_assign_member_tasks`（fai:1434-1465）goal→固定 task **if/elif 判斷器** prescribe 成員行為（含 V2-cmd：`if 徵收` 嚴格支配 `elif 攻擊` → 攻擊-eligible 成員恆死）。

**目標**：擴 `uses_unified` 全隊（非 subteam）→ **faction 成員走 `_decide_unified`（引擎 rank_scored 競秤）** 取代 if/elif hand-dispatch。faction goal→engine 橋**已建**（只待全隊走）。**副產物**：V2-cmd 自消 + 成員打草穀 raid 接回（序5 待項）+ 框架債縫#3 結清。

**scope**：序6=**成員** dispatch（`_assign_member_tasks`）。**leader dispatch**（`_assign_tasks` 1350-1382，含 立國/subteam-tribute 特殊語意）→ **序6b defer**（系統裁：leader 特殊語意分開拆，序6 專注成員=最大 win 最低額外風險）。`_update_goals`（faction 策略→goal→`faction_stakes`）**保留**=引擎 ctx 輸入（合憲「intent 作 ctx 輸入」）。

## 2. 現 repertoire（融合驗錨）
non-unified 成員 goal cascade（fai:1434-1465，嚴格 if/elif）：
| # | 條件 | task |
|---|---|---|
| if | 徵收∈goals & tag_weight(徵收)>0 | TASK_TRIBUTE（richest member）|
| elif | 外交∈goals & tag_weight>0 | TASK_DIPLOMACY |
| elif | 攻擊∈goals & tag_weight>0 | TASK_ATTACK（nearest indep）|
| elif | _can_manufacture | TASK_MANUFACTURE |
| elif | _can_trade | TASK_TRADE |
+ 前置：consolidate MERGE（_find_absorber/近 leader 攻擊 goal）、survival skip。

**engine 對應（已建）**：徵收 option（faction_duty+levy_drive）、外交（faction_duty+diplo_drive）、攻擊（faction_duty+attack_drive+intent_fit+feud_pull）、生產（produce_need）、貿易（economic_opp）、**掠奪（loot_drive+has_weak_prey=成員 raid 接回）**。applicable 吃 `faction_stakes`（STAKES_SET={攻擊,徵收,外交}，dc:180-197）。

## 3. 設計
### 3a. ★成員 dispatch gate 改（非動全域 uses_unified）
**陷阱**：`uses_unified` 不只 gate 成員 dispatch，也 gate `_evaluate_threat` skip / `_evaluate_solo` route / survival gate。**preempt scaffolding（序3.5）活在 `_evaluate_threat`（`if uses_unified: return` skip）**——若擴全域 uses_unified，_evaluate_threat 對全隊 skip → **序3.5 忙碌目標 preempt 被繞過=反龜縮 seam 又斷**；survival/solo scaffolding 同理。

**修正設計**：只改**成員 dispatch 路由**，不動全域 `uses_unified`（threat/preempt/survival skip 保 MERCHANT/PRODUCE）。`_assign_member_tasks:1394` 的 gate：
```gdscript
# 原：if uses_unified(mt): _decide_unified; continue
# 改：全非-subteam 成員走引擎 macro 決策（tag 只影響 weight 非路徑）
if mt.parent_team_id == -1:   # 非 subteam（subteam 走 loop2 _evaluate_subteam）
    _decide_unified(state, mt); continue
```
（or 加 `member_dispatch_unified(mt) = parent_team_id==-1` 命名 helper。）
- **結果**：成員拿 **macro 走引擎主 rank**（徵收/攻擊/掠奪/生產/貿易/生存 競秤）**+ threat/preempt/survival 走 loop3 scaffolding（保，uses_unified 未動）**。輕微冗餘（loop3 survival/threat 對 idle 成員可能重評，但成員 macro 已由 _decide_unified 設 task→多非 idle→loop3 只 preempt/stuck 觸發=正是要的）。**不破序3.5 preempt/序1-2 scaffolding。**
- **subteam 排除**：`parent_team_id==-1` guard 內建（防 subteam 雙寫，現缺）。

### 3b. 刪 _assign_member_tasks 成員 cascade
`uses_unified` 擴全隊後，`_assign_member_tasks` 的 non-unified 分支（1405-1465，含 consolidate + if/elif goal cascade）→ 全成員走 1394 `_decide_unified continue`。刪死碼分支。consolidate MERGE（1410-1433）語意保留評估：MERGE 是否成 engine option or scaffolding？→ **MERGE=faction 整併機制（小隊併大隊）非個體決策**，保為 scaffolding（dispatch 前置，like survival sticky）；或 `_find_absorber` 命中時 pre-empt engine（記錄實作）。

### 3c. V2-cmd 自消（驗證非改碼）
`rank_scored_ctx` argmax（engine:19-33）對 applicable 全 option 算 util sort → 徵收/攻擊 競秤（faction_duty 同 DRIVE，差 levy_drive vs attack_drive+intent_fit 人格染）→ 攻擊-eligible 成員不再被徵收無條件支配。**融合驗證此結構消解**（有 {徵收,攻擊} 雙 goal + 好戰成員 → 攻擊可勝）。

### 3d. 成員 raid 接回（驗證）
成員走主 rank → 掠奪 option（applicable=has_weak_prey，term loot_drive×cap）自然競秤 → 見弱 prey 選掠奪 = 打草穀，無需 loop3 cascade。**框架債縫#3 結清**（成員不再靠 hand-dispatch/loop3-idle-gate；主 rank 每 cadence 重評）。

### 3e. probe 遷移
`conq.member_atk_eligible/dispatch`（1449/1454，hand-dispatch）→ 成員走引擎後恆 0 → 遷至引擎 `conq.*`/`_probe_conq_winner`。`trade.dispatch.member_trade`（1465）→ `trade.dispatch.unified_貿易`。徵收 tribute 補 probe（現無專屬）供驗魂。實作對齊 framework S1-S3（用 leader/獨立 fixture，不依賴成員 hand-dispatch → 不破）。

## 4. 融合驗（`faction_dispatch_dissolution_check.gd`）
- **repertoire 沒少**：faction 成員（各 goal 情境）→ rank_scored 出對應：徵收 goal+貪婪成員→徵收；攻擊 goal+好戰成員→攻擊；外交 goal→外交；生產/貿易 tag→本業；**弱 prey 在場→掠奪（raid 接回）**。
- **★V2-cmd 解**：faction {徵收,攻擊} 雙 goal + 好戰成員 → 攻擊**可勝**（非恆被徵收支配）。
- **★成員 raid**：faction 成員 + 弱 prey → 掠奪 dispatch（打草穀活）。
- **無雙寫**：subteam 只走 loop2 `_evaluate_subteam`，不入 `_decide_unified`（`parent_team_id==-1` guard 驗）。
- **★序3.5 preempt 不破**（最高盯點）：成員 macro 走引擎但 `uses_unified` 未動 → 成員仍走 loop3 `_evaluate_threat` 非-unified 路 → **忙碌成員遇壓境攻擊仍 preempt 反應**（threat_preempt_check 驗成員亦適用）。反龜縮 seam 保。
- **無 loop3 macro 衝突**：成員 macro 由 loop1 `_decide_unified` 設 → loop3 survival/threat 對其多非 idle → 只 preempt/stuck 觸發（scaffolding），不與 macro 打架。驗成員被 _decide_unified 派 task 後 loop3 不亂覆蓋。
- **既有融合驗不破**：threat/solo/rung/vendetta/preempt/prosperity 全綠。framework PASS=7（S1-S6 souls，尤 S1 立國/S2 feud/S3 scout 不 DORMANT）。
- **回歸**：seeded（漂移允許 QA wave；成員 raid 接回+V2-cmd 解→征服/掠奪分佈變，據此 gen 重校=序6 後完整圖）+ 憲法閘。

## 5. 憲法閘 baseline
`_assign_member_tasks` 的 try_set（TRIBUTE/DIPLOMACY/ATTACK/MANUFACTURE/TRADE dispatch）刪 → 指紋 `faction_ai_system.gd::_assign_member_tasks` 若消（其 try_set 全刪）=removed=arc 進度。`_decide_unified` try_set 已在 baseline。實作跑閘定 removed/add，同 commit 更新 baseline 標 `# 序6 dispatch`。

## 6. ★de-risk 分階（系統 HOW）
- **Phase1**：改成員 dispatch gate（`parent_team_id==-1`→`_decide_unified`，不動全域 uses_unified）+ 刪成員 cascade → 驗成員路（repertoire/V2-cmd 解/raid 接回）+ **★驗序3.5 preempt 對成員仍活**（忙碌成員 preempt）+ 無 loop3 macro 衝突。
- **Phase2**：probe 遷移 + framework/harness 更新 + 憲法閘 baseline + 全回歸（threat/solo/rung/vendetta/preempt/prosperity 全綠）。
（分層設計[成員 dispatch gate ≠ 全域 uses_unified]已避開全隊化破 scaffolding 的坑；若仍揭冗餘/衝突→呈報。）

## 7. 待藍圖 / 後序
- **無新 WHAT 待裁**（faction goal→engine 橋已建，語意同構）。gen 重校=序6 後完整征服圖（藍圖 seq5-judgment：等成員 raid 接回對完整圖調）。B 照妖鏡：新閾殘全域者標 B-債。
- **leader dispatch（序6b）**：`_assign_tasks` leader 路（立國/subteam-tribute/direct 攻擊掠奪）→ 引擎，特殊語意（立國=state change 非 task、subteam-tribute=faction 機制）分開拆。
- spec → plan（de-risk 分階，融合驗+全隊化不破 first）→ 子 session。序6 綠 → gen 重校 follow-up → 序7 ReactionSystem（最大最難）。
