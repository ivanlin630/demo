# Spec：wave1 序7 — ReactionSystem 行為選擇溶入（bridge panic-flee）

> arc 序7（audit 標「最大最難」，★measure reframe=**其實小**）。承融合模式。**溶=融合非刪**。北極星：集體恐慌=遭遇/決策的一個輸出，朝統一評估收斂。系統 owner。

## 1. ★Reframe（measure 坐實，重要）
audit 標 ReactionSystem「9 反應 winner-take-all=完整平行行為引擎」。**調查坐實**：9 反應 apply **幾乎全是 state-effect，沒一個改 team task/dispatch**——**唯一行為選擇（改 task）= 聚合 panic-flee bridge**（reaction_system.gd:48-60）。其餘（comply/produce/expand/riot/defect/shirk/extort/breed + on_attack_defeat）= **情緒/loyalty/unrest/food/coin/離隊 spawn/生育/memory 後果** = **合憲保留**（正合藍圖 arc-order「拆行為選擇 vs 情緒/離隊/生育後果保留」）。

**∴ 序7 = 拆 1 個 bridge panic-flee（違憲 task 指派）+ 保反應為 consequence scaffolding。** 非拆 9 反應。

## 2. 現況（bridge panic-flee，唯一違憲）
`ReactionSystem.evaluate_all`（:48-60）：per-team 累 `flee_count`（N1_flee 人數）→ 若 `flee_count/pop ≥ PANIC_RATIO(0.3)` 且 `leader != player` 且 current_task ∉ {FLEE,ESCORT} → `_find_top_threat` → `TaskArbiter.try_set(TASK_FLEE, _flee_target_simple, PRIO_THREAT(70), "bridge_panic")`。無威脅→不劫持。
- **語意**：兵卒大量恐慌逃散 → 整隊被裹挾潰逃（即使 leader 勇）。= 團 emotional state（潰散）壓過 leader 決策。
- **FLEE 三源既定序**：survival(PRIO_SURVIVAL 80) > threat/panic(PRIO_THREAT 70)。panic 刻意 ≤ survival 防 ping-pong。**收編勿破此序。**
- 憲法閘：baseline 標 `reaction_system.gd::evaluate_all` 指紋（此 try_set）。溶解=移除指紋=arc 進度。

## 3. 目標
bridge panic-flee 手算 try_set 撕除 → **集體恐慌成引擎決策輸入**：團 panic state（aggregate 兵卒 stress/flee）→ ctx 信號 → 引擎 `survival` option 自然勝 → TASK_FLEE。潰散由統一秤輸出，非旁路 try_set。**合決策模型**（團情緒 state = 現況腳的決策輸入）。

## 4. 設計
### 4a. ctx.team_panic（團潰散信號）
`DecisionContext` 加 `team_panic: float`（gather 算 = 該隊 person 的 flee-傾向/stress 聚合，鏡射 ReactionSystem flee_count/pop 但取 state 而非跑 argmax）：
```gdscript
var team_panic: float = 0.0
# gather：team_panic = clampf(高stress低loyalty person 數 / max(pop,1), 0, 1)
#   （或直接讀 ReactionSystem 已算的 team-level panic state if 存在；避免重算 argmax）
```
（★注意：ctx 現不讀 person.stress/fear——需擴 context 讀該隊 person state 聚合。這也是 stress→決策的首個接線=決策模型情緒輸入起步。）

### 4b. survival option 吃 team_panic（潰散→逃）
`survival` option 現 term `[threat_pressure, survival_pressure]`（threat_react 驅 FLEE）。加 panic 貢獻：team_panic 高 → survival util 升（潰散壓過 leader 勇氣）。落點二選：
- (A) `threat_pressure` eval 疊 `+ ctx.team_panic × PANIC_WEIGHT`（潰散等價感知威脅升）。
- (B) 新 term `panic_pressure` 掛 survival option（team_panic 驅，weight=1.0 人格 baked）。
- **裁定：(A)**（潰散=團體感知的威脅放大，語意最貼；且不新增 option/term 數，淨判斷器不升）。但需守：panic-FLEE 仍 ≤ survival 真絕境（threat_react 主，panic 疊加不喧賓奪主）→ PANIC_WEIGHT 校使 panic-only 觸發的 survival util 對應 ≤ PRIO 語意（不抬過真 survival）。**B 照妖鏡**：PANIC_WEIGHT 若全域→標 B 債（該 team-state 驅，已是 state 非全域常數，尚可）。

