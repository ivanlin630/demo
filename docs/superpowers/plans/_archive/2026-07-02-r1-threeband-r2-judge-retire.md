# R1 三帶 + R2 judge 收編退役 — Plan

> Spec：`docs/superpowers/specs/2026-07-02-r1-threeband-r2-judge-retire-design.md`（**先整份讀**，含統一性硬約束）。
> 順序做：R2 → R1（R1 的 archetype gate 依賴 R2 統一後才語意一致）。
> **硬約束**：判斷器總數 −1。任何新 band 判斷器/enum/classifier = 違反藍圖裁定，打回。

## Task 1 — R2：disposition 共源 + derive_archetype 委派

**檔**：`scripts/simulation/ambition_ladder.gd`、`scripts/simulation/faction_ai_system.gd`

1. `AmbitionLadder` 新 static `disposition_scores(values: Dictionary) -> Dictionary`：
   回 `{"征服": 野心*0.4+好戰*0.4−義氣*0.4, "致富": 貪婪*0.6+野心*0.1, "防衛": 慎重*0.4+義氣*0.2, "守成": 0.25}`
   （= `_intent_scores` faction_ai:698-703 人格層原式**搬家**，數字一字不改）。
2. `FactionAISystem._intent_scores` 人格層改呼 `AmbitionLadder.disposition_scores(values)`，其上 viability 疊加（established/weak_enemy 壓征服、can_levy 打折致富）不動。**行為位元不變。**
3. `AmbitionLadder.derive_archetype` 改為委派：`argmax(disposition_scores(leader.values))` → 映射 `征服→ARCHETYPE_FORCE / 致富→ARCHETYPE_TRADE / 防衛|守成→ARCHETYPE_SETTLE`。平手序 武力>商業>定居（等分時先 FORCE）。leader==null → SETTLE（現行為保留）。**舊 force/trade/settle 三行公式刪除**（退役）。
4. headless 新測（`headless_test.gd`）：
   - desync=0：構造 values 使 `disposition_scores` argmax=征服 → assert `derive_archetype`==FORCE（同理 致富→TRADE、防衛→SETTLE）。
   - 平手序：三軸同分 → FORCE。
   - 分布 sanity：world gen（沿用既有 world 建測 helper）全 leader archetype 三型各 >10%、無單型 >80%。

**驗**：headless 全綠 + framework 7/7（S5 mint/S6 order 商隊生產魂仍 fire）+ coin_eq delta=0。

## Task 2 — R1a：拔 rung-food 攻擊閘

**檔**：`scripts/simulation/faction_ai_system.gd`（`_evaluate_prosperity_attack` gate）、`scripts/debug/conquest_measure.gd`

1. gate 改：`if team.ambition_archetype != AmbitionLadder.ARCHETYPE_FORCE: return`（**刪 `or team.ambition_rung < RUNG_EXPAND`**）。探針塊同步：刪 `prosp.gate_rung` bump 與 OR 拆分（archetype 單條件），`prosp.gate_archetype` bump 留。
2. **不動**（rung 職權=立國/坐穩/擴編）：`can_expand`(faction_ai:778 擴張 intent)、建國 `accum_ok`(:999)、`rung_task` ambient、其餘一切 `ambition_rung` 讀點。
3. `conquest_measure.gd` 輸出 key 刪 `prosp.gate_rung`。
4. headless 新測：FORCE archetype + rung=SURVIVE（餬口）隊 → 過 gate 進 prey 評估（拔閘生效）；非 FORCE → 仍擋。

**驗**：headless 全綠。

## Task 3 — R1b：means-end logistics 因子（②路程糧 + ③目標歸屬，單一連續因子）

**檔**：`scripts/simulation/faction_ai_system.gd`（`find_prosperity_prey`）

