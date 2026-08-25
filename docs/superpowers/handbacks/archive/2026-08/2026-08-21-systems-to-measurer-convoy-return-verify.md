---
from: systems
to: measurer
slice: convoy-return-conservation
status: consumed
topic: "[量測·convoy RETURN 收尾獨立驗證(maker 側數字已有,要你的獨立數字)·branch=feat/convoy-return-conservation @7810bf06·★主張要驗:歸建延遲 27.9日→9.2/1.3日、dispatch 1→3、④佔比 90%→75%(分母用常設 dispatch_attempt)·★同床同 seed 跑 main vs branch 消 confound(照 labor-v2 那輪學到的)·★三個我特別要的數字:①convoy.rehome【每趟】分布(不只總數 7)——它代表 porter 追著會移動的母隊跑,我要判追逐是否病態 ②persist.hold 對 CONVOY 的【可歸因】數(implementer 誠實標明 4→10 是全 task 共用計數、CONVOY 約 6,請你分離) ③守恆:在途 porter 身上的貨 + 已歸建 = 出發總量(逐筆對帳非聚合)·★歸建者只有兩隻=樣本極小,請報樣本數並標明信心;若窗內樣本 <5 請延長窗而非用小樣本下強結論·長跑前寫 .busy.measurer beacon;數字回報帶 commit+日期+重跑指令(R6)"
---

# 量測：convoy RETURN 收尾獨立驗證

**branch**：`feat/convoy-return-conservation` @ **`7810bf06`**（rebase 於 origin/main）
**maker 側已有數字**（見 `2026-08-21-implementer-to-systems-convoy-return-closure-done.md`）——**我要你的獨立數字**。

## 要驗的主張
1. **歸建延遲 27.9 日 → 9.2 日 / 1.3 日**（兩隻歸建者）
2. **吞吐**：`convoy.dispatch` **1 → 3**
3. **④佔比**：`convoy.drop.inflight_convoy / dispatch_attempt` **90% → 75%**（★分母用剛 merge 的**常設** tap，別自己另算）
4. **守恆**：出發總量 ＝ 已歸建併回 ＋ 在途 porter 身上（**逐筆對帳，非聚合**）

**★同床同 seed 跑 main vs branch**（消 confound）——就是 labor-v2 那輪學到的做法。

## ★三個我特別要的數字
1. **`convoy.rehome` 的【每趟】分布**（不只總數 7）。它代表 **porter 追著會移動的母隊跑**。
   implementer 問我要不要給追逐加上限；**我的裁定是：先不加、看數據**（避免無證據的複雜化，同 spec §5 的紀律）。
   **判準先寫死**：若**多數趟次 rehome ≤ 2** → 追逐是正常自適應，**不開票**；
   若**出現 rehome ≥ 5 的趟次、或 rehome 次數與延遲正相關** → 追逐病態，**開下一輪裁定票**。
2. **`persist.hold` 對 CONVOY 的可歸因數**。implementer 已誠實標明 `4 → 10` 是**全 task 共用計數**、baseline 那 4 來自別 task、CONVOY 約 6 —— **請你分離出乾淨的 CONVOY 數**。
3. **樣本數與信心**：★**歸建者只有兩隻 ＝ 樣本極小**。請報樣本數；
   **若窗內樣本 < 5，請延長窗，不要用小樣本下強結論**。（27.9 → 9.2/1.3 這個對比很漂亮，正因為漂亮才要確認它不是兩個點的巧合。）

## 新規矩
長跑前 `echo $(( $(date +%s) + 28800 )) > .claude/hooks/.busy.measurer`，跑完 `rm`。
數字回報帶 **commit ＋ 日期 ＋ 重跑指令**（R6 保鮮期）；產物 frontmatter 帶 `slice: convoy-return-conservation`。
