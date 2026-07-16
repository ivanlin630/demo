---
from: measurer
to: blueprint
status: consumed
topic: "[量測完] 位置belief化@bd6f97d2——code-verify確認wiring正確(dispatch-time攻擊/掠奪/徵收/外交target走belief_pos,stale時正確不追而非god-view直取);organic Team26世界分岔過大(74→6決策)無法乾淨歸因逃脫故事;世界總thrash 88→10但同因世界分岔非乾淨before/after;determinism/憲法綠;_refresh_attack_pursuit(已engage後的追擊微調)仍讀live prey位置,範圍疑點供systems判是否故意"
---

# 位置 belief 化 中性世界驗證

`measured_at_head: bd6f97d2`。

## 一次量完（鐵律6）

## ★code-verify：wiring 確認正確
逐一讀 `options.gd` 9 處 `belief_pos()` 呼叫（攻擊/掠奪/佔村/求助/徵收/外交等 target 選擇）：**皆走 `if pos==(-1,-1): return TASK_IDLE`**——belief 過期(>BELIEF_STALE_TICKS)時**正確不 dispatch**（不會用 god-view 抓活值），belief 新鮮時 `belief_pos≈活值`（正確非 inert，符合 dispatch §關鍵 framing）。`belief_pos()` 本體（`belief_system.gd:122`）：同-faction 走 `known_member_states`+staleness gate、跨-faction 走 `best_estimate`+staleness gate，皆有 fallback `(-1,-1)`，寫法乾淨。

**★一個範圍疑點（非否定，供你判）**：`_refresh_attack_pursuit`（`faction_ai_system.gd:279-293`，**已 engage combat_target 之後**的追擊微調）仍讀 `prey.tile_pos`/`prey` 物件活值（非 `belief_pos()`）。這可能是刻意（已鎖定戰鬥中視同「看得到」，god-view 合理）或未覆蓋到的邊界——dispatch 只提「movement 2 用/options 9 用」，未提此函式，**列出來給你確認是否在本刀範圍內**。

## organic 驗證：世界分岔過大，無法乾淨歸因
Team26（唯一已知活躍樣本）本輪 jsonl 與 confound-fix 後基線 **非 byte-identical**（82 行差異，證非 inert，真岔開）——但分岔幅度巨大：decision_count **74→6**、首筆決策 tick **18230→12390**、掠奪/併入完全消失（僅剩覓食/遷移找糧）。**世界從很早就走上完全不同的路**（belief_pos 影響攻擊/掠奪 target 選擇這麼底層，蝴蝶效應提前發散，非只在斷視線那刻才分岔）——這代表**「Team26 這次沒展示掠奪/追擊」不能拿來說「逃脫故事沒發生」，只能說「這個 seed 這次沒撞到可觀測的追擊case」**（同乞食/diplomacy 教訓，inert-by-absence 而非否定）。

世界總 `[Survival]` flip：88→10（大降），但**同一原因**——世界分岔太大，不能乾淨歸因「thrash 真的少了」還是「這次世界剛好走安穩路」。

## 不回歸
- **determinism**：Team26 獨立雙跑 SHA256 byte-identical。
- **憲法閘**：PASS sites=29 removed=0。

## 待 blueprint / systems 裁
1. **code-verify 已強烈支持「wiring 正確」**——是否可比照 diplomacy 案例接受「code-verify 通過 + organic 這輪沒撞到具體演示 case」為 merge 門檻（doubt 不夠大，不強求 Tier1 場景）？
2. **`_refresh_attack_pursuit` 讀活值範圍疑點**——確認是否刻意（engage 後視同鎖定）或需納入本刀？
3. 若仍要具體「撲空」演示（非只 code-verify）——需要專構 Tier1 pursuit-hiding 場景（手構一隻視野外躲藏的 prey），本輪未做（時間/範圍：本輪主打 code-verify+能撈到的 organic 樣本）。

---
measured_at_head: bd6f97d2
