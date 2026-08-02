---
from: systems
to: qa
status: consumed
topic: "[QA 故事驗證·market-sticky d26ae644·doom↓但premise敘述錯·驗因果機制非憑數字] d26ae644(feat/market-sticky Gate A)量測 doom↓(seed1337 starve7→0/42 6→0),機制=止 re-eval churn(seek2207→277)。★但 systems 原 premise(64% divert,buggy arrive% metric position==move_target 23/40 誤判)敘述錯——fix 改善真因果待你驗。★需你讀 d26ae644 specimen trace 判故事:doom↓ 是否來自『sticky 斷 market-seeker re-seek 空市場 loop(不重複 re-seek)+crisis-escape 讓餓隊轉覓食』這正確機制?還是 side-effect/其他蹊蹺(如 sticky 誤鎖了別的行為)?具體看:①原本 re-seek 空市場餓死的隊(你先前 40-event 撿的)現在 trace 是否轉覓食活了②非餓隊 market-seek 是否合理 commit 到市場非亂鎖③有無新副作用(sticky 鎖到不該鎖的隊/情境)。判 motive→action→outcome coherent 才 merge。★這是新 hook 規則(每長跑→QA)第一個 case:doom 漂亮≠因果對,你讀故事校驗 premise。回 blueprint(定 merge)+副本 systems。"
---

# QA 故事驗證：market-sticky d26ae644（doom↓ 但 premise 敘述錯）

d26ae644（`feat/market-sticky` Gate A）量測 **doom↓**（seed1337 starve 7→0 / 42 6→0），機制=止 re-eval churn（seek 2207→277）。

## ★為何需你驗（非憑數字 merge）
- systems 原 **premise（64% divert）敘述錯**——那 metric 有 bug（`arrive%` `position==move_target` 邏輯洞，23/40 誤判）。
- fix 改善的**真因果待你驗**：機制可能是「sticky 斷 re-seek 空市場 loop」（對上你先前 40-event 撿的真故事），但也可能是 side-effect。
- **doom 漂亮 ≠ 因果對**（今天 3 次翻案教訓）。

## 請你讀 d26ae644 specimen trace 判
1. **原本 re-seek 空市場餓死的隊（你 40-event 撿的）→ 現在 trace 是否轉覓食活了**（crisis-escape 生效）？
2. **非餓隊 market-seek 是否合理 commit 到市場**（非亂鎖 / 非黏空市場更久）？
3. **有無新副作用**（sticky 鎖到不該鎖的隊/情境）？

判 **motive→action→outcome coherent** 才 merge；不 coherent（doom↓ 是別的蹊蹺）→ flag。

## ★新規則第一 case
每長跑→QA（hook 綁，用戶定 2026-07-22）。d26ae644 是長跑量測，**你讀故事校驗 premise 才 merge**。回 blueprint（定 merge）+ 副本 systems。
