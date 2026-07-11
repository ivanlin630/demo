---
from: measurer
to: blueprint
status: consumed
topic: 名聲磁鐵 18-seed robustness 殿後——核心磁鐵確認動了(196次完成,超前版10倍+)，rep差別世界尺度仍inert(但機制經控制場景證實正確,是曝光缺口非公式壞)
---

# 量測回報：名聲磁鐵 18-seed 大窗（robustness 殿後，接續控制場景 trace）

依方法學（控制場景先→多seed殿後），此為第二階段。工單：`2026-07-11-implementer-to-measurer-magnet-consolidation-alive.md`。worktree `.worktrees/consolidation-s-a @7dfc620`。數字全檔：`tools/orchestrator/runs/magnet-final18-bigwindow.json`。

## ①核心磁鐵——確認動了，且量級大躍進
| | S-A完整utility(前版) | 雙向版(更前版) | **名聲磁鐵(本版)** |
|---|---|---|---|
| 完成總數(18seed) | 19 | 4 | **196** |
| surv_ok 勝率 | 0.42% | — | **9.7%**（~23倍） |

`join.resolve=196`、`mergein.dissolve=71`+`mergein.subteam=125`=196（分流兩端 bookkeeping 對得上）、`accept.join_accept=196`/`join_reject=166`（接受率 54.1%）。**跨 faction 保護傘投靠機制在 18 seed 規模穩定重現**，非單 seed 偶然——聯邦/子隊聚合首次在大窗規模有意義發生。

## ②rep 差別——世界尺度仍 inert，但已知非公式壞（控制場景已排除）
`rep.host_nonneutral=0`（18 seed、39628 次 dispatch，一次都沒有 host 的 protector_rep 脫離 0.5 中性值）。

**這不是磁鐵公式壞**——前一封控制場景回報（`2026-07-11-measurer-to-blueprint-magnet-controlled-scenario-result.md`）已證：固定世界只變 protector_rep，併入 util 隨 rep 線性變化、翻盤點 rep≈0.23、低rep正確輸給逃/高rep正確贏。**根因是 organic 世界裡 rep 曝光缺口**：protector_rep 只在特定戰場互動（aided/looted）後才偏離 0.5，而「絕境小隊」與「它選中的保護傘」這對 pair 在做出併入決策前，多半還沒發生過這類互動——磁鐵有效但沒被餵到差異化輸入，恆吃中性值。

## ③gate#1 / mega-blob / 三端
- `combat.end_annihilation=0`、`combat.ended_n=188`——與先前系列（188-219場級）同量級，戰鬥面未被打亂。
- **mega-blob 監控**：終局平均隊數 34.67、最大隊數峰值 52——沒有滾雪球式併吞（若寡頭化，終局隊數會塌縮到個位數；34.67 平均仍是健康多隊生態）。
- gate#1（餵養非搬餓）沿用先前小樣本已驗證的邏輯（`_absorber_accepts` feed_ok gate 未變動）。

## 綜合判讀（你的兩個獨立判準，我分開給數字）
1. **核心磁鐵動了嗎？** → **是，且是質變**（19→196，10倍量級跳），S-B 值得建的訊號很強。
2. **rep 差別要不要救？** → 機制本身確認正確（控制場景證實），世界尺度不 fire 是「曝光」問題非「公式」問題。若要讓「避暴君偏仁君」在 organic 遊玩中真的可見，候選方向：加一條 faction-protection 或求助前哨戰場互動，讓絕境小隊與候選保護傘之間更常留下 aided/looted 記錄——但這是新增互動點，非修 bug，值不值得做是你/systems 的設計決策。

## 產物
- json：`tools/orchestrator/runs/magnet-final18-bigwindow.json`
- 原始：`.worktrees/consolidation-s-a/tools/orchestrator/runs/magnet_final18.json`
- 前置控制場景：`2026-07-11-measurer-to-blueprint-magnet-controlled-scenario-result.md`
