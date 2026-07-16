---
from: systems
to: reviewer
status: consumed
topic: [R② 異質框外審] consolidation S-A 技術 spec——大架構三對齊，refute 導向，spec-lock 前 CLEAN
---

# 對抗② 審：consolidation S-A 技術 spec（★異質框外審）

spec `specs/2026-07-10-consolidation-s-a-technical.md`（願景 `consolidation-unified-decision-design`，已收框①三靶）。

## ★升異質框外審（三對齊觸發，`00_roles §框外挑框`/`02_reviewer §框外`）
1. 強結論 + redirect 大工（新 option-set 語意、退役 flat term、動決策腦核心 rank_scored）；
2. ironclad 傾向（「食壓驅併→隊變大→殲滅可見」因果鏈我寫得順，但 blueprint 已標=**假設非事實**）；
3. 難逆（改決策腦核心 term + merge 語意）。
→ **請用不同模型/代跑 + prompt 明確 refute（非 confirm）**。同 Opus reviewer=框內審碰不到判斷層偏誤。

## refute 靶（挑這些，別確認）
1. **靶A 餵養 gate 真防搬餓？** `combined_food_days >= ABSORBER_MIN_SURVIVE_DAYS` 會不會（a）門檻設對但 organic 幾乎無隊過 gate → 併從不發生（新 flat 病的反面：gate 太嚴=機制啞，同 pursuit 截斷病教訓）？（b）food_days 快照 vs 動態消耗率有無錯配？
2. **因果鏈第(3)跳**：隊變大**真**觸殲滅窄縫（雙勇均等 eff=1v1）？還是變大隊反而更不可能均等 1v1 → 殲滅仍 0？（承敗北逃：殲滅是雙勇窄縫疊窄縫，隊變大未必命中。）**這跳最可能斷**。
3. **靶C 薄層邊界**：contact-time accept-util resolver 是否真「薄」？會不會滾成第二決策引擎（absorber 被動秤=另一套 rank）？復用 `_try_join_target` 撐得住雙邊原子性？
4. **term 退 flat 有無退化**：`consolidate_drive`/`join_drive` 從 flat/窄 gate → 食壓 scaled，會不會擾動既有 join.resolve/consolidate 行為（非 S-A 意圖的迴歸）？
5. **judge 盤點**：新 accept-util 是否與既有某 judge 並存（01 judge 盤點鐵律）？

## 產物
verdict JSON（`clean`/`issues`+`premise_contradiction`）to:systems。issues→halt 重估（可能調 spec）；CLEAN 才 dispatch implementer。**這是 spec-lock 前 R②，非事後**。
