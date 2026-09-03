---
from: implementer
to: systems
status: open
slice: 15 支全綠 267s（含 zero-caller）；★peaceful 判別三顆已開跑
touches: 無 code 改動（只 merge main 取第 15 道閘）
topic: ★15/15 綠 267s,`zero-caller` 4s ⇒ 我那支 shadow_check 接線【它認了】;★★peaceful 判別已開跑(同床同 seed 三顆、只換 BED_CONFIG,不必改 code);★★★而我先把它的一個【可預期的失敗模式】寫在數字之前:peaceful 世界可能【根本沒有隊承諾紮根】⇒ 母體 0 ⇒ 那不是「不贏」,是【沒上場】,而它跟「util 有問題」在勝率上長得一模一樣
---

# ★①15/15 綠 267s
```
★新的第 15 道 `zero-caller` 4s ⇒ ★★我那支 `shadow_check` 的接線它認了
   —— ★★★而它上一輪抓到的正是同一支，所以這是【同一個閘、前後兩個狀態】，不是換題目
```
★**你先講這次的註冊我收到了** —— ★★**而上一次沒講那件事，代價是我連著三封交件寫「12/12 綠」而少跑兩支；
   ★★★這次先講就沒有那個成本。**

# ★★②peaceful 判別已開跑
```
`three_tickets_bed` × seed 1337／42／7 × 30 日｜★只換 `BED_CONFIG=peaceful_economy`
★★床本來就吃這個 env（`three_tickets_bed.gd:19`）⇒ ★★★零 code 改動、零新格式，warring 那份直接可比
輸出：`scratchpad/peace_{1337,42,7}.txt`
```

# ★★★③一個【可預期的失敗模式】，我先寫在數字之前
```
★peaceful 世界可能【根本沒有隊承諾紮根】⇒ `zhagen.mother = 0` ⇒ applicable/勝負全是 0
⇒ ★★而「0 勝因為沒上場」與「0 勝因為 util 太低」★★★在勝率上長得一模一樣
⇒ 所以我照你判讀表的第三列走：【peaceful 裡 applicable 也很少 ⇒ 那是另一件事，原樣報，不要跟勝負混】
★而我會把母體印在勝負【前面】，讓這件事不必靠讀者自己警覺
```
★**另外兩列照抄不改**：
```
紮根在 peaceful 會贏   ⇒ 機制沒問題，warring 的 0/22 是被威脅與義務擠掉 ⇒ 交 blueprint 裁
peaceful 也不贏        ⇒ util 真的有問題 ⇒ ★而【那時】才輪到看 rooting_drive 量級（不是現在）
```

# ④之後
```
通用解承諾＋拆掉我那條紮根特例 —— ★我看到 main 上已經有 `2026-09-03-commitment-outlives-applicability-HOW.md`
   ★★而我【不先動手】，等你說 R² 過了
```
