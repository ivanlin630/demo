# Session 交接（2026-06-19 #4，系統 session）

> 給重開後新 system session（`$env:SESSION_ROLE='systems'; claude`）。承接 #3（`2026-06-19-session-handoff-3.md`）。
> 本 session = **大量 spec/plan/merge**：E-1 收斂落地 + 雙因果脊椎（①G2 行為 / ②G1 經濟）主體 + ③G3 HOW+G3a。main 全綠、無未 merge、無懸 plan（除 G3b/c/d 待寫）。

## 你是誰
系統(Systems, HOW)。owner = invariants.md / 流程docs / progress.md / known_issues.md / CLAUDE.md / docs/process/* / auto-memory(單寫者)。不碰 game-design.md(藍圖)。開頭讀 `docs/process/00_roles.md` + auto-memory（hook 自動注入）+ 掃 `handbacks/` 的 `to: systems / status: open`。

## 跨角色 channel（本 session 建立，重要）
handback 已**泛化為雙向跨角色 channel**（任意 from/to + open/consumed，定義 `00_roles.md`「跨角色交接 channel」節）。SessionStart hook（`.claude/hooks/session-role.sh`，gitignore 本地）自動掃未讀 `to:你/open` 注入 📬。藍圖↔系統靠此非同步協作（並行 session 不能直接對話）。memory `[[feedback_cross_role_handback]]`。

## 本 session 落地（全 merged origin/main，回歸全綠 coin_eq=0 InvariantAudit 0）

**E-1 遭遇戰收斂**（藍圖殲滅裁定後）：
- 繼承統一（`on_leader_death` 單一 owner + faction_ai 安全網 + 刪 dormant `_promote_successor`/`_handle_player_leader_death`）。
- E-1 結構免疫退化修（敗方整隊 pop 損耗 encounter+npc_combat 對稱 + tier 加權存活 + 武裝下限）。
- E-3 玩家邊界離場（最小，**UI 待真人 run-verify**）。E-2 撤退門檻 → 歸藍圖「衝突統一」參戰意志子 spec（藍圖裁，未做）。

**①G2 行為脊椎 — a/b/c/d 全 merged ✅**：a 關係圖(`RelationGraph` typed-edge) / b 野心階梯(`AmbitionLadder`,`TeamData.ambition_*`,strategic_ai 衍生) / c rung×archetype→task(ambient `PRIO_AMBIENT`) / d 私人脫軌(`vendetta_target` 讀 feud,`PRIO_VENDETTA`55)。

**②G1 經濟脊椎 — a/b/d merged ✅**：a 鑄幣(W8 機制早存,補 log/驗) / b 訂單(`OrderSystem` 走 message)+需求生產 / d 商隊訂單驅動套利(取代 `_find_trade_target` 上帝視角)+短缺買單。

**③G3 情報（魂）— HOW 設計 ✅ + G3a merged ✅**：`BeliefSystem` 讀 accessor seam（~8 決策讀者遷移，行為保留，de-risk schema）。

詳見各 spec/plan（`specs/2026-06-19-*` + `plans/2026-06-19-*`）+ memory `[[project_causal_spine]]`。

## 下一步（排序）

1. **G3b multi-claim 儲存**（G3 最大單一改動，accessor 已 de-risk）：`team_intel[r][t]` single→claim Array（值/源/時效/可信度/失真，不覆蓋）；`message_system:215-229` 停 confidence-max 覆蓋改 append；寫端遷移（message/vision/interaction）；`best_estimate` 聚合 + `uncertainty` 換 claim 分歧；上限/LOD/剪枝。**⚠ sim_bridge.gd:185 UI 直讀 raw team_intel → G3b 換 schema 前必遷 `BeliefSystem`（否則 UI 破）**。HOW 全在 `specs/2026-06-19-g3-info-decision-how-design` §3。
2. **G3c** 可信度(類型×身份信任 RelationGraph 新 `trust` 邊×跳數×時效)+技能識破(信假/生疑/裁決)+觀察吃技能。
3. **G3d** 決策讀 belief+uncertainty + 查證迴路(不確定→scout Tier0)。
4. **④Trait 縫** — 藍圖未開。

## 待辦 / 隱患（系統領域）
- **pricing 守恆隱患（查）**：`BASE_PRICE`(ore_gold=10) vs `OutpostSystem.GOLD_TO_COIN_RATIO`(20) 兩表不一致 → 一般 ore_gold 交易可能已破 coin_eq。藍圖 flag、系統 owner、非阻塞。
- **E-3 run-verify**：玩家遭遇戰邊界離場 UI 待真人玩測。
- **全 TEST VALUE 待平衡 pass**：階梯門檻/archetype 權重/survival_weight/vendetta gate/訂單 lifetime·cadence·SHORTAGE/arbitrage 公式/鑄幣率…。藍圖平衡 pass 統一調。
- **refinement**：G2 立國/稱霸細節 + 弱仇偏置 + kin feud 傳播；G1 部分履約記帳 + distort×order params + `_find_trade_target` 完全刪；E-2 參戰意志（藍圖衝突統一傘）。
- **_find_trade_target / dormant 清理**：降 fallback 標 deprecated，擇時刪。

## 藍圖 channel 待覆（open handbacks 你開頭掃）
- `systems-to-blueprint-g3-how-done`（藍圖可回 feel）/ `g2b-feel` / `g2c`(consumed) / `annihilation`(consumed) 等。各 TEST VALUE feel 待藍圖平衡 pass。

## 工作流提醒（memory）
- 挑 backlog 前**先 grep 驗 code 現況**（本 session B-1/W8 兩個 stale 已修，差點重做）[[feedback_verify_backlog_fresh]]。
- 子 session worktree 基於 origin/main → spawn 前確認已 push（本 session 多次 stale-base，3-way merge 保留未刪，但要知道 2-way diff 誤導）[[feedback_worktree_stale_base]]。
- 避免 dormant：plan 要含 reader（本 session G1b 半 inert 由 G1d 閉、G3a accessor 由讀者遷移非 dormant）。
- merge 序：乾淨檔先、共改 faction_ai/headless_test 的後 rebase 解（evaluate_all 尾段衝突）。
- 別問技術微決策；ctx ~90% 才提醒交接。
```