1. score 乘上 `logistics` 因子（**乘進 score，非 filter，非 classifier**）：
   - **②路程糧**：`trip_ratio = ResourceSystem.effective_food(state,team) / (eta_days × pop × FOOD_PER_PERSON_PER_DAY)`，`trip = clampf(trip_ratio, 0.2, 1.0)`（TEST VALUE 下限——絕不歸零，糧緊只壓權重）。**既有信號讀取,嚴禁新後勤 state（guard ②）。**
   - **③歸屬（belief claim,guard ①）**：`bel_fid = bel.get("faction_id", ABSENT)`——**區分「欄位缺席」與「值 -1(獨立)」**（tier2 寫 faction_id=-1 = believed 獨立;tier0/1 snapshot 無此欄 = 未知）。
     - believed 獨立（欄位在且 == -1）→ `own = 1.0`。
     - **欄位缺席（未知）→ `own = 0.5`（TEST VALUE,保守 fallback,Phase E 慣例）**——盲 raid 壓、誘因 scout。
     - believed 屬 faction → `own = WAR_COST_BASE + war_capability`，`war_capability = (自身 established faction ? 0.3 : 0.0) + rung/RUNG_HEGEMON*0.3`（clamp ≤1.0）。`WAR_COST_BASE = 0.15`（TEST VALUE）。
   - `logistics = trip × own`；`score = (richness*貪 + weakness*殘 + border*野) / eta_days × logistics`。
   - **確認 `best_estimate` 透傳 `faction_id` 欄**（tier2 snap 有寫但 merge/estimate 可能濾欄——不透傳則補透傳，非另建管道）。
   - **可騙 channel**：interaction_system:741 既有 deceive 塊補 faction_id 誤報欄（弱村謊稱屬大勢力嚇阻,TEST VALUE 機率,同塊一欄非新系統）。
   - **禁讀 `prey.faction_id` 真值**——belief 錯 → 照打/被嚇阻 = G3 戲劇，不防呆。
2. headless 新測：
   - 同 prey 三版：believed 獨立 / 欄位缺席（未知→0.5） / believed 屬 faction → score 階序 獨立 > 未知 > 屬村（獨立餬口攻擊者）。
   - established faction + 高 rung 攻擊者 → 屬村罰減輕（仍可中選）。
   - 路程糧不足 → score 壓低但非零。
   - deceive faction_id 誤報 → 攻擊者按假歸屬計 own（嚇阻生效）。
3. 所有新常數標 TEST VALUE 註解。

**驗**：headless 全綠。

## Task 4 — 合體驗收（seeded，量化）

1. `conquest_measure`（`GODOT_TIMEOUT=2500` 背景）：
   - `conq.prosperity_reached` 1 → **≥10**（量級起，非精確值）。
   - `prosp.gate_archetype` ≈0（R2 結構保證；殘量>入口 5% = desync 回歸，查）。
   - `capture.total` / `capture.by_attack` 上升。
2. seeded WarringHarness / warring bed：
   - 隊數不雪崩（不 over-war：非 FORCE 傾向隊仍蹲）。
   - 獨立隊攻 believed-faction-owned 目標次數低（③管住）。
   - `SurvivalLoot` 仍 fire（絕境仍搏）。
3. specimen trace（specimen_bed）：狼性餬口隊 想=征服→做=raid 弧可見（trace print 佐證即可）。
4. **貿易量不歸零（guard ④）**：seeded harness R1 前後 `[Market]` 成交/`g1.arb_hit` 對比記進 handback。被吃殘 → **呈報**（護衛/保護費 affordance 藍圖議），不自行實作。
5. **assimilate 預標（guard ④）**：handback 記 `conq.win_absorbed`/`P1Absorb` 數。低=可預測下一瓶頸（manpower cadence），記錄即可非本波修。
6. 回歸：headless（1 FAIL pre-existing「弱目標未加入攻擊 goal」容忍）+ 0 SCRIPT ERROR、framework 7/7 DORMANT=0、coin_eq 全池 delta=0、InvariantAudit 0。

## Handback

`docs/superpowers/handbacks/2026-07-02-r1-threeband-r2-retire.md`（實作→系統）：各 Task 結果、驗收數字（prosperity_reached 前後、gate_archetype 殘量、capture、隊數曲線、archetype 分布佔比）、偏離 spec 處、新 TEST VALUE 清單。

## 注意

- Godot 跑一律 `.\tools\godot.ps1` wrapper（UTF-8）；重型 seed `GODOT_TIMEOUT=2500` + 背景。
- 新增 class_name 後 `--headless --import` 重建快取（本 plan 無新檔，改既有檔通常免）。
- 基準：headless 現有 1 FAIL（弱目標未加入攻擊 goal）= pre-existing，非你造成。
- 平手/邊界行為改動若超 spec 範圍 → 停，handback 呈報，勿自行擴 scope。
