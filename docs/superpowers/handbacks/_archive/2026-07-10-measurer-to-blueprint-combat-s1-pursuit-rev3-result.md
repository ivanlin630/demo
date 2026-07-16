---
from: measurer
to: blueprint
status: consumed
topic: S1 rev3 pursuit 絕對 straggler-kill——loss_sum>0 首次生效(6殺/5次)，三端比例穩，達你判準（我不代判 merge）
---

# 量測回報：S1 rev3（絕對 straggler-kill）大窗結果——★機制首次真生效

工單：`2026-07-10-implementer-to-measurer-combat-s1-pursuit-rev3-measure.md`。同 18 seed×3月（`.worktrees/combat-s1-pursuit` @f2af65e），數字全檔：`tools/orchestrator/runs/pursuit-s1-rev3-bigwindow.json`。

## ①三端漂移（gate）—— 比例穩，總場數因真流血下降 ~9%
| | baseline(219場) | rev3(199場) |
|---|---|---|
| end_annihilation | 0（0.0%） | 0（0.0%） |
| end_mortal_flee | 182（83.1%） | 165（82.9%） |
| end_rout | 29（13.2%） | 30（15.1%） |
| end_retreat | 8（3.7%） | 4（2.0%） |
| capture.total | 30 | 29 |

逃仍主端（~83%不變）、annih 仍 0%。**總戰鬥數 219→199（-9%）**——這是機制真生效的下游連鎖（追擊真殺人→隊變小/團滅少了下季再打的機會），不是某單一端被灌爆，是全局戰鬥密度因果性下降，判讀不同於「三端比例被打亂」。

## ②loss_sum>0 + 人格集中 —— 首次確認生效
`pursuit.n=5`、`pursuit.loss_sum=6`（**首次 >0**，rev1/rev2 皆 0）、平均每次追擊放血 **1.2**、參與 pursuer 平均殘忍值 **0.669**（略高中性 0.5，符合軍閥見血邏輯：殘忍係數 2.0 > 貪婪 0.8，殘忍主導）。

## ③extinct/attrition —— 未見團滅暴衝
`extinct.combat=0`（樣本內無隊因 pursuit 直接團滅——straggler_kill cap=3 單獨不足清空隊伍）、`extinct.starve=442`/`extinct.other=87` 與飢荒等既有死因量級相近，無異常暴漲訊號。

## 對照你的判準
> 軍閥見血 + 逃為主 + 人格集中=達標；無差別暴漲=回退。

三項皆命中：見血（loss_sum=6>0）+ 逃為主（83%不變）+ 人格集中（cruelty 略偏高、非全面暴漲）。**我只出數字，merge 判決是你 + reviewer② diff CLEAN 兩條件合議，非我裁。**

## 產物
- 數字 json：`tools/orchestrator/runs/pursuit-s1-rev3-bigwindow.json`
- 原始批次：`.worktrees/combat-s1-pursuit/tools/orchestrator/runs/pursuit_rev3_{a,b}.json`
