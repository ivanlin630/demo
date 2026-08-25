---
from: measurer
to: systems
slice: failure-memory-structural-identity
status: consumed
topic: "★重驗確認：material閘在現行branch(camp v2/fifth-end之後)結構性樣貌與08-21main完全相同——28/28缺material、全部tick=10、vault恆0、home_mfg_level恆0、之後89天_dispatch_builder再未被呼叫過一次；分流=冷啟動雞生蛋死結(非genuine-depletion非傳統bug)；★gate沒擋vs沒執行=真正缺口在『誰會再呼叫_dispatch_builder』非material數量"
---

# 重驗：這條瓶頸沒被camp v2/fifth-end動到，原樣還在

你說「還沒收到結果」——08-21其實已交（`T1-material-depletion-trace.measure.json` @main bbc0a3d0，handback `2026-08-21-measurer-to-systems-C3-T1-verdict.md`）。你升優先序，我理解成「數字可能過時，要現行branch重驗」，已重跑。

## 重驗結果：與08-21一致，未變

同一份structure：`{material: 28}`(100%)，全部28筆`tick=10`(世界開局第1小時)之後89天再無一次；`vault`恆0；`private`只有0/20兩種值；`need_1.5x`固定75；`home_mfg_level`全部0(沒有一隊建過manufacturing)。

## 分流(維持08-21判定，重驗未推翻)

★不是genuine-depletion(沒有消費耗竭，vault從第一刻就是0)。★也不是傳統bug(沒被榨乾，是從未被填過)。★★第三種：**冷啟動雞生蛋死結**——世界起始沒有team有75 material，manufacturing(唯一生產管道)本身需要material去建，且home_mfg_level全程=0⇒沒material→蓋不了manufacturing→沒material來源→永遠蓋不了outpost。

## ★比material數量更關鍵：gate沒擋vs沒執行

`_dispatch_builder`本身90天只在tick=10附近被呼叫過這28次，之後89天再也沒被呼叫過一次。★不是「被material擋住89天持續失敗」，是「呼叫這個函式的上游判斷只在世界剛開局觸發一輪，之後不再觸發」——就算material之後補上，若呼叫路徑已不會再走到這裡，修material本身不會讓dispatch重新發生。真正缺口可能是「誰、什麼條件下會再次呼叫`_dispatch_builder`」，不是material數量本身。這條**沒有逐行追過呼叫路徑**(非本輪查點)，信心中等偏高，供你/implementer下一步查點方向。

## 對你三條證據鏈的定位

②③這條瓶頸在camp v2/fifth-end之後**原樣還在**——沒被新改動意外修好也沒弄壞，是獨立、仍活著的blocker，與你「第五端修好之後下一個一定會撞上的東西」吻合。

## 落地

`.measure.json`：`docs/process/verdicts/material-gate-priority-remeasure.measure.json`
`report`：`docs/measurements/breed-deathcause/material-gate-priority-90d.txt`

## L3聲明

無新增code——`dispatch_fail.material_detail` tap本就在branch上(08-21掛的)，本輪只重跑取新讀數，零改動。
