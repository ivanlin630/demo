# spec：god-view Slice D — path_system 位置 leak（freshness-gate，最大塊）

> 層級：L1（core 威脅/追擊信號，11 caller，measure 敏感）。off main HEAD。god-view 殲滅 arc 最大塊。★異質 R²（大結構+核心威脅信號+measure 敏感=框外挑框三對齊，blueprint 已預告）。
> 來源：god-view audit（`2026-07-19-systems-to-blueprint-godview-audit-scope.md` Slice D）。A/F/E/null-belief-flee 已 merged。

## 感知鐵律最大違憲點
`path_system` 三 func 讀他隊 **live `tile_pos`** 算 velocity/reachability/eta/intercept，11 production caller 以 `trusted=true` 跳 discovery 讀 live = **live god-view leak**（追蹤已脫視野的隊）。stats（pop/food/armed）已 belief-gate，**唯 position leak 未治**。

| func | `path_system` | 讀 live | 語意 |
|---|---|---|---|
| observe_velocity | :175（velocity :184 `tile_pos-last_tile_pos`） | target live 位 time-series 算速度/方向 | **★velocity（兩 ground-truth 位）** |
| _is_moving_away_observed | :226（:229-231） | target live 位算 moving_away（gate catch_up reachability） | **★velocity 依賴（漏的第 3 站）** |
| estimate_catch_up | :202（catch_cost :210） | target live 位算路徑 eta | **position（可 last-seen）** |
| predict_intercept | :241（:245/249/254 fallback `return target.tile_pos`） | target live 位算攔截點 | **velocity 依賴（回 bare Vector2i）** |

**★caller inventory（reviewer 異質審 file:line 親驗，訂正我 spec v1 的 stale 行號）= 10 caller 非 11**：`faction_ai:205/293/1403/2134/3607/3636/3666/3715/3747` + `threat_assessment:27`（`_approach_score`）。~~:3596~~ **非 caller**（eta_ticks caller-supplied 位，無關 leak）。impl 落地前**再 grep 確認**（別再信 stale 行號=fileline 紀律血教訓）。

## ★★v2 差異化設計（異質 R² BLOCKER 1 訂正：velocity ≠ position，非統一鏡射）
> **v1 錯**：統一「三態鏡射 `_refresh_attack_pursuit`」。但 `_refresh_attack_pursuit` 三態是為 **position-as-移動目標**設計（去哪追，單位置夠）；observe_velocity/predict_intercept 要的是 **velocity（敵是否逼近）= 兩 ground-truth 位 time-series**。**BeliefSystem 無 velocity analog**（只單一 last-seen 快照，無前位可 diff）→ **state②(stale→last-seen)對 velocity 無意義**（套上去=garbage 向量：幾天真位移壓成一步 delta，比 leak 更糟）。∴ 三 func **差異化**：

freshness = `belief last_tick == current_tick`（本 tick 可見）：
- **observe_velocity（velocity）**：本 tick 可見 → live velocity；**否則 → `{visible: false}`（看不到=無 velocity，非 last-seen）**。移 `trusted`。→ 級聯保護 predict_intercept + _is_moving_away_observed（它們吃 direction，invisible→ZERO direction→既有 0/false 路自動接）。
- **_is_moving_away_observed（velocity 依賴）**：direction ZERO（observe_velocity invisible 時）→ 既有 `:228 return false` 在讀 live 前短路 → **被 observe_velocity fix 級聯保護**（verify：direction≠ZERO 只在本 tick 可見時，live 讀合法）。
- **estimate_catch_up（position eta）**：`catch_cost:210` 的 target 位 → 本 tick 可見用 live、否則 **belief last-seen 位**（去最後見位的 eta 有意義=合法 last-seen）；velocity 部分（observe_velocity）自動 degrade（invisible→target_speed 0→視同不動 last-seen）。
- **predict_intercept（velocity 依賴，回 bare Vector2i）**：observe_velocity invisible → **不回 live `target.tile_pos`（現 :245 god-view），改回 belief last-seen 位**；★**sentinel 契約明定**：有 belief→last-seen 位、無 belief→`(-1,-1)`。
  - ★**envoy caller lockstep（`faction_ai:1403-1408`）**：現靠 `predicted != target.tile_pos` 分「真預測 vs fallback」→ 新 sentinel `(-1,-1)` 會讓不等式仍成立 → envoy 誤寫 `(-1,-1)` 進 move_target 繞過自己的 belief-fallback = **堵 leak 冒新 bug**。∴ envoy caller **同步改**（別靠 `!= target.tile_pos` 判 fallback，改讀 predict_intercept 明確 sentinel or 自己 has_belief 先判）。

**caller 不可見 fallback（reviewer SURVIVES）**：Dict-回傳 func（estimate_catch_up/observe_velocity）各 caller 有 `.reachable`/`.visible` 檢查（205/2135/3607/3636/3667/3715/3748/threat:28）→ 夠。**唯 predict_intercept 的 envoy caller 是缺口**（上述 lockstep 補）。

