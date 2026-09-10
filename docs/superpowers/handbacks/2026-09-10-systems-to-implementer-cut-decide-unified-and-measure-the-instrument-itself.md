---
from: systems
to: implementer
status: open
slice: `_decide_unified` 內部切相位（★岔路照走：**每次很貴**，不是叫太多次）
topic: ★裁：切開 `rank_scored`，而**切法我讀了 code 給你**（`decision_engine.gd:72-110`：`ensure_maintain_goals` ／ `DecisionContext.gather(advance=true)` ／ `rank_scored_ctx` ／ ★**Probe 區塊**）｜★★而 `src` 要**穿進去**，否則新鍵又會變成四個呼叫端共用的 multi —— 那就是我們剛剛才拆掉的東西｜★★★而有一格我要你**一起量**：**`Probe.enabled` 的區塊本身在被量的那條路上做真工**（迴圈＋字串串接）⇒ **儀器可能是成本的一部分**
---

# ① 岔路已定（★你的數字直接選了分支）

```
`from_leader` 241 次／53.29s ⇒ **221.1 ms per call**（max 473.9ms）⇒ **每次很貴**
⇒ 照信裡先寫死的岔路：下一張是【切開 `_decide_unified` 內部】，**不是**【誰在叫它】。
⇒ ★★而「誰在叫它」那條**現在正式排除**，不是待辦 —— 241 次不是多。
★而第二個發現要留著：**leader 221ms vs member 42.6ms ＝ 5.2 倍（同一支函式）**
  ⇒ ★★它是這張票要回答的第二個問題，見 §③。
```

# ② 切在哪（★我讀了 `decision_engine.gd:72-110`）

```
`rank_scored(state, team)` 的身體就四段：
   ①`GoalResolver.ensure_maintain_goals(state, team)`      ⇒ 鍵 `rank.goals`
   ②`DecisionContext.gather(state, team, true)`            ⇒ 鍵 `rank.gather`
   ③`rank_scored_ctx(ctx, ...)`                            ⇒ 鍵 `rank.score`
   ④★**`if Probe.enabled:` 那兩大段**（flee.degrade ／ zerowin 逐 option 迴圈）⇒ 鍵 `rank.probe`
★★★`src` 必須穿進 `rank_scored`（它現在沒有這個參數，而 `_decide_unified` 有）
  ⇒ 鍵長成 `rank.gather.from_leader` 這種、各自掛在對應的 `unified.rank.from_*` 底下
  ⇒ ★**否則這四個新鍵會變成四個呼叫端共用 ⇒ 又一族 multi** —— 那正是我們剛拆掉的東西。
★而 `gather.*` 那族既有的鍵**先不動**（它們是 multi）：本票只要知道 `rank.gather` 佔多少。
```

# ③ ★★同時回答「為什麼 leader 是 member 的 5.2 倍」

```
★再做一次同樣的除法，只是分母換成【候選數】：
  每次呼叫記一顆 **evaluated options 數**（`scored.size()`）
  ⇒ **us per option ＝ us per call ÷ options per call**
⇒ ★★這一格分辨兩件處置完全不同的事：
   (a) **leader 評的 option 比較多** ⇒ 機制在【誰進得了候選】
   (b) **每個 option 比較貴** ⇒ 機制在【term 計算】
⇒ ★★★而在這個數字出來之前，「leader 特別貴」**沒有主詞**。
```

# ④ ★★★而這一格是我要你【一起量】的（★它可能推翻上面全部）

```
`rank_scored` 裡的 `Probe.enabled` 區塊**在做真工**：
   `for _zr in scored:` 逐 option、字串串接 `"zerowin." + _zo + ".n"`、多次 `Probe.bump/add_amount`
⇒ ★而所有這些相位數字**都是在 Probe 開著的情況下量的**
  ⇒ ★★**儀器本身可能佔了那 221ms 的一部分**，而我們會把它讀成「決策很貴」。
⇒ 做法：**同窗同 config 跑兩趟：`Probe` 開 vs 關**，比 `evaluate_all` 的**牆鐘總時**
  （★相位數字在關的那趟不存在，所以只能比外層總時 —— **這一句要寫進交件**）。
⇒ ★★★這不是離題：它是【觀測改變被觀測物】那一族，而我們今天已經在 RNG 那一軸上守過同一條。
  ⇒ 若儀器佔比很小 ⇒ 上面的結論站得住；★若很大 ⇒ **這張票的主詞要換成儀器**。
```

# ⑤ 驗收

```
①負的 self_us 仍 **0 個**；②守恆：`rank.*` 四鍵相加 ≈ 該 `unified.rank.from_*` 的 tot
  ⇒ ★差額要能解釋（不可以只寫「差不多」）
③★us per call ＋ **us per option** 都印；④★★Probe 開／關的牆鐘對照
⑤fp 不變（純儀器）＋零 RNG；⑥★★★母體地板：每一個 `from_*` 的次數與 options 數 **>0**，
  是 0 就明寫是 0（★一個沒跑到的呼叫端與一個沒登記的呼叫端在表上長得一樣）
```
