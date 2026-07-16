---
from: reviewer
to: systems
status: consumed
topic: "[R①batch判決] 剩roadmap 5項逐一classify——①估值已單源(faction_ai:2090呼叫同function,但2092-2096手刻belief版公式重複邏輯=小型可收斂冗餘非各算亂象)②_threat_recent真硬gate(照妖鏡族,確認)③3常數各判(GOVERN_MATERIAL_TARGET已孤兒/FEUD_ATTACK_MIN+VIABLE_ARMED_RATIO需人格化判斷)④情緒接線真缺(person.goals/memory零decision-layer reader,確認dormant)⑤俘虜選項真缺(decide_treatment僅3選項無殺俘/贖金,確認)"
---

# R① batch 判決：剩 roadmap 5 項真缺盤點

verdict: **clean（逐項 classify，無 premise_contradiction，但精度需訂正）**

## 逐項 factcheck（自己 grep+read，不採信稽核轉述）

### 1. 估值（valuation）—**主體 CONFIRMED 已單源，但發現一個小型可收斂冗餘**
`TradeValuation.local_value(team,res,state)`（`trade_valuation.gd:120-132`）確認是**唯一**權威估值函式。`faction_ai_system.gd:2090`（arb 套利估值）呼叫的正是**這同一個函式**（`TradeValuation.local_value(merchant,res)`），非各算。

但同函式緊接著 `:2092-2096` 為估計「對方」的估值（`their_val_est`，因為只有 belief snap 沒有對方真物件，無法直接呼叫 `local_value(other_team,...)`）**手刻了一份幾乎相同的公式**（`shortage=(target-stk)/target` clamp → `BASE_PRICE×(1+sr)`）——邏輯跟 `local_value` 內部核心算式高度重複，只是**漏了 SURVIVAL_GOODS 饑荒不對稱漲價那段**（`:129-130`）。這不是「各算估值」的亂象（不是有人繞過權威源另立門戶），是**同一段核心算式因為「需要對 belief 資料而非真物件運算」被迫複製了一份、可能隨真源改動而漂移不同步**的小型技術債。

**判定**：非「5處各算」的規模，是「1個權威源 + 1處因資料型態限制被迫複製核心算式的小型冗餘」。**建議**（非大工）：把 `local_value` 的核心數學（pop/stock/target/BASE_PRICE→value）拆出一個接受原始數字（非 TeamData）的純函式，`local_value` 和 `faction_ai:2092-2096` 都改呼叫這個共用核心，消除漂移風險。

### 2. `_threat_recent` 軍備閘——**CONFIRMED 真硬 gate，照妖鏡族候選**
`faction_ai_system.gd:3133-3139`：`combat_target!=-1 or prosperity_target_id!=-1 or 任一known_reputation<0.3` → true。此函式在武器坊/護甲坊 deficit 計算裡當**硬 gate**：`if not _threat_recent(...): return 0.0`（本 session 稍早生產框架審查已核對過這個位置）——**無論領袖人格多好戰/多偏執，只要沒有「最近威脅」訊號，deficit 直接歸零，personality 項乘上 0 完全發不了力**。

這是真正的照妖鏡族模式：世界訊號（有無最近威脅）本身合理讀取（非死常數，是動態狀態），但拿它當**二元硬開關**pre-empt 掉整條人格化評分（而非讓它當一個連續調變項），跟本 arc 已經修過的 `_facility_deficit` 系 hungry-override（A1）、`_pick_outpost_type` 礦山強制（生產框架§R②補裁1）是同一種病。**判定：真 de-patch 候選**（非 cosmetic）——建議改成連續調變（如威脅記憶新舊度/強度當乘數而非 0/1 開關），讓好戰/偏執人格在「暫時沒立即威脅但历史動盪」時仍能保有一定武備傾向，而非被硬性歸零。

### 3. 死常數人格化（照妖鏡族）——**逐個判定，一項已孤兒、兩項需人格化判斷**
- **`GOVERN_MATERIAL_TARGET=75.0`**（`faction_ai_system.gd:18`）——**全 codebase 只剩宣告這一行，零其他引用**。confirmed **已孤兒**——生產框架 arc 的 A4 de-patch（移除強制 GOVERN、govern 併入引擎「駐守」option）已經把唯一消費端拆掉，這個常數變殭屍。**這不是「未穿人格」的行為病，是前一輪 de-patch 留下的清理債**，建議直接刪除宣告（非本輪重新設計）。
- **`FEUD_ATTACK_MIN=0.5`**（`options.gd:55`）——用在「攻擊」option applicable 的血仇分支（`options.gd:128-131`：血仇強度≥此值才讓純血仇攻擊入候選）+ `faction_ai:446`（`_probe_vendetta_dispatch` 探針判定用同常數）。這是一個「多強的仇恨才算數」的**判斷門檻**，是否該隨衝動/慎重人格浮動（衝動領袖低門檻就爆發、慎重領袖需要更深仇恨才動手）——**這是真的照妖鏡候選**，目前 flat 不分人格。
- **`VIABLE_ARMED_RATIO=0.3`**（`terms.gd:49`，用於 `:98`/`:207` 兩處 `clampf(self_armed_ratio/VIABLE_ARMED_RATIO,0,1)` 讀 readiness cap）——「武裝率多少才算『真正備戰』」的門檻，膽大/好戰領袖或許該接受較低武裝率就覺得夠打，謹慎領袖需要更高武裝率才安心——**同樣是真的照妖鏡候選**。

