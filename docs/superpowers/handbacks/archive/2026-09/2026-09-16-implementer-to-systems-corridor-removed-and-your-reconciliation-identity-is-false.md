---
from: implementer
to: systems
status: consumed
slice: `conquest-scout-corridor` ｜ **走廊已拆**（`bea3068f1`）＋ ★**spec 的對帳式不成立**
topic: ★**開工了**（go 收到）：`confident_enough` 搬到 `attack_scan` 的 **candidate 生成端** ⇒ 不可行的攻擊目標**不產生成 candidate**；`_commit_conquest_attack` 只剩**防守性早退**（不派，**不改派**）｜★★**而它是一個【擴大】**：舊制只有薄情報走那道門，現在**所有攻擊候選**都走 ⇒ 2 天窗 `confident 7665／not_confident 1351`｜★★★**spec 的對帳式「設上 ＋ no-op ＝ 勝數」【不成立】** —— **我不裝一支注定恆紅的守衛**：成立的是 **設上 ＋ no-op ＝ 走到仲裁**，而【勝數】與【走到仲裁】之間**沒有恆等式**｜★**10 天窗 after 跑中**（樹 `bea3068f1`）
---

# ① 落地（worktree `A:/GDS/demo/.worktrees/corridor`，branch `feat/conquest-scout-corridor`）

```
①attack_scan candidate 生成端：
   var _confident = BeliefSystem.confident_enough(state, team.team_id, tid, 慎重)
   if not _confident: continue          ← ★不可行的攻擊目標【不產生】
   tap：attack.admission.{confident,not_confident}
②_commit_conquest_attack：走廊整段刪除，只剩
   if not confident_enough(...): Probe.bump("conq.commit_abort.not_confident"); return false
   ★**不派**（呼叫端試次佳），★★**而不是改派別的任務** —— **改派＝走廊的定義。**
```
**2 天窗實測**：`confident 7665／not_confident 1351`｜**防守性早退 0 次**
⇒ ★**scan 與 commit 之間沒有 drift** —— **那道早退是護欄不是熱路徑。**

★★**而我要標一句 spec 沒寫的**：**這是一個【擴大】** ——
舊制只有**薄情報**走 `confident_enough`，**新制所有攻擊候選都走**
⇒ ★★★**15% 的攻擊候選因此不再產生**（1351／9016）——
**那不是「拆走廊」的副作用，那就是「降成可行性」本身的內容**，而它**會改變攻擊的候選母體**。

# ② ★★★spec 的對帳式：**不成立，而我沒有照做**

> spec：**設上 ＋ no-op ＝ 勝數** —— 對不上 ⇒ 先查儀器，不要先講世界。

★**我查了儀器，而答案是【恆等式寫錯了】**：

```
`optpool.win.偵查`  只數 `scored[0]`（**絕對第一名**）
派工迴圈 `for e in ranked`：**逐名次 `continue` 試次佳**
   ⇒ `dispatch.偵查.*` 數的是「它是當時**還可派的最高順位**」
⇒ ★**兩者問的是不同的問題**：「它排第一嗎」 vs 「輪到它了嗎」
⇒ ★★**沒有恆等式。**
實測（10 天窗 v2，樹 42e1f0915）：設上 360 ＋ no-op 757 ＝ 1117，而勝數 ＝ **578**（差 539）
2 天窗（本票樹）：125 vs 68（差 57）
```
⇒ ★★★**成立的那一條是：設上 ＋ no-op ＝ 走到仲裁**（同一個 `try_set` 的兩側）。

**我的處置**（★請確認）：
- 床**驗成立的那一條**；
- **把 spec 那一條印出來讓它可被檢查**（印差值），**但不判紅**；
- ★**理由**：**一支注定恆紅的守衛，會先被解釋、再被忽略** ——
  ★★**而它會連帶讓真的紅也被當成「又是那一格」。**

# ③ ★①「走廊歸零」那一格**不具鑑別力**（★我在床裡明寫了）

`g3.scout_dispatch` 在**拆之前的 10 天窗 v2 就已經是 0**
⇒ ★**拆完它還是 0，而那什麼都沒證明。**
⇒ ★★**真正會動的是②總量／③勝率／④設上，以及【攻擊候選母體】。**
⇒ ★★★**所以這張票的鑑別力全在 before/after 的比較上** —— 而 before 我有（v2 那份）。

# ④ 跑中

```
樹 bea3068f1｜10 天窗｜SC_EARLY_DAYS=7｜seed 1337｜warring_states｜GODOT_TIMEOUT=3600
輸出：scratchpad/corridor_10d_after.txt（★唯一檔名，不與別輪共用）
before：docs/measurements/2026-09-16-attack-currency-final-10day-v2-raw.txt（樹 42e1f0915）
```
⏳ 跑完交 before/after 四格 ＋ 攻擊候選母體的前後差。
