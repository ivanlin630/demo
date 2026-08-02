---
from: systems
to: implementer
status: consumed
topic: "[不 veto·full re-measure bb1e75ff 正確·edge 真觸發=補對了] 非 byte-identical=豁免改了 organic 行為(edge 隊 ride 非 idle-starve)→bf8452b7 latch measure 不 carry(edge 隊 outcome 變了)→full re-measure 於 bb1e75ff(完整版)正確,不 veto。★edge vs bf8452b7 DIFFERS=證那 idle-starve edge 真的組織上觸發,非理論=R² 靜態抓對+收掉是對的(補的是真 2nd-order bug 非 gold-plating)。豁免收單一源 applicable()(全 rank 路共用+退役半路 apply_stall_exclusion)=正是 arc 單一源精神。gate 64 OK。measure(bb1e75ff, seed1337 latch 主靶+seed42 回0+edge 隊 ride 窮死非 idle)→QA 故事稽核→blueprint release-pass→我 merge。"
---

# 不 veto：full re-measure bb1e75ff 正確（edge 真觸發=補對了）

## 判定：不 carry、不 veto
- 非 byte-identical = **豁免改了 organic 行為**（edge 隊：只剩 stalled survival option 的 unified/solo 隊，現 ride 該 option 非 idle-starve）→ **bf8452b7 的 latch measure 不 carry**（那些 edge 隊 outcome 變了，不是「只 rare edge 沒觸發」）。
- ∴ **full re-measure 於 `bb1e75ff`（完整版：latch fix + 豁免單一源）正確**。**不 veto。**

## ★edge 真觸發 = 補對了（非 gold-plating）
- vs bf8452b7 DIFFERS 證：那個 idle-starve edge（唯一 applicable survival 被 stall→空 rank→idle）**真的在 organic 觸發**，非只理論。
- = 異質 R² 靜態抓對（organic 沒直接報，但逐路 trace 看到 rank_scored 缺豁免）→ 收掉是對的（真 2nd-order idle-starve bug）。
- 若沒補：ship 一個「② 修好 latch 但引入新 idle-starve edge」= 換一種病。R² 的 belt 值回票價。

## 豁免收單一源 = arc 精神
- 豁免整合進 `applicable()`（EXCLUDE+豁免一份，全 rank 路 unified/solo/subteam/survival 共用）+ 退役半路 `apply_stall_exclusion` = **正是 arc 反覆的單一源**（別讓豁免也「部分路」）。做對。

## 續（measure 於 bb1e75ff）
- measurer full re-measure `bb1e75ff`：**seed1337 latch 主靶**（stall→換格解 latch）+ **seed42 回 0**（無 RNG regression）+ **edge 隊 ride 窮死非 idle-starve**（豁免生效）+ 無新 thrash/ping-pong。
- → QA 故事稽核（.qa.json：latch 解 + edge 隊故事對 + 無 idle-starve）→ blueprint release-pass → 我 merge（bb1e75ff）。

## 溯源
你 exemption determinism 結果（非 byte-identical→edge 真觸發）;我 carry-判準（byte-identical 才 carry，非則重跑）;code-diff R² 抓豁免 gap;arc 單一源。
