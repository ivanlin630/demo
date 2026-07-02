# Hand Back: R1 三帶（拔閘+logistics）+ R2 judge 收編退役（實作→系統）

> Plan：`docs/superpowers/plans/2026-07-02-r1-threeband-r2-judge-retire.md`
> Branch：`feat/r1-threeband-r2-judge-retire`（worktree `.worktrees/r1-threeband-r2-judge-retire`）
> Status: open

## 實作摘要（各 Task 結果）

### Task 1 — R2 disposition 共源 ✅
- `scripts/simulation/ambition_ladder.gd`：新 static `disposition_scores(values)`（=舊 `_intent_scores` 人格層原式搬家，數字一字不改）；`derive_archetype` 退役自有三行公式，委派 `argmax(disposition_scores)` → 映射（征服→FORCE / 致富→TRADE / 防衛|守成→SETTLE），平手序 武力>商業>定居（strictly-greater 迭代序實現），leader==null→SETTLE 保留。
- `scripts/simulation/faction_ai_system.gd`：`_intent_scores` 人格層改呼共源，viability 疊加（established/weak_enemy 壓征服、can_levy 打折致富）不動。行為位元不變。
- **判斷器總數 −1 達成**：舊 force/trade/settle 公式退役，零新 band 判斷器/enum/classifier。
- 測：desync=0 委派一致（三傾向 × 前提自驗）、平手序（征服=致富=防衛=0.4 fp 精確 → FORCE）、分布 sanity。
- **archetype 分布（seeded 300 leader 生成）**：FORCE=48(16.0%) TRADE=155(51.7%) SETTLE=97(32.3%)——三型 >10%、無單型 >80% 過。

### Task 2 — R1a 拔 rung-food 攻擊閘 ✅
- `_evaluate_prosperity_attack`：gate 只留 `archetype != FORCE → return`，刪 `rung < RUNG_EXPAND`。
- 不動處確認：`can_expand`(擴張 intent)、建國 `accum_ok`、`rung_task` ambient、其餘 `ambition_rung` 讀點全保留。
- 探針：`prosp.gate_rung` 刪（含 conquest_measure 輸出 key）；`gate_archetype` 留作 desync 回歸哨。
- 測：FORCE+rung=SURVIVE 過閘攻擊；非 FORCE 仍擋。

### Task 3 — R1b logistics 因子 ✅
- `find_prosperity_prey`：`score = (richness*貪 + weakness*殘 + border*野) / eta_days × logistics`，`logistics = trip × own`（連續因子乘進 score，非 filter 非 classifier）。
- ②路程糧 `trip = clampf(effective_food / (eta_days×pop×FOOD_PER_PERSON_PER_DAY), 0.2, 1.0)`——既有信號讀取，無新後勤 state（guard ②）。
- ③歸屬三態（guard ①）：believed 獨立(欄在且==-1)→1.0；**欄位缺席→0.5 保守 fallback**；believed 屬 faction→`min(0.15 + war_capability, 1.0)`，`war_capability = (established?0.3:0) + rung/RUNG_HEGEMON×0.3`。禁讀 `prey.faction_id` 真值。
- `best_estimate` 透傳確認：claim value 整份 dict 回傳（tier2 snap 已含 `faction_id`），**免補透傳**。
- 可騙 channel：`interaction_system._write_tier2_intel` deceive 塊補 faction_id 誤報——弱獨立隊（armed_ratio<0.5）以 `deceive_chance`（既有人格式 (1-信義)*0.5+計謀*0.2）謊稱屬最大 established faction（`_biggest_established_faction` helper）。同塊一欄，非新系統。
- 測：歸屬階序（獨立>未知>屬村；prey 真值故意與 belief 相反=belief 驅動非 god-view）、established+HEGEMON 罰減輕（富屬村仍中選）、糧 0 仍非零可中選、deceive 誤報+嚇阻（誤報村被避開）。

### Task 4 — 合體驗收（seeded 量化）
見下。⚠ 兩項未達/語意偏差呈報（prosperity_reached 量級、gate_archetype 探針前提）。

## 驗收數字

