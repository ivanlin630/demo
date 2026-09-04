---
from: systems
to: blueprint
status: consumed
slice: peaceful-regime-injection
topic: ★政權注入 MERGED + pushed(15 支閘全綠 277s);★★headless 那支紅過而【不是行為變了】——是我修好 UTF-8 讓以亂碼記錄的 baseline 全部失配,已驗內容同 9 條同計數才重錄;★★★施主線那 2 筆交集的成因仍未查(三變因同換,我不歸給最近的改動)
---

# ①已落地（exact path）

```
main @ pushed                     ← ★整包已在 origin/main,worktree 可以 rebase 了
config/peaceful_economy_regime.json          ←★新檔;舊 peaceful_economy.json 一字未動
docs/process/.headless-baseline-list.txt     ←★重錄(理由寫在檔頭 4 行註解裡)
```

# ②政權注入驗收 —— **兩格皆綠且皆為機械證據**

| 問 | 答 |
|---|---|
| 每個政權真的有成員嗎 | ✅ **逐政權印成員數**（A 6／B 4，各自 leader 另計）——★**不印總數**：總數看不出「一個 8 人一個 0 人」 |
| 義務類 option 真的被秤了嗎 | ✅ `徵收`／`歸建` cand 舊檔 **0** → 新檔 **36／64**，且各贏 **23／20** |

⇒ ★★**這一整類是【從無到有】，不是「變得更常贏」。**
變動最大三項：**返家補給 win 227→56｜備戰 127→280｜建設 9→133**。

# ③★★★三件我不歸因、留給你裁的

1. **施主線的階梯交集 0→2** —— ★**同一輪換了三個變因**（政權注入＋順序相依 bug 修＋wrapper UTF-8）
   ⇒ ★★**我不把它歸給最近的那個改動。** 要拆的話得逐階印條件名，我還沒派。**要不要開？**
2. **90 日成本已知**：peaceful_regime **431 秒跑完**；warring 上一次死在 **day 53/90**（外部砍、無 crash）。
   ⇒ ★**成本驅動是隊數不是天數**（23 隊 vs 64 隊）。warring pilot 已重派、**`EXCLUSIVE=unknown`**
   （implementer 自己降的：2.3 小時的跑在共用 main dir 上**無法保證獨佔**，宣告成 yes 是宣告他控制不了的事）。
3. **⑤新基線長考的 B 前置件**：peaceful 政權 spec ✅已落地待你驗收／90 日 run-reliability ⏳warring 仍欠。
   ★**正考 GO 是用戶扳機，我不代按。**

# ④★★這輪抓到的一條通則（已進 detail 檔）

**修好一個編碼 bug ⇒ 所有以壞編碼記錄的基準線同時失效。**
★而它長得**跟真迴歸一模一樣**（逐行 diff 全紅）⇒ ★★**先證「內容沒變」才可以重錄**
（ASCII 骨架＋計數逐條比對，9 條全同），**否則重錄會蓋掉真迴歸。**
★★★而重錄要用 **gate 自己的管線**產生：我先用 python 產，差在 `awk` 會把連續空白壓成單一空白 ——
**「兩端要用同一種標識」連空白處理都算。**
