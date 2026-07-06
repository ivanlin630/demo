# Hand Back: 序7 ReactionSystem 行為選擇溶入（bridge panic-flee）

分支 `feat/reaction`。arc 序7（audit 標「最大最難」，★measure reframe=**其實小**）done。

## ★Reframe 坐實（核心）

audit 標 ReactionSystem「9 反應 winner-take-all=完整平行行為引擎」。**調查+measure 坐實其實小**：

- 9 反應 apply **幾乎全 state-effect**（loyalty/stress/unrest/food/coin/離隊 spawn/生育/memory 後果）——**沒一個改 team task/dispatch**。
- **唯一行為選擇（改 task）= 聚合 panic-flee bridge**（`reaction_system.gd:48-60` 手算 try_set TASK_FLEE）。
- ∴ 序7 = **拆 1 個 bridge**（違憲 task 指派）+ **保 9 反應為 consequence scaffolding**。非拆 9 反應（合藍圖 arc-order「拆行為選擇 vs 情緒/離隊/生育後果保留」）。

baseline measure 佐證：seed 1337/1200t **bridge 觸發 = 0**（dormant 路徑），個體反應 change = 0（seeded 兵卒穩定）→ 撤除零 seeded 影響。

## 實作摘要（改的檔）

- `scripts/simulation/decision/decision_context.gd` — 加 `team_panic: float`（高 stress 低 loyalty **named** 成員數 / pop 聚合）+ `PANIC_STRESS 0.6`/`PANIC_LOY 0.4` const。gather 迭 `named_members`（anon 無個體 state；O(named) 非 O(N²)）。**ctx 首讀 person stress/loyalty = 決策模型情緒腳首個接線起步。**
- `scripts/simulation/decision/terms.gd` — `threat_pressure` eval 疊 `+ ctx.team_panic × PANIC_WEIGHT`（潰散=感知威脅放大→survival option FLEE util 升）。加 `PANIC_WEIGHT 0.5` const（TEST/B 債）。
- `scripts/simulation/reaction_system.gd` — `evaluate_all` bridge 段撕除（try_set + flee_count 聚合 + 死碼 `_find_top_threat`/`_flee_target_simple`）。**個體反應 apply（:151-293）全不動。** 集體恐慌現由引擎 survival option（team_panic 驅）輸出。
- `scripts/debug/reaction_dissolution_check.gd`（新）— 自建融合驗（序7 無現存 probe/framework S7）。
- `scripts/debug/constitution_baseline.txt` — `evaluate_all` 指紋 removed（gate PASS sites=31，reaction_system 零 TaskArbiter 面）；header 記序7 溶解。
- `scripts/debug/headless_test.gd` — 移除 `_test_bridge_*`/`_test_panic_skips_player_team`/`_test_bridge_cannot_stomp_survival` + `_make_panic_team`（測 dissolved bridge 機制，融合驗改新 harness）。

## 融合驗結果（reaction_dissolution_check.gd，ALL PASS）

- **①行為溶入**：team_panic=0.8 隊 → `rank_scored` survival(FLEE) util=0.4 勝主 rank（潰散→逃，非旁路 try_set）。
- **②★FLEE 三源序保**：真絕境(food=0) survival-class util=12.0 **壓過** panic-only FLEE util=0.4 → panic 不喧賓奪主。PANIC_WEIGHT max 0.5 << survival_pressure 絕境量級（12）。
- **③反向守**：兵卒穩（低 stress 高 loyalty）+ 無威脅 → team_panic=0 → survival util=0 → 不逃（top=建設）。
- **④★個體反應後果保**：comply→loyalty+ / riot→unrest+ / defect→離隊 spawn / breed→minor+ / extort→coin轉 / shirk→food− 各 apply 全執行（consequence scaffolding 完好）。

## 全回歸（綠）

- reaction/threat/solo/rung/vendetta/prosperity/faction-dispatch 融合驗 **ALL PASS**（threat/preempt 尤驗——FLEE 路共用未破）。
- framework **PASS=7 DORMANT=0**、threat-preempt **ALL PASS**、憲法閘 **PASS removed evaluate_all**。
- headless seeded **49/8/1/381 零漂移**（bridge 撤前後同；threat.dispatch flee=6 前後同）。
- **唯一 headless FAIL = `弱目標未加入攻擊 goal`（pre-existing，已於 base 725c039 驗同 FAIL，非序7 引入）**。

## 連動風險（主 session 決定是否補修）

- **玩家隊自動 FLEE 保護**：舊 bridge 帶 `leader_id != player_id` 顯式 guard。新 team_panic→survival 路徑**倚賴既有 per-path 玩家 guard**：`_evaluate_solo`(:1701) 玩家早退**在** `_decide_unified`(:1706) 前、`_evaluate_survival`(:2906) 玩家早退、`_evaluate_threat` unified 早退。已驗玩家隊到不了引擎 survival dispatch → 顯式 guard 被涵蓋。**低風險，建議系統確認**無其他路徑讓 team_panic 對玩家隊派 FLEE。
- **team_panic 時序差**：舊 bridge 在 step7（faction_ai step6b 後）可覆蓋本 tick task（即時）。溶解後 team_panic 進 ctx → **下次 faction_ai cadence(step6b)** 吃。panic=累積 state（非瞬時）→ cadence 反映可接受，harness 驗潰散仍及時觸發 FLEE。若觀察到「該逃沒即時逃」再議。
- **team_panic 只計 named 成員**：anon 無個體 stress/loyalty（team-level 抽象）→ 純 anon 隊 team_panic 恆低。**與舊 bridge 同限**（flee_count 亦只計有 PersonData 的 named）→ 非新退化，但大兵卒隊潰散信號弱=既有限制。

## 待主 session 確認 / backlog

- **PANIC_WEIGHT=0.5 = B 債**（★照妖鏡）：team-state 驅（非全域行為常數）尚可，但殘全域 const——**該由這隊膽識算**（膽小早潰早逃 / 悍將硬撐），非全域一刀切。列常數人格化 backlog（同 PREEMPT_MARGIN/FEUD_ATTACK_MIN 類）。
- **記憶染價值腳仍 dormant（決策模型 gap）**：reaction 寫 `person.memory(intensity)` 但 **DecisionContext 完全不讀**。序7 的 team_panic 讀 stress=**情緒腳首接線起步**，但 memory 腳完整接=未來 slice（決策模型完成）。backlog。
- **反應後果健康度觀測空白**：reaction 零 probe / framework 無 S7 → 序7 自建 harness。反應 consequence 健康度 wave QA 需 observer/harness。backlog。
- **pre-existing `弱目標未加入攻擊 goal` FAIL**：commander-v2 `_update_goals` belief armed_est 門檻測，非序7 引入（base 同 FAIL）。呈報供系統排入 known_issues 驗證。
- **PANIC_STRESS/PANIC_LOY 門檻 = TEST VALUE**：panic 聚合門檻未平衡校，待 measure。

## 後序

序7 綠 → 序8 灰項（select_strategic_intent/diplomatic/strategic trade_net dispatch 片段）→ 全掃憲法閘 + 撤 pre-commit 轉常駐。決策模型「記憶腳」接線=arc 後另軌。
