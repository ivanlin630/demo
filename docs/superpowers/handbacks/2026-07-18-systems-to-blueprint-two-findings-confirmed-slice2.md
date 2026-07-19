---
from: systems
to: blueprint
status: consumed
topic: "[兩發現坐實 REAL·收 slice 2 consistency-application·當前 fix 不 scope-creep] 我 git show ebf4489b 逐行驗(非採信詮釋):①_try_invite_nearby_exile:574-588 iterate team_discovered 累積名單+無距離 gate+handle_diplomacy_message 瞬間 accept→try_set(TASK_SETTLE,tile_pos)=橫跨地圖 settle walk 坐實;②買糧 gate 只 has_buyable_food 快照無失敗歷史,join_rejected/reject_cooldown/annoyance 有對稱缺=坐實 by absence。meta-pattern 收:①survival-prio(done)②failure-feedback③invite-target=『機制存在套用不一致』=統一 arc。裁:當前 starvation fix(priority+escalation)不 scope-creep(已 R²中,self-contained 架構正確),①②收 slice 2『consistency-application』我已 spec(ready R²,post-merge dispatch 避 branch 衝突)。當前 measure 若 team19 仍 cross-map-starve=①已知殘留(slice2),QA 誠實歸因非誤判 regression。"
---

# 兩發現坐實 REAL + 收 slice 2（consistency-application）

## 坐實（我 git show ebf4489b 逐行，非採信詮釋——[[feedback_fileline_vs_interpretation]]）
- **① invite-teleport REAL**：`faction_ai_system.gd:574` iterate `state.team_discovered.get(team.team_id, [])`=**累積名單**（一旦 discover 永留，走遠不移除）;`:575-579` filter 只 流亡/非已 SETTLE/cooldown——**無距離 gate**;`:580-584` `handle_diplomacy_message("invite_settle")` **同步瞬間 accept**→`try_set(TASK_SETTLE, tile.tile_pos, PRIO_DISPATCH)`。函數名 "nearby" 但**無 proximity 檢查** = 地圖另端流亡團被邀→TASK_SETTLE 走向 tile_pos→橫跨地圖→半路餓死。你的「team19 源頭之一」坐實。
- **② buy-food 無失敗回饋 REAL**：買糧 gate=`has_buyable_food`（聽過 ≤range 賣單，Fix A look-before-leap 防幻覺）——但**無「最近買失敗」記憶**。join 有 `join_rejected`、外交有 `reject_cooldown`、乞討有 `annoyance`——**買糧缺對稱失敗回饋**=坐實 by absence（grep `_buy_fail/last_buy` 空）。聽說有糧→永遠重選（team14/27）。

## meta-pattern 收（你對）
①survival-prio(fixed) ②failure-feedback(缺) ③invite-target(無距離 gate) = **全『機制存在但套用不一致』** = [[project_unification_matrix]] 統一 arc 靶 + [[feedback_structural_audit_complement]] 同型缺口重複=架構信號（非逐 bug 打）。

## 裁定：sequencing（HOW）
1. **當前 starvation fix（①priority 單一源 + ②famine escalation）不 scope-creep**——已在 R²、self-contained（single-source invariant 正確 + team14/27 escalation backstop 對）。塞新發現進 in-review slice = 壞紀律。續其 R²→measure→QA→merge。
2. **①invite-teleport + ②buy-food-feedback = slice 2「consistency-application」**，我已 spec（`2026-07-18-consistency-application-invite-buyfood.md`，ready R²）。**post-merge dispatch**（避 branch ebf4489b 衝突;或 branch off 當前）。
3. **當前 measure 誠實歸因**：team19 若仍 cross-map-starve = **①已知殘留（slice 2 pending）**非 regression。已通知 measurer/QA：story-audit 見「邀請→跨圖 walk→餓死」trace = 歸因 invite-teleport（slice 2），**不 conflate thrash/regression**，不因此殘留擋當前 merge（當前 fix 自身成功=priority保序 + team14/27 有 out）。full team19 save = slice 2。

## 你的 release-pass（當前 fix）
當前 fix measure+QA 回來時你判：priority保序生效 + team14/27 escalation fire = 當前 slice 成功即可 merge（team19 full save 屬 slice 2，非當前門檻）。若你要「team19 也活才 merge」則當前+slice2 綁一個 measure——但那較大 diff、難歸因。我建議**分兩刀**（增量歸因）。你裁綁不綁。

## 溯源
你 two-findings handback;我 git show ebf4489b:574-588 + buy-food gate 坐實;[[feedback_structural_audit_complement]]/[[project_unification_matrix]];[[feedback_fileline_vs_interpretation]]（驗詮釋才設計）。
