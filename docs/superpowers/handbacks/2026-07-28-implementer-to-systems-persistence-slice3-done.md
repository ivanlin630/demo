---
from: implementer
to: systems
status: consumed
topic: "[done·持守統一 Slice 3 try_set 持守-aware 門檻式·請 R²(Slice3)] feat/persistence-slice3-tryset-threshold 15952748 off local main eef7ea7c。try_set 加持守門檻:committed progressive(persist>THRESHOLD 0.1)擋非危機搶班;危機 axis 原封守命+玩家 authority+同 task 不擋;單點 return false 非 skip 硬鎖=不凍。★execution-verified 抓過度壓制:初版硬擋全非危機 committed→長 PRODUCE 隊鎖不轉攻擊→attrition 0(向凍);修=PROGRESSIVE_HOLD_TASKS 白名單(只 BUILD 族 completable 硬保護,ongoing 不擋)→attrition 恢復 2.03%。驗:tryset 7/7+headless 0-new+gate 74+determinism byte-identical(8ebce533)+世界不凍(attrition 2.03%/teams 49→63/pop flux)。"
branch: feat/persistence-slice3-tryset-threshold
commit: 15952748
base: eef7ea7c (local main HEAD，Slice 1/2 merged)
spec: docs/superpowers/specs/2026-07-28-persistence-decision-layer-HOW.md §6/§9
---

# done：持守統一 Slice 3（try_set 持守-aware 門檻式）——請 R²(Slice 3)

執行層核心（A1 rank-only 修不到的 committed 動作真持守）。

## 做（§6 門檻式）
`TaskArbiter.try_set` 加持守門檻（危機-immunity guard 後、tier 比較前）：
```gdscript
if new_task != current and current in PROGRESSIVE_HOLD_TASKS \
   and priority < PRIO_THREAT and current.task_priority < PRIO_THREAT \
   and priority != PRIO_PLAYER and persist_strength > PERSIST_HOLD_THRESHOLD:
    return false   # 擋非危機搶班,完成優先
```
- `PERSIST_HOLD_THRESHOLD=0.1`（TEST；固執過 ~1/3 progress 黏、務實幾乎不黏）。
- **危機 axis 原封**（任一側 ≥PRIO_THREAT：combat/survival/threat → 過，守命/背水一戰）。
- **玩家 authority**（PRIO_PLAYER 不擋）+ **同 task**（target 更新非搶班不擋）。
- **★latch 反例避開**：單點 `return false`（非 skip reeval 硬鎖）→ 被擋者下 tick 照評、危機/玩家照打斷、committed 隊自跑決策、完成/timeout release→persist 歸 0 = 世界照演化不凍。

## ★★execution-verified 抓過度壓制 + 修（本輪關鍵）
初版硬擋**全非危機 committed**（NON_PROGRESSIVE 只排 IDLE/FLEE）→ 長 **PRODUCE 隊** persist 高被硬鎖、不轉攻擊/防衛 → 戰鬥趨零 → **attrition 0（向凍）**（seed1337 1mo：baseline 1.80→S1/2 1.13→初版 S3 **0**，pop 444→444 flat）。
**修**：`PROGRESSIVE_HOLD_TASKS` 白名單（BUILD/CONSTRUCT/UPGRADE/EXPAND/SETTLE/MIGRATE）——硬門檻**只保 completable committed**（有終點的 A1 建造類）；ongoing 開放式（PRODUCE/TRADE/GOVERN/FORAGE）不硬擋（照 tier 正常搶）。決策層 bonus（Slice 1）仍對全 committed 溫和偏置（max 0.3 不鎖）。
→ **attrition 恢復 2.03%**（vs baseline 1.80%，健康）。★這是 execution-verified（非只 TDD 綠）抓到的向凍，符「別做出凍世界的東西」。

## 驗（全綠）
- `persist_tryset_test` **7/7**：非危機擋 / persist 低過 / 危機 tier 守命 / 玩家 authority / 同 task 不擋 / release 不凍 / ★ongoing task 不硬擋。
- headless **0-new**（6 baseline）+ `constitution_gate` **74 removed=0**（persist gate 未新增 flagged site）。
- determinism **3跑 byte-identical** `8ebce533`。
- **★★世界不凍**：seed1337 1mo attrition **2.03%** / teams 49→**63** / pop 444→435 flux = **活**（修前 attrition 0 過度壓制已解）。

## 待
systems R²(Slice 3)——尤其：門檻式不破現有 PRIO/仲裁（危機守命/玩家 authority 保）+ PROGRESSIVE_HOLD_TASKS 白名單對（避過度壓制）+ 世界不凍 → merge → **Slice 4**（A1 手不聽腦收：committed builder persist 高→執行層不被外交/貿易搶→`construct.complete_build>0` 真完工，execution-verified specimen-off/aggregate）。material PARK。
