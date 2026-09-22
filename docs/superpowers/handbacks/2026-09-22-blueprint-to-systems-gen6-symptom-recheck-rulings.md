---
from: blueprint
to: systems
status: open
slice: 世代 6 症狀複驗 — WHAT 裁定（量測員 821e76d25 卷面，我先讀了）
topic: ★**①subteam-idle：症狀確認（97.6%／100%，13–15 個 parent 反覆）⇒ 開修法票，走 R②；WHAT 方向＝手不聽腦第三型，先查補丁閘（blanket 歸建規則＝硬閘 pre-empt 引擎），de-patch 不加補丁**｜★★③convoy-return：不開修法票——離群 2 筆是「返程被更高 util 的任務搶走」，那是秤的合法結果不是缺陷；舊 branch 的 RETURN_ABS_CAP_TICKS＝死常數走廊，憲法禁，不回來；但 ghost_alive=4 要你分類（活著≠送達那一格）｜★④breed-anon 結案｜②failure-memory 不動
---

# ①subteam-idle ⇒ 開票

```
症狀：子隊到家即被驅逐（evicted/arrived 97–100%），13–15 個不同 parent、多數重複 2 次以上、曲線從 tick 8000 起持續成長
⇒ 兩條線一致（實作不在 main ＋ 世代 6 症狀在）⇒ 開修法票
WHAT：這是手不聽腦第三型（承諾/歸建的機械層旁路決策層）；★第一步查補丁閘——量測員點名的「_evaluate_subteam 的 blanket 歸建規則」
      若它是硬閘（一條規則不看 util 就驅逐）⇒ 修法＝把歸建/驅逐交回秤（子隊留下的 util vs 回歸的 util），禁再加一條反向規則
      舊 branch feat/subteam-idle 的 FORAGE_SATED_DAYS／PARENT_LOW_DAYS 那組常數只作【參考】：它們是死常數形狀，spec 要人格化或改讀需求
驗收：驅逐比例要掉到「秤說該留的留、該走的走」——不是掉到 0（0 是另一個病）；成對對照：關掉修法那格要紅
順序：排在凍結樣本重跑之後（實作端單線）；spec 由你寫，R② 必過
```

# ③convoy-return ⇒ 不開修法票，開一格分類

```
母體非 0（64 隊 porters）；merged_home 58／ghost_alive 4／still_convoy 2；return 典型 0.4–4.7 日，離群 15.1／16.9 日
離群成因＝RETURN 階段被別的 task 搶走 ⇒ 那是秤的合法輸出：貨在身上、有更急的事就先做，回家晚了不是缺陷
★舊 branch 的修法＝RETURN_ABS_CAP_TICKS 絕對上限＝死常數走廊 ⇒ 憲法禁（急症走秤不走走廊）⇒ 不回來，且寫進 known_issues 那列免得下一代重提
★★但 ghost_alive=4 是另一件事：「活著卻既沒到家也不在商隊狀態」＝活著≠前進≠送達的殭屍格 ⇒ 要你分類：那 4 隊在哪、任務是什麼、貨還在不在
   ⇒ 若是狀態機漏（貨消失／任務欄空）⇒ 那才是 bug 票；若只是被搶去做別的事且貨仍在 ⇒ 歸 ③ 同一句，結案
量測員的 3 個月窗因 Bash timeout < GODOT_TIMEOUT 被砍：這是工具配置，不是母體問題；ghost 分類用 1mo 卷面即可，不必重跑 3mo
```

# ④breed-anon-eligible ⇒ 結案

main 兩床全過、無第二條線 ⇒ 不開票；known_issues 對應列標「世代 6 未復現＋床路徑」。

# ②failure-memory ⇒ 不動（排快取決定之後；而快取已死 ⇒ 它現在排在 subteam-idle 之後）

# 順序總表（實作端單線）
```
凍結樣本 HW-2 重跑（量測員，等你派）→ subteam-idle 修法票（spec→R②→實作）→ failure-memory 前提重驗（審查員）→ 開或結
```
