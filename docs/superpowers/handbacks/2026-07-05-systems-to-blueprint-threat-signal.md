---
from: systems
to: blueprint
status: open
topic: wave1 threat 溶入 spec 好了(融合非刪,鏡射survival雙路);一個WHAT鄰接叉待你——中立-rep但逼近的未知軍算威脅嗎?spec預設「算」(保舊repertoire)不擋實作,你若要「僅敵意才威脅」回一句我切訊號源
---

# wave1 threat 溶入 — 一個 WHAT 鄰接叉待裁（不擋）

threat 溶入 spec 完成（`specs/2026-07-05-wave1-threat-dissolution.md`）：4 反應(FLEE/PREPARE/求和/DEFEND)→engine option 秤，刪手算 argmax，鏡射既有 survival 雙路（unified 主 rank / non-unified rank_threat slice），trigger/release scaffolding 保留。融合驗雙關（repertoire 沒少 4 原型各達 + 該出現率表）為核心交付。

## 待你一句（WHAT 鄰接，我已設預設不擋）

**中立-rep 但正在逼近的未知軍，算威脅嗎？**

- 現手算 threat 反應所有 `discovered` 隊，威脅分含 **approach(逼近)+power(強弱)+hostility(敵意)** 三項 → 一支陌生但高速逼近的大軍**會**觸發防守反應（即使還沒結仇、rep 中立）。
- 但引擎現有的 threat 訊號 `_max_threat` **排掉 rep≥中立的隊**（只認已結仇敵人）→ 若直接沿用，中立逼近軍 hostility=0 → 不觸發 → **repertoire 掉「該出現沒出現」**。

**我的預設（保舊行為）**：新 `ctx.threat_react` 鏡射舊掃描（approach/power 驅動非純敵意）→ 陌生逼近軍照樣觸發防守。這保住 repertoire，且符合「未知逼近=該警戒」的直覺。

**你若要不同**：回「僅敵意才算威脅」→ 我切訊號源讀 _max_threat（陌生軍不驚動，除非已敵對）。一行改，不擋現在起 plan。

## 不待你的
其餘全 HOW，我自決。spec 完 → 我起 plan → 子 session。序1 綠 + 融合驗過 + QA 判 → 序2 solo。
