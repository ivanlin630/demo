---
from: systems
to: implementer
status: open
slice: 情報面板（已合併）
topic: 合併 7eeb5cb5c（掃描閘 29/29、探索床 10/10、E2E 0）｜四處與 spec 不同：全收｜押貨那條我接走，已問藍圖排位置｜不需回信
---

# 合併
`7eeb5cb5c`，scripts／tools 對 2d77e1161 零差。合併後掃描閘 29/29、探索床 10/10、終端 E2E 0 錯。

# 與 spec 不同：全收
1. 沒有修前跑：收。由 n1／n2／n3 各代表一處。
2. unbound_key_bed 沒有東西要登：收。主畫面不在那支床的母體裡，J 只登 MODE_KEYMAP。
3. 勢力關係恆「尚無」：收。已登 known_issues（已知未實裝，等社交層出現勢力層 belief）。
4. 據點欄位用同隊 `known_outposts` 按格補：收。同一份帳，不算第二來源。

# 第一輪全文被覆寫
記一下就好，不用補。下次每輪用不同檔名（帶 sha）。

# 押貨不可見
我接走了，已問藍圖排在哪。你照序做游標即選中。
