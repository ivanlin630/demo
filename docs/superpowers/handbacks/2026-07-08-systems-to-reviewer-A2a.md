---
from: systems
to: reviewer
status: open
topic: A2a spec round-4(scope B)——你打臉成立(既有=3路含_evaluate_solo:1767);A2a 只做對子隊新路,既有 join 債立 follow-up
---

# A2a spec round-4 回覆（給 reviewer）

你 D4b 的洞**打臉成立**——非吹毛求疵，是真 premise 矛盾。藍圖 round-4 用戶裁定 **scope B**：A2a 不修 P2a 既有 join 債，只把自己新路做對，既有 bug 立案。核心設計（D1-D3/D5-D7）你已核實真統一＝不動。逐點回：

## 你的洞#1（`_evaluate_solo:1767` 是被漏的第 3 條零-guard 投靠玩家路）
**成立，重讀 code 查證屬實**：`_evaluate_solo`（獨立隊 fid=-1 非 merchant/produce，`evaluate_all:672/676` 每 idle tick 呼，序2 solo arc 已 merge=主力路非死碼）在 `1762-1771` 對「投靠」直接 `try_set(TASK_JOIN)`(1767)+`set_social_target`(1771)，**全程零 player-guard**（不像 unified/survival 有 `pp.team_id==social_target` 檢查）。`_find_strong_neighbor:3232` 不排玩家 → 選中 → `_resolve_join:1035` 無條件 `merge_teams` = P2a W2 坑。
- **修 premise**：spec 不再寫「既有 guard=2 處」。改述 **既有＝3 條投靠玩家派工路**（`_decide_unified:1512-1516` + `_trigger_survival:3082-3086` 帶 inline guard但有 fallthrough、`_evaluate_solo:1762-1771` 零 guard）。round-3「僅 2 處」誤，你對。

## 你的洞#2（抽 helper 的 return-not-fallthrough 其實是行為變更，非純搬移）
**成立**：既有 2 處 guard 在 `_maybe_request_join_player` 回 false 時**無 continue → fallthrough 到通用 `try_set(JOIN,玩家 tile)`**（先移動過去、到場自動併）＝P2a 尚未關的殘缺。round-3 我把 helper 寫成「玩家 target 一律 return、caller false→continue 不 fallthrough」＝悄悄改了既有語意。你指出這點對。

## 藍圖 round-4 裁定＝scope B（A2a 只做對自己，不碰既有）
- **helper 只給 A2a 子隊新路呼**（`_try_join_target(state, team, target_id)`，3-arg，玩家→forced_event **return 不 fallthrough**；NPC→try_set JOIN）。
- **★既有 3 處零改動**（`_decide_unified:1513-1517`/`_trigger_survival`/`_evaluate_solo:1767`）——保 P2a settled code、A2a 零回歸。helper＝未來 consolidation 的錨（不複製錯的、引入正確 pattern 就夠）。
- **★立 follow-up（spec Future-work 段 + scope.json follow_up）**：`join-consent-consolidation`＝全 join-player 路遷 helper + 修 `_evaluate_solo` 無 guard + 修既有 2 處 fallthrough。**藍圖驗證後另 slice**，非 A2a 職責。

## 驗收（配 scope B）
- §9：子隊投靠玩家→forced_event、**不 try_set、不移動、不 merge**（子隊新路正確）。
- §10：**既有 3 處零改動**（`git diff` A2a 不 touch 那 3 處 join/guard 邏輯→零回歸）。
- §11：通用戰略-gate 生效（建設/佔村/訓練 子隊不候選）。

## 驗了啥
- 純 spec/scope（systems，不跑 godot、不寫 plan）。**核心設計零改**（只改 D4b scope + premise + follow-up + 驗收）。
- **重讀 code 查證**（鐵律）：`_evaluate_solo:1762-1771` 零 join-guard✓、`_decide_unified:1512-1516` guard 後 fallthrough 到 1526 try_set✓、`_trigger_survival:3082-3086`✓、`_find_strong_neighbor:3232` 不排玩家✓、`_resolve_join:1035` 無條件 merge✓、`_maybe_request_join_player:3220`✓。

## 殘留疑點（呈報）
- scope B＝A2a 後**既有 3 條 join 路的 P2a 殘缺原樣留存**（明講、立 follow-up，非偷藏）。子隊新路已正確。
- helper 單 caller（子隊）→ prio/reason 硬編；consolidation 時再參數化。

審過我才寫 plan → 實作。
