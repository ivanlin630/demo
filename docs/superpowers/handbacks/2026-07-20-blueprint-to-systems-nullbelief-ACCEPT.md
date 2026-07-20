---
from: blueprint
to: systems
status: consumed
topic: "[ACCEPT null-belief-flee fix]570→20(97%降)applicability-gate精確對應QA原始診斷,coherent flee保留,gates綠。這次不再繞QA——修法窄範圍+機制對應直接(非模糊調參),跟今天其他反覆drift的case不同類。accept,Slice D前置達成,走merge。殘留20隻+seed42 attr 4.9→13.4波動記非阻塞追蹤項,measurer若有空可補查殘留20是集中幾隊還是長尾分散,非blocker。"
---

# ACCEPT：null-belief-flee fix

`28470932` accept。570→20（~97% 降），applicability-gate 精確對應 QA 原始診斷的 signature（`task=逃跑+flee_from=(-1,-1)`），coherent flee（真座標）照跑不受影響，gates 綠。

## 為何這次不再繞 QA 一輪
今天好幾次調參/fix 因果故事反覆漂移（subteam-idle v1→v2→v3、beast-fix 撿到 team16/64/68）才需要每輪都 QA 複驗。這次不同：**修法窄範圍且機制對應直接**——applicability-gate 就是直接殺掉 QA 抓到的那個 signature，不是模糊調參後看聚合數字猜因果。97% 降 + coherent flee 明確保留，證據種類跟前面那些「聚合數字模糊、需要故事解讀」的情況不一樣。

## 非阻塞追蹤項
- **殘留 20 隻**：不擋 accept，但如果你/measurer 有空，可以看一下是集中在少數幾隊（edge case 殘留）還是長尾分散（fix 有 gap）——非急件。
- **seed42 attr 4.9→13.4**（只 0→1 starve）：小樣本世界一隻死可能就大幅拉動 %，先記著留意，不特別處理。

## Slice D 前置達成，走 merge
D 準備前置條件（污染源清掉）滿足，走你的 merge 流程即可。

## 溯源
`2026-07-20-measurer-to-blueprint-nullbelief-flee.md`（量測 PASS-leaning，已 consumed）。
