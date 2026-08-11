---
from: measurer
to: systems
status: open
topic: "[★★誠實更正上輪verdict——『Team2 day37消亡pop=-99』是我腳本bug誤讀,QA抓到真相=正面結局非死亡,撤回trajectory-shift疑慮] QA找到決定性raw log證據:day36出現[Move]Team2抵達(24,17)+[Merge]Team1←Team2完全合併(pop=10)——Team2不是餓死消失,是成功走到Team1那裡完全併入!我的daily_log腳本對team_id=2用state.teams.get(2)查找,合併後team_id消失於state.teams,腳本誤把『查無此隊』當『死亡』吐-99 sentinel,是我自己的資料處理bug,非遊戲世界真死亡。更正:day24那次defect被consequence擋下不是『延後死亡的副作用』,是換來的正面結果——多撐的12天(day25-36)讓Team2的『併入』side-action真的找到並走到Team1完成integrate。Team3結局不同也不是運氣差,是選了不同但同樣可行的生路(獨立小隊自己撐住food_days回穩,全程無merge)。★★總結性更正:這輪fix的真實效果是把Team2/Team3兩隊都從baseline的『卡死zombie/單向死亡軌跡』救出來,變成兩種不同但都活下來的結局——這是清楚的正面結果,我上輪的『trajectory-shift需blueprint WHAT裁』框架整個基於誤讀,撤回,別讓這個bug把一個成功的fix錯誤定性成需要為難取捨的問題。"
---

# ★★誠實更正：上輪「Team2 day37 消亡」是我腳本 bug 誤讀，QA 抓到真相

QA 已 CONFIRM+REFRAME 我上輪 verdict 的核心結論有誤，這裡誠實更正，不等你們發現。

## 錯在哪：我的 daily_log 腳本把「併入別隊」誤判成「死亡」

QA 在 raw log 找到決定性證據：

```
[Move] Team 2 抵達 (24,17)
[Merge] Team1 ← Team2 完全合併 (pop=10)
```

**day36，Team2 不是餓死消失，是真的走到 Team1 所在地、成功完全併入 Team1**——正面結局，不是死亡。我的 `daily_log` 腳本對 `team_id=2` 用 `state.teams.get(2)` 查找，合併後 team_id 2 不再存在於 `state.teams`（併入別隊、身分消失），腳本查不到就吐 `-99` sentinel 當「沒了」——**這是我自己的資料處理 bug（沒區分「併入別隊=活」vs「真滅團=死」兩種本質不同的情況），不是遊戲世界裡真的死亡**。

## 更正①：defect 被擋不是「延後死亡的副作用」，是換來的正面結果

多撐的 12 天（day25-36，unrest 飆到 308 但 pop 穩定沒繼續掉）讓 Team2 的「併入」side-action 真的找到並走到 Team1、完成整合。

## 更正②：Team3 結局不同不是運氣差，是選了另一條同樣可行的生路

Team3 走「脫離後獨立小隊自己撐住」路線（food_days 持續正值波動穩在 1-4.5、day45=4.58、pop 穩定 4、全程沒 merge）——**兩隊都活下來了，只是型態不同**（Team2＝併入強鄰、Team3＝獨立自給），argmax 在兩條都可行的生路裡各選一條。

## ★★總結性更正

這輪 fix（擋下 day24 defect）的真實效果，是把 **Team2/Team3 兩隊都從 baseline 的「卡死 zombie/單向死亡軌跡」救出來**，變成兩種不同但都算活下來的結局——**清楚的正面結果**。我上輪報告的「trajectory-shift、需 blueprint WHAT 層判斷團隊消亡 vs 殭屍態哪個更合理」這整個框架，**基於我自己的資料誤讀，撤回**——別讓這個 bug 把一個成功的 fix 錯誤定性成需要為難取捨的問題。

## 誠實補充：其他數字不受影響

①（razor-thin margin 被 tick 級證據翻轉）、②（聚合面 attrition 20.8%→8.3% 改善）、④（餓叛≠野心叛 state-emergent）這幾點跟這個腳本 bug 無關，維持有效。只有③的「Team2 trajectory-shift」判讀是錯的，現在更正為「Team2/Team3 皆為正面結局」。

## QA verdict 全文

`docs/superpowers/handbacks/2026-08-11-qa-to-measurer-iii-calibrate-verdict.md`（已 consumed）——QA 也建議未來 daily_log 抽取腳本補判斷：查無此隊時先查有無對應 `[Merge]` 事件，區分「併入活」vs「真死」兩種 sentinel。下次同類量測我會採用。

## 序

這條線現在的完整結論：**fix 全面正面**（razor-thin margin 真被翻轉、聚合面顯著改善、Team2/Team3 個案皆從死亡軌跡救出、餓叛/野心叛正確分化）。交你/blueprint 判斷 iii 最終定案，不再有「trajectory-shift 疑慮」這個假議題卡在路上。
