---
from: systems
to: blueprint
status: open
topic: [真根·零跑+算] command-tenure code正確build未merge(驗收失敗);B2仍卡真根=成長速率×leader週轉交叉—0.0003/日爬門檻缺口需170-430日>>leader在任;succession不繼承統領;第四層=絕境早崩吃掉一切累積
---

# command-tenure B2 仍卡真根：成長太慢 × leader 週轉（第四層，但指向絕境早崩上游根）

## 先澄清：code 狀態
- **code 正確 build 在 worktree `feat/command-tenure-growth`**：`_grow_leadership_tenure` 落點對（loop2:670 三分支**外層**、function:2703-2711 公式對），reviewer 提示的巢狀陷阱沒踩。
- **但 NOT merged into main**（git 確認）。blueprint「merge 流程走完」不準——是 build + 驗收,**驗收 B2 沒解 → 本就不該 merge**。measurer 驗收跑 worktree（有 code）→ B2 仍 100% = 真實信號,非「code 沒跑」。**先排除 code-presence 假象**（patch-gate-first：先確認在跑,已確認）。

## 真根：成長速率 × 門檻缺口 × leader 週轉 三者交叉（算給你）
**速率**：`LEADERSHIP_TENURE_GROWTH=0.0006`/日 × 魅力(~0.6) × 毅力係數(~0.8) × skill_mult(~1) ≈ **+0.0003/日**（implementer 單元 50 INTERVAL:0.25→0.265 一致）。
**門檻缺口**：初始統領 mean ~0.25 → B2 門檻 = 0.4−(野心−0.5)×0.2。B3 要野心≥0.6 → 門檻 ≤ 0.38（野心0.6）～0.30（野心1.0）。缺口 **0.05～0.13**。
**爬過所需**：0.05/0.0003 ≈ **170 日**（最順:野心1.0）；0.13/0.0003 ≈ **430 日**（野心0.6，>12mo!）。
**leader 在任**：本世界月1-3 attrition ~45%（絕境早崩）→ leader 頻繁陣亡。**在任 << 170-430 日** → 統領永遠爬不到門檻就換人。

∴ implementer 單元「12mo≈+0.10 爬過」**假設 360 日不間斷在任**——organic leader 死得早,假設不成立。**速率對孤立 leader 沒錯,對週轉世界太慢。**

## succession 不繼承統領（坐實重置，file:line）
`event_system.gd:40-64` leader 陣亡繼承：
1. **有 named 成員**（:41-52）：選**統領最高的 named 成員**接任。但 **named 成員不長統領**（tenure 只長 `team.leader_id`=現任 leader，named 成員從不當 leader→凍在初始 ~0.25）→ successor = 一群 ~0.25 fresh 中挑最高,**非累積**。
2. **無 named**（:57-64）：`PersonGenerator.generate_for_team` **全新 anon 晉升**（統領 ~0.25 fresh）。
- ∴ leader 死 → 統領**重置回 fresh ~0.25**，前任累積的 tenure 蒸發。**跨 leader 世代零繼承。**

## ★這是第四層,但真正上游根 = 絕境早崩（誠實結構判讀）
farming(一)→A門人口82.7%(二)→B2繁榮閘(三)→**leader週轉吃成長(四)**——每層修完露下一層,但**四層共享同一上游根:月1-3 急性餓死崩（attrition 45%）**。
- pop 攢不到 8（A門）、統領累積不過門檻（B2/四層）、readiness 上不去（B4）——**全是「累積型」門,全被早崩重置吃掉**。
- **繼續逐層補下游 gate = 打地鼠**（改了但沒觸及真根,你已警覺）。真根是**急性早崩讓任何累積都來不及**。

## 修向（兩條路,你/用戶裁——這是策略分岔）
1. **停下降、轉攻上游急性崩**（建議）：月1-3 attrition 45% 是所有累積門的共同殺手。修早期存活（開局 buffer/急性餓死緩衝/早期食物地板）讓隊活過頭 3 月 → pop 攢得起來、leader 活得夠久累積統領、readiness 爬得上 → **一修多解**（四層門一起鬆）。
2. **繼續逐層 de-patch 下游**（打地鼠風險）：command-tenure 這層的具體修=①succession 統領部分繼承（institutional memory，拔重置）②建國/當上 leader 授統領 XP 躍升（非慢爬）③速率大幅提。但就算全做,上游早崩沒解,還會卡 A門/B4。

## 序建議
1. **measurer 量 leader 平均在任 tenure 分布**（blueprint 候選假說坐實）——比對「爬門檻需 170-430 日」。若在任中位數 << 170 日 → turnover 根鐵證。
2. **command-tenure worktree 先擱置別 merge**（單獨無效；等策略定：併入上游早崩修,或補繼承+授XP 才有意義）。
3. **你/用戶裁策略分岔**：轉攻急性早崩上游（一修多解）vs 繼續逐層。我強烈建議轉上游——四層打地鼠已證下游修無效,measure 也標長程週期（月1急性+月10惡化）共享此根。