### 4c. 撤 bridge try_set + 保個體反應
- `ReactionSystem.evaluate_all` 的 :48-60 bridge 段刪（try_set + flee_count 聚合 dispatch）。flee_count 若他用保留計數。
- **個體反應 apply 全保**（loyalty/stress/unrest/food/coin/離隊 spawn/breed/memory）= consequence scaffolding，不動。
- 集體恐慌現由引擎 survival option（team_panic 驅）輸出 → faction_ai loop3/主 rank 派 FLEE（既有路，PRIO_SURVIVAL/THREAT 語意保）。

### 4d. 時序
bridge 原在 step7（faction_ai step6b 後）可覆蓋本 tick task。溶解後 team_panic 進 ctx → 下次 faction_ai 決策（step6b）吃 → 潰散反映在正規決策 cadence。**微時序差**（原 step7 即時 vs 現下 cadence）：panic 是累積 state（非瞬時），cadence 反映可接受；驗潰散仍及時觸發 FLEE。

## 5. 融合驗（`reaction_dissolution_check.gd`，★需自建=無現存網）
- **行為選擇溶入**：構高 team_panic 隊（多兵卒高 stress 低 loyalty）+ 威脅在場 → `rank_scored`/survival 出 TASK_FLEE（潰散→逃，非旁路 try_set）。
- **★FLEE 三源序保**：真 survival 絕境（food≈0）→ survival(80) 仍壓過 panic-only；panic-only（無真絕境）→ FLEE 但不喧賓奪主（不抬過真 survival/威脅）。
- **反向守**：低 panic（兵卒穩）+ 無威脅 → 不逃（team_panic 低→survival util 低）。
- **★個體反應後果保**：comply→loyalty+、riot→unrest+、defect→離隊 spawn、breed→minor_pop+、extort→coin 轉、shirk→food− 全不變（consequence scaffolding 保，驗各 apply 仍執行）。
- **回歸**：seeded（漂移允許 QA wave；潰散路徑改→分佈微變）+ framework PASS=7（S1-S6 不含 reaction，不破）+ threat/solo/rung/vendetta/preempt/prosperity/faction-dispatch 融合驗+live-seam 不破 + 憲法閘（`evaluate_all` 指紋 removed）。

## 6. 憲法閘 baseline
`reaction_system.gd::evaluate_all` 的 bridge try_set 撤 → 指紋 removed（arc 進度）。個體反應無 try_set（state-effect）不在閘內。同 commit 更新 baseline。

## 7. 待藍圖（reframe 確認 + 2 finding）
1. **★序7 reframe 確認**：序7 其實小（只拆 bridge flee，保 9 反應=情緒/後果，合你 arc-order「情緒/離隊/生育後果保留」）。確認此 minimal scope？OR 你要情緒-argmax 本身也統一（大很多，且反應不映引擎 option=情緒非 task）？我判 minimal（你 arc-order 已定拆行為保後果）。
2. **★記憶染價值腳 dormant（決策模型 gap）**：reaction 寫 memory(intensity) 但**引擎完全不讀**（DecisionContext 無 memory）→ 決策模型「記憶染價值」腳**未接線**。序7 的 ctx.team_panic 讀 stress=**情緒腳首個接線起步**，但 memory 腳完整接=未來 slice（決策模型完成）。列 backlog。
3. **反應零 probe / framework 無 S7**=觀測空白，序7 自建 harness（§5）。反應後果健康度 wave QA 需 observer/harness（backlog）。

## 8. 後序
spec → plan → 子 session。序7 綠 → 序8 灰項（select_strategic_intent/diplomatic/strategic trade_net dispatch 片段）→ 全掃憲法閘 + 撤 pre-commit 轉常駐。決策模型「記憶腳」接線=arc 後另軌。
