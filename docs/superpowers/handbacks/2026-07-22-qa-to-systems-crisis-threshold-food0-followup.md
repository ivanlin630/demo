---
from: qa
to: systems
status: consumed
topic: "[follow-up·crisis 門檻 food=0 不 fire] market-sticky 故事驗證撿到獨立於 sticky 的缺口:seed1337 team54 food_days=0.0 連 500 tick(tick4800-5300)全程 in_crisis=false(11/11 food=0 DIVERT 事件 in_crisis=false),被鎖在空市場貿易。字面餓著卻沒進 crisis→crisis-escape 不 fire→lingered。雖 [SurvivalMergeIn]→併入 Team34 獨立接住沒釀死,但 crisis 門檻在 food=0×500tick 該 fire。這接我上輪 gate-A 點的 abandon-trade-guard 缺口(food 低+市場空該放棄 trade 去覓食)。非 sticky 新引(market-sticky 已 WITHDRAW),是既有 crisis-threshold/abandon-guard gap。請查:crisis 判定是 food_days 門檻還是 famine_days gate?為何 food=0×500tick 不觸發?FINAL 故事判詳 to:blueprint 那封。"
measured_at_head: d26ae644
---

# follow-up：crisis 門檻在 food=0 不 fire（獨立於 sticky）

market-sticky d26ae644 故事驗證（詳 `2026-07-22-qa-to-blueprint-market-sticky-story-verdict-FINAL.md`）撿到一個**獨立於 sticky、既有的缺口**：

## 現象
- **seed1337 team54**：`food_days=0.0` 鎖在空市場 (13,24) **連 500 tick**（tick4800-5300），**全程 `in_crisis=false`**（DIVERT-SPEC 11/11 食糧=0 事件皆 in_crisis=false）。
- 字面餓著（food=0）卻沒進 crisis → crisis-escape / sticky-bypass 都不 fire → team54 lingered 在空市場貿易，不 abandon-trade 去覓食。
- **結局沒釀死**：`[SurvivalMergeIn] Team54 → 併入 Team34`（絕境整併安全網獨立接住）。

## 為何值得查（雖沒釀死）
- crisis 門檻在 **food=0×500tick** 不 fire = 不合理。餓著的隊該進 crisis / 該 abandon-trade。安全網（SurvivalMergeIn）這次接住，但不能靠運氣。
- **接我上輪 gate-A 診斷的 abandon-trade-guard 缺口**（`2026-07-22-qa-to-blueprint-gateA-rerank-story-verdict.md`）：food 低 + 市場空（Gate B sns）→ 該放棄 trade 轉覓食，卻續黏市場。crisis 門檻不 fire 是同一 gap 的機制面。

## 請查
1. crisis 判定用 `food_days` 門檻還是 `famine_days` gate？為何 food=0 連 500 tick 不觸發 in_crisis？
2. abandon-trade-guard：food 低 + 市場空時該退出 trade。與 crisis 門檻是否同一決策點。
3. **非 sticky 引入**（market-sticky 已 WITHDRAW）——是既有缺口，sticky 只是在 trace 裡讓它現形。

（QA 只找不修不裁；修法/門檻歸你。此為 FINAL 判的 follow-up 分支，主判在 to:blueprint 那封。）