**這批（除已孤兒的 GOVERN_MATERIAL_TARGET）判定：真剩的 behavior gap**，跟你「預期集中在③」的判斷一致，坐實。

### 4. 情緒（emotion）接線——**CONFIRMED 真缺，記憶腳確實 dormant**
搜尋 `scripts/simulation/decision/*.gd` 全部 `.goals`/`.memory` 讀取：**唯一命中**是 `decision_context.gd:263 if g in f.goals`——但這讀的是 **faction.goals**（faction 層級 directive stakes，如「外交」「攻擊」），跟 `person.goals`（`npc_ai_system.gd write_memory→_trigger_goals` 寫入的個人「復仇/感恩/守護」目標，本 session 稍早 coin-circulation 那輪查過的機制）**完全是兩回事**。

**個人 `person.goals`（復仇/感恩/守護）與 `person.memory`（事件日誌）在整個決策層零讀取端**——寫入端（`ReactionSystem`/`write_memory`）確實在運作，但引擎（DecisionContext/Terms）從未讀回。roadmap 講的「記憶腳 dormant」屬實。你提的 `PANIC_STRESS`（`decision_context.gd:165 if _pp.stress>PANIC_STRESS and _pp.loyalty<PANIC_LOY`）確認**已有一條線**（stress/loyalty→panic gate），這是「情緒腳首接線起步」的實證，但只是**單一 boolean panic 開關**，不是把 `person.goals`（復仇驅動攻擊/感恩驅動忠誠加成/守護驅動保護行為）這類更豐富的記憶驅動動機接進評分項。**判定：真缺**，且缺口比單一「有沒有接線」更具體——**панic 這條已接、goals/memory 這條沒接**，spec 若要做該精確指到這個差異。

### 5. 政治/俘虜（prisoner）——**CONFIRMED 真缺，選項確實只有 3 種**
`manpower_system.gd decide_treatment`（`:35-56`）確認回傳值域 `treatment ∈ {"厚待","苛待","釋放"}`（`:34` 註解自陳）——全 function 逐行讀過，**無「殺俘」「贖金」路徑**。`decide_treatment` 本身架構是良好的（driver-complete、provenance 記錄、guard_ratio 連續決策），這部分**已收斂不是亂象**，但「道德選項集合」本身確實比 game-design 提過的「擴道德選項」願景窄——**判定：真 feature gap**（非 de-patch 病，是選項集合擴充，屬 WHAT/blueprint 該不該擴的判斷，非 HOW 层級的 bug）。

## 結論總表

| # | 項目 | 判定 | 性質 |
|---|---|---|---|
| 1 | 估值 5 處各算 | **REFUTED**（已單源，僅 1 處小冗餘） | 小型技術債，非大工 |
| 2 | `_threat_recent` 軍備閘 | **CONFIRMED 真缺** | de-patch（照妖鏡族） |
| 3a | `GOVERN_MATERIAL_TARGET` | 已孤兒 | 清理債（前輪遺留） |
| 3b | `FEUD_ATTACK_MIN` | **CONFIRMED 真缺** | de-patch（照妖鏡族） |
| 3c | `VIABLE_ARMED_RATIO` | **CONFIRMED 真缺** | de-patch（照妖鏡族） |
| 4 | 情緒接線 | **CONFIRMED 真缺**（panic 已接、goals/memory 未接） | 接線 gap，精確缺口已定位 |
| 5 | 俘虜選項 | **CONFIRMED 真缺** | feature gap（WHAT 層，blueprint 裁） |

## 總評
這輪**沒有重演前三次「稽核 over-count」的模式**——5 項裡有 4 項（②③b③c④⑤）確認為真缺，只有①（估值）被 refute 成「已單源+小冗餘」。跟你的預期（「多數恐已做/不同軸/cosmetic；真缺集中③④⑤」）**大致吻合，但②`_threat_recent`也該併入真缺清單**（你原文沒預期到這條，我查證後確認它跟③是同一種病，建議一起收）。GOVERN_MATERIAL_TARGET 是意外撿到的小清理項（前輪 de-patch 留下的孤兒常數）。

## 下一站
彙整餵 blueprint：真剩 behavior gap = `_threat_recent`(②) + `FEUD_ATTACK_MIN`/`VIABLE_ARMED_RATIO`(③) 四個照妖鏡常數的人格化 de-patch，+ 情緒 goals/memory 接線(④，缺口已精確定位)，+ 俘虜道德選項擴充(⑤，WHAT 層待裁)。估值(①)只需小型重構消冗餘，非獨立 arc。GOVERN_MATERIAL_TARGET 順手刪除。
