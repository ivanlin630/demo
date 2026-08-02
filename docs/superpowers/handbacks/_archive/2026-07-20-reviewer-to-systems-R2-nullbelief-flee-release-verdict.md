---
from: reviewer
to: systems
status: consumed
topic: "[R² verdict·null-belief-flee 凍結·CLEAN+建議] root 坐實;修方向對(釋放 null-flee)。★審點④答:A gate 1595/1948=覆蓋全 FLEE dispatch,release 清 flee_from_pos+IDLE→B 對現站冗餘(harmless defense,不同層)。建議 applicability-gate(FLEE 無座標 not applicable)=更乾淨真根治,收斂 A+B。審點①:solo re-rank 覓食 OK;成員 D1 期間退化 ambient(slice1 域)但仍優於凍結=無 regression。"
---

# R² verdict：null-belief-flee 凍結根治

**VERDICT: CLEAN**（附設計建議 + 審點④答，非 blocker）— 可 dispatch。`premise_contradiction: false`。root 坐實，look-before-leap 方向對。

factcheck 對 HEAD `af1838bd`。

## Root 坐實
- FLEE dispatch `faction_ai:1595`（unified/成員）+`:1948`（solo/獨立）：`if td.task==FLEE: flee_from_pos = _flee_threat_pos(state, team)`。
- `_flee_threat_pos`：最高威脅 → `BeliefSystem.belief_pos`；無威脅/positionless → `(-1,-1)`。
- `movement:82-86`：`FLEE + flee_from_pos != (-1,-1) → move_target=away`；`==(-1,-1)` → 無 target → `:86 continue`（凍結）。註「靠 release 收」= 空話沒人 release。→ 卡 task=逃跑 凍結餓死。坐實（team75/4/13 = finder-check 看不到的第 4 種 broken family：dispatch 了但 target null）。

## 審點回覆

1. **A release 後 re-rank 真接得到 → 分隊型（帶 slice1 異質審教訓查）**：
   - **solo/獨立隊（`:1948`）→ CLEAN**：release→IDLE→下 tick `_evaluate_solo` rank_scored 選覓食。solo 路**不受 D1/D2 choke**（那是 faction 成員特有）→ 真接得到覓食。
   - **faction 成員（`:1596`）→ 有 slice1 交互（非本 fix 責任）**：release→IDLE。re-rank 靠 loop1 `_assign_member_tasks→_decide_unified`；若 D1（領主 combat/null）active → 該路被擋 → IDLE 由 `:851` ambient 填（非 forage）。**但仍優於凍結 FLEE**（ambient 至少移動；凍結 FLEE task 連 ambient 都不觸）→ **淨改善、無 regression**。「forage re-rank」的完整接住待 slice1 落地。
   - ★注意：spec 的「finder-check 揭 survival option finder-hit → 應接得到」**重蹈 slice1 被異質審抓的 gap**（finder-hit=option 有解 ≠ dispatch 路被呼叫）。對成員-during-D1 不成立。但因本 fix 是**淨改善**（凍結→至少 ambient/或 forage），此 gap 不 block 本 fix，只是「完整 forage 接住」依賴 slice1。建議 spec 措辭改「solo 接 forage；成員待 slice1」避重蹈 conflate。

2. **不誤傷 coherent flee → CLEAN**。只 gate `flee_from_pos==(-1,-1)`（positionless）。team67/54 型（威脅有 belief 座標）→ flee_from_pos 有值 → A 不 release、movement 正常 away。零誤傷。

3. **不回退 live-track → CLEAN**。無座標→release 轉覓食（顧眼前），**非偷讀 live 位逃**。守 belief-化/感知鐵律。與 Slice E 同精神（無估=保守，非 fallback-live）。

4. **★A+B 重複? → A 覆蓋全站，B 對現站冗餘（harmless）**。grep 確認 **FLEE dispatch 只有 `:1595`/`:1948` 兩站**（其餘 TASK_FLEE 引用 = `:392` release 檢查、`:2329` extinct 探針，非 dispatch）。A gate 兩站 = 覆蓋所有 FLEE-with-flee_from_pos dispatch。`release`（`task_arbiter:98-102`）**清 flee_from_pos + 轉 IDLE** → movement 見不到「FLEE + flee_from_pos==(-1,-1)」（清 flee_from_pos 必同時離 FLEE）→ **B 對當前 code 不會 fire**。
   - spec 的「FLEE 設後 belief 過期成 positionless」timing 論**不成立**：flee_from_pos 是 dispatch 時 cache 的 Vector2i，非每 tick live 讀 belief → 不會自己過期成 (-1,-1)。
   - **B 非決策層冗餘 solver（非 refute-checklist #2 反模式）**——是 movement 層不同層安全網，cheap+harmless。但對現 code = 死防禦（不 fire）。
   - **★建議（收斂為一，更乾淨真根治）**：採 spec 提的**替代 A = FLEE option applicability gate**（`options.gd:56` 加 `_flee_threat_pos(...) != (-1,-1)` 才 applicable）→ **positionless 威脅時 FLEE 根本不被選中** → 連 dispatch-then-release 都省，A+B 皆 moot。這才是真 look-before-leap（現 A 是 dispatch-then-release=look-after-leap）。B 可留作「movement 不變量：FLEE 無座標永不凍結」的顯式防禦（供未來新 FLEE-set 路），但**標明是不變量防禦、非「補 A 漏的 timing 邊角」**（因無此邊角）。

5. **release side-effect → CLEAN**。`release:102` 清 flee_from_pos=(-1,-1)（FLEE 撤乾淨，無 stale 殘留）。combat_target **不清**——但 null-belief FLEE（威脅無座標=無法定位）幾乎不可能帶 combat_target（打不到看不見的敵）→ 低度，impl 順帶確認 null-flee 隊 combat_target==-1（若有殘留 combat_target→release 後 try_set 被 combat lock 擋，另議，非本 fix 常態路）。

## 回覆
CLEAN → 可 dispatch。**建議 impl 採 applicability-gate 形式**（options.gd FLEE 無座標 not applicable）為 primary，比 dispatch-then-release A 乾淨、且天然收斂 A+B；B 留作顯式 movement 不變量防禦（標明性質）。TDD 照 spec（positionless→不留 FLEE / coherent flee 不誤傷 / movement backstop）。impl pre-merge R² 重點：①FLEE 全 dispatch 站（1595/1948 或 applicability-gate）覆蓋 ②solo 真轉 forage、成員待 slice1（trace 分隊型）③coherent flee 零誤傷 ④無 live-track 回退。
