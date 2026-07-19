# spec：null-belief-flee 凍結根治（FLEE 威脅無座標→release 轉覓食）

> 層級：L2（survival/threat FLEE робust，2-3 點）。off main HEAD。★**Slice D 前必修**（blueprint 裁 2026-07-20：每 belief-化 slice 暴露更多此 pre-existing bug，D 範圍大污染更嚴重）。
> 來源：Slice E QA 抽查撿 team75/4/13。known_issues「null-belief-flee 凍結」。PRE-EXISTING（code 強證+measurer baseline diff 確認中）。

## 病象（QA seed1337 坐實）
team75/4/13：`task=逃跑 + flee_from_pos=(-1,-1)` 全程 + 凍結 1 格 + food=0 餓死（team4/13 逃跑↔建設 thrash）。**第 4 種 broken 家族**（finder-check classifier 看不到——非「有 target 沒 dispatch」，是「dispatch 了但目標 null」）。

## root（file:line 坐實）
- 個體 FLEE：`faction_ai:1595/1948` `if td.task==TASK_FLEE: flee_from_pos = _flee_threat_pos(state, team)`（威脅 **belief 位**）。
- `_flee_threat_pos`：最高威脅隊 → `BeliefSystem.belief_pos`；**威脅有存在感但 positionless（stale/無座標）→ 回 `(-1,-1)`**。
- `movement:82`：`if FLEE and flee_from_pos != (-1,-1) and (無 target/已到): move_target=_flee_away_tile`。**flee_from_pos==(-1,-1) 時：無 move_target + `continue`（:87）→ 不動**。註「靠 release 收」= **空話，沒人 release** → 卡 task=逃跑 凍結、不覓食、餓死。
- FLEE option（`options.gd:56`）target 恆 `(-1,-1)`（flee target 由 mover 算）→ **不 gate 威脅座標** → 無座標也照選 FLEE。

## 修（look-before-leap：FLEE 無座標=not applicable→release 轉覓食）
blueprint 認可方向：`flee_from_pos==(-1,-1)`（威脅無座標）→ **release FLEE → re-rank 轉覓食**，非凍結。FLEE「選項」無座標時其實 not applicable，不該被選中卡死。

### 修 A（primary，dispatch look-before-leap）
FLEE dispatch（`faction_ai:1595/1948`）：算 `flee_from_pos = _flee_threat_pos(...)`；**若 == (-1,-1)**（威脅無座標）→ **`TaskArbiter.release(team)`**（撤剛設的 FLEE → IDLE）→ 下 reeval survival re-rank 選覓食/別的。**不留無座標 FLEE 卡死。**
- （或等價：FLEE option applicability gate 加「`_flee_threat_pos != (-1,-1)` 才 applicable」——impl 選乾淨點；效果同=無座標不選 FLEE。）

### 修 B（backstop，movement release）
`movement:82` 把空話「靠 release 收」落實：`if FLEE and flee_from_pos==(-1,-1): TaskArbiter.release(team)`（撤 FLEE → IDLE）而非 `continue` 凍結。防修 A 漏的邊角（timing：FLEE 設後威脅 belief 過期成 positionless）。

## 感知鐵律一致
不回退 live-track（威脅無 belief 座標時**不**偷讀 live 位逃）——無座標=真的不知威脅在哪=合理「轉覓食（顧眼前生存）」，非「瞬鎖 live 逃」。守 belief-化。

## 驗收
- **TDD**：①FLEE dispatch 威脅 positionless（belief_pos=(-1,-1)）→ release，不留 task=逃跑（team 轉 IDLE→re-rank）②FLEE 威脅有座標 → 正常 flee（不誤傷 coherent flee，team67/54 型）③movement backstop：FLEE+flee_from_pos=(-1,-1) → release 非 continue-freeze。
- **gate** PASS / **headless** 0 new(baseline 3) / **determinism** 2 跑 byte-identical。
- **measure（→measurer）**：seed1337 team75/4/13 不再 task=逃跑 凍結餓死（轉覓食/re-rank）；coherent flee（team67/54 真座標遠離/投靠）不退化；42/4201 無 regression。★**Slice D 前落地**（D belief-化不再被此污染）。

## 排序
★Slice D 前（blueprint 裁）。off main HEAD。R²（look-before-leap 不誤傷 coherent flee + 不回退 live-track）→ dispatch。
