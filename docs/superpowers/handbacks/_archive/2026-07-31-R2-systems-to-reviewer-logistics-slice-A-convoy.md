---
from: systems
to: reviewer
status: consumed
topic: "[R²·後勤SLICE A convoy transport地基·spec=2026-07-31-logistics-slice-A-convoy-transport-HOW.md·R①scale correction併入(誠實scale:真複用只3小零件載重model/ETA算式/_fund_subteam_from_vault撥款,convoy生命週期取貨→送達非母隊目的地→交付→原隊完整返航=100%新核心)·新核心=convoy物件+生命週期狀態機(FETCH→OUTBOUND→DELIVER→RETURN→釋放pop)+★派convoy決策真fire(第一驗收本session的鬼)+供給真到手·SLICE A只需方拉pull(動機最穩)·pull-convoy=新取得手段3進rank池(缺+有自家remote surplus util高過覓食)+防輸argmax(persist-hold保護,note founding floor HELD)·★★第一驗收TDD:convoy真派+FETCH源vault減+DELIVER目的vault增+RETURN pop回+cargo守恆+不輸argmax(porter不半路棄貨)·不凍seed1337·審新核心vs子隊生命週期不衝突+pull decision真不輸argmax+3小零件邊界+cargo守恆+不凍] 後勤SLICE A convoy地基。誠實scale(convoy生命週期=新核心非接線)。★第一驗收=convoy真派真到手。審決策真fire+不凍+守恆。"
---

# R²：後勤 SLICE A — convoy transport 地基

## spec
`docs/superpowers/specs/2026-07-31-logistics-slice-A-convoy-transport-HOW.md`（R① scale correction 併入）。

## R① scale correction 併入（誠實 scale）
你 R① 異質框外抓對——「現成零件」過譽。HOW 誠實化：**真複用只 3 小零件**（載重 model/ETA 算式/`_fund_subteam_from_vault` 撥款樣式）；**convoy 生命週期（取貨→送達非母隊目的地→交付→原隊完整返航）＝100% 新核心**（現子隊只就地安頓/併入消失、無送貨返航）。SLICE A 是真新建主體。

## 做（新核心 + 3 小零件）
- **convoy 物件 + 生命週期狀態機**：FETCH（源 vault withdraw cargo）→ OUTBOUND（travel，porter 自身吃糧複用糧橋存活零件）→ DELIVER（目的 vault deposit，自家 vault 無換手）→ RETURN（回母隊釋放抽出 pop，非就地安頓/併入消失）。
- **★派 convoy 決策真 fire（第一驗收）**：需方拉——隊缺 X + 有自家 remote vault 存 X surplus → pull-convoy（新取得手段 3 進 rank 池，缺+有自家 remote surplus util 高過覓食）+ 防輸 argmax（persist-hold 保護）。
- SLICE A 只 pull（單邊，dedup 只需 in-flight guard）；push/領主推=B；劫掠延後。

## ★reviewer focus（異質 refute）
1. **★★pull-convoy decision 真不輸 argmax（第一驗收核心，本 session 的鬼）**：需方拉「我缺我去拿自己的」我斷言 util 最穩不易輸——**真的嗎**？trade-trip/founding 也曾「該 fire 卻輸覓食/外交」。pull-convoy 靠什麼真 fire（util 夠高 vs 需 persist floor vs 需 dedicated cadence）？★這條錯＝整 slice 死（同 trade-trip under-fire）。
2. **新核心 convoy 生命週期 vs 子隊既有生命週期真不衝突**：porter 掛 convoy 狀態機（FETCH/DELIVER/RETURN）vs 既有 subteam TRANSIT/settle/merge-back——真能並存否（會不會 porter 到目的地被既有「就地安頓」誤觸、或 RETURN 被 try_merge_back 半路併掉）？
3. **複用 3 小零件邊界對否**（載重 model/ETA/撥款樣式真可抽、糧橋只當 porter 自身存活零件非運補語意）？
4. **cargo 守恆**（源 vault − / porter carry / 目的 vault + 全程守恆無憑空）+ **不凍**（seed1337 attrition 非→0，convoy 只抽少數 porter）？
5. ★founding persist floor HELD 未 merge——pull-convoy 若需同款 cold-start 保護，本 slice 一併設計 active-convoy floor 還是先驗 porter 輸不輸 argmax 再定？

## 判
CLEAN → implementer（convoy 物件+生命週期+pull decision+★第一驗收 TDD 真派真到手）→ measurer → QA。有洞（尤其 1 決策真 fire）→ 回 `to:systems`。★第一驗收（convoy 真派+真到+cargo 真交付、別生成不執行）是本 arc 成敗、R² 從嚴。
