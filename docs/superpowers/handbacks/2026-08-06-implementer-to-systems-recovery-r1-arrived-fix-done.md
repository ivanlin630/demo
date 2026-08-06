---
from: implementer
to: systems
status: consumed
topic: "[recovery-r1 執行層修 DONE·feat/recovery-r1 commit 14203b57]migrant arrived=0 修:_tick_migrant 移動改直接 sub.move_target=target.tile_pos(村靜態 own-faction、位置行政知)、棄 PathSystem.predict_intercept(對靜態村錯工具:新生 anon subteam 零 belief→belief_pos(-1,-1)走不動+observe_velocity 耗 RNG)。★決策層三態 measurer 已 CONFIRMED(plains +0.17 唯一正 3/3 dispatched)。驗:r1_test 8/8(+★★驗執行端 migrant 抵村 pop2→5 併入+arrived=1+解散)+headless 0-new+constitution 74+determinism FCE1BAC4 byte-identical(去 predict_intercept RNG 更乾淨)。★merge-gate 核移動改。請 R²→measurer 重量(arrived>0+plains 抵達併入 target pop 真升+forest 樣本補捕)→QA→merge。"
branch: feat/recovery-r1
commit: 14203b57
---

# recovery-r1 執行層修（migrant arrived=0）— DONE（路 systems R²）

**★決策層三態 measurer 已 CONFIRMED**（plains marginal +0.17 唯一正→3/3 dispatched、mountain −2.24→0 派、精準對齊 formula sign）——核心機制證成、只差 delivery 執行。本修＝驗執行端（[[feedback_verify_execution_end]]、我 R1 漏測 arrival、measurer 抓到）。

## root（systems runtime-trace pinpoint、我認）
`_tick_migrant` 用 `PathSystem.predict_intercept`（移動目標**攔截器**）對**靜態村**是錯工具：
- (a) 斷視線分支對**新生 anon subteam（零 belief）**→ `belief_pos` 回 `(-1,-1)` → move_target 不更新 → 走不動 → arrived=0。
- (b) `observe_velocity` 耗 global RNG——此路本該零 RNG。
- 對比：convoy（`_tick_convoy` move_target=home_pos）/ settle 到靜態 own-faction outpost = **直接 `move_target=target.tile_pos`**（非攔截預測）。

## fix（execution-layer、L3 surgical）
`_tick_migrant` 移動改 **直接 `sub.move_target = target.tile_pos`**（村靜態、own-faction、位置=行政知非 god-view）；**棄 `predict_intercept`**（靜態村無需攔截 + 去 `observe_velocity` RNG 消耗＝路徑更乾淨）。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `recovery_r1_test` | **8/8**（前 6 決策層 + **★★驗執行端** migrant 抵村→target pop 2→5 併入(P2 共址即產能)+arrived=1+subteam 解散 / 移動 move_target=村靜態 pos(8,8) 非 `(-1,-1)` 卡死） |
| headless | **0-new** |
| constitution_gate | **PASS sites=74 removed=0** |
| determinism | 3-run（GODOT_TIMEOUT=1200、seed1337 1mo）MD5 `FCE1BAC4E808430F3222CCBEDB2E1FDB` **byte-identical**（migrant warring 1mo inert；**去 predict_intercept `observe_velocity` RNG 反而更乾淨**＝此路零 RNG 恢復；真效果 recovery/faction 床） |

## 路
1. **你 R²**（merge-gate 核移動改：`_tick_migrant` 直接 move_target=村 pos、棄 predict_intercept；仍守零 god-view[村位=own-faction 行政知]/determinism 更乾淨）。
2. → measurer 重量：**arrived>0** + plains 抵達併入 target pop 真升（P2 共址即產能）+ forest 樣本補捕（三態 delivery 端確認）。
3. → QA → **merge**（R1 決策+執行雙證成）。

★R1 substrate（MarginalEconomy + 移民）決策層 measurer 證成 + 執行層本修補齊。**R2（投資 material-delivery）/ R3（遷村令）後續 slice。HOLD-warm 待 R²。**
