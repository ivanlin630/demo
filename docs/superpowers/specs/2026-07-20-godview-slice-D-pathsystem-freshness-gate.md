# spec：god-view Slice D — path_system 位置 leak（freshness-gate，最大塊）

> 層級：L1（core 威脅/追擊信號，11 caller，measure 敏感）。off main HEAD。god-view 殲滅 arc 最大塊。★異質 R²（大結構+核心威脅信號+measure 敏感=框外挑框三對齊，blueprint 已預告）。
> 來源：god-view audit（`2026-07-19-systems-to-blueprint-godview-audit-scope.md` Slice D）。A/F/E/null-belief-flee 已 merged。

## 感知鐵律最大違憲點
`path_system` 三 func 讀他隊 **live `tile_pos`** 算 velocity/reachability/eta/intercept，11 production caller 以 `trusted=true` 跳 discovery 讀 live = **live god-view leak**（追蹤已脫視野的隊）。stats（pop/food/armed）已 belief-gate，**唯 position leak 未治**。

| func | `path_system` | 讀 live |
|---|---|---|
| observe_velocity | :175 | target live 位算速度/方向 |
| estimate_catch_up | :202 | target live 位算追上 eta |
| predict_intercept | :241 | target live 位算攔截點 |

**11 caller**（invariants:174 坐實）：`faction_ai:201/289/1364/2087/3537/3566/3596/3645/3677`（finder 族）+ **`threat_assessment:27 _approach_score`（核心威脅信號，call observe_velocity）**。

## 正確範式（已存在，`_refresh_attack_pursuit:269-291`「Fix F 追擊 vision-gate」）
三態（鏡射之）：
- **① `belief last_tick == current_tick`（本 tick 可見）** → live 位合法（在視線內）→ predict_intercept/observe live OK。
- **② 斷視線（last-seen 有位但過期未過 stale 門）** → belief last-seen 位（prey 已移=撲空機制，非現址）。
- **③ belief 過期/無位** → 放棄（追擊 re-eval / 威脅信號視為不可見）。

## 修（centralized freshness-gate in path_system，DRY）
三 func 內建 freshness-gate（取代 `trusted=true` 跳 discovery）：
- 用 `BeliefSystem.best_estimate(observer, target)` 取 `last_tick`：
  - `last_tick == current_tick` → 用 target **live 位**（本 tick 可見合法）。
  - stale-但-有位 → 用 belief **last-seen 位**。
  - 過期/無位 → 回**不可見**（`{"visible": false}` / sentinel），caller 照既有「不可見→0/放棄」處理（如 `_approach_score:29` `if not visible: return 0.0` 已備）。
- **移 `trusted=true` 後門**（god-view 讀 live 的跳閘）。
- **DRY 理由**：11 caller 同型「他隊位算距離/速度」→ 集中 path_system freshness-gate，caller 多數不需改（threat_assessment/finder 讀回值照用，不可見→既有 0/skip 路）。逐 caller 審有無特例（同-faction 協調 tally 若有=豁免，逐 site 判）。

## ★measure 敏感（spec 硬含 before/after 協議）
改威脅/追擊距離 = **動全盤行為**（threat 評估→誰是威脅→flee/defend/attack；finder catch-up/intercept→追擊/攔截）。∴ **不盲改**：
- **before/after doom-delta**（seed1337/42/4201）：真隊存亡/attrition 對照。
- **threat/combat 行為對照**：威脅評估數（_approach_score 分佈）、追擊成功/撲空率、flee 觸發率——belief-gate 後「追不到脫視野的隊/威脅評估只算可見+last-seen」=intended 深度（伏擊/脫接觸），非 regression。
- **coherent vs broken 切**（承 Slice E 教訓）：doom-delta 升的隊逐隊讀是 intended（脫視野甩追）還是 bug（null-belief-flee 類 pre-existing 又被暴露）。

## 驗收
- **TDD**：①三 func 本 tick 可見→用 live（同結果）②斷視線→belief last-seen ③過期/無位→不可見（caller 0/放棄）。leak 測（威脅/追擊跟 belief 非 live）。
- **gate** constitution PASS / **headless** 0 new(baseline 3) / **determinism** 2 跑 byte-identical。
- **measure**：before/after doom-delta + threat/combat 行為對照（上述協議），逐隊 coherent/broken 切。
- **★god-view audit**：D 改後 path_system 三 func 無 `trusted=true` 跳 discovery 讀 live（belief-gate 證）；zero god-view gate 逼近（A/F/E/D 全落 → 剩 B/C）。

## out-of-scope
B（創世②③知識）/C（市場 belief-gate+store）= D 後另 slice（方向已定）。1119 can_reach 下批。

## 排序
最大塊，off main HEAD。★異質 R²（核心威脅信號+measure 敏感+難逆）。CLEAN→dispatch→before/after measure→逐隊切→merge。
