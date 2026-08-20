---
from: systems
to: reviewer
status: consumed
topic: "[R² 審設計:promote_util 去慎重壓制項(多疑與提拔 decouple、用戶裁倒因果修)·feat/decouple-suspicion-promotion 7ee9ec29·★systems merge-gate 硬讀已 CLEAN、請你獨立 skeptical R²(每 slice 必過、只信 file:line):①genuine 非 crank 核心=純去 `−慎重×0.7` 項、_promote_pmult(ambition)=clampf(0.3+野心×0.9,0,1.5)、★零 boost/零 crank 加入(diff 親驗只減不加)②caution 參全清乾淨(promote_util/promote_util_desperate/_try_promote_advisor call site 連動、無 dead param、無殘留 cau 讀取)③差異化來源=野心 modulate rate(高1.11>中0.75>低0.48、非 gate)+真實成本 kill_random 1 anon(已在、size 靠經濟)、非多疑④bounded 全不變(need-gated demand=0→0/candidate-gated quality/desperate spare≤0/spare≥CONCURRENT→0/無村→0/非領主→0 皆未動)⑤stale 註全更新(「多疑吝嗇」「多疑絕境照樣不濫拔」→野心-modulate+need/candidate-gated)·僅 3 檔(faction_ai 30 行多為註+簽名、active_promotion_test 60、named_scarcity_ab_test 8)·★倒因果 WHAT 正確性(你可挑框):懷疑是對已存在的人、沒提拔哪來對象可疑→懷疑擋創造=倒因果(用戶裁)、多疑 genuine 位置移下游對待現有 officer PARK·implementer fp 前後對照 LIVE(promote.fired 4→5 +1 前多疑-blocked lord、field_desperate 4→5=relief 解卡)·CLEAN→我 route measurer realistic 前後對照(野心差異化率+size 靠資源+relief 解卡)→QA→merge;有洞→halt 回·地基 KEEP"
---

# R² 審設計：promote_util 去慎重壓制項（多疑與提拔 decouple）

`feat/decouple-suspicion-promotion` `7ee9ec29`。★systems merge-gate 硬讀已 CLEAN、請你獨立 skeptical R²（每 slice 必過、只信 file:line）。

## 審點
1. **genuine 非 crank 核心** = 純去 `−慎重×0.7` 項、`_promote_pmult(ambition)=clampf(0.3+野心×0.9,0,1.5)`、★**零 boost/零 crank 加入**（diff 親驗**只減不加**）。
2. **caution 參全清乾淨**（`promote_util`/`promote_util_desperate`/`_try_promote_advisor` call site 連動、無 dead param、無殘留 cau 讀取）。
3. **差異化來源** = 野心 modulate rate（高1.11>中0.75>低0.48、非 gate）+ 真實成本 `kill_random 1 anon`（已在、size 靠經濟）、**非多疑**。
4. **bounded 全不變**（need-gated demand=0→0 / candidate-gated quality / desperate spare≤0 / spare≥CONCURRENT→0 / 無村→0 / 非領主→0 皆未動）。
5. **stale 註全更新**（「多疑吝嗇」「多疑絕境照樣不濫拔」→ 野心-modulate + need/candidate-gated）。

僅 3 檔（faction_ai 30 行多為註+簽名、active_promotion_test 60、named_scarcity_ab_test 8）。

## ★倒因果 WHAT 正確性（你可挑框）
懷疑是對「已存在的人」、沒提拔哪來對象可疑 → 懷疑擋創造 = 倒因果（用戶裁）。多疑 genuine 位置移下游對待現有 officer PARK。

implementer fp 前後對照 LIVE（promote.fired 4→5 +1 前多疑-blocked lord、field_desperate 4→5=relief 解卡）。

CLEAN → 我 route measurer realistic 前後對照（野心差異化率+size 靠資源+relief 解卡）→ QA → merge；有洞 → halt 回。地基 KEEP。
