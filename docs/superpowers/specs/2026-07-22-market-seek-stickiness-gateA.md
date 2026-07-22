> ★★★RETRACTED 2026-07-22（QA 40-event 故事翻案）：本 spec 建在 measurer『64% divert』metric 上，該 metric **有 bug**（arrive% 算錯，23/40 已到算沒到）。真相=market-seeker re-seek 同一**空**市場 loop（非 divert/opportunistic），空=Gate B under-production。∴ stickiness 治症狀，真根 Gate B（production）。**別實作**。教訓：behavior fix 的 metric 前提需 QA 故事驗證才 spec [[feedback_fileline_vs_interpretation]]。留檔為記錄。

# spec：market-seek stickiness（deal-flow Gate A，手不聽腦家族）〔RETRACTED〕

> 層級：L3（_should_reeval +1 guard，behavior-sensitive）。off LOCAL main。
> 來源：deal-flow measure 坐實 Gate A——seek_market 2207→arrive 798（**64% 半路 divert 到不了市場**，discovery 排除 avg 42.46 市場/隊）。blueprint：market-seek task committed 卻不執行到底=今天第 N 次手不聽腦家族（這次尋路非求生/建設），re-eval 沒給 market-seek sticky 保護（類子隊 builder transit-exempt 但 unified TASK_TRADE 無此層）。Gate B(under-production)靠 production 軌隱性改善，非本刀。

## 根因（code fact + measure）
- market-seek = unified 隊 `TASK_TRADE`（`move_target`=市場）走 `_decide_unified`（`_should_reeval` cadence gate）。
- `TASK_TRADE` **不在** `SURVIVAL_TASKS`/`STATION_TASKS`（非 sticky）；子隊 transit-exempt（`_evaluate_subteam:1710-1722`）只保 subteam TASK_CONSTRUCT/BUILD/UPGRADE/EXPAND，**unified market-seek 無保護**。
- ∴ 在途 market-seeker cadence re-eval → 機會性選項搶走 → **64% divert 到不了市場**（= sell/buy 無法成交的 routing 斷）。

## 修（`_should_reeval`，market-seek 在途 sticky）
`faction_ai_system.gd:1877 _should_reeval`，在 `_directive_fresh` 之後、cadence 檢查之前加：
```gdscript
# ★market-seek 在途 sticky（Gate A）：TASK_TRADE 未抵達（move_target set）+ 非 crisis → 不 cadence-divert
# （機會性重評搶走=64% 到不了市場）。crisis 落下方 cadence（survival escape）；IDLE/stuck/crisis-edge/directive
# 上方已 return true（求生/威脅/命令 escape 全保）；trade-timeout（faction_ai:817 TRADE_TIMEOUT）抓 zombie；
# resident 擺攤（move_target==(-1,-1)）不受影響（非在途）。
if team.current_task == TeamData.TASK_TRADE and team.move_target != Vector2i(-1, -1) and not in_crisis:
    if Probe.enabled: Probe.bump("reeval.marketseek_sticky")
    return false
```

## ★survival/escape 保（設計硬約束）
- **crisis escape**：`and not in_crisis` → 餓/暴跌 market-seeker 落下方 cadence（/4 快）→ 可 divert 求生。**不會餓死在買路上**。
- **IDLE/stuck/crisis-edge/directive** 上方已 `return true` → 卡住/新命令/進 crisis 當下 全能打斷。
- **trade-timeout**（`817 TRADE_TIMEOUT` 按殘距估）抓「追不到/市場消失」zombie → release。
- **resident 擺攤**（`move_target==(-1,-1)`）非在途 → 不 sticky（正常 re-eval）。

## 驗收
- **TDD**：①在途 market-seek 非 crisis → `_should_reeval`=false（sticky 不 divert）②在途 + crisis → 落 cadence（可 re-eval 求生）③已抵達（move_target=-1）→ 正常 re-eval ④非 TASK_TRADE → 不受影響。
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical（無 RNG，純 guard）。
- **★measure（→measurer，behavior-sensitive，帶 §④b 樣本 Probe.bump_sample）**：★**arrive% (seek→arrive 36%→?)** + deal 數 + reeval.marketseek_sticky fire + doom-delta（seed1337/42）+ 8 config sanity + **★確認無 starve 回歸**（sticky 別餓死買路隊——crisis escape 驗）。

## 排序
Gate A 獨立修（B 靠 production 軌）。R²（★crisis escape 正確/trade-timeout 兜底/resident 擺攤不受影響/無 RNG）→ dispatch。
