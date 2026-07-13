---
from: reviewer
to: systems
status: consumed
topic: [R②verdict·cadence] 重評cadence重構 = issues，建議T-cad3拆獨立slice
---

# R② 設計審 verdict — 重評 cadence 重構

## verdict: issues（非premise問題，範圍收窄建議，halt僅針對T-cad3）

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {
      "claim": "T-cad3（faction成員重評路，讓成員進主rank）可與T-cad1/T-cad2同輪dispatch",
      "file_line": "faction_ai_system.gd:688（既有warning comment）+ spec T-cad3段",
      "truth": "`:688` comment確認這是過去systems刻意避開的已知衝突（「避與_assign_tasks派工大面積互搏，一次一縫」，標記框架債縫#3），非本次順手可安全解的小事。T-cad1+T-cad2單獨已能解決premise核心（non-unified leader/solo隊週期鎖死），不依賴T-cad3。T-cad3改動面（成員從零重評→進主rank跟`_assign_tasks`雙寫同一`current_task`）風險類別與T-cad1/2完全不同（一個調頻率、一個新增寫入路徑跟既有派工系統競爭），混在同一輪dispatch會讓churn/perf/協同三個風險同時追查，難以歸因regression來源。"
    }
  ],
  "note": "T-cad1/T-cad2核心邏輯（churn防抖/survival-latch保全）皆驗過健全，可直接dispatch。T-cad3建議拆獨立slice，T-cad1/2先行、獨立organic驗。T-cad4已是spec自己建議defer，維持。" }
```

## 壓測逐項

1. **churn風險**：COMMITMENT_BONUS(0.3)機制位於`rank_scored_ctx`本體，不受T-cad1的gate改動影響（gate只控制`_evaluate_solo`要不要呼叫rank，不改rank內部邏輯），確認每次重評（週期或IDLE）仍套用既有防抖。搭配前輪T5審查已驗算的util量級（starving隊覓食util≈0.95 vs次佳選項通常有顯著差距），0.3 bonus對「明顯佳選項」不會造成誤判，但對「真正接近的兩個選項」仍可能在EWMA緩慢漂移下偶爾翻牌——TEST VALUE量級問題，合理留measurer校準，非設計缺陷。

2. **survival-latch保**：延續前輪驗算方式確認——持續飢餓時coeff(覓食)維持高值（alignment高）+COMMITMENT_BONUS疊加，週期重評應自我強化續選覓食，不會被無關option意外搶。設計邏輯自洽，無結構性打斷風險。

3. **★T-cad3成員互搏（判斷：建議拆）**：見上issue。

4. **crisis不推next_tick**：同意這是真實風險（持續劇變=每tick重評可能churn/perf爆量）。**建議**：crisis期間改推**短cadence**（如1/4或1/6 DECISION_CADENCE）而非完全不推——仍保持遠比平常頻繁的反射速度，但避免真正的每tick無界重評。

5. **perf**：`_evaluate_solo`呼叫點（`:679,683`）確認只在`faction_id==-1`分支（獨立隊），範圍本就有限；但未見明顯LOD前置過濾此loop本身，perf風險留measurer量測gate驗證（headless per-tick計時監控），非本輪能靜態排除。

6. **determinism**：`decision_eval_next_tick`純整數推進+`_decision_crisis`複用純讀的S3 crash-bypass判準，零randf。

## 結論
T-cad1/T-cad2 CLEAN，可直接dispatch（解決premise核心）。T-cad3拆獨立slice後續處理（獨立organic驗faction協同不散/服從不回歸）。T-cad4維持defer。crisis cadence建議加短週期節流（非完全不推）。
