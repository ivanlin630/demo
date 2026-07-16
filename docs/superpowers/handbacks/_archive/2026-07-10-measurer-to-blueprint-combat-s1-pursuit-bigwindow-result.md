---
from: measurer
to: blueprint
status: consumed
topic: S1 追擊放血人格化——merge-gate 靶B：三端未打亂，但根因是 pursuit 機制本身在 organic 尺度恆 truncate 到 0（第三種結果，非你判準二選一）
---

# 量測回報：S1 pursuit 大窗 organic full_probe（merge-gate 靶B）

工單：`2026-07-10-implementer-to-measurer-combat-s1-pursuit-GO-measure.md`（+ 前情 `-done.md`，兩張一併消化，同一份數字回答）。
worktree `feat/combat-s1-pursuit`（批A@94bb60d、批B@d139392——兩 commit 間純 dict-erase 安全補丁，diff 已讀確認不動 Probe 行為，兩批可合併）。同 18 seed×3月，可與 `defeat_flee_bigwindow{,2,3}.json`（219場 baseline）逐項對照。數字全檔：`tools/orchestrator/runs/pursuit-s1-bigwindow.json`。

## ①三端漂移（gate）—— 未打亂
| | baseline(219場) | S1後(218場) |
|---|---|---|
| end_annihilation | 0 | 0 |
| end_mortal_flee | 182 | 180 |
| end_rout | 29 | 29 |
| end_retreat | 8 | 9 |
| capture.total | 30 | 30 |

全項 delta ≤2，落在新增 code path 改變 RNG 流的噪音範圍內。**表面上「三端不打亂」判準過關。**

## ②③ pursuit 人格分配 / extinct — 根因：機制本身恆零效
`pursuit.n=14`（218 場戰鬥裡追擊放血機制觸發 14 次）、`pursuit.cruelty_sum=8.497`/`greed_sum=6.270`（均值 cruelty≈0.607、greed≈0.448，略偏殘忍側，符合隨機領袖分布）。**但 `pursuit.loss_sum=0`——14 次觸發，14 次放血量皆算出 0，無一例外。**

查 code（`npc_combat_system.gd:570`）：
```
pursuit_loss: int = maxi(int(float(loser.population) * PURSUIT_RATE(0.05) * factor), 0)
```
`int()` 截斷（比 round() 更嚴）。用測到均值 factor≈1.10 反推：需 `loser.population≥18` 才能 loss≥1（0.05×1.10×18≈0.99→1）。前期 defeat-flee 量測已證：organic 裡進 combat 收場的 loser 多半 pop 已小（mortal_flee/rout 主端）——14 次觀測到的 pursuit 全部落在 pop<18 區，故全部 truncate 到 0。`extinct.combat=0`、`death.combat_pop=0` 與此一致（無 pursuit 放血=無額外死因）。

## 判讀：你的二選一判準沒覆蓋到的第三種結果
你信 §27 判準：「殲滅升集中高殘忍且逃為主=接受；無差別暴漲打亂三端=回退」。**兩者皆非**——三端沒被打亂，但**不是因為機制調得好，是因為機制在 organic 尺度上根本沒動任何 pop**（14/14 全 truncate 0）。「軍閥暴虐湧現」訊號現階段量不到，不是因為不存在，是探針前的公式截斷把它砍光了——與先前 `MORTAL_EFF_POP` 殲滅端、`_cas_carry` de-patch 前同一類病（小數捨入/截斷把小尺度效果歸零）。

## 待你 → systems（我不裁）
- 若要「殘忍軍閥窮追見血」這個質感真的在 organic 遊玩中可見，`int()` 截斷需處理（候選：`round()` 取代 `int()`、或比照 `_cas_carry` 模式做跨 pursuit 事件累積器）——這是 systems 設計決策。
- 若接受 pursuit 現階段只在大隊（loser pop≥18+）才生效、小隊/mortal-zone 追擊本就不放血=可接受邊界情境，機制不用動——也是可能落點，但需你明確認可，不是「三端沒打亂」自動等於「機制達標」。

## 產物
- 數字 json：`tools/orchestrator/runs/pursuit-s1-bigwindow.json`
- 原始批次：`.worktrees/combat-s1-pursuit/tools/orchestrator/runs/pursuit_bigwindow_{a,b}.json`
