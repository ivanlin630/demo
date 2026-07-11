---
from: blueprint
to: systems
status: consumed
topic: [§2/§3 config缺口] 據點數/勢力數變異被warring_states顯設釘死未驗——遊戲config放野+控制測試config釘死;驗§2/§3
---

# 藍圖：world-gen variety §2/§3 config 啟用 + 驗

measurer 快答（`worldgen-rightsize-result`，consumed）：**§1 據點散布達標驗綠**（地板30/30、重疊7.5%真異、build-outpost 7/7 fire、determinism）。**但 §2（據點數變）/§3（勢力數變）沒驗到**——`warring_states.json` 顯設 `total_count:42`/faction 8，range 只在無顯設時觸發。code 支援、config 釘死。

## 裁定：config 分工（控制 vs 遊戲）
用戶選「都做/放野」（count/faction 該變）。但釘死 config 有用途。分工：
- **控制測試 config（如 warring_states）保留顯設釘死**——當**控制場景基線**（固定 count/faction，只變位置/人格，呼應「除錯控制變數」原則）。回歸/量測隔離用。
- **遊戲/default config 啟用 §2/§3 放野**——真實開局的據點數/勢力數也每 seed 甩（否則「都做」只交付 §1，§2/§3 dormant）。

## 要你（systems）
1. **釐清 config 版圖**：哪個 config 是「玩家實際玩的遊戲世界」（default？別的？）vs 「控制測試場景」（warring_states）。file:line 回。
2. **遊戲 config 啟用 §2/§3**：該 config 移除 `total_count`/faction count 顯設（或改成 range），讓 §2/§3 range 觸發。硬上限留空地（build-outpost 驗）仍守。
3. **measurer 驗 §2/§3**：在啟用的 config 上，據點數/勢力數**跨 seed 真的變**（非固定）、全域地板仍守（放野退化不破）、determinism 守。

## 守則
- 控制測試 config 釘死是 feature 非 bug（量測隔離）。
- 遊戲 config 放野守全域地板（reviewer 靶C：每勢力≥1據點/連通/覆蓋度）+ 硬上限留空地。
- determinism 守。

## 流程
- 這是 §1 已驗後的補完（§2/§3 config 啟用+驗），非新 slice。
- systems 釐清 config + 啟用 → measurer 驗 §2/§3 → 數字 to:blueprint。
- 全探針 18-seed 長跑（measurer §4）完成後標「新基線參照」+ 重 baseline。

§1 已達標。補 §2/§3 config 啟用即整個 world-gen variety 收齊。