### conquest_measure（14400 tick warring seed，R1 後；unseeded runtime 有 drift）
- `conq.prosperity_reached`：前 1（measure handback adc5a26）→ 後 **4**。**未達 plan ≥10 門檻**（4×，方向對量級不足）——呈報，見「待確認」。
- gate ladder：`prosp.entered`=46 → `gate_archetype`=34、`gate_readiness`=3、`gate_noprey`=5、reached=4（`gate_score`/`scout_defer`=0）。
  - **⚠ `gate_archetype`≈0 的 spec 前提與探針放置不符**：`prosp.entered` 入口=所有獨立隊+faction leader 隊的 cadence 評估（`_is_prosperity_candidate` 不濾 archetype），非「征服 intent 者」——34 次=TRADE/SETTLE ambient 隊被人格 gate 正確擋下，**非 desync 證據**。desync=0 由 R2 單測結構證（同 argmax 共源）。基線同理（54 進 26 archetype 擋）。要真量 desync 殘量需「intent=征服 且被 archetype 擋」交叉探針（未加，避 scope 擴）。
- `capture.total`=3、`capture.by_attack`=1（本 run 絕對值；同 seed 對照見 bed）。
- `surv.loot_dispatch`=140（絕境仍搏）；`conq.indep_atk_believed_owned`=0（③管住）。
- 漏斗：intent=92 → reached=19(20.7%) → combat=16(84.2%)；FORCE 獨立隊樣本 rung 分布 survive=91%、`food_flow<0.5`=91.4%（三帶敘述成立：多數 FORCE 隊在餬口/絕境帶，由 survival 域+R1a 後 prosperity 域雙路出手）。

### seeded warring bed（同 seed 前後對照，2 月窗）

| metric | seed1337 前→後 | seed42 前（post 未取得，見下註） |
|---|---|---|
| final teams（不雪崩） | 75→78 | 62 |
| attrition | 47.9%→41.1% | 46.1% |
| capture.total | 3→6 | 5 |
| capture.by_attack | 0→1 | 0 |
| conq.prosperity_reached | 1→4 | 0 |
| [Market] 成交（guard ④ 貿易） | 3→9 | 5 |
| SurvivalLoot print（絕境仍搏） | 239→201 | 79 |
| g2.feud_formed | 0→14 | 7 |
| conq.indep_atk_believed_owned | —→0 | — |
| p1.assimilate | 0→1 | 3 |

> ⚠ **seed42 post 側三次跑皆未完成**（一次前景 585s cap、兩次 detached 1500/2400s 被同機並行 session（dieoff-erase-batch worktree）搶 CPU/殺 Godot process 弄死）。baseline/post metric JSON 已入庫 `docs/superpowers/handbacks/assets-2026-07-02-r1/`（base_1337 / base_42 / post_1337）；機器獨占時補跑 `WARRING_SEEDS=42 WARRING_MONTHS=2 WARRING_BASELINE=<base_42.json>` 即得逐點 diff。前後對照結論以 seed1337（完整）+ conquest_measure + specimen 為準。

- **不 over-war ✓**：隊數不雪崩（1337 反升 75→78、attrition 降）；意圖分布 RICH/DEFEND 主導未變（非 FORCE 傾向隊仍蹲）。
- **③管住 ✓**：獨立隊攻 believed-faction-owned = 0 次（兩床）。
- **絕境仍搏 ✓**：SurvivalLoot 仍大量 fire（1337:201、conquest:140），未歸零；微降與 prosperity 分流一致。
- **貿易量不歸零（guard ④）✓**：[Market] 成交 1337 前 3→後 9 未被吃殘（`g1.arb_hit` 兩側皆 0=窗內套利未觸，以 [Market] 為準）。
- **assimilate 預標（guard ④）**：`conq.win_absorbed`=0、`P1Absorb` print=0、`p1.assimilate` 個位數——**低，如藍圖預測=下一瓶頸（manpower assimilate cadence）**，記錄非本波修。

### specimen trace（conqueror mode）✅
- 狼性餬口隊 T18（獨立高野心）：**想=征服 78/80 決策、做=掠奪(raid) 78/80**——「想=征服→做=raid」弧 trace 可見（例：tick=4830 `intent=征服 mode=prosperity → winner=掠奪`）。絕境帶 survival 域搶食與征服意圖並存=三帶敘述性 regime 成立。

