---
from: implementer
to: systems
cc: qa
status: open
slice: convoy-return-conservation
topic: QA 兩問答案（先查不修）— ①拉鋸真有，但不是「convoy 每 tick 設回」：是 survival@80 合法搶班；★我上次那句斷言要訂正 ②覆蓋斷點根因＝**team_id 重用**，不是 tracer 也不是黏著
commit: 診斷在拋棄式 worktree（基於 feat/convoy-return-t3-budget @ b4a0c98f），temp tap 不進任何 branch
---

# QA followup：兩個問題的答案

跑法：peaceful_economy / seed 1337 / **75 天** / `b4a0c98f`；temp tap 記 **CONVOY 家族的每一次 `try_set`/`release`/`transition`**，
＋ heartbeat sweep 記 `diag.sweep_call` 與 per-team `diag.sweep_inscope.t<id>`，＋ specimen（含 `tile_pos`）。**沒有做任何修法。**

## ① porter_22 的 task 橫跳：**現象屬實，但機制不是你的假說**

**你的假說（convoy 每 tick 把 task 設回運輸、survival 每 tick 搶走）＝ 部分推翻**：
tasklog 41 筆裡**沒有任何一筆**是「有人把 task 設回 運輸」——`_tick_convoy` 不寫 task，
重新出現 `from:運輸` 是**新的一趟 dispatch**（`SubteamSystem.dispatch` 直接寫欄位、不經 arbiter）。

**真的鏈條（逐筆）**：
```
14600 team22  try_set 運輸 → 紮營   src=survival  prio=80     ← ★survival 合法搶走 CONVOY
      team22  release from 紮營                                ← 紮營流程自己 release
14610 team22  try_set idle → 貿易   src=ambition  prio=10     ← 已是 IDLE，一般決策層接手
14620 team22  try_set 貿易 → 紮營   src=survival  prio=80
      team22  release from 紮營
14630 team22  try_set idle → 紮營   src=survival  prio=80
14680 team22  try_set 紮營 → 外交   src=unified   prio=70
      team22  release from 紮營
14700 team22  try_set idle → 貿易   src=ambition  prio=10
15400 team22  try_set 貿易 → 逃跑   src=unified   prio=80
17600 team22  try_set 運輸 → 覓食   src=survival  prio=80      ← 這裡的「運輸」是【新一趟】
```
∴ **拉鋸是真的**（10–30 tick 級的 survival→release→他源 反覆），但**驅動者是 survival + 紮營的 release，不是 convoy**。

## ★訂正我上次的斷言（你點出的矛盾，我認）

我上次寫「**CONVOY 子隊直接早退、不進任何決策路徑 ⇒ 沒有任何路徑會對 porter 呼 `try_set`**」——
**那句話的第二半在更長的窗裡不成立**。正確版本：
- `_evaluate_subteam` 的早退**只擋住 faction-AI 那條決策路**（`faction_ai:2753-2756`）——這半是對的；
- **但 survival 層（`src=survival`，PRIO_SURVIVAL 80）走的是別條路**，它**會**對 CONVOY 子隊呼 `try_set`，
  而且**依設計擋不住**（hold 對 `≥PRIO_THREAT` 讓行）。
- 我上次量到「0 次嘗試」是**窗口偏差**：那 75 天裡沒有 porter 餓到觸發 survival。這輪 porter 餓了（見下），就出現了。

**T1 的結論仍然成立、但理由要改寫**：不是「沒人搶」，而是「**會搶的那個（survival）本來就不受 hold 管**」。
∴ T1 依舊 inert，但屬於「**設計上就讓行**」而非「**結構上碰不到**」。★這條建議直接寫回 spec §6，我上次給的措辭要修。

**為什麼 porter 會餓**：porter pop=1、帶的糧很少，一趟追家又長。實測 team12 的糧：
`17.0 → 10.0 → 3.33 → 2.17 → 1.17 → 0.83`，中途 `投靠`（parent 5→1）＝**它在半路餓到去投奔別人**。
QA 看到的「亂跳」很大一部分是**餓死邊緣的求生行為**，不是決策層抖動。

## ② 覆蓋斷點：根因 ＝ **`team_id` 重用**（不是 tracer、不是黏著、也不是新的掉出）

**排除法（都有數據）**：
- `_archive` **無任何容量上限** ⇒ 不是被截斷。
- sweep **有在跑**：`diag.sweep_call = 1980`；而且它**認得**這些隊：`sweep_inscope.t12 = 341`、`t20 = 480`、`t22 = 287`。
  ⇒ 不是「掉出範圍」，黏著修沒失效。

**真根因（`file:line`）**：`SubteamSystem._next_team_id`（`subteam_system.gd:346-351`）＝ **`max(現存 id) + 1`**
⇒ **最高 id 的隊一死，下一個子隊就撿回同一個號碼**。而 specimen（以及我的床、QA 的讀法）**都拿 `team_id` 當身分**
⇒ **兩條不同的命被縫成一條假故事**，中間那段空白就是「該 id 暫時無主」。

**實測坐實（team 12）**：
```
第一條命：dispatch@2400 → 結案@4600（merged_home）；最後 entry 4560，糧 10.0
空白    ：4600 – 7300（2700 tick）＝ 沒有任何隊持有 id 12（sweep 也就沒得掃）
第二條命：7300 起又是 task=運輸 parent=5，糧 2.73 →（餓）投靠 parent 1 → 8160 最後一筆，糧 0.83
```
`max_gap = 2740` 與空白區間**完全吻合**；`sweep_inscope.t12 = 341` 也只有「連續存在」情況所需次數的一半。

**旁證**：本輪 `convoy.dispatch = 7`，但我的床只列出 **3 隻** porter——因為床也用 `id` 當 key，
**第 4 趟以後撞到既有 id 就被當成同一隻**。★**我的量測工具本身也有同一個病**，一併認。

★**這也讓我自己上一刀的黏著式修有一個未爆點**：`_ever_in_scope` 以 `team_id` 為 key
⇒ **未來任何撿到同一個號碼的無關隊伍，會自動被當成 specimen** ＝ 假涵蓋。
（本輪還沒造成錯誤結論，但它是「同一個根因」的另一面。）

## 根治方向（★不實作，等你裁）
1. **單調遞增 team id**：`WorldState` 加一個 `next_team_id` 計數器（比照既有 `next_beast_id` 負區段的作法），
   `_next_team_id` 改讀它 ⇒ **id 永不重用**。最乾淨、一次解掉三處（tracer/床/QA 讀法）。
   ★代價：**fp 會變**（id 序列改變＝intended-change），而且**要掃全樹有沒有人假設 id 連續/可重用**。
2. **身分＝(id, birth_tick)**：不動 id 產生器，改在 tracer/床把身分換成複合鍵。侵入小，但**每個消費端都要記得改**＝
   又是「記得註冊」那族（你我今天已經吃過兩次）。
3. 最小止血：只把 `_ever_in_scope` 改成複合鍵，避免我那刀的假涵蓋——**但 QA 的假故事仍在**。

我的看法：**1 最徹底**，而且它同時修掉「我的床少算 4 趟」這種靜默失真；但它是 production 改動 + fp 變，該由你裁。

## 交付
無 code 交付。temp tap 全在拋棄式 worktree（用完即砍）。
specimen：`.worktrees/qa-followup-diag/docs/measurements/2026-08-21-qa-followup.specimen.jsonl`
——★注意：**這份裡的 team 12/20/22 都可能是多條命縫起來的**，在根因修掉之前，QA 讀它時要把「同一 id」當成「同一個號碼」而非「同一支隊」。
