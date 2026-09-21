---
from: reviewer
to: systems
status: open
slice: 窗標籤把「一天」手抄成 240（真值 1440）
topic: verdict=issues｜①「至少四處」嚴重低估(全庫實掃 15+ 檔同型 ＋ production 一顆) ②「只改標籤不改世界」對 crisis_override_test.gd 是假的(★已實跑驗證：main 現在就 6/14 FAIL，跟這票無關，TPD 是判斷輸入不是標籤)
---

# 先核 §0 事實：四處逐一核過

```
world_sim.gd:36-42          ✅ 核實，算式用裸 240（月/日取樣）
crisis_override_test.gd:9   ✅ 核實，const TPD := 240，註解自己說是 TICKS_PER_DAY
game_sim_test.gd:158,165    ✅ 核實（158 誤植為 150/157，實際行號 150/157/158/164/165 一片都是）
construction_funnel_bed.gd:162  ⚠️ 部分核實——**這一格不是同一種病**：
  line 162 只是 print 字串裡的裝飾文字 `"day=tick/240："`；
  真正的算式在 line 165 `int(a3.get("tick",-1)) / WorldState.TICKS_PER_DAY` —— ★已經讀真值。
  ⇒ 這格改了只是把字串裡的數字改對，**不影響任何行為**（跟另外三格不同類）。
  §2 修法寫「四處…一律改讀 WorldState.TICKS_PER_DAY」對這格不成立（它本來就在讀），
  只需要把字串裡的 "240" 換成插值變數或拿掉那個數字。
```

# 一、你問的第①題：判準會不會漏——答案是【會，而且漏得比你以為的多】

你自己的懷疑（`TPD`／`24*10` 這類算出來的形狀）**成立，而且我找到一個更嚴重的活例，不是假設**：

```
scripts/simulation/path_system.gd:15
  const AI_ETA_LIMIT: int = 1200   # 5 day plains 等量 (5 × 240)
scripts/simulation/path_system.gd:287
  if eta > AI_ETA_LIMIT:   ← ★production 決策閘，判斷 AI 要不要接受這條路徑
```
- 這是**production 代碼**（不在 `scripts/debug/`），不是工具標籤。
- 它是【手算好的 1200】，字面上沒有 `240` 這個 token（只在註解裡），
  ⇒ **裸字串 `grep 240` 抓不到常數本體，只抓得到旁邊那行註解**。
- 若這常數真的意圖代表「5 個遊戲日」，真值該是 `5 * WorldState.TICKS_PER_DAY = 7200`，
  現在的 1200 只有真值的 1/6 ⇒ **AI 路徑決策把「還算合理的路」提早判定超時拒絕**。
- ★這已經超出這張票的 WHAT（票只講「標籤」），但它是同一個手抄物理血統
  （`memory: 估算器禁手抄物理`），我判斷不了要不要收進這一票——呈你裁。

★★另外，全庫實際 grep（不加過濾）裸 `240` 用在「日/月」算式的，在 `scripts/debug/` 底下
還有至少這些同型（我逐一開過，確認是算式不是註解／字串常量表）：
```
climb_diagnose.gd:51 econ_bed_diagnose.gd:60 establishment_diagnose.gd:52
food_ledger_diagnose.gd:61 founding_path_measure.gd:45 indep_found_bed.gd:51
rung_diagnose.gd:61 specimen_bed.gd:41,102 spine_trace.gd:8 team_trace.gd:9
warring_states_seed.gd:58-59 conquest_measure.gd:33,83,85
member_report_control_bed.gd:147,171 settlement_s2a_test.gd:64
scaling_bed.gd:13（TICK_RUN，同型變數名）
```
⇒ 「至少四處」這句本身就是低估（真數 ≥ 15 檔，我沒有窮盡再往下掃 UI/simulation 層，
只掃了 `scripts/debug/`）。**這不是要你這票全修**——是這個判準句本身站不住：
你的 1-a「全庫掃：不再有把 240 當一天用的算式」如果只驗證這四個檔案，
交件信寫「全庫掃」就是【範圍講小了】，跟本專案 memory 裡「斷言範圍>證據範圍」是同一種病。

**建議判準**（不靠字面 `240`，而是靠對照真源）：
```
掃「所有把 tick 換算成 day/month/year 的除法/取模算式」（模式：`/ <int字面>`、`% <int字面>`
  出現在含「day」「月」「年」「daily」等中英文變數名/註解附近的行）
→ 逐支人工核：除數是不是 WorldState.TICKS_PER_DAY 或它的整數倍
→ 不是 ⇒ 記錄（不論它像不像 "240"）
```
這個判準抓得到 `TPD`／`AI_ETA_LIMIT` 這類，因為它掃的是【語意角色】（誰在扮演日長），
不是【字面數字】。★但這仍然是推論式窮盡，不是機械可證偽——寫進交件信要老實標「人工核過，非自動」。

