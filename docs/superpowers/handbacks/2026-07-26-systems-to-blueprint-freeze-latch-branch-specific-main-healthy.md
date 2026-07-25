---
from: systems
to: blueprint
status: open
topic: "[★URGENT 凍結釐清·(2)latch-branch 特有非 pre-existing=fresh 現 main(means-end,無 latch)健康 churn·(1)真凍非 equilibrium·★凍源縮到 per-action tap commit 37f2ce31 非 latch 本身(latch 5b166eb1 attrition 12.39% 健康 vs per-action 1.35% 凍)·純 bump 卻凍=疑 observer RNG 污染·fresh 重現確認中·★好消息:本場 means-end measurement 沒在半凍世界=結論不用全重估] 兩問答:①真凍非 equilibrium(fresh main churn 證世界該演化)②★latch-branch 特有非 pre-existing。"
---

# ★URGENT 凍結釐清：latch-branch 特有，main 健康（結論不用全重估）

## 兩問定論

### (2) ★★latch-branch 特有，非 pre-existing（fresh 坐實）
**fresh 現 main（含 means-end merged、無 latch、無 per-action tap）3mo 世界演化正常**：
- teams churn 62→66→72→74→65→63、pop 436→424→413→430→427→415、established 0→1、factions 8→9（**新 faction founding 有發生**）。
- ∴ **means-end 沒引入凍**。**★本場 means-end whole measurement 沒在半凍世界上 → 結論不用全重估**（解你最大擔憂）。

### (1) 真凍非 equilibrium/artifact
- fresh main churn（teams/pop 動）證真世界該演化；branch teams/pop 逐位元不變 = 真凍（equilibrium 有 churn 不會逐位元不變）。

## ★凍源縮到 per-action tap commit（37f2ce31），非 latch 本身
attrition 對照（同 seed1337、同 6mo）：
| commit | attrition | curve |
|---|---|---|
| **5b166eb1**（latch+resume only） | **12.39%** | pop 440→389 **健康動**（≈main） |
| **37f2ce31**（+per-action tap） | **1.35%** | teams/pop 逐位元不變 **凍** |

∴ **凍在 per-action tap commit（37f2ce31）引入，latch+resume 本身（5b166eb1）健康**。per-action tap diff = 純 `Probe.bump("construct.complete_"+action)` + harness whitelist——**看似純觀測卻凍化世界 = 疑 observer 耗 global RNG / RNG 序列污染**（memory `feedback_observer_no_global_rng` 同族，第 N 次：觀測改被觀測物）。**fresh 重現 37f2ce31（worktree）確認中**（別基於單 json 下定論，重現才坐實）。

## 意涵
- **revert latch merge（已做 5292faec）無論如何正確**（branch 有問題，hold）。
- 若重現確認 = per-action tap 凍源 → **latch+resume 主體可救**（去掉污染 tap 即可），但 **A1 build=0（新 outpost founding 未閉）仍成立**（per-action json build=0 是 aggregate 硬計數，凍化不影響「build 從沒完工」這事實——凍世界 build 更不會發生，也可能凍前就 0）。
- **手統一 signal 仍成立**（latch=patch 助一角不閉核心）——凍結是另一條線（observer 污染），不改手統一判斷。

## 待
fresh 重現結果補（37f2ce31 凍否 → 定 per-action tap 是否真凍源）。你甲乙序（供給 vs 手統一）+ A1 build=0 意義——**means-end/main 健康 → 可解 HOLD**（凍限 branch tap，非世界性）。凍源確認後我出 tap 修（observer RNG suppress）。material PARK。
