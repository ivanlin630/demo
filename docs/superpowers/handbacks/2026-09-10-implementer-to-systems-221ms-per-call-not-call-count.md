---
from: implementer
to: systems
status: open
slice: rank ＝【幾次 × 每次幾微秒】
topic: ★★★答案是【每次很貴】：`from_leader` **241 次／53.29s ⇒ 221.1 ms per call**（單次 max 473.9ms）⇒ 照你事先寫死的岔路，下一張是【切開 `_decide_unified` 內部】，**不是**【誰在叫它】｜★★而四個一起量才看得到第二件事：**leader 每次 221ms vs member 每次 42.6ms ＝ 5.2 倍** —— 同一支函式，兩種呼叫端的單次成本差五倍｜★交件 commit **0bb4acc4a**（表：`docs/measurements/2026-09-10-rank-calls-breakdown.txt`）
---

# ① 四欄 ＋ 每隊分母（warring_states｜6000 tick ＝ 4.2 遊戲天｜★全部呼叫，非 spike 母體）

```
呼叫端     次數    總計(s)   us/call    單次max(ms)   走這條路的隊數  每隊次數
leader      241    53.29    ★221138.6      473.9            8          30.13
member      468    19.93      42589.9      107.4           25          18.72
threat       22     1.52      68955.3      294.2           18           1.22
solo          2     0.20     102483.0      155.7            2           1.00
unknown   ★0 次（★★明寫：它在這一窗【沒有被走到】，不是沒登記）
⇒ ★驗算：221138.6 us × 241 ＝ 53.29s ✅（純除法，印出來讓人自己驗）
```

# ② ★★而「四個一起量」立刻付清了它的成本

```
★leader 每次 **221ms** vs member 每次 **42.6ms** ⇒ **5.2 倍**。
⇒ ★★所以「rank 很貴」這句話【不完整】：**同一支 rank，被 leader 叫的時候貴五倍**。
⇒ ★★★而這是【下一張票的形狀決定性資訊】：若只量 leader，
   我們會去切 `_decide_unified` 的內部；而現在還多一個問題可以問 ——
   **「leader 的 ctx 有什麼是 member 沒有的？」**（★候選：discovered 數、faction 成員數、
   conquest scaffolding ⇒ ★我沒查，標【未驗】）。
```

# ③ ★而我自己抓到並修掉的兩個量測錯（★兩個都會生出「看起來很有解釋力」的數字）

```
①★量測窗沒有貼著被量的東西：第一版終點放在 90 行之後的 Probe 區塊
  ⇒ 混進 reorder／funnel／specimen dump ⇒ 得到「每次 222ms」——
  ★★而它與正確答案（221ms）幾乎一樣 ⇒ **這種錯不會被數字本身戳破**。
  ⇒ 修法：在 `rank_scored` 回來的【下一行】就把 us 存進區域變數。
②★單次 max 讀錯桶：`Probe.note()` 寫的是 `peaks`，而我用 `Probe.amount()`（讀 `amounts`）
  ⇒ 全部印成 0.0ms ⇒ ★★而「max = 0」看起來像【沒有慢的呼叫】，不像【讀錯地方】。
```

# ④ 驗收三格

```
①母體地板：四個 from_* 的次數都 >0，★而 unknown ＝ 0 次【明寫出來】
②us/call × 次數 ≈ 總計（印出來可自驗）
③fp 不變 850d35a0…（Probe-gated、零 RNG）
```

# ⑤ 下一張（★我不自己開）

```
★照你的岔路：us/call ≫ 1ms ⇒ 【切開 _decide_unified 內部】。
★★而我建議切法先問一句你已經問過的那類問題：**先量再切** ——
  候選：候選生成（options）／逐 option 的 term 計算／排序本身／to_task。
★★★而【誰在叫它】那條線我沒有碰，理由照你寫的：
  它的天真修法（少叫幾次＝降低思考頻率）是決策層 LOD ⇒ 零 LOD 憲法禁。
```
