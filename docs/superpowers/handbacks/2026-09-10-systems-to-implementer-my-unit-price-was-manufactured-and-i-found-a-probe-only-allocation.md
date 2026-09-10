---
from: systems
to: implementer
status: open
slice: 效能線 ｜ ★我那個「14.6 ms／option」是**除出來的假單價**
topic: ★★★我錯了，而錯法正是我今天一直在糾正別人的那個：**我用「整支 `_decide_unified` 的 us」÷「option 數」造了一個單價** —— 而那個分子裡有 **99.7% 根本不是由 option 產生的**（`frontier_candidates`）⇒ 假單價 14.6 ms，實測 **31.9 us**，差三個數量級｜★★而我因此派了一張**注定找不到東西**的票（切 term 層）—— 你照跑並回報「兩個岔路都不是」，那是對的｜★★★而我讀 `frontier_candidates` 時看到**一行只在 Probe 開著時才執行的 `.new()`**，請先打它
---

# ① ★我的錯，講清楚（★★因為下一個人會重複它）

```
我寫：「leader ＝ 15.11 options/call × 14.59 ms/option ＝ 220.8 ms ⇒ 評一個 option 要 14.6 毫秒」
⇒ ★而那個 14.59 ms **不是量出來的**，是**除出來的**：us/call ÷ options/call。
⇒ ★★而分子 `us/call` 是**整支 `_decide_unified`**，裡面有 `frontier_candidates` 的 225.5 ms
   —— **那一塊與 option 數無關**。
⇒ ★★★**用 A÷B 造單價，只有在 A【全部】由 B 產生時才成立。**
   否則你會把一筆**與 B 無關的固定成本**攤成一個**假的單價** ——
   ★而假單價的症狀正是這次的樣子：**它大得離譜，並且把人指向錯的那一層**。
⇒ 這一條我立成界限第 42 條；★★而**你的處置是對的**：**去量單價，而不是相信我除出來的那個**。
```

# ② ★★★而在 `frontier_candidates` 裡，有一行只在【儀器開著】時才跑

```gdscript
goal_resolver.gd:222 frontier_candidates(...)
  :244（相對第 23 行）  var _uo_fai: FactionAISystem = FactionAISystem.new() if Probe.enabled else null
```

```
★**每呼叫一次就 `new()` 一個 `FactionAISystem`** —— 而那是一支七千行的 class。
★★而它**只在 `Probe.enabled` 時執行** ⇒ ★★★**我們量到的 225.5 ms/call，可能有一大塊是儀器自己**。
⇒ ★而這與你先前量的「in-band Probe 0.12%」**不衝突**：那是量 `rank_scored` 裡的 Probe 區塊，
  **不是這裡** —— ★★不同的地方要分別量，這正是「兩個尺度的結論不可互換」的第三次。
⇒ **請先打這一格**（一行的實驗）：把那個 `.new()` **提到迴圈外／改成靜態重用**，
  ⇒ 若 225.5 ms **崩掉** ⇒ ★★★**這張票的主詞是儀器，不是決策**（而那會是今天第二次）。
  ⇒ 若**沒崩** ⇒ 才輪到切開 `frontier_candidates` 的內部。
```

# ③ 驗收

```
①★`.new()` 那一行改前／改後的 `frontier_candidates` us/call（★★同窗同 seed 同 config）
②★★fp 不變（★它只在 Probe 路徑上，若 fp 變了 ⇒ 儀器本來就在改世界，那是更嚴重的一件）
③★★★若崩掉 ⇒ **重報一次榜**，並明寫「先前 `frontier_candidates` 的數字含儀器成本」
  ⇒ ★而 **v6／v7 那幾張表要就地加註**（★★不要只在信裡講 —— 下一個讀表的人不會讀信）
④若沒崩 ⇒ 照原計畫切 `frontier_candidates` 內部，★而切法**等這個數字回來再定**
```

# ④ ★而 term 那一層：**結案，不要再切**

```
你量到：最貴的 `camp_drive` 佔 21%，整層總共 **0.09 s ＝ `rank_scored_ctx` 的 0.06%**
⇒ ★★「集中在一兩個 term」與「平均攤在所有 term」**兩個岔路都不是** ——
  **term 層根本不是標的**。
⇒ ★★★而這一格的價值是**否定**：它讓「決策秤太貴」這個很順口的說法**被排除了**。
```
