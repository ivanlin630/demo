---
from: systems
to: implementer
status: open
topic: [裁決 S2] B案—SEEK_FOOD map移除「貿易」(語意修正:貿易=致富主表達由intent_fit驅);TC7自動PASS不動框架bar;plan已更新續build
---

# 裁決：S2 取 B（移除 SEEK_FOOD 的「貿易」）

你分析對——reviewer 貿易 watch-item 坐實成 TC7 硬 bar。**取你傾向的 B,理由強化如下。**

## 裁定（plan Task 2 已更新）
- **`_phase_option_bias(PHASE_SEEK_FOOD)` = `{"覓食": MAG, "買糧": MAG}`**（移除「貿易」）。
- **設計原則（新增,防此類 collapse）**:phase map 只含 phase 目標**內在**選項,**排除其他 intent/個性的「主要表達」option**。**「貿易」= 致富 intent 主表達（intent_fit 致富→貿易 已驅）→ 不放任何 phase map。**

## 為何 B 乾淨（三得）
1. **語意修正**:SEEK_FOOD=缺糧求生→直接取食（覓食/買糧）,貿易=profit-trade 是致富路徑,原誤置。
2. **化解 reviewer watch**:貿易只 intent_fit 驅、phase 零觸 → 無雙偏置疊加（watch 徹底消,非只壓低）。
3. **TC7 自動 PASS,不動框架 bar**:霸主→建設、商人→貿易（走 intent_fit 致富非 phase）、隱士→駐守（不再被推貿易）= 3 distinct uniq=3。**不需 A（改測 artifact）也不需 C（放寬框架不變量）**——你擔心的 A 案 pop=5→GROW collapse 也不會發生（B 不碰 TC7 的 SEEK_FOOD 判定,只移除貿易偏置,隱士留原駐守）。

## 附:GROW「紮營」watch（給你 + measurer）
你敏銳指出 GROW map {紮營,返家補給} 對非定居個性同類風險。**保留但 measurer S2 驗收 watch**:GROW 隊有無 collapse 定居 vs 非定居分歧（紮營近定居主表達）。若實測破同原則 → 下輪移除。**本 slice 不預先動 GROW**（TC7 沒撞它,避過度改;真撞了再說）。

## 續
- 照更新後 plan 改 `_phase_option_bias` SEEK_FOOD 一行（移貿易）→ 重跑 TC7 + 2 phase 測 + determinism + 融合閘 → 一次交 measurer。
- 你的 code 已在 worktree（只需改 SEEK_FOOD map 一行）。
- 驗收帶 GROW 紮營 watch + 貿易 util 量級（reviewer watch 現應歸零疊加）給 measurer。
