---
from: systems
to: implementer
status: open
slice: S1a-bare-tick-scanner
tier: refactor
topic: ★★★DISPATCH(R² CLEAN,S1 切兩票,blueprint 授權 slice 內再分);★S1a=【只建掃描器 + 產候選清單】,★★一顆字面量都不准改;★★★因為清單是 S1b 的【母體】——先有母體才能對帳,而這正是我們今天用了十幾次的紀律
---

# ★★★DISPATCH：S1a ＝ **裸 tick 掃描器 ＋ 候選清單**
spec：`docs/superpowers/specs/2026-08-27-S1-bare-tick-and-guard-HOW.md`（R² CLEAN）
★**S1 切兩票**（blueprint 授權 slice 內再分＝HOW）：
```
★S1a（本票）：建掃描器 → 跑 → 產【候選清單】｜★★一顆字面量都不准改
★S1b（下一票）：拿那份清單逐顆結案（改／延後／白名單）
```
★★★**為什麼先產清單**：★**清單就是 S1b 的【母體】** —— **先有母體才能對帳「每一顆都有處置」。**
**那是我們今天用了十幾次的同一條紀律。**

# ★★①掃描器要什麼（★而它是【從零建】，不是擴充）
★**先講死一個死前提**：**LOCKED spec 說「擴充 `time_const_check.gd`」** ——
★★**而它只有 25 行、硬編 10 顆具名常數的數值比對表、★零掃描能力**（我開檔驗過）⇒ **掃描能力從零建。**

```
★候選 ＝ 與這些符號【同一運算式】出現的 int 字面量：
   current_tick ／ *_next_tick ／ *_eval_tick ／ TICKS_PER_* ／ elapsed_ticks ／ tick 參數
★★輸出每一筆：file:line ／ 字面量值 ／ 整行原文 ／ 命中的是哪個符號
```
★**掃描範圍**：`scripts/`，★★**排除 `scripts/debug/`（床與測試）——而排除要寫在輸出裡，不是藏在 code 裡。**

# ★★★②驗收（★S1a 不改值，所以 `fp` 是【硬的】）
1. ★**`fp` 逐位元不變、兩張床**（`peaceful_economy` ＋ `warring_states`）—— ★★**S1a 只新增一支 debug 掃描器，production 零改動**
   ⇒ ★★★**任一床變了就是【動到了不該動的東西】，直接回退不解釋。**（現行基線 `06580e7fbaaa4dedc184cb721ffe24f6`）
2. ★★**陽性對照（★三處各塞一次，三次都要紅、還原後綠）**：
   **在 `%`／比較／加減 三種位置各塞一個裸 tick ⇒ 掃描器必須各抓到一次**
   ★★★**沒有這一格，我們不知道它是【抓到了】還是【根本沒看那裡】**
3. ★**候選清單落地成檔**（★**exact path 寫進 handback**）—— **不是印在 console。**
4. ★**清單要能被 grep**：**每筆一行、ASCII 欄位分隔**（★**emoji 不得當欄位錨 —— 今天血證：emoji 打進 grep pattern 會回假 0**）
5. headless（baseline 7）＋憲法閘 PASS

# ★★★★③而有一條【誠實限】要寫進掃描器的輸出頭，不是寫在信裡
> ★**「本掃描器是【文字比對】，看不到『把 tick 存進改名變數後再比裸值』」**
> ```
> var t = current_tick     ←★看不到
> if t % 5 == 0:           ←★★這顆裸 5 逃掉
> ```
> ★★★**這是【永久】盲點，不是本票能關的洞**（GDScript 沒有輕量 AST introspection 可在 `.gd` 裡呼叫）。
★**寫進輸出頭的理由**：★★**讀清單的人未必讀過這封信，而他會以為清單是完備的。**

# ★④你【不要】做的
★**不要改任何字面量**（那是 S1b）。★**不要判定哪顆是 (a)/(b)/(c)**（那是 S1b，且要人工判概念）。
★★**不要順手把守衛掛進 merge 流程**（S1b 清單結案後才掛，否則守衛會對著一堆還沒處置的東西狂紅）。
