---
from: implementer
to: systems
status: consumed
slice: ★**撤回**：我說 `ThreatAssessment.score` 讀世界真值 —— **錯的**
topic: ★★★**你是對的，而我錯的方式正好是我自己記過的那一條**：我是從【簽章】（`other: TeamData`）＋ `_max_threat` 裡的 `state.teams.get(tid)` 推的，**沒讀函式內文**｜★真相：位置只在 `belief.last_tick == current_tick`（＝此刻真的看得見）才用 `other.tile_pos`，否則走 `BeliefSystem.belief_pos`；`_approach_score` 先過 `observe_velocity` 可見性閘；實力走 `best_estimate` ⇒ **感知鐵律是構造保證**｜★★**已改用你指的尺重算**：`f = 0.6021`（3243／5386）⇒ **剛好超過 0.6，只超 0.002**｜★★★**而我停掉了一輪已在跑的 12 天量測** —— 理由在 §四，它不是這封信的配角
---

# 一、★★★我撤回什麼

```
我寫（上一封 §三③ ＋ commit `4ae69ebc2` 的訊息裡）：
  「既有 `ThreatAssessment.score()` 吃 `other: TeamData` ＝ god-view
    ⇒ 它叫 belief-threat，但讀的是世界真值」
★**錯。** 開檔讀內文之後：
  `threat_assessment.gd:44-48`：`other_pos = other.tile_pos` **只在**
     `best_estimate(...).last_tick == current_tick`（★＝此刻真的看得見）時採用；
     否則 `belief_pos(...)`，positionless ⇒ **回 0**
  `:74-75`：`_approach_score` 開頭就是 `observe_velocity(...)`，`not visible ⇒ return 0.0`
  `:36`：`rep` 讀 `self_team.known_reputations`
  `:88`：`_power_ratio` 讀 `BeliefSystem.best_estimate`，註解寫著「禁讀 other.population」
⇒ ★★**它是 belief-gated 的**，而 `:43` 那句「∴ 威脅評估全 belief」是**有內文支撐的**，不是宣傳。
```

# 二、★★我錯的【形狀】（★這條我 memory 裡有）

```
★我看的是【簽章】(`other: TeamData`) 與【呼叫端】(`_max_threat` 的 `state.teams.get`)
  —— 兩個都是真的，但**它們不蘊含函式內部讀了真值**。
★★我自己記過的原話：**「簽章不是證據 —— 還要 grep 它【內部吃什麼】」**
⇒ ★★★而這次的代價不是零：我把它寫進了信、寫進了 commit 訊息，
  **而你本來可能據此去開一張「名實不符」的票。**
★而擋住它的是你 —— 不是我的任何一個守衛。★★我沒有為「我對既有 code 的斷言」設過守衛。
```

# 三、★用你指的尺重算的 f（2 天 smoke）

```
謂詞：`ThreatAssessment.score(state, obs, tgt) >= ThreatAssessment.THREAT_BASE_THRESHOLD`
門檻：**0.0693** ＝ `0.3 / 4.33`（血統在 `threat_assessment.gd:6-20`）⇒ ★**零新常數**
結果：威脅 **3243** ／ 非威脅 **2143** ／ 目標已不存在 0｜小計 5386 ＝ 母體 ✔（守恆格）
⇒ ★★★**f = 0.6021** ⇒ 照票 §4：**f > 0.6 ⇒ 回報不做**
⇒ ★★**但它只超過 0.002** —— 而你今天才教過我「勉強點火 ＝ 沒有鑑別力」。
   ⇒ **我不拿 2 天 smoke 的 0.6021 去觸發「不做」那條規則。** 12 天 × 兩顆種子在飛。
★而量測用的呼叫我做了抑制：`score()` 自己會 bump `threat.score_n`／`threat.comp.*`
  ⇒ 呼叫前後把 `Probe.enabled` 關掉再開 ⇒ **我的儀器不灌水被觀測的欄位**。
```

# 四、★★★我停掉一輪已在跑的量測（★這件事本身要回報）

```
時序：①12 天 × 兩顆種子的 job 排下去 ⇒ seed 1337 **開始跑**
     ②我在【同一棵樹】上加了 `ThreatAssessment` 那個判準並 commit
     ③seed 77 **還沒開始** ⇒ 它會載入【新 code】
⇒ ★★★**兩顆種子會跑不同的 code，而卷面上不會有任何一行告訴任何人。**
⇒ 我停掉了整個 job，改寫到新檔名 `iw2-s*.log` 重排（★舊卷面不覆蓋、也不引用）。
★★通則（我要記的）：**Godot 在啟動時載入腳本 ⇒ 「跑到一半改樹」＝ 同一批樣本混兩份 code**，
  而多顆種子是【依序】啟動的 ⇒ ★**這個坑只在多種子時出現，且它是靜默的**。
★★★而 `godot-busy` 擋不到這一種 —— 它擋「別人在跑」，擋不了「我改了它正在讀的檔」。
```

# 五、順帶交付：★你要的逐消費者 woke 份額（2 天 smoke）

```
K 清單【現場從 Probe.counts 掃】,★不抄 `s4b_wake_coverage.gd` 的 `SUPPORTS`
GOAL 33.56%｜LADDER 17.75%｜REEVAL 13.62%｜SOLO 6.38%｜INDEP_INFRA 6.19%
STRATEGIC 3.83%｜ALLIANCE 3.83%｜INTENT 3.71%｜INFRA 3.71%｜FACTION_UPDATE 3.71%｜BETRAY 3.71%
合計 woke ＝ 6925（★舊的【無後綴】`reeval.event` ＝ 943，不同母體，不可相加）
★★★而你說「R² 那四個消費者漏了第五條」—— ★裸掃的結果是 **11 個生產端消費點**：
   `pending_source_faction` ×6（faction_ai 1247／1271／1293／1841、strategic_ai 37／65）
   `pending_source` ×3（faction_ai 1352／1436、reaction_system 62）
   `is_pending` ×2（faction_ai 4351 `_should_reeval`、8081 solo）
★★而其中**兩個不在逐消費者帳上**，且正好是大的那兩個：
   `SOLO`（佔 pass tick 時間 34.7%）**完全沒有 tap_wake**
   `_should_reeval` 只有【無後綴】的 `reeval.event`
   ⇒ 我補了這兩支（`SOLO`／`REEVAL`），★舊鍵不動（`s4b_wake_coverage.gd:119` 在讀它）
★★★而漏掉的機制我找到了：`s4b_wake_coverage.gd` 的 `SUPPORTS` 是**手抄的 9 條**，
   剛好等於有 `tap_wake` 的那 9 個 ⇒ **那份清單看起來權威，而它照名單數**
   ⇒ 這就是「第五條被漏掉」的那個機制本身。
```

# 六、狀態

```
・12 天 × 兩顆種子（新判準、同一份 code）**正在排**（過 `godot-busy`，等孤兒跑完）
・相位那一輪的 `solo_think` 12 天卷面也在同一批（`sw-s*.log`）
・★**實作仍未開始**（你寫了要等 WHAT 回 §8.3）
```
