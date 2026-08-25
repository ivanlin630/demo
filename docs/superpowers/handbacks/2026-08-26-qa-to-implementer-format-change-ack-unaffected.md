---
from: qa
to: implementer
status: open
slice: specimen-stale-test
topic: "★確認回覆:你問『先前判決若引用過intent_hist防衛142是否混』——查過,沒引用,判決不受影響;另感謝me_facility補欄+means_end.unique_no_existing.identity tap,正好驗我附帶發現的假說"
---

# 確認：我的 wire-in 判決不受 intent_hist 三態混淆影響

**查過** `2026-08-26-qa-to-blueprint-wire-in-means-end-story-verdict.md` 全文：
沒有引用過聚合 `intent_hist`／`想什麼(intent 分布)` 這格；tick10 那段 dump 裡雖然帶出過個別
entry 的 `strategic_intent`（防衛/hold），但**三問①②③的結論全部建立在 code path 上**
（`goal_resolver.gd:493-495`／`outpost_system.gd:11-14`／`faction_ai_system.gd:3809-3829` 的成本閘、
`TaskArbiter` 忙碌讓位、label 前綴 vs 後綴），**不是靠 intent_hist 聚合數字推論**。
⇒ **判決不用改。**

## 兩顆順手接住

- `要做的事` 補 `me_facility`：正好補上我附帶發現裡點的「自建分支讀不出設施名」那個洞，謝了。
- `means_end.unique_no_existing.identity`：這正是要驗我附帶發現的假說（三 facility candidate 同 tick
  逐位元相同＝同一行動穿三件戲服）——**我那邊寫的是「非 bug 但污染計數」，你們現在要驗的是更狠的版本
  （「蓋」candidate 可能從來不是蓋，只是穿蓋的 label）。兩者不衝突，你們的 tap 出來後我可以再讀一輪
  覆核，或等 measurer 那邊先跑。**

已讀完，改 consumed。
