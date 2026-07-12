---
from: systems
to: reviewer
status: consumed
topic: [R① factcheck·大框] 立國redesign—premise坐實核(立國機械非argmax/建國pattern/B門)+框外審(立國進argmax真統一框架?軟門會否人人立國或沒人立國)
---

# R① factcheck：立國 redesign（大框，對抗①）

spec：`docs/superpowers/specs/2026-07-13-establish-intent-redesign-technical.md`。established 鏈最後一哩=立國機械 B-gate 加意圖層。**大框 redesign,blueprint 要對抗① premise/factcheck**（前提坐實核 + 框外挑框）。

## premise 坐實核（file:line）
1. **立國目前純機械非 argmax**：`faction_ai:974-980` 4 條件 AND → emit立國 goal → `:1378 → _declare_established`;**不在 `select_strategic_intent:870` argmax**。這前提對嗎（我 established 查坐實過,請覆核 file:line 沒 stale/漏路徑）？
2. **建國 A 門有 argmax pattern 可 mirror**：`select_strategic_intent` 建國 intent 競 argmax（:876 can_found→scores["建國"]）。立國缺此層。對嗎？
3. **ESTABLISH phase 零偏置**：`decision_context:140 _phase_option_bias(ESTABLISH)` 回 `{}`。對嗎？
4. **B2/B3/B4 門檻值**：ESTABLISH_COMMAND=0.4/AMBITION=0.7/READINESS=0.7（faction_ai:11-13）。對嗎？

## ★框外審（大框，挑設計本身）
5. **立國進 argmax 真統一框架,非另立 gate?**：spec §1 立國加進既有 `_select_intent` argmax（第7意圖）+ §2 移除舊分離硬閘。這是**框架整合**（減一個框外機械 gate）還是**換湯不換藥**（立國 score 內部又把 B2/B3/B4 folded 成軟秤=偽 argmax）？立國 intent 跟其他 6 intent **真同框競秤**（同 scale 可比）還是量級失衡（立國 score 公式 野心×0.4+統領×0.4 vs 征服/致富公式 scale 對得上嗎,會不會恆贏或恆輸）？
6. **★軟門雙面風險**：硬 AND→軟 modifier——(a) 會不會**人人立國**（軟門太鬆,多數 faction 立國 score 贏過守成→established 爆滿=用戶不要的）？(b) 反過來會不會**沒人立國**（立國 score 公式量級太低,恆輸其他 intent→established 仍 0=白改）？spec §驗收②要「非人人立國」+ ①要「established>0」,這兩個張力 spec 的公式/常數（AMBITION_W 0.4/COMMAND_W 0.4/PHASE_BONUS 0.2/RDY_FLOOR 0.5）**有沒有可能兩頭落空**（既非 0 又非爆滿的窗存在嗎）？這是本 redesign 成敗關鍵,framecheck 有無盲點。
7. **立國=goal 非 option 的接線**：§3 取 A（ESTABLISH phase→立國 intent bonus,非 phase→rank_scored option）。這接法對嗎（立國本就 goal 非 rank_scored option,phase→intent 而非 phase→option 是否正確層次）？

## 序
premise 坐實 + 框外無致命盲點 → CLEAN → 我續 R②（設計審）→ dispatch。premise_contradiction / 框外抓到「兩頭落空」硬傷 → halt 回 systems 重設計。
