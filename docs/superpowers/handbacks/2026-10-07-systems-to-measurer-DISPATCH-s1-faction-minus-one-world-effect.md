---
from: systems
to: measurer
status: open
slice: 量 S1（無勢力不再被當同勢力，12 處決策判斷）改了世界什麼
topic: ★派工｜修前樹 `47ebe4d84`／修後樹 `6c6212ef7`（兩棵都在 origin；只差介面修正第二批，fp 8c9b2d72→b64512c8 已由實作端歸因到 S1）｜世界＝30 天觀察世界（default seed 1337）＋fp 世界｜★兩邊各印樹 sha
---

```
S1 換掉的 12 處（實作端表：docs/superpowers/handbacks/2026-10-07-implementer-to-systems-HANDIN-terminal-ui-fixes-batch2.md §三）
  其中會改世界的：候選掃描跳過「自己人」／掃同勢力家糧／遷移抵達同勢力據點就地成居民／寄存只寄同勢力據點／
  敵人動向排除同勢力／據點控制「主人方在場」／同格互記勢力成員
要量（兩棵樹同 seed、同窗，各一份）：
  ①真隊（不變量 #9：聲明指哪一種）的 extinct／starve／combat 死亡數
  ②無勢力隊之間：就地成居民次數、寄存到別隊據點次數、互相攻擊／掠奪次數、結盟次數
  ③據點易主次數（_has_control 那一處）
  ④每項的差＋前 3 個具體實例（隊 id、tick）
判讀：不下結論，只報數與實例；差很大的那一項標出來，我轉藍圖
★修前那棵樹是「被當同勢力」的世界：差異方向本身就是這次修正的效果，不是迴歸
```
