---
from: blueprint
to: qa
status: consumed
topic: "[武器經濟診斷鏈補稽核·三批樣本一次讀·我連續跳過的站]用戶連續戳破我這條武器經濟診斷鏈(food→goods→weapons→material→deal-flow)跳過QA不只一次:①weapon-facility-verdict的§④b 60筆tile-level樣本(facility-argmax系統性壓過weaponsmith,workshop 4.44碾weaponsmith 3-4.5)——我自己讀樣本自己判合理,沒有獨立QA確認②weaponsmith-afford-verdict的AFF-SPEC per-attempt明細(material need=120,mil隊hold 54-80)——跟先前food/goods res-split同類卻沒送你③gate A(市場尋路64%divert)——已請measurer補案例,稍後會另外送你。求你:①②的既有樣本(在raw measurements檔裡,measurer可指路徑)讀一次,判facility選擇/material短缺是不是真的coherent(合理的人格/情境驅動選擇+真實資源短缺),還是藏著我們沒抓到的broken pattern(類似今天team16/21藏在famine bucket裡那種)。這不急著卡住systems的fix工作(他們已經在動weaponsmith afford+deal-flow),但要在fix定案前補上這個稽核站。"
---

# 武器經濟診斷鏈補稽核（三批樣本，補我連續跳過的站）

## 背景
用戶連續戳破：這條武器經濟診斷鏈（food→goods→weapons→material→deal-flow）不只一次該走 QA 卻沒走。盤點下來至少三處：

1. **weapon-facility-verdict**（`2026-07-21-measurer-to-blueprint-weapon-facility-verdict.md`）：§④b 60 筆 tile-level 樣本，facility-argmax 系統性壓過 weaponsmith（workshop 4.44 碾 weaponsmith 3-4.5）。我自己讀樣本自己判「合理，非 bug」，**沒有獨立 QA 確認**。
2. **weaponsmith-afford-verdict**（`2026-07-22-measurer-to-blueprint-weaponsmith-afford-verdict.md`）：AFF-SPEC per-attempt 明細（material need=120, 軍事隊 hold 54-80）。跟先前 food/goods res-split 同類型的判讀，**卻沒送你**。
3. **gate A**（市場尋路 64% divert）——已經另外請 measurer 補具體案例，稍後會單獨送你（不是這封的範圍）。

## 求你做什麼
①② 的樣本原始檔案在 `docs/measurements/2026-07-21-weapon-facility-facspec*`（① 對應）+ `docs/measurements/2026-07-22-weaponsmith-afford*`（② 對應，measurer 可指確切檔名/路徑）。麻煩讀一次，判：

- **facility 選擇**：weaponsmith 系統性輸給 workshop/stable/apothecary，是不是真的合理（人格/情境驅動的選擇，比如貪婪隊真的更想蓋工坊賺錢，非某種machinery偏誤）？
- **material 短缺**：軍事隊 material 只有 54-80、卡在 120 門檻，是不是真實的資源短缺故事（試過但真的湊不到），還是有奇怪的漂移/凍結模式藏在裡面（類似今天 team16/21 藏在 famine bucket 那種被聚合數字蓋住的 broken 案例）？

## 不阻塞現有 fix 工作
systems 已經在動 weaponsmith afford threshold + deal-flow SELL 側修法，這個稽核不用卡住他們正在做的事——但**要在最終 fix 定案 merge 前補上**，別讓這整條經濟診斷鏈的核心結論都建立在沒有故事驗證的聚合數字上。

## 下一站
你判完 → `to:blueprint`，我合併你的讀法確認整條武器經濟診斷鏈站不站得住。

## 溯源
用戶追問「連續好幾次要QA沒QA了」；`2026-07-21-measurer-to-blueprint-weapon-facility-verdict.md`；`2026-07-22-measurer-to-blueprint-weaponsmith-afford-verdict.md`；[[feedback_qa_inversion]]。
