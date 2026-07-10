---
from: blueprint
to: systems
status: consumed
topic: [流程intent] reviewer 對抗補一維:偵測「補丁/框架內補丁/冗餘求解器」——本session漏抓證據,你編入02_reviewer+memory
---

# 藍圖 intent：強化 reviewer 對抗——補丁 / 框架內補丁偵測

用戶定（2026-07-11）：對抗式審查要加強「補丁與**框架內補丁**」的偵測。`02_reviewer.md` 你 owner，我給 WHAT-intent，你編入 + memory 提煉。

## 為何（本 session 漏抓的鐵證）
「統一框架 vs 補丁」的失效模式**不只是「框架外硬 gate」**（那個 [[feedback_patch_gate_first]] 已管），還有一種**更隱蔽**：
- **框架內補丁 / 冗餘求解器**：join 與整併 是**兩個 option 做同一件事**（都 `merge_teams` 全併、搶同絕境 niche）→ 整併 marginal 2.5%。這是「在統一框架**裡面**增殖冗餘求解器」，表面像在用框架、實則違背「消除多求解器」的統一初衷。
- **這個 reviewer 兩次對抗①都沒抓到**（combat-into-engine、consolidation 框審都過），是**用戶**在設計對話裡看穿的。reviewer 缺這個 lens。

## 要補的對抗維度（你編入 02_reviewer refute checklist）
reviewer 審 spec/設計時（尤 R②），除既有「真根治 vs 搬問題」，明確加問：
1. **是否加補償補丁**（settled architecture 上疊繞過）？[[feedback_no_patch_on_settled_architecture]]
2. **是否加框架內冗餘求解器/option/term**——新增的東西**跟既有某 option/solver/term 做重疊的事**嗎？（join vs 整併型：兩路殊途同歸、搶同 niche）。若是 → refute，要求**收斂為一**（一決策、參數分流），非並存。
3. **是否為 flat/特例驅力**（consolidate_drive flat 1.0 型：掛在框架上但沒真過人格/生存秤）？
4. **正解方向**：收進真 term 秤 / 收斂冗餘求解器為一 / de-patch 拆閘——**非**在框架內多加一個平行物。

## 判準（給 reviewer 具體 smell test）
- 「這個新 option/term/solver，**能不能用既有的某個 + 參數分流達成**？」能 → 冗餘，refute。
- 「兩個 option **applicable 域重疊 + 結果殊途同歸**嗎？」是 → 該收斂為一。
- 「這是**延伸統一**還是**在框架裡開分支繞過**？」

## memory（你單寫者提煉）
補一條：**「框架內補丁」= 統一框架下增殖冗餘求解器/option（表面用框架、實違消除多求解器初衷）**。與 [[feedback_patch_gate_first]]（框架外硬 gate）互補——兩種補丁 reviewer 都要抓。血證：join/整併 冗餘（用戶抓非 reviewer）、consolidate_drive flat 特例。配 [[feedback_no_patch_on_settled_architecture]]。

## 落地
- 你編入 `02_reviewer.md`（refute checklist 加此維 + smell test）。
- 提煉 memory。
- 此後 R②（每 slice）reviewer 帶此 lens——尤其我/systems 下「加 X」型變更時,先問「是不是框架內冗餘」。

編完 handback 確認即可，非急鏈。
