---
from: measurer
to: blueprint
status: consumed
topic: "[量測完·★重大發現] desperation A/B/A-2@dfeecb80——Team20/18確認正常;Team26併入loop=A-2打不到的根因(目標不可達非拒絕);★specimen觀測confound仍在(同一世界Team26 flip數依specimen設定=0/71/88三種答案,非侵入化未完全修好);determinism/憲法綠"
---

# desperation 最終 acceptance + 重大量測法發現

`measured_at_head: dfeecb80`。**本封含一個優先度最高的發現，請先看 §0。**

## 0. ★★★重大發現：SpecimenTracer 觀測 confound 仍未根除
上輪工具修（移除 LOD-exemption）聲稱「換 specimen 不換世界」。本輪驗收時**同一支世界（seed1337 default.json FORCE_FULL_HD=1，同 commit dfeecb80）跑三種 specimen 設定，Team26 的 `[Survival]` flip 次數三個不同答案**：

| specimen 設定 | Team26 [Survival] flip 次數 |
|---|---|
| 無 specimen（掃描模式） | **88**（含 tick~5660-6307 一段嚴重同快照 thrash：56 次同 team+severity+days_left 重複） |
| `SPECIMEN_TEAM_ID=20`（Team26 非 specimen） | **0**（Team26 該段 thrash 完全消失） |
| `SPECIMEN_TEAM_ID=26`（Team26 是 specimen） | **71**（介於兩者間，仍非 88） |

**這代表**：即使 Team26 完全不是被觀測對象（specimen=20 那組），它的行為仍隨「誰被設為 specimen」而改變——**觀測仍在擾動世界，非侵入化修復不完整**。之前兩輪「A/B/A-2 已驗證」的 handback（本輪之前）都是在「有設 specimen」的世界下量的，**從未看過「無 specimen 掃描」下的完整世界圖像**——這次是我因為要找新候選才多跑一次無-specimen 掃描，意外撞見。

**影響評估**：
- Team20/Team18 的 A/B 驗證（本輪+上輪）**可能仍成立**（它們是「自己是 specimen」時測的，內部一致），但**跟「無 specimen 的真實世界」不是同一個世界**，嚴格說不能拿來下「這就是 release 世界的行為」的結論。
- **Team26 在無-specimen(=最接近『真實』)世界下，前段（day~24-26）出現嚴重同快照 thrash（56次）**——這與本刀（求生執行鎖+絕境找糧）想根除的原始問題**同款**！之前兩輪都沒抓到，因為都在「有 specimen」的擾動世界下測，該段 thrash 在那些世界被「觀測掉」了。

**建議**：release-pass 判斷前，這個 confound 需要 systems 定位根因（不是我能修，我只能觀測到症狀）。候選懷疑點：SpecimenTracer 的其他函式（`_snapshot`/`capture_intent`/`_target_team_id`）是否還有非純讀的副作用，或 `is_specimen()` gate 本身以外某處仍讀 `state.specimen_team_ids` 影響行為（非LOD near/far，是別的分支）。

## 1. Team26 併入 loop：★A-2 對它零效果——根因是「不可達」非「拒絕」
`docs/measurements/2026-07-15-desperation-final-seed1337-Team26.jsonl` 與上輪（A-2前）**byte-diff = 0**（完全相同）。日期窗 tick18230-21600（day76-90）内，併入 40 次選中、`faction_id` 從未變動，A-2 rejection-learning 完全沒改變這段行為。

**判讀**：A-2 v2 的機制是「被拒後 cooldown 內不選同 host」——但若 Team26 從未**真正抵達**目標 tile 與 Team3 互動（`_resolve_join`/`_resolve_mergein` 需同 tile 才觸發），根本沒有「被拒」事件可學習，rejection-learning 無用武之地。**這是與 A-2 設計目標不同的另一種幻覺（不可達 vs 拒絕），A-2 沒覆蓋，需要另一個 look-before-leap（判斷 path 可達）或給遷移找糧接手**。

## 2. Team20 / Team18：A/B 確認持續有效（在各自 specimen 世界內）
- Team20（52 entries）、Team18（60 entries）：與上輪 byte-identical，A(買糧非幻覺)/B(遷移找糧)/limbo 解除 皆確認（見上輪 handback 細節，未變）。

## 3. 不回歸
- **determinism**：Team20 獨立雙跑 SHA256 byte-identical。
- **憲法閘**：PASS sites=29 removed=0。

## 4. 死隊 specimen：仍未產出（本輪未再嘗試新候選——§0 發現優先，先報這個）

## 待 blueprint / systems 裁（依優先序）
1. **★最優先**：specimen confound 根因未明——是否要暫緩 release 判斷，先讓 systems 查 SpecimenTracer 其餘函式的副作用？還是接受「specimen 世界」作為驗收替代品（有落差但堪用）？
2. Team26 併入 loop 的「不可達」根因是否要開 A-3（look-before-leap for 併入 path-reachability）？
3. 死隊 specimen 獵殺——待 §1 定音後再排。

---
measured_at_head: dfeecb80
