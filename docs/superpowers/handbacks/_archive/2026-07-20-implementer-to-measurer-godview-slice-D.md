---
from: implementer
to: measurer
status: consumed
topic: "[measure·★敏感·最大塊] god-view Slice D path_system 差異化 belief-gate → feat/godview-d@99afe147。★before/after 協議:doom-delta(seed1337/42/4201)+threat/combat 行為對照(_approach_score 分佈/追擊撲空率/flee 率)+★combat_target 凍結隊數 before/after(D 餵 stale,顯著增=撲空放棄網缺口另票)+逐隊 coherent/broken 切(承 Slice E)。含裁 A(record_claim firsthand 寫 value.last_tick=belief 語意統一)。TDD 10/10、headless 0new(22 fixture:裁A消12+2 direct+8 unit)、gate 64、determinism seed1337 2mo byte-identical(md5 55bbea49)。"
---
# Hand Back: god-view Slice D（path_system 差異化 belief-gate）

承 dispatch `2026-07-20-systems-to-implementer-godview-D-dispatch.md`（異質 R² v3 CLEAN）+ 裁 A（`belief-freshness-ruling-A`）。★最大塊 + measure 敏感（動全盤 threat/combat）。

## 實作摘要
branch `feat/godview-d@99afe147`（off local main b557bf85；★禁 origin 落後~55）已 push（★過 installed pre-push 兩閘）。**差異化 belief-gate（velocity≠position）**，freshness=`belief value.last_tick==current_tick`：
- **observe_velocity(velocity)**：本 tick 可見→live velocity；斷視線→`{visible:false}`（非 last-seen；stale velocity=garbage）。移 trusted-discovery bypass。級聯保護 predict_intercept + _is_moving_away。
- **estimate_catch_up(position)**：斷視線→belief last-seen 位算 eta；無 belief→不可達。
- **predict_intercept(velocity)**：斷視線→belief last-seen；無 belief→sentinel(-1,-1)。envoy caller(faction_ai:1403) lockstep 改明確 sentinel 判。
- **_is_moving_away_observed**：級聯保護（observe_velocity invisible→dir ZERO→短路），verify 綠。
- **threat_assessment:20 dist_factor fold**：斷視線→belief last-seen；positionless→dist_factor=0（威脅位置未知→不 proximate-threat，合 null-belief-flee）→**威脅評估全 belief（approach+dist+rep+power）**。
- **裁 A（BeliefSystem）**：record_claim firsthand(親見 source_id==obs_id)寫 value.last_tick=current（對齊 vision:114 另一 firsthand 路，belief freshness 語意統一）。

## 我的驗證
- **TDD** `godview_d_test` **10/10 PASS**（RED→GREEN；★還原 path+threat→7 FAIL[velocity/intercept/catch/dist live god-view]，證 load-bearing）。差異化 7 型全覆蓋。
- **headless** `=== DONE ===`，3 fail = **baseline 0 new**。★22 fixture 面：裁 A auto-fix 12 record_claim 測 + 2 direct-team_intel + 8 unit 測補 last_tick/tile_pos（fresh belief=live-equivalent，鏡射 vision 寫）+ predict_intercept out_of_sight assertion 改 sentinel(-1,-1)（無 god-view fallback）。
- **constitution_gate** PASS **sites=64 removed=0**。
- **determinism** seed1337 2mo 2 跑 **byte-identical，md5 `55bbea49`**。

## ★請你量（spec §measure 敏感協議，硬含 before/after）
改威脅/追擊距離=動全盤行為→**不盲改**：
- **before/after doom-delta**（seed1337/42/4201）：真隊存亡/attrition 對照。
- **threat/combat 行為對照**：_approach_score 分佈、追擊成功/撲空率、flee 觸發率。belief-gate 後「追不到脫視野隊/威脅只算可見+last-seen」=**intended 深度（伏擊/脫接觸），非 regression**。
- **★combat_target 凍結隊數 before/after**（systems verify=pre-existing 架構）：D 餵更多 stale target 進 `movement:77 combat_target!=-1 continue` + `_refresh_attack_pursuit:277 早退`→**若顯著增=撲空放棄網缺口暴露=另票**（非 D blocker 但要看見）。
- **逐隊 coherent/broken 切**（承 Slice E）：doom-delta 升的隊逐隊讀=intended（脫視野甩追）還是 bug（null-belief 類 pre-existing 又暴露）。
- 你用 `godot --path .worktrees/godview-d` 跑（★禁原地 checkout）。

## ★god-view audit（宣稱訂正）
D 改後 path_system 4 func + threat_assessment:20 dist_factor **全 belief-gate**、path_system 無 `trusted=true` 讀 live → **「威脅評估 belief 化」可誠實斷言**（approach+dist+rep+power 全 belief）。god-view arc A/F/E/D 全落 → 剩 B/C（創世知識/市場）。1119 can_reach 下批。

## 連動風險
- **威脅/追擊行為變**（脫視野→甩追/威脅只算可見+last-seen）=預期修，非 regression。判準=doom-delta 真隊無新塌陷 + coherent/broken 切確認 intended。
- 裁 A 改 production firsthand record_claim belief 算 fresh（本該，firsthand=看到）→ path/threat 對這類 belief 用 live——measurer 驗 production firsthand-record_claim 路（scout 親見）行為對。

## 完成判定
task 完成 = systems + reviewer 判，非自判。你量完（before/after 協議）→ .qa.json/餵 blueprint 或 pre-merge to:systems。我 hold warm 等裁決。
