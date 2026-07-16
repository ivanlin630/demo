---
from: blueprint
to: systems
status: consumed
topic: [S-A spec 工單] consolidation 併決策統一——design 收 reviewer 框①三靶，出技術 spec
---

# systems 工單：consolidation S-A 併決策統一 技術 spec

reviewer 框外① 清框（issues×3，非前提矛盾、非阻塞），我已收窄 design 過度確定語氣 + 補硬 gate。放你出 S-A 技術 spec。

## 願景來源（committed）
`docs/superpowers/specs/2026-07-10-consolidation-unified-decision-design.md`（已收 reviewer 三靶）。本 slice = **S-A 併決策統一**（整併/投靠）。S-B 降服/附庸獨立後續。

## 你出 spec 的 HOW（term/context/seam，你 owns）
1. 退役 `consolidate_drive` flat 1.0 / `join_drive` `has_strong_neighbor` 窄 gate → 過真生存/人格 term 秤（飢餓壓/野心/忠誠 weigh；野心低+餓→投靠 util 高、野心高→傾向當吸附方）。
2. 生存訊號進 context/term：飢餓（food 存量 vs 消耗率/餘命）、威脅（打不過的鄰）量化。
3. `_find_absorber` 納**餵養能力**（吸附者 food 餘裕 vs 被吸 pop 增量）——**這是靶A 硬 gate 的 code 面**（防搬餓）。是否放寬同 faction 限制你評。
4. 雙方同意「接受方」決策路徑（吸附方也 rank 秤願不願收）——**靶C：若雙邊異步握手純腦內解不了、需框外薄層，spec 明寫這薄層邊界**（別假裝零 bespoke）。

## ★S-A 硬驗收 gate（reviewer 靶A，spec 須寫成 measurer 先驗項，非事後量）
1. **餵養真解生存非搬餓**：併後合隊 food 餘裕/餘命實質改善（吸附者併前有真 surplus 才吸），非兩餓隊併成更大餓隊。
2. **隊變大真觸殲滅可見**：organic full_probe 量隊規模分布上移 + `end_annihilation` 隨之 >0。若隊變大但殲滅仍 0 → 因果鏈第(3)跳斷，回報 blueprint 重估（別默默過）。
3. **併=湧現非腳本**：無硬寫 `pop<N 就併`；食壓 term 驅 argmax。三端/戰鬥不退化、determinism/融合閘/憲法綠。

## 地板守則（design §地板，不可退化）
收進 rank_scored 真 term，**禁 flat/補償閘**（否則重蹈 consolidate_drive flat 病）；不重造概念。

## 流程
- spec-lock 前你原本的 reviewer 對抗②（審具體 S-A spec）仍跑。框層對抗①已清（本輪）。
- spec → implementer → measurer 硬 gate 三項 → 數字 to:blueprint 我判因果鏈成不成立（尤其靶A 搬餓/隊變大見效）。
- S-B risk 清單（靶B）留 S-B 動工前，本 slice 不做。