### 回歸
- headless：綠（唯一 FAIL = pre-existing「弱目標未加入攻擊 goal」）、0 SCRIPT ERROR。
- framework validation：7/7 PASS DORMANT=0（S5 mint / S6 order 商隊生產魂 fire）——R2 分布位移後經濟魂未死。
- coin_eq：CoinAudit 200-tick 全池 delta=0.00；InvariantAudit 全過（population/faction/subteam/roster 雙向+反向）。

## 新 TEST VALUE 清單
| 常數 | 值 | 位置 | 意義 |
|---|---|---|---|
| `TRIP_FOOD_FLOOR` | 0.2 | faction_ai_system.gd | ②路程糧下限（絕不歸零，糧緊只壓權重）|
| `OWN_UNKNOWN_FACTION` | 0.5 | faction_ai_system.gd | ③歸屬欄缺席保守 fallback（未知=危險）|
| `WAR_COST_BASE` | 0.15 | faction_ai_system.gd | ③believed 屬村基準罰 |
| war_capability 權重 | established 0.3 + rung/HEGEMON×0.3 | faction_ai_system.gd | 戰爭能力減免（既有信號讀取組合）|
| faction_id 誤報門檻 | armed_ratio<0.5、機率=deceive_chance | interaction_system.gd | 弱隊謊稱屬大勢力（沿用既有人格式機率）|

## 偏離 spec 處
- 無行為性偏離。實作選擇備註：
  - 平手序用「嚴格大於 + 迭代序 [征服,致富,防衛,守成]」實現（等分先 FORCE），非 epsilon 比較。
  - faction_id 誤報機率直接沿用既有 `deceive_chance`（人格驅動），未另立獨立機率常數——最小侵入；要獨立旋鈕再拆。
  - 驗收哨探針 +2（`surv.loot_dispatch`、`conq.indep_atk_believed_owned`）+ WarringHarness PROBE_KEYS +3（含 `g1.arb_hit`）——純量測 infra。

## 連動風險
- **WarringHarness PROBE_KEYS 變** → 舊 baseline JSON diff 會出現三個新 key 的 `<缺>` 條目（非行為 diff）。
- **R2 分布位移**：FORCE 佔比 16%（舊公式無義氣負項；義氣高的好戰者滑向 TRADE/SETTLE）。framework/經濟未死，但「武力隊」佔比結構性降——conquest_measure 的好戰 boost（好戰0.75/野心0.7 不動貪婪/義氣）下 FORCE entrants 從 28 降到 12，直接壓 prosperity_reached 量級（見待確認①）。
- **deceive faction_id 誤報**隨 tier2 claim 傳播/過時——belief 網路會有「假歸屬」情報流（設計要的 G3 戲劇），未來任何讀 belief faction_id 的決策自動吃到。
- known_issues.md:23「修向:...可能 rung-gate flow 門檻放寬」與 :28②「conqueror 食物 survival-trap」段落 = R1 拔閘後部分過時，**系統 session 收編時請更新**（實作不動系統敘事段）。

## 待主 session 確認
1. **`conq.prosperity_reached` 4 < plan 門檻 10**。三因並存：(a) R2 新公式義氣負項令 FORCE 佔比降（16%），conquest bed 的好戰 boost 只拉野心/好戰 → boosted 狼半數落 TRADE；(b) 91.4% FORCE 隊 food_flow<0.5 多在 survival 域佔用（絕境帶正確走 survival-loot，140 次）→ idle 窗少、prosperity 入口少（entered 46）；(c) unseeded drift。**方向對（1→4、capture 上升、鏈通）但量級未達**——是否收貨/調 disposition 權重（TEST VALUE）/或 boost 腳本改拉貪婪外的軸再量，主 session 裁。
2. **gate_archetype 探針語意**：spec「≈0」前提=入口只有征服 intent 隊，實際入口=全 archetype ambient cadence 隊 → 此探針不能當 desync 哨用。若要真 desync 殘量哨，需加「intent=征服 且被 archetype 擋」交叉 bump（一行，等裁）。
3. seed 42 跑一次 >585s（前景 cap 撞牆），數字採 detached 跑——同機有並行 session（dieoff-erase-batch）搶 CPU + 曾互殺 Godot process，量測期間 wall-clock 不可靠，機器獨占時建議復跑核對。
4. 建議後續：assimilate cadence（win_absorbed=0 如預測）、「intent=征服被 archetype 擋」交叉探針、R2 分布位移是否需藍圖平衡 pass。
