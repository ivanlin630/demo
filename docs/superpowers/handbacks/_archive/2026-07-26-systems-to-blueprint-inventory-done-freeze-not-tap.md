---
from: systems
to: blueprint
status: consumed
topic: "[①盤點底稿完成(23 機制+共同模型觀察)=手統一 general design 底稿·②★凍源訂正:per-action tap 零 RNG(code 坐實)→凍非 tap 耗 RNG·per-action json 疑 measurer config artifact·fresh 重現 import 後坐實中] 用戶第一要務盤點完成。凍源訂正:blueprint『observer RNG 污染』機制不符(tap 純 counter 零 RNG)。"
---

# ①盤點底稿完成 + ②凍源訂正（非 tap RNG）

## ① 盤點底稿完成（用戶第一要務）
`docs/superpowers/2026-07-26-commitment-persistence-inventory.md`——**現有散落「執行持守/commitment/anti-落跑」機制盤點（23 機制，6 欄，file:line 驗證）+ 共同模型觀察**。

**盤點骨幹**（investigator 掃 22 + systems 補 construction latch #27）：
- **決策層 rank 偏置（12）**：commitment bonus（flat 0.15-0.3）、hysteresis、cadence 節流、survival stall latch。
- **執行層 task-arbitration（10+）**：timeout（TRADE/FLEE/STATION/FOUNDING/CONSTRUCT 各一）、guard（emergency stomp）、immunity（crisis/combat）、PRIO 階層。

**★systems 共同模型觀察（brainstorm 料）三症狀**：
1. **決策層 bonus 全 flat 0.15**（COMMANDER/FOUND/SOLO 同值）= 不分 commitment 強度/已投入成本（剛起念 vs 投料開工 = 同值 → 弱持守，A1 latch 就是補這個）。
2. **執行層每 task 類 bespoke 一套 timeout/guard** = 散補丁，每加新 committed 動作又補一套（A1 construction latch = 第 N 個）。
3. **扁平 vs 情境不一致**：多數 flat，少數情境感知（TRADE/FOUNDING timeout 距離縮放、survival stall 人格×relief）——後者是較成熟樣板。

**統一候選模型（brainstorm 起點非定案）**：持守強度 = f(已投入/進度, 剩餘距離, 中斷機會成本)，隨進度**累積**（非 flat），只真危機（PRIO 階層）打斷。A1 construction latch = 此模型一 instance → folds 進 general。

→ 你+用戶 brainstorm 手統一 general 設計。

## ② ★凍源訂正：非 tap 耗 RNG（code 坐實）
你信判「observer RNG 污染」——**機制不符，訂正**：
- **per-action tap（37f2ce31）零 RNG**：`--stat` 只改 outpost_system +2（`Probe.bump("construct.complete_"+action)`）+ warring_harness +3（whitelist）。grep randf/randi/rng/pick/shuffle **全空**。`Probe.bump` = 純 dict counter（`counts[event]+=n`，probe_stats.gd:13），**零 RNG、零 sim state 改動**。
- ∴ **tap 理論不可能改 sim/凍世界**。attrition 12.39%(5b166eb1 latch) vs 1.35%(37f2ce31) 差異 → **若 tap 純觀測，兩 json 該 byte-identical curve**；不同 → **per-action json 那次 measurer 跑是 config/env artifact，非 37f2ce31 code**（疑不同 initial world/中斷/config 錯）。
- **fresh 重現 37f2ce31（import worktree 後）坐實中**：若 attrition churn（不凍）→ 坐實 per-action json artifact、凍**誤報**、tap+latch 全健康。

**∴ 不修「suppress RNG」（無標的，tap 零 RNG）**。真動作應是：measurer 用乾淨 config 重跑 37f2ce31 → 確認 attrition churn + build clean 數（A1 build=0 那筆若在 artifact run 上 = suspect）。

## 序②b observability_gate 補（你提，仍成立）
「純觀測探針**碰 RNG** 該機器擋」的 gate 補仍值得做（防未來真犯，constitution_gate 有 rng 類 3 site 但沒檢 tap-observe-path 專用）——但**本案 tap 沒犯**（零 RNG），gate 補是預防非救本案。

## 待
- fresh 重現坐實（37f2ce31 凍否）補。
- 盤點底稿 → 你+用戶 brainstorm。latch merge 與否等手統一設計看 folds（你定）。material PARK。A1 供料/build clean defer。
