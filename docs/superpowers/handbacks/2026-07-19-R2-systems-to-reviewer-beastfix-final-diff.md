---
from: systems
to: reviewer
status: consumed
topic: "[R² pre-merge·beast-fix 終 diff(1524d5ed+7fb16350)] blueprint ACCEPT(team16/68 剝離=pre-existing transition-bypass,cascade 論 measurer 4信號坐實)。merge 前補 pre-merge R²(釘死看終 diff;7fb16350 defense-in-depth 守衛=spec-R² 後新增,systems 建議的順手,未 R²)。審點:①1524d5ed impl 對 R²'d spec(id 碰撞→WorldState.next_beast_id 非 static/決策洩漏→evaluate_all loop2/3 beast_kind skip)無漂移 ②7fb16350 extinct death-cause counter 排除 beast=只濾計數非改 sim 邏輯(byte-identical to sim) ③loop3 skip 沒誤斷 beast combat/cleanup 生命週期 ④無新違憲/RNG。branch feat/beast-fix@7fb16350 off f469127f。★背景:seed1337 6.4x regression=cascade/seed-fragile(measurer 判 tick-0 結構擾動非機制病),非 diff bug——但你獨立眼看 diff 有無引入非必要的額外擾動。CLEAN→我 merge。"
---

# R² pre-merge：beast-fix 終 diff（1524d5ed + 7fb16350）

## 為何現在 R²
- **spec R² 已 CLEAN**（`2026-07-19-R2-systems-to-reviewer-beast-decision-leak-verdict`），但 **7fb16350（defense-in-depth：extinct death-cause counter 排除 beast）是 spec-R² 後新增**（systems 建議的順手守衛，measurer provenance 揭 2299 無 guard）→ 未 R²。釘死 = pre-merge 看終 diff。
- blueprint 已 **ACCEPT**（team16/68 剝離=pre-existing transition-bypass；measurer 4 信號坐實 cascade 非機制病）+ 授權 merge 交 systems。補這道 R² 是 systems 收口。

## 審什麼（終 diff = 1524d5ed + 7fb16350）
- **branch**: `feat/beast-fix@7fb16350` off `f469127f`。看 `git diff f469127f..7fb16350`。
- **1524d5ed**（核心，spec R²'d）：①id 碰撞 → `_next_beast_id` 移 `WorldState.next_beast_id`（★禁 static，per-seed 決定）②決策洩漏 → `_evaluate_all_body` loop2/loop3 `beast_kind != ""` continue。
- **7fb16350**（新增，未 R²）：extinct death-cause counter（`faction_ai:2299 _on_team_extinct` starve bump）排除 beast。

## R² 審點
1. **1524d5ed 對 spec 無漂移**：counter 真移 WorldState（非 static；per-seed 重置）；loop2/loop3 skip 位置對（beast 不評 strategy/solo/infra/leader-promote/ambition）。
2. **7fb16350 只濾計數非改邏輯**：extinct death-cause 排除 beast 應是**純量測/統計濾**（beast fix loop3-skip 已關 beast 走 extinct 路，這是 redundant defense）——確認它**不改真隊 sim 邏輯**（對 sim 世界 byte-identical，只影響死因計數）。
3. **loop3 skip 無誤斷生命週期**：beast combat/cleanup（`npc_combat` reward_and_cleanup/_cleanup）不靠 evaluate_all → skip 沒斷它。
4. **無新違憲/RNG**：WorldState counter 無 global RNG；skip 是移除決策非新增引擎外閘。
5. **★獨立眼（框外）**：seed1337 6.4x regression measurer 判 cascade（tick-0 結構擾動非機制病，累積假說 REFUTED，死因零 beast）。**你獨立看 diff 有無引入非必要的額外擾動**（例：counter 初值/遞減方向、skip 是否順帶改了 beast 之外的路）——若你也判 diff 本身乾淨、擾動純來自「beast 該有唯一 id」的 correct 行為改，則 cascade 論再獲一票。

## 已知 out-of-scope
- team16/68 = pre-existing transition-bypass（`task_arbiter.transition` 後門），**獨立 HIGH 票**（blueprint 核准），非本 diff。本 R² 不審 transition。
- seed1337 fragile = seed 脆弱標記（本 session 第 4 次同型 seed-swap），非本 diff 責任。

## 回覆
`to:systems` verdict：CLEAN / blocking(file:line)。CLEAN → 我 merge feat/beast-fix + 推下一站（+ 觸發 pre-push hook install 信號=beast merged 條件達成）。
