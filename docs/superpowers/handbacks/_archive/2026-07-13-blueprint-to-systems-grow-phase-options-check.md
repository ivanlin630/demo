---
from: blueprint
to: systems
status: consumed
topic: [code審·零跑] 成長(GROW)phase偏置實際導向哪些option——繁殖是唯一出路還是其中一條？用戶質疑「成長=只能靠繁殖」這個等號是否成立
---

# GROW phase 偏置範圍查——繁殖是不是唯一出路

## 背景
上輪查明：pop<8卡在GROW phase，`_score_breed`(繁殖)需safety>0.7在warring世界難達→判定「pop卡死」。**用戶質疑**：人口成長不一定只能靠繁殖（生小孩），照理還有招募/吸收anon流民/隊伍合併等其他管道——「成長=只能靠繁殖」這個等號可能是我/systems上輪過度簡化。

## 待查（零跑，file:line）
1. **GROW phase的`plan_phase_drive`偏置term實際導向哪些option**——查`_phase_option_bias`（或等價實作位置）裡GROW對應的option清單，是否只有「繁殖(breed)」一項，還是包含其他pop成長管道（招募/吸收anon/合併/掠奪人口等）。
2. **若GROW偏置只導向breed**——那上輪判讀成立（繁殖是唯一出路，卡住=真卡死）。
3. **若GROW偏置涵蓋多條pop成長路徑**——查其他路徑（招募/吸收anon等）在warring世界的可行性是否也一樣被鎖，還是這些路徑其實暢通，只是`bias_hit`統計沒把它們算進去（上輪測到的25-33%命中率可能低估了實際可用出路）。
4. **是否有anon晉升/吸收機制可以繞開繁殖**——之前有memory提過`generate_for_team`晉升釋放anon（`project_anon_cohort_refactor`），查這個管道是否也算「pop成長」的一種，GROW phase有沒有把它納入考量。

## 為何現在查
上輪判讀「繁殖被鎖=真瓶頸」是我沒細查就轉述systems原話的簡化說法，用戶合理質疑「成長」不該直接等於「繁殖」。這個等號沒查證前，不能斷定「established卡死的下個真根=繁殖」，需要先確認GROW phase的完整選項範圍。

## 序
零跑出GROW phase完整option清單+可行性 → to:blueprint → 我重新判讀「成長phase卡死」的真正含義（純繁殖鎖 vs 更廣的pop成長管道問題）。這題查完後回到S3繼續，不影響S3本身進度（S3是survival-bypass，跟GROW phase選項無關）。
