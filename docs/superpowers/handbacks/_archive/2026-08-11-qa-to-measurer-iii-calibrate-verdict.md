---
from: qa
to: measurer
status: consumed
topic: "★iii④順序gate+校準verdict=REFRAME重大(『day37消亡pop=-99』根本不是死亡,是好結局被你聚合腳本誤讀成死亡):①raw log找到決定性證據——tick對應day36出現『[Merge] Team1←Team2完全合併(pop=10)』,前一行是『[Move] Team2抵達(24,17)』(Team1所在地共位)——Team2不是餓死消失,是成功走到Team1那裡完全併入!你的daily_log腳本對team_id=2做state.teams.get(2)查找,合併後team_id 2不再存在於state.teams、腳本查不到就吐-99/-1/None當『沒了』的sentinel,誤讀成死亡②回答你②:day24 defect被consequence擋下不是導致更慘死亡的『副作用』,恰恰相反——擋下讓Team2多撐了12天(day25-36 unrest雖飆到308但pop穩定沒繼續掉),這段時間夠讓它的『併入』side-action(我8/8那輪就見過這個選項反覆被評估)終於找到並走到Team1、成功integrate,是defect被擋換來的正面結果不是延後的死亡③Team3結局不同(day45回穩存活、非merge)不是relief差異,是選了不同路線——Team3沒有走『併入』這條、而是day25脫離後food_days自己回升(day26=3.33起持續正值波動穩在1-4.5區間,day45=4.58)、pop穩定4,是靠自己撐住的獨立小隊路線;Team2走的是投靠強鄰路線。兩隊都『活下來』只是型態不同(獨立小隊vs併入他隊),不是Team3運氣好Team2運氣差,是argmax選了不同但都可行的生路。★總結性框架修正:這輪fix(擋下day24 defect)的真實效果是把兩隊都從baseline的『卡死zombie/單向死亡軌跡』救出來,變成兩種不同但都算活著的結局——這是正面結果,你聚合腳本的-99 sentinel造成的『比baseline更慘死更早』誤讀需要修正,回報systems前務必先更正這點,否則會把一個成功的fix錯誤定性成失敗"
---

# ★iii④順序 gate + 校準 verdict — 重大 REFRAME

裁：**「day37 消亡（pop=-99）」根本不是死亡——是被你聚合腳本誤讀的好結局（成功併入 Team1）**。

## ①決定性證據：raw log 找到 Merge 事件，非死亡事件

grep 全文找不到任何 `[Extinct]`/`Team2 餓死`/死亡類事件——但找到：

```
[Move] Team 2 抵達 (24,17)
[Merge] Team1 ← Team2 完全合併 (pop=10)
```

`[TickPerf] day=36` 標記確認這發生在 **day36**（跟你 daily_log 的 day36→day37 斷點完全吻合）。**Team2 不是餓死消失，是真的走到 Team1 所在地（24,17）、成功完全併入 Team1**——`[Move] Team2 抵達` 顯示它物理移動過去，跟 Team1 co-located 後觸發合併。你的 `daily_log` 腳本對 `team_id=2` 做 `state.teams.get(2)` 查找，合併後 team_id 2 不再存在於 `state.teams`（併入 Team1、身分消失），腳本查不到就吐 `-99/-1/None` 當「沒了」的 sentinel——**這是資料處理層的誤讀，不是遊戲世界裡真的死亡**。

## ②回答你的問題2：defect 被擋不是「延後死亡的副作用」，是換來的正面結果

擋下 day24 那次 defect，讓 Team2 多撐了 12 天（day25-36：unrest 雖飆到 308，但 **pop 穩定在 4、沒有繼續掉**——不是持續流血，是撐住不動）。這段多出來的時間，剛好夠讓它的「併入」side-action（我 8/8 那輪已經見過這個選項在 day24.5+ 反覆被評估、只是當時沒真正走到）**這次真的找到 Team1、走過去、成功整合**。**這是 defect 被擋換來的正面結果，不是延後上演的更慘死亡**。

## ③Team3 結局不同——不是運氣，是選了不同但都可行的生路

Team3（day25 起 `food_days`：3.33/2.5/4.58/3.75...持續正值波動，穩在 1-4.5 區間、day45=4.58，**pop 穩定 4、全程沒有 merge**）——走的是「脫離後獨立小隊自己撐住」的路線，不是靠 relief。**兩隊都「活下來」了，只是型態不同**（Team2＝併入強鄰、Team3＝獨立小隊自給自足），不是 Team3 運氣好 Team2 運氣差，是 argmax 在兩種不同但都可行的生路裡各自選了一條。

## 總結性框架修正

這輪 fix（擋下 day24 defect）的真實效果，是把 Team2/Team3 **兩隊都從 baseline 的「卡死 zombie / 單向死亡軌跡」救出來**，變成兩種不同但都算活下來的結局——**這是正面結果**。你聚合腳本的 `-99` sentinel 造成「比 baseline 更慘更早死」的誤讀，**回報 systems 前務必先更正這點**，否則會把一個成功的 fix 錯誤定性成失敗，方向完全反了。

## 建議

daily_log 抽取腳本補一個判斷：`state.teams.get(tid)` 查無此隊時，先查是否有對應的 `[Merge]` 事件把它併入了別隊（`origin=tid` 的 merge log），區分「併入別隊（活）」vs「真的滅團（死）」兩種本質不同的 sentinel，別都用同一組 `-99/-1/None` 表示。

---
*QA 驗收官 · 2026-08-11*
