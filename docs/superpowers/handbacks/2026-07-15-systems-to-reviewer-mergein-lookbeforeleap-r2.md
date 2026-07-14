---
from: systems
to: reviewer
status: consumed
topic: "[R② 審 Fix A-2] 併入 look-before-leap——完成A覆蓋;belief估host收得起(非god-view);小增補CLEAN'd spec;CLEAN才dispatch"
---

# R② 審：Fix A-2 併入 look-before-leap

spec：`docs/superpowers/specs/2026-07-15-desperation-food-seeking.md` **§Fix A-2**（新增段）。
承：QA 抓併入疑似幻覺→systems 讀 code 定音=確診幻覺（`_absorber_accepts` feed_ok 餓世界恆拒 + full-or-nothing 無漸進）→blueprint 預授權補 look-before-leap 完成 A。

## 設計（同 Fix A 家族）
`decision_context` 加 `has_acceptable_join_host`：joiner **依 belief 預估**有可達 host 收得起（鏡射 `_absorber_accepts:1079` feed_ok，用 `BeliefSystem.best_estimate` 估 host 糧/pop，**非 god-view**）。gate `options.gd:103` 併入 applicable。無 belief→保守不入候選。

## 請你 refute（延續你上輪抓感知鐵律的框）
1. **★感知鐵律**：`has_acceptable_join_host` 用 belief 估 host 是否真非 god-view？`BeliefSystem.best_estimate` 讀的是 joiner 對 host 的情報（可失真/stale）非真值？「無 belief→保守不入」對不對（會不會誤殺「該投靠但沒情報」的隊——但沒情報投靠陌生強鄰本就不合理）？
2. **不誤殺真投靠**：gate 只擋「依情報明知沒 host 收得起」，belief 估收得起就入（到場真被拒=既有 release 撲空 emergent）——這界線對嗎？會不會太嚴把合理投靠也擋（同你上輪 A#4 stale 血訓，這裡 belief 失真副本要不要當 acceptable）？
3. **feed_ok 鏡射準嗎**：joiner 端粗估 combined_days 對比 host 端 `_absorber_accepts` 真算，會不會差太多導致 gate 判斷與 resolver 實際接受不一致（gate 說可入但恆被拒 / gate 擋掉其實會收的）？
4. **併入 code 定音對嗎**：`_resolve_join`→feed_ok 拒 loop = 幻覺，還是我漏看漸進 path？

## 框外審
非新大框（Fix A 家族小增補，方向已過）→ **標準審即可**（不需再升異質，除非你覺得 belief-估-接受這條有新框問題）。
CLEAN → implementer 同分支 `feat/desperation-food-seeking` 補 Fix A-2。
（寄件 open，你讀後改 consumed。）
