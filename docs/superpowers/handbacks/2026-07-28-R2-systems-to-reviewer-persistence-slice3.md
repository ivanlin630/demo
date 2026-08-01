---
from: systems
to: reviewer
status: consumed
topic: "[R²·持守統一 Slice 3 try_set 門檻式(執行層核心)·15952748·★implementer execution-verified抓過度壓制(初版硬擋全非危機committed→PRODUCE隊鎖不轉→attrition 0向凍=latch重演)→修PROGRESSIVE_HOLD_TASKS白名單(只BUILD族completable硬保護,ongoing不擋)→attrition 2.03%恢復·危機axis原封+玩家authority+同task不擋+單點return false非skip·驗tryset 7/7+gate74+determinism+世界不凍·★spec §4/§6 refinement=progressive-only→completable-only白名單需ratify] Slice 3執行層真持守done。審門檻+白名單completable-only refinement+世界不凍。"
branch: feat/persistence-slice3-tryset-threshold (15952748)
---

# R²：持守統一 Slice 3（try_set 持守-aware 門檻式，執行層核心）

## 做（spec §6）+ ★execution-verified refinement
- try_set 加持守門檻：`committed progressive(persist>THRESHOLD 0.1)擋非危機搶班`；危機 axis 原封守命 + 玩家 authority + 同 task 不擋；單點 `return false` 非 skip 硬鎖。
- **★★implementer execution-verified 抓過度壓制（差點重蹈 latch）**：初版硬擋全非危機 committed → **長 PRODUCE 隊（persist 高）鎖不轉攻擊 → attrition 0（向凍！latch 陷阱重演）**。修 = **`PROGRESSIVE_HOLD_TASKS` 白名單（只 BUILD 族 completable 硬保護、ongoing PRODUCE 不擋）** → attrition 恢復 2.03%。
- **★設計 refinement（需 ratify）**：spec §4/§6 原「progressive-only」不夠精確 → 實際 **completable-only**（有終點會釋放的動作才持守鎖；ongoing 無終點動作持守=向凍）。**spec 待補（Edit 文字 mismatch，refinement 記此 handback）。**

## 驗
- tryset test 7/7 + headless 0-new + gate 74 + determinism byte-identical(8ebce533)。
- **★世界不凍**（latch 反例，核心 slice 最關鍵）：attrition 2.03% / teams 49→63 / pop flux＝活。

## ★reviewer focus（refute）
1. **★completable-only 白名單 refinement 對否**：只 BUILD 族 completable 持守鎖、ongoing（PRODUCE）不擋——這 refinement 對否（vs 原 progressive-only）？白名單有沒有漏該保護的 completable 動作、或誤含 ongoing？
2. **try_set 門檻位置對否**：危機 axis（combat_lock/crisis/≥THREAT）+玩家 authority 全在 persist 判斷前（守命/玩家權威不受影響）？同 task 不擋對否？
3. **★★世界不凍真過否**（attrition 2.03%/teams 活＝latch 反例真避開，初版向凍已修）？這是本 arc 最容易重蹈 latch 的 slice——親算確認。
4. **單點 return false 非 skip 硬鎖**：被擋搶班者下 tick 照常再評、committed 隊自己照跑決策/完成釋放——真非 latch 凍死？
5. `PROGRESSIVE_HOLD_TASKS`/`THRESHOLD 0.1` 常數合理否（TEST VALUE）？

**CLEAN（含 ratify completable-only refinement）→ merge Slice 3 → Slice 4（A1 手不聽腦收，驗 construct.complete_build>0）。** 有洞 → 回 `to:systems`。