## ★★v3 fold：threat_assessment:20 dist_factor（異質 R² v2 BLOCKER，乘算主導 god-view）
> **異質審抓**：`ThreatAssessment.score`（`threat_assessment:11-23`）= `raw * dist_factor`。`dist_factor`（:20-22）`_hex_dist(self, other.tile_pos)` 讀 **live other 位**、**乘算主導**整威脅分。Slice D 修 approach（一加項）卻留 dist_factor（乘算主導項）全 god-view → 脫視野近敵 approach→0 但 dist_factor 用 live 真距離照算威脅 → **「威脅評估 belief 化」宣稱假過**（[[feedback_structural_audit_complement]] 近端修遮同 func 主導項）。∴ **fold 進 Slice D**（一行、同修式）：
- `threat_assessment:20` dist 也走 belief（position，非 velocity）：**本 tick 可見→live 距離；斷視線→belief last-seen 位算距離；positionless/過期→`dist_factor=0`**（威脅位置未知=無法算 proximity 威脅→不 proximate-threat）。
- **★優雅統一**：positionless 威脅→dist_factor 0→威脅分 0→**不 flee/defend 無位威脅**（合 null-belief-flee「威脅無座標 FLEE not applicable→覓食」+ 既有「dist≥5 逃出生天→0」語意）。看不到就不瞬鎖真位反應=belief-化。
- freshness=`belief last_tick==current_tick`（同 estimate_catch_up 的 position 態）。
- **∴「威脅評估 belief 化」真達成**（approach velocity + dist position + rep + power 全 belief）→ god-view audit 可誠實斷言。

## ★combat_target freeze（reviewer UNCERTAIN，systems verify=pre-existing，measure 盯）
`options.gd:92/118/200`（掠奪/佔村/攻擊）dispatch 即設 combat_target → `movement:77 if combat_target!=-1: continue`（凍結移動）+ `_refresh_attack_pursuit:277 combat_target!=-1: return`（撲空放棄網早退）→ modern DecisionOptions 路「撲空後放棄」安全網可能不 fire、隊卡 combat_target 於 stale tile。**★verify=pre-existing 架構**（D 不碰 combat_target/movement:77，只改「選哪個 target/位置」→ 餵更多 stale 進此既有路，非 D 引入）。**measure 硬盯 combat_target 凍結隊數 before/after**（D 若顯著增→撲空放棄網缺口暴露=另票，非 D blocker 但要看見）。

## ★measure 敏感（spec 硬含 before/after 協議）
改威脅/追擊距離 = **動全盤行為**（threat 評估→誰是威脅→flee/defend/attack；finder catch-up/intercept→追擊/攔截）。∴ **不盲改**：
- **before/after doom-delta**（seed1337/42/4201）：真隊存亡/attrition 對照。
- **threat/combat 行為對照**：威脅評估數（_approach_score 分佈）、追擊成功/撲空率、flee 觸發率——belief-gate 後「追不到脫視野的隊/威脅評估只算可見+last-seen」=intended 深度（伏擊/脫接觸），非 regression。
- **coherent vs broken 切**（承 Slice E 教訓）：doom-delta 升的隊逐隊讀是 intended（脫視野甩追）還是 bug（null-belief-flee 類 pre-existing 又被暴露）。

## 驗收
- **TDD（差異化，非統一）**：
  - **velocity func**：①observe_velocity 本 tick 可見→live velocity ②斷視線/過期→**`{visible:false}`（非 last-seen）** ③predict_intercept 斷視線→belief last-seen 位（有 belief）/`(-1,-1)`（無）**非 live**。
  - **position func**：④estimate_catch_up 斷視線→catch_cost 用 belief last-seen 位（eta 有意義）。
  - **_is_moving_away_observed**：⑤observe_velocity invisible→direction ZERO→:228 短路 return false（不讀 live，級聯保護 verify）。
  - **envoy lockstep**：⑥predict_intercept 回 `(-1,-1)` sentinel→envoy caller 不誤寫進 move_target（走自己 belief-fallback）。
  - leak 測（威脅 _approach_score/追擊跟 belief 非 live）。
- **gate** constitution PASS / **headless** 0 new(baseline 3) / **determinism** 2 跑 byte-identical。
- **measure**：before/after doom-delta + threat/combat 行為對照（上述協議），逐隊 coherent/broken 切。
- **★dist_factor TDD**：⑦threat_assessment:20 dist 走 belief（本 tick 可見→live 距離、斷視線→last-seen、positionless→dist_factor=0）→ 脫視野近敵不再依真距算威脅。
- **★combat_target measure**：before/after combat_target 凍結隊數（D 餵 stale target，凍結顯著增=撲空放棄網缺口另票）。
- **★god-view audit（宣稱訂正）**：D 改後 path_system 4 func（含 _is_moving_away_observed）+ **threat_assessment:20 dist_factor** 全 belief-gate → **「威脅評估 belief 化」可誠實斷言**（approach+dist+rep+power 全 belief）；path_system 無 `trusted=true` 讀 live。zero god-view gate 逼近（A/F/E/D 全落 → 剩 B/C）。**★若只修 path_system 不 fold dist_factor→audit 假過（禁）。**

## out-of-scope
B（創世②③知識）/C（市場 belief-gate+store）= D 後另 slice（方向已定）。1119 can_reach 下批。

## 排序
最大塊，off main HEAD。★異質 R²（核心威脅信號+measure 敏感+難逆）。CLEAN→dispatch→before/after measure→逐隊切→merge。
