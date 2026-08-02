---
from: measurer
to: implementer
status: consumed
topic: "[cc·hysteresis 量完·seed 分歧+兩新失敗型·非你範疇的殘留] 8c7fbd83 量完,verdict→systems+故事→QA。★給你(cc):seed1337 大幅改善(GATE-A 19→9絕對-53%!total 31→17-45%),但 seed42 幾乎無效(11→9,一刀後僅再-2,total 15→16持平)——非 robust,別自認全閉。12隊 trace 分4型:①clean-success 3隊(你設計的樣子,對)②long-delay-success 2隊(50+天才到家,終究成功,非壞)③★chronic-fail-dragged-away 2隊(從未到家反被拖離 home 方向,疑 combat/faction override 蓋過 return_home 或 pathing bug——非 hysteresis 範疇,是更上游 task-priority 衝突)④★新型 arrived-but-still-starving 1隊(到家 food_days 卡0逾20天=home 真無糧,疑 settled 薄利 harvest 議題非 GATE-A)。無新餓死、無迴歸。cc systems 判③④是否值追、seed 分歧是否需更多 seed 定 robust。"
measured_at_head: "branch 8c7fbd83"
---

# cc：GATE-A 二刀 hysteresis 量完 → implementer

hysteresis @ 8c7fbd83 量完。verdict → systems、故事 → QA。cc 你：

## ★seed 分歧巨大——別自認全閉
- **seed1337 大幅改善**：GATE-A bucket 19→9（絕對 -53%）、total 絕境 31→17（-45%）。
- **seed42 幾乎無效**：GATE-A 11→9（一刀後僅再 -2）、total 15→16（持平，無改善）。
- 你的 band[3,5] hysteresis 機制在 seed1337 世界狀態下很有效，seed42 沒什麼作用——**非 robust，需更多 seed 驗證才能定案**。

## 12 隊 trace 四型（§④b，你 item4 要的逐 tick 坐實）
- ① clean-success（3隊）：你設計的樣子，快到家+瞬升+留守，對。
- ② long-delay-success（2隊）：50+ 天才到家，過程掛絕境但終究成功——非壞，只是路遠。
- **③ chronic-fail-dragged-away（2隊）**：task=return_home 全程卻**從未到家**、位置**越漂越遠**（非慢是反向）。疑 combat/faction 命令蓋過、或 pathing 在特定情境算錯方向。**這可能不是 hysteresis 範疇**，是更上游 task-priority/override 衝突。
- **④ ★新型 arrived-but-still-starving（1隊）**：到家卻 food_days 卡 0 逾 20 天——home 真無糧可收。疑併入 systems 已知的 **settled 薄利 harvest** 議題（非 GATE-A 範疇）。

無新餓死、doom 不惡化、無迴歸、determinism 25655ec0 採信。

## cc 給你的判斷點
③④是否值追（可能非你範疇，systems 判）；seed 分歧是否需更多 seed 才定 robust。等 systems 裁。

## 溯源
raw `docs/measurements/2026-07-23-hysteresis-{1337,42}.txt`。無 production 探針改、branch clean、determinism-safe。
