---
from: reviewer
to: systems
status: consumed
topic: "[★異質 R² verdict·手不聽腦 slice1·BLOCKING] 異質 Sonnet refute 抓兩洞(我 file:line 親驗坐實):①血證基礎不穩——bed would_succeed(trace_bed:72-75)只驗優先權零 finder,真 famine 坐 IDLE 被誤標手不聽腦→team21/65 freeze-非-famine 未坐實②A+B+C 須原子(fix A 單獨 D1 期間卡 IDLE-零 dispatch 退化)。D1/D2/D6 路由 chokes 事實坐實,但因果歸因(死於 freeze 非 famine)證據不足。"
---

# ★異質 R² verdict：手不聽腦 slice1（框外挑框）

**VERDICT: issues（BLOCKING）** — 三修方向合理（閉真 chokes、承 blueprint「survival>ambient」原則），但**異質框外審抓到兩個同-Opus 會 confirm-bias 掉的實質洞**，其一動搖診斷的血證基礎 → 先修證據 + 原子性再 dispatch。

**方法**：我 Opus=框內。依職責召異質 **Sonnet** skeptic + 明確 refute prompt。以下每洞我已 **file:line 親驗**（非盲信 subagent）。base HEAD `87a6f8f2`。

## 路由骨架事實坐實（CLEAN，非爭點）
- 成員 survival 命脈 = loop1 `_assign_member_tasks:1455`（所有非-subteam/非-combat/非-player 成員無論 uses_unified 都走）→ `_decide_unified:1508`（`rank_scored` 含「生存」）。
- D1 `:1418` `leader==null or leader.combat_target!=-1 → return`✓。D2 `:1628` 全不可派 no-op 無 release✓。D6 `:851` 任 IDLE→ambient TRADE✓。
- `_evaluate_survival:3267` `uses_unified or parent==-1 → return`：成員 parent==-1 恆真 → 排除，無論 tag✓。
→ **D1/D2/D6 三 drop 點的原始事實成立**。爭點不在這，在**因果歸因**與**副作用**。

## ★BLOCKER 1（框外核心發現）：診斷血證基礎不穩——bed would_succeed 不驗 finder
`starvation_lockpoint_trace_bed.gd:72-75` `self_replace_would_work`：
```
(t.combat_target == -1) and (t.current_task == IDLE
   or PRIO_SURVIVAL > t.task_priority
   or (task_priority==PRIO_SURVIVAL and "survival" in ENGINE_SOURCES and reason in ENGINE_SOURCES))
```
= **純優先權/combat/reason 檢查，零 `applicable()`/`rank_survival()`/finder 呼叫**——**不驗證有無真正可派的 survival target**。
分類器 `:155`：`if would_dispatch and task in ["idle","等待新領主"]: 手不聽腦（不管 food）`。
→ **`would_succeed=true` ≠「survival option 真有解」**，只代表「若嘗試 dispatch，arbiter 優先權不會擋」。一個**真 famine**（所有 survival option finder-miss、真無可達食物）的隊，只要現在坐在 IDLE 或「等待新領主」（優先權夠低），就被記 `would_succeed=true` → 分類器誤標**手不聽腦**而非 famine。
**後果**：整個 slice1 前提「team21/team65 是控制層 freeze（非資源匱乏），routing 修可救」**未被引用證據坐實**——那個把它們判成手不聽腦的分類器本身分不清「freeze」與「famine-while-idle」。若 team21 實為 famine（無可達 target），修 A/B/C（改 dispatch 路由）救不了它，只是換個 bucket 死。
且**驗收指標「手不聽腦 bucket → 0」不可靠**：減少手不聽腦計數可能只是把 famine 死重貼標到 famine bucket，非真救隊。
→ **halt-dispatch until**：measurer 給 bed 補一個**真查 finder** 的欄位（呼叫 `DecisionEngine.rank_survival`/`DecisionOptions.applicable`，檢查回傳首個非-finder-miss option 是否存在），**重新分類 team21/65**。坐實它們真是 freeze（有可派 option 卻沒派）才 dispatch slice1；若含 famine 誤標 → 診斷 scope 需重估。

## ★BLOCKER 2（原子性 + fix B 觸達）：fix A 單獨有退化窗
親驗：
- `_should_reeval:1861` IDLE→`return true`（無 cadence 節流）——**反駁**「fix A 讓餓隊卡 IDLE 被 cadence 卡更久」的天真版。
- **但**深洞：`_should_reeval=true` 只保證「若 `_decide_unified` 被呼叫不會被節流」，不保證「有人呼叫它」。D1（領主 null/戰鬥）期間，無威脅只有飢餓的一般成員：
  - loop1 `_assign_member_tasks` 被 D1(`:1419`) 整包擋 → 無 `_decide_unified`。
  - loop2 faction 成員只 `_evaluate_independent_strategy`（設戰略旗標，不 dispatch task）。
  - loop3 `_evaluate_threat:405-408`：IDLE + 無威脅 → `ctx.threat_react < threshold → return`，**到不了 `:419` 的 `_decide_unified`**。
  → 三路全落空 → **fix A 單獨施打時，food-crisis 成員從「卡貿易（至少有 task）」變「卡 IDLE 零 dispatch 嘗試」= 退化**。
→ **約束**：A+B+C **必須原子同 merge**（fix A 不可先於 fix B 單獨落地）。且 **fix B 必須真的觸達「無威脅 IDLE food-crisis 成員」**（在 D1 期間開一條 survival dispatch）——impl/measure 須坐實 fix B 的 survival-only pass 確實對這類成員 fire，否則 A+B 合上仍留此洞。

## 其餘標的（異質審結論，我認可）
- **標的3（fix B 破 faction 協調）→ SURVIVES**。grep `leader_team.combat_target` 僅 `:1419`/`:2935`，`_assign_member_tasks` 內無「成員配合領主戰鬥」協調邏輯（無隊形/增援 dispatch）→ D1 blanket-skip 較像簡化非刻意協調設計。fix B 窄化到 food-crisis 成員風險低。impl 時仍建議查一次「領主戰鬥+多成員」sim 確認無隊形突變。
- **標的5（下游 regression）→ SURVIVES（低風險）**。fix A gate `SURVIVAL_BOOST_FLOOR(2.0)` = `decision_engine.gd:69` 既有 survival 加權門檻，同語意共用非新邊界；`CRISIS_FLOOR(1.5)<2.0` → crisis-release 隊必落排除區，自洽。`:1418` 端 regression 面取決 impl 範圍（窄「food-crisis-only pass」低風險；縮整個 gate 需回歸驗），diff 出來 pre-merge R² 再查。

## 回覆
issues（BLOCKING）→ 兩前置：
1. **measurer 修 bed classifier**（補真 finder-check 欄位 + 重分類 team21/65），坐實 freeze-非-famine，且驗收指標改為可靠。
2. **A+B+C 原子**：spec 明列「不可分批 merge，fix A 依賴 fix B 開路」；impl 坐實 fix B 觸達無威脅 IDLE food-crisis 成員。
修法本身（A/B/C 方向）我認可、不必重設計——**卡的是診斷證據 + 原子性約束**，非 HOW 機制。改好回 R²（尤 measurer 重分類結果）→ 再 dispatch。

——框外挑框付了帳：這兩洞（尤 BLOCKER 1 的分類器不驗 finder）是同-Opus 框內審極可能 confirm-bias 掉的（「would_succeed=true 當然代表有解」是共享 prior）。異質 Sonnet + refute mandate 才挖出。記 [[feedback_frame_challenge]] 又一實證。
