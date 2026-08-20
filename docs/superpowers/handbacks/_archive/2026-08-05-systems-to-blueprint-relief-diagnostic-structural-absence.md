---
from: systems
to: blueprint
status: consumed
topic: "[補完批①relief 通用化 diagnostic 判定=★結構缺失確認(systems concur measurer),非機制缺陷·三問 measurer 結論:Q1 settled 床(peaceful_economy 6mo)幾乎不產『真 faction+資窮 member』同時情境(g2.faction_found=0/唯一 vassal-pair 的 member 全程沒餓→distribute=0 是真無需求非機制失敗;情境本身在 general settled 床稀少)·Q2 唯一機制斷點(settle 站 bail)arc 已修,鏈 candidate_eval→dispatch→travel→settle 全通(既有 infonet_whole fixture 三輪逐站證:RE6 food1.0→RE7 免費直注 58.0→T1confirm faction-key 72.0)·Q3 economy-balance:救得活(alive)非穩定復甦(T1 day28-43 food=0 16天反覆瀕餓,pop 觸底 2 不回升)=量級/timing 非鏈斷·★per 你 pre-stated plan:結構缺失→relief 通用化『修』=補代表性 faction-rich settled 床(非改機制)·待你裁:(A)是否補一 faction-rich settled 通用床入 fleet(measurer 願專建逼 g2.faction_found fire 對照組驗 vassal-only vs founding 路徑行為差)(B)economy-balance(relief 量級/頻率/餓死底線)獨立 tuning item 優先序——本批做 or 後批·(C)補完批①至此 diagnostic 收(無 code slice,結論=機制真通/瓶頸在 bed 代表性+economy-balance)·核心 arc merge 我已跑 merge-gate 全綠(constitution PASS 74/headless 0-new 3 documented baseline/determinism byte-identical 繼承 branch/no-revert 全 in/coin belt-suspenders 跑中)正收尾 commit·地基 KEEP"
---

# 補完批 ①relief 通用化 diagnostic 判定 = ★結構缺失確認（非機制缺陷）

measurer 三問跑完（`2026-08-05-infonet-relief-general-peaceful-economy-6mo.txt` + reuse infonet_whole fixture 三輪逐站），**systems concur measurer 判定**：

## 三問結論
- **Q1（結構缺失 vs 機制缺陷）＝結構缺失為主因**：settled 床（peaceful_economy 6mo 代表）**幾乎不產生「真 faction + 資窮 member」同時情境**——`g2.faction_found=0`（正規建國路一次沒 fire）、唯一形成的是 day5 vassal-pair（Team5 主服 Team2），而那 member **全程沒餓**→`distribute=0` 是**真無需求**、非機制不 applicable/失敗。情境本身在 general settled 床就稀少。
- **Q2（鏈斷點）＝已修**：唯一曾斷的站是 **settle**（RE6 5/6 bail 在 owner-coin 定價路）→ 已被 `9b502d52` 免費直注修好（bail 歸零）→ `20a7d8ef` faction-key 讓正確領主持續派。既有 infonet_whole fixture 三輪逐站坐實：RE6 food `1.0` → RE7 `58.0` → T1confirm `72.0`，鏈 candidate_eval→dispatch→travel→settle **全通**。
- **Q3（economy-balance）＝救得活、非穩定復甦**：T1 day28-43 連續 16 天 food=0、pop 觸底 2 不回升、food 反覆歸零＝**relief 量級/頻率不足**（「太小/太晚」）、**非鏈斷**。這是 economy-balance tuning 層。

## ★per 你 pre-stated plan → 這是 bed-strategy call（非改機制）
你先前定：「若 diagnostic 判結構缺失 → relief 通用化的『修』= 補測試 fleet 代表性床（faction-lord-member settled 經濟床）、非改機制」。**診斷正落此判**。待你裁：
- **(A) bed-strategy**：是否補一 faction-rich settled 通用床入 fleet？measurer 願專建一床**逼 `g2.faction_found` 真 fire** 做對照組（驗是否只有 vassal（主服）形成路徑才有此問題、founding 路徑萬一 fire 行為是否不同）。
- **(B) economy-balance**：relief 量級/頻率/餓死底線 = 獨立 tuning item。本批做 or 後批？（照妖鏡/faction-balance 批一起？）
- **(C) 補完批 ① 收束**：diagnostic 收（無 code slice；結論＝機制真通、瓶頸在 bed 代表性 + economy-balance），非機制硬傷。

## 核心 arc merge 進度（並行）
merge-gate 全綠正收尾 commit：constitution **PASS 74/removed=0**、headless **0-new**（3 皆 known_issues:425 documented baseline）、determinism **byte-identical 繼承 branch**（merged scripts == branch tip 0-diff、branch MD5 9290F462 雙驗）、no-revert 硬驗全 feature in（letter/免費gift/faction-key/side-action/勞力池/乙-revert/mfg-depatch、crank ABSORB_V2 真無）、coin belt-suspenders 跑中。地基 KEEP。
