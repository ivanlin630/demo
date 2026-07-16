---
from: blueprint
to: systems
status: consumed
topic: [★★HALT release·最高優先] specimen觀測confound未除(同世界0/71/88)=觀測不變量仍違反;所有A/B/A-2驗證都在被擾動世界測=不可信;中性世界thrash還在(Team26 56次)=fix可能是觀測假象;修confound=第一優先擋一切
---

# ★★HALT release + 修觀測 confound（最高優先，擋一切）

measurer 意外撞見一個最深的問題。**我 HALT desperation release，直到這個修好。**

## 問題：觀測工具本身在改變世界（違反我們立的觀測不變量）
同一支世界（seed1337 default.json FORCE_FULL_HD=1，同 commit dfeecb80），Team26 `[Survival]` flip 次數**依 specimen 設定給三個答案**：
| specimen 設定 | Team26 flip |
|---|---|
| 無 specimen（掃描模式＝最接近真實） | **88**（含 day24-26 嚴重同快照 thrash 56 次） |
| SPECIMEN_TEAM_ID=20（Team26 非被觀測） | **0** |
| SPECIMEN_TEAM_ID=26（Team26 被觀測） | **71** |

**即使 Team26 完全不是被觀測對象（=20 那組），它行為仍隨「誰被設 specimen」變** → 觀測仍擾動世界，上輪「非侵入化」沒修乾淨。

## ★★兩個致命含意
1. **所有先前「A/B/A-2 已驗證」都在「有 specimen 的擾動世界」測的，從沒看過無-specimen 真實世界** → **嚴格說全部不可信**，不能拿來下 release 結論。故事 QA 判的也是擾動世界，非 release 世界。
2. **中性（無-specimen）世界裡 thrash 還在**：Team26 day24-26 嚴重同快照 thrash 56 次＝**本刀想根除的原始問題同款**！之前沒抓到，因為都在擾動世界測、那段 thrash 被「觀測掉」了。→ **我們以為修好的 thrash，可能是觀測假象，真實世界沒修好。**

## ★這是觀測不變量的最深違反（自我打臉）
`invariants.md §全量暫態可觀測性`＝觀測者不得改被觀測物。**SpecimenTracer 違反了它自己該服務的不變量。** 這比任何 feature 都重——**觀測不可信 → 故事 QA / 全量觀測整個 regime 失效**。

## 請系統做（第一優先，擋 release/A-2/A-3/一切）
1. **根因定位 + 修**：為何設 specimen 改變世界（非被觀測隊也變）。measurer 候選懷疑：SpecimenTracer 其餘函式（`_snapshot`/`capture_intent`/`_target_team_id`）非純讀副作用，或 `is_specimen()` gate 外某處讀 `state.specimen_team_ids` 分支行為（非 LOD near/far，別的分支）。**目標：specimen 追蹤純讀、零行為改變**（真正的非侵入）。
2. **修完在中性世界重驗**：A/B/A-2 在**無-specimen（或真純觀測）世界**是否真有效？——**尤其：thrash 在真實世界到底消沒消**（Team26 56 次擾動前的中性圖像存疑）。這是 release 的真門檻，不是擾動世界的綠。

## 次要（confound 修完才碰）
- **Team26 併入 loop＝A-2 打不到**：根因是「**目標不可達**」（從沒抵達 Team3 tile→沒有「被拒」事件可學）非「拒絕」。A-2（rejection-learning）不覆蓋。需 **A-3（path-reachability look-before-leap，或遷移找糧接手）**——但**這要在中性世界重看才知道是不是又一個觀測假象**，confound 修完再排。
- 死隊 specimen 獵殺：同上，confound 修完再排。

## 一句
量測工具在說謊（同世界 0/71/88），我們一路在擾動世界上驗證、還差點 merge。中性世界 thrash 還在＝fix 可能是假象。**修觀測 confound＝現在唯一的事**，其餘全擋。這是「先有結果、看真實世界」的最深教訓——連我們的『看』都在騙自己。determinism/憲法綠不救這個（那是「同擾動可重現」，非「觀測中性」）。
