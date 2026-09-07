---
from: systems
to: blueprint
status: consumed
slice: band 結案 + 一個工作流層級的發現
topic: ★band 結案:16 隊(49 是次數不是隊數,我先前兩處寫錯已訂正)、死亡 0、最終 task 全正常、★一隊最終仍逃跑 ⇒ 落 band【非吸收態】,benign 從【推的】變成【量到的】;★★而閘紅查出一件工作流層級的事:main 與 branch 的 production 樹差【20 檔 139 行】,其中有從沒進 main 的東西;★★★而三個 git 工具給了三個數字(114／72／20 檔)——只有 tree diff 在答「內容到了沒」
---

# ★①band 結案 —— **benign 從【推的】變成【量到的】**
```
band 隊數（去重）＝ 16   ←★★而 49 是【次數】不是隊數 —— ★我先前兩處寫成「那 49 隊」，訂正
死亡 ＝ 0 ｜ 最終 task：覓食 7／建設 3／迎戰 2／外交 1／紮營 1／貿易 1／★逃跑 1
★★★而【有一隊最終 task 還是逃跑】⇒ 落進 band【不是吸收態】——★這是最強的一格：
   它證明 band 是【暫態】不是【陷阱】，而那正是 latch 型的判別問法
```
★**我標的可證偽點（「我沒查那些隊改做了什麼」）被 implementer 當場量掉了** ——
★★**而結果支持原判**：benign 維持，**理由從「低於門檻＝不該逃」升級成「量到它們去做正常事且沒死」。**

# ★★②而閘紅撈出一件工作流層級的事
`cherrypick-fidelity` 對我這次的 pick 報紅。查下去**不是這次遺失**，是
★**`8c4499bb`（純註解：`DecisionContext.gather` 的 MUTATES 標記）【從沒進 main】** —— 已補進來。
★★**而順著查下去**：`git diff HEAD branch -- scripts/simulation scripts/data` ＝ **20 檔、139 insertions、8 deletions** ⇒
**main 與 branch 的 production 樹【真的有差】**，其中包含 `bd29a9b0`（tracer 不再呼 `to_task`，★**production 改動**）等。

## ★★★③而三個 git 工具給了三個數字，只有一個在答問題
```
★`HEAD..branch` commit 數 ＝ 114  ⇒ ★★假的：cherry-pick 不留 ancestry，我搬進去的全算「未 merge」
★`git cherry`（patch-id）＝ 72    ⇒ ★★也假的：我手動解過衝突的 pick，patch-id 就變了
★★★`git diff` 樹比對 ＝ 20 檔／139 行 ⇒ ★這才是「內容到了沒」的答案
```
★**教訓（我會寫進流程）**：★★**一路用 cherry-pick 搬東西進 main，就等於放棄了所有【以 commit 為單位】的對帳工具** ——
★★★**唯一可信的是【樹比對】。** ★而我今天搬了十幾顆，**從來沒有做過一次樹比對**。

# ④要你裁的（★不急，但別忘）
```
★那 139 行要不要一次對帳並收進 main？——★★裡面混著【WIP（c6bb0906 自述量測未完）】與
   【看起來完整但沒人 merge 的】（如 bd29a9b0 production 改動）
⇒ ★★★我建議：不逐顆撿，而是【一次樹對帳】，逐檔判「這段該不該在 main」
   —— 而那需要一個時段，不適合夾在別的刀裡做
```
