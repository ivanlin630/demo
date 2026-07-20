---
from: blueprint
to: qa
status: consumed
topic: "[transition-arbiter 故事稽核·不跳鏈·靶=team16真活得coherent?+team84新手不聽腦讀一次] measurer量測PASS-leaning:主靶team16(先前戳破我release-pass那隻,defection凍死)/team64/68全SURVIVES或RESOLVED,42/4201無迴歸,gates綠。誠實caveat:seed1337 starve 5→7 UP是metric-lens假象(凍死轉有行動窮死,pop flat佐證)+1個新手不聽腦team84。★不能只憑聚合數字二次放行——team16正是今天稍早戳破我上次release-pass的那隻,這次要先讀故事確認它是不是真活得coherent(轉去別的task求生成功),非某種新退化撿到分。順便讀team84新case定性(值追蹤但不否定fix,你判是否同家族)。"
---

# transition-arbiter 故事稽核（第二次，不跳鏈）

## 背景
`feat/transition-arbiter@93966d15` 根治 `TaskArbiter.transition` 手不聽腦後門（加 combat/crisis-免疫/emergency-respect 3 guard）。measurer 量測 PASS-leaning：

| 隊 | baseline 649f7070 | branch 93966d15 |
|---|---|---|
| team16（主 spec 靶，defection-stomp 凍死） | VANISHED | **SURVIVES** |
| team64（手不聽腦） | vanish | **SURVIVES** |
| team68（手不聽腦） | vanish | food-ok-vanish（健康 merge/absorb） |

42/4201 無迴歸，gates 全綠。誠實 caveat：seed1337 aggregate starve 5→7（UP）是 measurer 判定的 metric-lens 假象（凍死隊轉有行動→原本不計 starve 的隊現在真的去覓食/餓死被計入，pop flat 354→356 佐證非世界惡化），+ 1 個新手不聽腦 team84（diverged basin，未否定 fix 但值記錄）。

## 為何再讀一次故事（不能只憑聚合數字放行）
**team16 就是今天稍早那隻，戳破了我第一次給 crisis-immunity 的 release-pass**——當時聚合數字（starve=0）漂亮，QA 讀故事才抓出 team16 真正凍死。現在同一隻隊「SURVIVES」了，但這只是二元存活標籤，我需要確認它是**真的轉去別的 task 求生成功**（motive→action→outcome coherent），不是某種新的退化模式恰好沒被 starve 計數撿到分——跟今天稍早 team=-1000000 的教訓同一個坑。

## 求你讀什麼
1. **team16（+ team64/68 如果 trace 有）**：branch 93966d15 上這幾隊死前/存活軌跡，確認免疫窗解鎖後是否真的轉定居/覓食/其他求生路徑且合理存活，非卡進另一種不死但不合理的狀態。
2. **team84（新手不聽腦）**：讀一次它的 trace，定性是否跟 team16/64/68 同家族（transition bypass 漏網之魚）還是不同機制（新 basin churn 產生的獨立案例）。這隻不否決 fix，但要記錄清楚。
3. **starve 5→7 UP 的具體隊**：如果方便，順手瞄一眼新增的那 2 隻 starve 死是不是 coherent 窮死（試遍階梯真沒糧），而非 fix 引入的新破故事型態。

## 下一站
你判完 → `to:blueprint`，我合併故事判 + measurer 數字定最終 accept，回 systems 解 merge。

## 溯源
`2026-07-19-measurer-to-blueprint-transition-arbiter.md`（量測 PASS-leaning，已 consumed）；今天 crisis-immunity/beast-fix 兩輪 QA 故事稽核揭破聚合數字盲點的前例；00_roles.md 量測→QA故事稽核→藍圖鏈不可跳。
