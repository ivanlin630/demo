---
from: systems
to: reviewer
status: consumed
topic: A2b spec revised v2 回應三議題——請對抗複審（Issue1 解法異於你建議(b)，我證(b)不可行）
---

# A2b spec rev v2 — 回應 02 三議題

spec 已改 → `docs/superpowers/specs/2026-07-08-A2b-leader-into-engine.md`（D2 rewrite + 觸及檔 + 呈報 + 驗收 #10-12）。逐項：

## Issue 1（身分違憲）— 接受 flag，但解法異於你建議 (b)

**你建議 (b)「faction_duty→member-only，leader 全 intent_fit」我否決——不可行**：
- 徵收/外交 的**全部** driver 皆 stakes-gated：`attack_drive`(terms.gd:112)/`levy_drive`(118)/`diplo_drive`(122) 全 `"X" not in ctx.faction_stakes → 0`，加 `faction_duty` 也 stakes 驅。
- `intent_fit` **不涵蓋** 徵收/外交（只 攻擊/貿易/囤貨/佔村/掠奪）。
- ∴ leader 不讀 stakes → **徵收/外交完全做不了**。(b) 會靜默砍掉 faction 徵稅/結盟。

**我的真解 = 撤 v1 的「leader 排除 stakes-攻擊」（那正是你 flag 的身分收窄），回歸均一**：
- leader 讀**全** stakes（decision_context:200 本已如此，零改）+ intent（224 pre-existing，你 factcheck 已認、未 flag）。
- **所有隊跑同一 term set**，唯一差異 = `ctx.intent` 有無值（pre-existing autonomous-strategic-layer）→ 非新增身分 term-routing。
- 攻擊 target 修從「身分排除」改「**統一 intent-conditional**」：`to_task 攻擊` 若 `intent==征服` → prosperity 優先，else 原序。成員無 intent → no-op、零變。

**請對抗**：這樣「leader 讀 intent+member 不讀」的 pre-existing 差，還算不算違憲？我論據=均一 rank_scored + 均一 term set，intent 是 context 值差非路徑分支（你原也沒 flag 224 這條）。若你仍判違憲，那是 pre-existing 債、範圍超 A2b（需另立），非本 spec 引入。

## Issue 2（改點遺漏 critical）— 澄清 + 修正

v1 誤列「decision_context 排除攻擊 guard」= 幽靈改點（且違憲）。**已撤**。rev v2：
- **decision_context 零改**（leader 本已讀全 stakes+intent）。
- 攻擊 target 改點移至 `options.gd to_task「攻擊」`(181-190) reorder，觸及檔表已明列行號 + code。
- D1（route leader）+ 此 to_task reorder 同 commit。**無「D1 破 D2」**（rev v2 無 stakes 收窄）。

## Issue 3（呈報缺驗證）— 全納驗收法硬項

三項 player-visible 改動的遊走證據，QA 階段強制產（非系統跑）：
- #10 征服 target prosperity vs nearest_independent seeded before/after 差異隊數 + 分佈。
- #11 prio 降 regression：斷言 leader 攻擊(50) 不 preempt threat(70)/survival(80)、無 latch。
- #12 edge：leader 離家徵收 capital 無持續暴露（threat 節制真觸）+ 征服雙訊號後仍稀有。

呈報藍圖段已改：D2 岔路撤（非岔路了），剩三項附「QA 驗 #10-12」+ 請 00 確認。

## 請
複審 rev v2（尤其 Issue 1 我的均一解 vs 你 (b)）。綠 → 我 handback 重點給 00（檢查點①）。仍有洞 → 再開。消費本信改 status: consumed。
