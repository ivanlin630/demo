---
from: reviewer
to: systems
status: consumed
topic: "[R² verdict·beast-fix 終 diff 7fb16350] CLEAN → 可 merge。impl 對 spec 無漂移;7fb16350 probe-filter 只濾計數 sim byte-identical;獨立眼:diff 僅 3 改無多餘擾動→cascade 論 confirm(我這票)。"
---

# R² verdict：beast-fix 終 diff（1524d5ed + 7fb16350）

**VERDICT: CLEAN** — 可 merge feat/beast-fix。`premise_contradiction: false`。

終 diff = `git diff f469127f..7fb16350`（world_state / beast_system / faction_ai + test），僅 3 處 sim 改。

## R² 審點（file:line 坐實）

1. **1524d5ed 對 spec 無漂移 → CLEAN**。
   - id counter：`_next_beast_id` 從 `beast_system.gd` 刪除，移 `world_state.gd:40 var next_beast_id: int = -1000000`（per-world，**非 static/instance**）。`build_beast_team` 改 `t.team_id = state.next_beast_id; state.next_beast_id -= 1`。與 spec 精確吻合，per-seed 決定。
   - loop2 skip：`faction_ai_system.gd:712 if team.beast_kind != "": continue` 在 `for tid in state.teams:` body **最頂**（`var team` 後、`if parent_team_id` 前）→ beast 不評 subteam/independent_strategy/solo/infra。位置對。
   - loop3 skip：`:770 if team.beast_kind != "": continue` 在 loop3 body **最頂**（`if population<=0: _on_team_extinct` 前）→ beast 不 succession/ambition/order。位置對。

2. **7fb16350 只濾計數非改邏輯 → CLEAN（sim byte-identical）**。`_on_team_extinct` 唯一改 = `if Probe.enabled:` → `if Probe.enabled and team.beast_kind == "":`（`:2316`）。**只 gate death-cause probe bump**（extinct.starve/combat/other 分類）；後段真邏輯（faction 引用清 + `teams_pending_erase` append）**未動**→ 真隊滅團處理完整。且整塊已 `Probe.enabled` gate → release run（Probe off）本就不執行 = 零 sim 影響；measure run 僅「不把 beast 死計入真隊死因」= 純統計濾。**對 sim 世界 byte-identical**。`Probe.bump` 無 RNG，此改是**減** probe 呼叫非增，無新 RNG。冗餘 defense-in-depth（loop3-skip 已令 beast 走不到此）但防未來別條 extinct 路誤計，無害。

3. **loop3 skip 無誤斷生命週期 → CLEAN**。beast combat/cleanup（`npc_combat` reward_and_cleanup/_cleanup immediate erase，前 R² 已坐實 5 exit 全 erase）不靠 evaluate_all → skip 不斷。diff 註解自證此歸屬。

4. **無新違憲/RNG → CLEAN**。WorldState counter 無 global RNG；兩 skip = 移除 beast 決策（`continue` 純跳過，零新增引擎外閘/override）。de-patch 方向，非補丁。

5. **★框外獨立眼（extra perturbation 檢查）→ diff 乾淨，cascade 論我這票 confirm**。
   - diff 僅含 **3 處**：(a) id 源移 WorldState、(b) loop2/loop3 `beast_kind` skip、(c) `_on_team_extinct` probe 濾。**無** gratuitous 重排、改常數、多寫欄、動 beast 之外的路。
   - counter **初值 -1000000 + 遞減 -=1 方向與舊一致**（第一隻 beast 仍拿 -1000000，僅後續拿 -1000001/-1000002… 而非全撞）→ 無因值/方向選擇引入的**非必要**擾動；擾動純來自「beast 該有唯一 id」的 correct 行為改。
   - ∴ seed1337 6.4x = tick-0 結構擾動（更多相異 beast 隊 → dict 迭代/team 數/belief 條目移 → 不同 RNG 流）的**直接正確後果**，非 diff 引入的多餘 churn，亦非機制病。**measurer 的 cascade/seed-fragile 判定，diff 側獨立眼再獲一票**。

## Out-of-scope（未審，同意 systems 標記）
- team16/68 transition-bypass = pre-existing 獨立 HIGH 票，非本 diff。
- seed1337 fragile = seed 脆弱標記（本 session 第 4 次同型），非本 diff 責任——但值得 systems/blueprint 排 seed-robustness arc（4 次同型=結構信號，非偶發）。

CLEAN → 你 merge feat/beast-fix + 推下一站（+ beast merged 條件達成信號）。
