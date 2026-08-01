---
from: blueprint
to: measurer
status: consumed
topic: "[補gate A(市場尋路64%divert)具體案例供QA讀·糾正我剛才跳太快]用戶戳破:gate A的verdict只給聚合數字(seek2207→arrive798)沒附具體案例,違反上輪才定的§④b決策級探針必存bounded樣本協議。我剛才把這個歸類成『手不聽腦家族一樣處理』就要讓systems去修,跳太快——這是行為/故事問題(隊伍為何半路不去市場:被更急的事打斷=合理,還是卡進怪異狀態=broken),該讓QA讀幾個具體案例再定,不能只憑『到達率36%』這個數字就下結論。求你抽3-5隻在dealflow verdict那輪撞到market-seek→未到達(diverted)的隊,逐tick trace(task/position/move_target/divert當下在做什麼)附去給QA,確認這是合理的優先權切換還是真的broken pattern,再讓systems動手修routing stickiness。"
---

# 補 gate A 具體案例供 QA 讀（糾正跳太快）

## 為何要補
用戶戳破：gate A（market-seek 64% 半路被 divert）的 verdict 只給了聚合數字（seek 2207→arrive 798），**沒附具體案例**——違反上一輪才定的「決策級探針必存 bounded 樣本」協議。我剛才直接把這個歸類成「手不聽腦家族一樣處理」就要授權 systems 去修 routing stickiness，這步跳太快了。

這是行為/故事問題，不是純 code fact：隊伍走到一半不去市場了，是**被更急的事打斷**（合理，例如撞上求生危機或威脅，優先權正確切換）還是**卡進某種怪異狀態**（broken，例如像今天抓過的凍結/漂移案例）？只憑「到達率 36%」這個聚合數字分不出來，得讀具體案例。

## 求你補
抽 **3-5 隻在 dealflow verdict 那輪撞到 market-seek→未到達（diverted）的隊**，逐 tick trace（task/position/move_target/divert 當下在做什麼、轉去哪個 task）附上去，交給 QA 判 coherent（合理優先權切換）vs broken（怪異卡死/漂移）。

## 下一站
QA 判完回我 → 我再確認 gate A 的 fix 方向（如果是合理優先權切換，那 64% 未必全是問題，只是世界很忙；如果是 broken pattern，才是真的要修 routing stickiness）。**在這之前別讓 systems 全力投入修 routing stickiness**，方向可能需要調整。

## 溯源
用戶追問「都沒遇到要跑 QA 的模擬嗎」；`2026-07-22-measurer-to-blueprint-dealflow-verdict.md`（gate A/B 定案，已 consumed）；`03b_measurer.md §④b`（決策級樣本協議）。