# 二、你問的第②題：TPD 有沒有參與判斷——★已用實跑驗證，答案是【有，而且它現在正在讓 6 支測試假紅】

```
grep TPD crisis_override_test.gd → 8 處使用，全部餵進 current_tick／task_start_tick
（不是只印字，是拿去建構 SUT 的輸入狀態）

production 對照：faction_ai_system.gd:7026
  if state.world.current_tick - team.task_start_tick < int(CRISIS_DAYS * float(WorldState.TICKS_PER_DAY)):
  ★這裡已經讀真值（CRISIS_DAYS=6.0 × 1440 = 8640 tick 門檻）

⇒ 測試用 TPD=240 構造「committed 8 天」時，實際只給了 8×240=1920 tick，
  遠低於 production 真門檻 8640 ⇒ 「committed 未到 N 天」分支會 fire，函式回 false，
  而測試斷言的是 true。
```

★★我沒有停在算式推論——**實跑驗證**（`tools\godot.ps1 --headless --script scripts/debug/crisis_override_test.gd`）：
```
=== DONE === 6 FAIL
（_test_crisis_fires_stuck_famine 1 個 + _test_five_stuck_tasks 5 個task，全部 FAIL）
```
**這 6 個 FAIL 現在、main 上、跟這張票完全無關，就已經是紅的。**

⇒ 你 1-c 寫「fp ＋ 逐 tick 行為軌跡逐字相同（這一票只改標籤，不准改世界）」，
**對 `crisis_override_test.gd` 這句本身是錯的前提**——不是「這格可能紅」，
是**這格現在就是紅的，而修法（TPD 改讀真值）大機率會把它從 FAIL 修成 PASS**
（8×1440=11520 ≥ 8640 門檻，符合測試原意「committed 8 天 > N 天門檻應該 fire」）。

⇒ ★你在 §三/(2) 問「要不要在 spec 裡先聲明」——**要，而且不是聲明「可能紅」，
是聲明「這支現在就紅，這票的驗收標準是把 6 支 FAIL 修成 PASS，不是保持逐字相同」**。
1-c 的「逐字相同」對另外三個檔案（world_sim/game_sim_test/construction_funnel_bed）
成立，**唯獨 crisis_override_test.gd 要單獨列一格，判準是「FAIL 數從 6 降到（你驗證後填的數字）
且哪幾支從 FAIL 翻 PASS 要點名」，不能用同一句「逐字相同」蓋過去**。

# 三、premise_contradiction

```json
{ "verdict": "issues",
  "premise_contradiction": true,
  "issues": [
    {"claim": "四支工具…只改標籤不改世界",
     "file_line": "crisis_override_test.gd:9,49,55,61,67,72,78,81,91；faction_ai_system.gd:7026",
     "truth": "TPD 是判斷輸入不是標籤；main 現在就有 6/14 測試因此假紅（已實跑驗證），修法會（大機率）把它們變 PASS，屬於【對的行為改變】不是【只改標籤】"},
    {"claim": "construction_funnel_bed.gd:162 是同型手抄 240",
     "file_line": "construction_funnel_bed.gd:162 vs :165",
     "truth": "162 只是 print 字串裝飾文字，165 的實際算式已經讀 WorldState.TICKS_PER_DAY——這格不影響行為，跟另外三格不同類"},
    {"claim": "至少四處 ／ 全庫掃",
     "file_line": "scripts/debug/ 下 15+ 檔同型裸 240 用於日/月算式（清單見上）＋ scripts/simulation/path_system.gd:15,287（production，AI_ETA_LIMIT=1200 手算自 5×240，真值該 7200）",
     "truth": "四處是嚴重低估；且純字面 grep 240 會漏掉像 AI_ETA_LIMIT 這種【算好的常數】"}
  ],
  "note": "設計方向（讀 WorldState.TICKS_PER_DAY、de-patch 非改數值）本身對，我沒有異議。擋在：(a) construction_funnel_bed.gd:162 分類錯，那格不是行為 bug；(b) crisis_override_test.gd 的 1-c 判準句用錯了模板——那不是『可能的例外』，是『已驗證現在就紅』，spec 要把它單獨列格且寫清楚期望的 PASS/FAIL 翻轉；(c) 四處＋全庫掃兩句範圍講小了，真實影響面至少 15 個 debug 檔 + 1 個 production 常數（path_system.gd:15，AI_ETA_LIMIT），這票要不要一併收，還是明確劃出範圍寫進交件信，呈你裁（WHAT 我不裁）。" }
```
