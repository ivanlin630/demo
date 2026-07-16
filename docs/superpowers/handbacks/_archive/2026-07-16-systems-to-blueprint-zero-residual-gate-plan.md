---
from: systems
to: blueprint
status: consumed
topic: "[零殘留閘·接受reframe+證明機制計畫] 用戶原則收下:框架驗收=零殘留非框架閘,證法=強化constitution_gate抓全閘型跑綠。查現gate:只掃TaskArbiter task指派,抓不到硬門檻/override/RNG。★核心挑戰:task指派無歧義但硬門檻有歧義(if food<X=世界規則餓or行為閘塞糧,regex分不出)。解=baseline-freeze擴用:加偵測器抓全閘型(RNG-in-decision/override early-return/硬門檻)enumerate進baseline,de-patch減baseline+禁新增→baseline→零/全legit-marked=零殘留可證。歧義由de-patch進度處理非auto-classify。需你section-A閘清單當de-patch標的。R①-batch互補"
---

# 零殘留閘：接受 reframe + 證明機制計畫（constitution_gate 強化）

用戶原則**收下**：框架硬驗收=**零殘留非框架閘**（一個殘留閘→整 arc 垃圾結果）；**重點是殲滅每個閘、非統一 oracle**（R① 證 oracle 大半已統一）；**證法=強化 constitution_gate 抓全閘型→跑綠=證零殘留**。

## 查現 constitution_gate（`scripts/debug/constitution_gate.gd`）
- 現只掃 `TaskArbiter.(transition|try_set)` 呼叫點（引擎外 task 指派），指紋 `<relpath>::<func>`，current⊆baseline，新增 FAIL/移除=進度。
- **抓不到你指的：硬門檻 / override early-return / RNG 閘**（用戶盲區正確）。

## ★核心挑戰（誠實）
task-dispatch **無歧義**（引擎外指派=一律可疑）。但**硬門檻有歧義**：`if food < X` 可能是**世界規則**（合憲：餓=物理代價）或**行為閘**（違憲：塞糧=替 NPC 決定）——**純 regex 分不出好壞**（憲法「世界規則 vs 行為規則」分界靜態難判）。

## 解：baseline-freeze 擴用（同現 gate 設計，歧義由 de-patch 進度處理）
1. **加偵測器抓全閘型**（syntactic pattern）：
   - **RNG-in-decision**：`randf|randi|randomize` 出現在 decision 路徑檔（faction_ai/decision/…，排除明允世界機制點）。
   - **override early-return**：decision 函式（`_pick_*`/`_decide_*`/`_evaluate_*`/`applicable`）裡引擎 rank 前的 early `return`（bypass 秤）。
   - **硬門檻比較**：decision 函式裡具名常數門檻比較（`< DESPERATION_DAYS`/`< X` 等）。
2. **enumerate 全閘型進 baseline**（首跑產一份「當前所有閘」清單，違憲的標 `# 序N`/`# 待de-patch`）。
3. **de-patch 每個 → 移除 → baseline 縮**（removed=零殘留進度信號）；**禁新增**（added=FAIL）。
4. **★綠 = baseline 縮到零/全 legit-marked = 零殘留可證**。歧義（好/壞門檻）**由 de-patch 進度處理**（人工判該閘去留一次、標記），非 gate auto-classify（做不到）。

## 需你 + 分工
- **★需你 section-A 閘全清單**（_threat_recent/evaluate_threat 忙碌門檻/tribute override/紮營獵食硬門檻/applicable DESPERATION 天閾/diplomatic RNG 閘…）= **de-patch 標的 + baseline 種子**。你派的擴充性稽核也一起。
- **R①-batch（我剛派 reviewer）互補**：它 enumerate/classify 剩項真缺——與 section-A 閘清單交叉=完整閘地圖。
- 我建強化 constitution_gate（偵測器+baseline）= 證明機制；de-patch 各閘 = 逐 slice arc 工（照 Arc1 模式）。

## 流向
你給 section-A 清單 → systems 建強化 gate + 產全閘 baseline → 逐閘 de-patch（R①/R² per 大閘）→ gate 綠=零殘留證 → 框架硬驗收過 → 才談 behavior/deal。**先建 gate（量得到殘留）再殲滅**（measure-first：先讓殘留閘可見可數）。
