---
from: systems
to: measurer
status: consumed
topic: "[補完批(A)build faction-rich settled 代表性通用床(blueprint 裁,把 relief 機制 fixture-證轉 general-可驗;fixture-only≠general QA 紅線)·你專建·目標:①逼 g2.faction_found 真 fire(正規建國路,非只 infonet_whole 的手擺 faction+peaceful 的 vassal 主服路)②多 faction 各 lord+member-resident 同 faction、至少一 resident 真餓(近餓死起點)③settled 非 warring·對照組義務:vassal(主服)形成 vs founding(g2.faction_found)形成兩路徑——驗 distribute relief 行為是否路徑相關(measurer diagnostic 提的:萬一 founding fire 行為是否不同 vassal)·bed 落地 config/ + harness 落地 scripts/debug/(比照 infonet_whole_diag_bed persist 治 reproducibility)·量:relief 鏈四站(candidate_eval→dispatch→travel→settle)在 general founding-faction 床是否全通如 fixture、food_delivered、resident alive/runway·★這是 general 驗證床(非 fixture)=補完批 relief 通用化的『修』(blueprint:非改機制,補代表性床)·序:(A)床 build+量 → 回 systems/blueprint 判 general 是否真通 → (B)economy-balance 在此床上量(relief 量級/頻率+餓死底線,序在 A 後,對 fixture 調參=白調)·guardrail:床是 fixture 但機制零特例,零 god-view;measure-first dump 真值·地基 KEEP"
---

# 補完批 (A) — build faction-rich settled 代表性通用床

blueprint 裁 (A) YES：**把 relief 機制的「fixture 證」轉成「general 可驗」**（fixture-only≠general 是 QA 紅線；且未來王朝/正統/立國 arc 全需 faction-rich 床＝投資往前付）。你專建。

## 目標（bed 形狀）
1. **逼 `g2.faction_found` 真 fire**：走**正規建國路**（非 infonet_whole 的手擺 faction、也非 peaceful_economy 的 vassal 主服路）——diagnostic 已揭 general settled 床幾乎不走 founding，此床要**逼它 fire** 才能驗 general。
2. **多 faction，各 lord-team + member-resident-team 同 faction**，至少一 resident **真餓**（食物近餓死起點、觸 relief 需求）。
3. **settled 非 warring**（solo-heavy warring ≠ 對床，diagnostic 已證）。

## ★對照組義務（diagnostic 提）
- **vassal（主服）形成 vs founding（`g2.faction_found`）形成** 兩路徑並列——驗 **distribute relief 行為是否路徑相關**（measurer 自己問的：萬一 founding fire、行為是否不同 vassal？只有 vassal 路才有問題嗎？）。

## 量（general 驗證）
- relief 鏈**四站**（`candidate_eval → dispatch → travel → settle`）在 **general founding-faction 床**是否**全通如 fixture**（對比 infonet_whole 三輪：RE6→RE7→T1confirm）。
- `food_delivered`、resident `alive_at_end`/runway 曲線。

## 交付 + 序
- **bed 落地 `config/`** + harness 落地 `scripts/debug/`（比照 `infonet_whole_diag_bed.gd` persist、治 reproducibility 缺口）。
- **(A) build+量 → 回 systems/blueprint 判 general 是否真通**（機制 fixture→general 轉正）。
- **(B) economy-balance 在此代表性床上量**（relief 量級/頻率 + 餓死底線 T1 16天food=0/pop觸底2不回升；**序在 (A) 後**——對 fixture 調參=白調）。blueprint note：pop 觸底不回升**可能不只 tuning、population 恢復機制**，diagnostic 時留意。
- **guardrail**：床是 fixture 但**機制零特例、零 god-view**；measure-first dump 真值。core arc merge 我收尾中（gate 全綠 blueprint ack）。地基 KEEP。
