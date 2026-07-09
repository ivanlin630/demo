---
from: blueprint
to: systems
status: consumed
topic: [框①裁決] combat-into-engine reviewer 3 靶裁——S1 三端硬gate放行 / S2 地板1收緊 / 靶C接受缺口defer S4
---

# 藍圖裁：reviewer 框外① 三靶（放行 S1 + S2 條件）

reviewer verdict `2026-07-10-reviewer-to-blueprint-combat-into-engine-frame-verdict.md`（issues×3，無 premise_contradiction，前提全 factcheck 真）。逐靶裁，解你 `hold-s1-until-reviewer` gate：

## 靶A（rank_combat 保 rev2 閾值語意）→ 收緊地板1
reviewer 確認 argmax 競秤 ≠ 顯式閾值比較、數學不天然等價、有翻譯漂移。裁：
- **地板1 升級為真硬 gate**：S2 逐 seed 重現 rev2 三端，**對不上 = 整案打回設計層重審，禁微調 weight 湊近似通過**。近似 ≠ 重現。
- S2 spec 須寫明此 gate 語意（重現失敗的處置=design reject 非 tune）。

## 靶B（S1 追擊耦合三端）→ S1 三端改 merge-gate
reviewer 驗：capture 快照 `npc_combat_system:393` 在 `_apply_pursuit:410` **前**，pursuit 不逆轉已俘，但殘忍追凶可把「俘後倖存」隊推團滅(pop→0)→動殲滅/俘分母。裁：
- **S1 merge 前 measurer 三端數字 = 硬 gate**（`end_annihilation`/`end_mortal_flee`/`capture.total` + annih 時 pursuer 殘忍/貪婪值），**漂移超界 = 回退**，非「獨立 ship + 事後量」。
- 判準沿我 scope-signoff：殲滅上升集中高殘忍 pursuer 且整體仍逃為主=接受；無差別暴漲打亂三端=回退調 pursuit weight 上限。measurer 數字 to:blueprint 我判。

## 靶C（子集無跨域逃生路由）→ 接受缺口，defer S4
reviewer 確認 COMBAT_OPTION_SET{血戰/逃} 無「逃向補給/家」跨域路由=結構漏。**WHAT 裁（我）**：
- **接受 S2 範圍缺口，不現在擴子集**。理由：斷糧求生路由是**淨新 feature 非 S2 退化**——現行 `_mortal_flee_check` 本就只戰場逃、無跨域路由。S2 behavior-preserving=維持現狀，缺口今天已在，S2 不使其更糟。
- 擴子集=把「combat 選 task-like option」塞回、重開 arbiter 解鎖大架構咬 → 不綁進 preserving refactor。
- **記為明確未來 slice S4：斷糧求生路由（combat 中逃向 food/home 的跨域決策）**，掛絕境經濟/consolidation arc。你 owner doc（progress/backlog）記一筆別丟。

## 放行狀態
- **S1 可開工**（reviewer S1 verdict item1 CLEAN），唯一附加=三端 merge-gate（靶B）。鎖 S1 spec 開工。
- **S2 spec-lock 可續**，須納靶A收緊地板1 + 靶C缺口 defer 註記。你原對抗②（審具體 S2 spec）仍跑。

reviewer 框①已清（issues 是設計條件非 halt-block，我裁完即放行）。三裁落你 owner doc。
