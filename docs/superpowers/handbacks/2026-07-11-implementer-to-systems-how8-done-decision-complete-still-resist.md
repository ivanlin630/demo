---
from: implementer
to: systems
status: consumed
topic: [§HOW-8 done, 翻案判準達] 完整 utility 決策到位(slack/yield 非trivial)仍 dispatch~0=真世界抗拒→升 user
---

# §HOW-8 完整 utility done + 翻案測試：決策到位仍 ~0 = 真世界抗拒（非薄決策）

§HOW-8 四改全上（@076b237）+ 全驗綠（parse/bed fail=0/multi-sanity inv=0/constitution/determinism IDENTICAL）。**這是 consolidation 最後一塊**——你要的「完整 utility 測決策到位再判世界抗拒」。**結果：決策到位仍 ~0 → 你決策樹的「真世界抗拒→升 user」支達成。**

## §HOW-8 做了什麼
- 併入 applicable ungate（絕境 OR 威脅認慫求保護）。
- +context `resource_slack`（空容量×舒適，你公式）+`absorb_yield`（target 自養能力=產能−pop 負擔+帶地，你公式，≠richness）。
- join_drive（食壓 OR 威脅）；absorb_drive=resource_slack×絕收益(yield≥0)×ambition_gap；仁慈(1-殘忍)入 absorb weight。
- 常數 SLACK_COMFORT_DAYS(7)/YIELD_NORM(20)/YIELD_LAND_BONUS(0.3)。

## ★翻案判準鐵證：決策到位（utility 真算）仍 dispatch=0
| 探針 | 數 | 判讀 |
|---|---|---|
| `absorb.util_n` | 9383 | 評估次數 |
| `absorb.slack_pos`(>0.05) | 6439 (**68%**) | 多數強隊**有容量+舒適**收人（resource_slack 真算非0） |
| `absorb.yield_pos`(>0) | 7655 (**82%**) | 多數 target **值得吸**（absorb_yield 真算非0） |
| `absorb.dispatch` | **0** | 吸納**有正 utility 卻恆輸 rank** |
| `merge.consolidate_dispatch`(併入) | 107 | 威脅-ungate 助升，但 completion~0 |

- **utility 非 trivial、非 formula-bug**：slack 68% 正、yield 82% 正——強隊真的算得出「我有餘裕、target 划算」。
- **仍 dispatch=0**：absorb_drive(≈1.2×0.5×0.65×0.75≈0.29,weight≈0.5→util≈0.15) 恆輸 攻擊/征服(faction_duty 1.5+…)。**強隊理性選征服**（收益更高）。
- **per 你工單守則「征服真划算而贏=保留不動」**：這是**正確決策**，非 bug、非薄決策 artifact。

## 結論（你 §HOW-8 決策樹的終點支）
你決策樹：「起量→翻案（決策沒到位）；仍~0（決策到位仍強寧征服/弱寧覓食）→真世界抗拒→升 user」。
- **決策已到位**（完整 utility：slack/yield/ambition/威脅 全真算，68%/82% 正）。
- **仍 ~0**（強寧征服 dispatch=0、弱 push survival-locked completion~0）。
- ∴ **真世界抗拒確認**（非薄決策、非 formula bug、8 層+雙向+完整 utility 全試遍）。

## → 升 user（我不能單方裁，你決策樹定的終點；我不在終端問 user，走你這條 handback）
**核心 user 問題**：小-絕境隊 + 征服收益 > 和平吸納 的世界結構下，**和平 consolidation 本質非 emergent**。三選項（我 bidirectional 報告已列，此處重申給 user）：
- **(a) 接受罕見 flavor**：機制全備（併入/吸納/分流/loyalty/完整 utility），volume 隨世界（現況~0）。最小改動、誠實。**推薦**（決策系統正確，湧現與否是世界事實）。
- **(b) 改世界動力**：降征服收益 or 給 consolidation rank 優勢——但這違「禁 flat 硬優勢」、傷 combat/征服平衡。高風險。
- **(c) 退役 consolidation 野望**：移除併入/吸納，保留 join dissolve flavor。承認結構事實、減 code。

## 現況
- worktree @076b237：§HOW-1~8 全 + 三 movement 修 + 統一併入 + 吸納 + 完整 utility + 分流 + loyalty + guard + 完整雙向漏斗+utility 分布探針。**gates/determinism 全綠、實作零 bug、決策系統完整正確**。
- **建議**：measurer big-window（03b detach+resume）雙向重量確認 → 你/blueprint 判翻案判準 → 升 user 裁 (a)/(b)/(c)。
- **merge 閘**（你定）：reviewer 對完整 S-A diff CLEAN + measurer 全站 + blueprint 翻案判準判。決策統一 win（8 層 de-patch/join+整併合一/loyalty/完整 utility）備好一起 merge。

框外總終（8 層 + 雙向 + 完整 utility）：這世界的決策系統**完整且正確**，它**理性地**得出「弱隊逃/散、強隊征服」——和平 consolidation 不是這結構的 emergent。**這是 user 願景事實裁決，工程已到極致。**
