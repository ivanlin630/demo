---
from: systems
to: blueprint
status: consumed
topic: "[★凍源定論(乾淨重現坐實):latch+resume 本身凍化 seed1337,非 tap 非 artifact 非 pre-existing·翻用戶「latch valid 健康」前提·latch 不該 folds 進手統一 until 凍化根治·★但與 measurer latch-resume json 12.39%動矛盾需釐清·機制待深查(latch只施工隊卻凍全世界=詭異)·context爆交接] 乾淨 fresh 重現(worktree=純5b166eb1確認+cache清+re-import):latch seed1337 凍(71/438 attrition 1.4)vs fresh main 動(71→63)。"
---

# ★凍源定論：latch+resume 本身凍化 seed1337（乾淨重現坐實）

## 乾淨 fresh 重現（ground truth，排除我前 3 次翻轉的 code/json 猜 + cache bug）
| 版本 | seed1337 monthly _snapshot | 判定 |
|---|---|---|
| fresh 現 main（means-end，**無 latch**） | teams 71→73→75→65→62→63、pop churn | **動（健康）** |
| **5b166eb1（latch+resume，無 tap）** | **71/438 逐月不變、attrition 1.4** | **★凍** |
| 37f2ce31（latch+tap） | 71/438 凍 | 凍（同 5b166eb1，tap 無額外效果） |

- **worktree=純 5b166eb1 確認**：outpost 無 per-action bump（grep 0）、harness 無 whitelist（grep 0）、`git diff 5b166eb1` 空、cache 清+full re-import。
- `_snapshot` 讀真 `state.teams.size()`+`_total_pop`（非 dump bug）。

∴ **凍源 = latch+resume 本身**（非 per-action tap、非 pre-existing means-end、非 artifact）。seed1337-specific（seed42 動）。

## ★★意涵：翻用戶「latch valid 健康」前提
- latch+resume **凍化 seed1337 世界**（fresh main churn → latch fixed-point）。
- ∴ **latch 非全健康**，**不該 folds 進手統一 general / 不該 merge，until 凍化根治**。
- 手統一盤點底稿仍有效（latch 是其中一 instance，但這 instance 有凍化 bug，設計時要診斷為何）。

## ★未解矛盾（需釐清，別當定案）
`latch-resume-a1-6mo.json`（measurer 跑「5b166eb1」）seed1337 **attrition 12.39% 動** vs 我乾淨 5b166eb1 **凍（1.4）**。同 base same seed 一動一凍。我乾淨測 worktree 確認 5b166eb1 + cache clean（高信心），但 measurer json 怎麼跑的（config/實際 commit）未知。**需 measurer 澄清那次 config**——若 measurer 對（latch 不凍），則我乾淨測有隱藏差異。傾向我乾淨測（worktree+cache 確認）。

## ★機制詭異（待深查）
latch = `_should_reeval: TASK_BUILD→false`（只**施工隊**）+ resume orig_recall（5b166eb1 seed1337 orig_recall=5，少）。**只影響施工隊，卻凍全世界 teams/pop（births/deaths/foundings/splits 全停 day30後）= 機制不通**。要嘛 latch/resume 有更廣副作用（連鎖鎖死），要嘛 seed1337 本就 day30 後低 churn（fresh main monthly 71→63 也在降）被 latch 推入完全 fixed-point。**需深查**（逐 tick trace latch 下 seed1337 day25-35 世界怎麼卡）。

## ★context 爆，交接
我 context >90%、凍源診斷多輪（誠實：3 次翻轉 non-tap→tap→latch，前兩次 code/json 猜錯，第 3 次 cache bug，這次乾淨重現才坐實）。**已確定可用**：凍源 latch、main 健康、盤點底稿已交。**建議下個 systems session 續**：①釐清 measurer json 矛盾 ②深查 latch 凍化機制（為何只施工隊卻凍全世界）③手統一 general 設計時 latch instance 帶此 bug 診斷。material PARK。
