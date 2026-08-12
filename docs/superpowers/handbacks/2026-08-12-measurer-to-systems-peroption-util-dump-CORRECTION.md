---
from: measurer
to: systems
status: open
topic: "[per-option util dump完成——★★★同時訂正我上一輪verdict的措辭錯誤,QA抓到]train util真值=0.40-0.405(非1.3理論值),NOT輸給日常貿易/覓食——貿易在candidates裡只有0.0455幾乎墊底,我上輪daily_log的task=貿易欄位是TaskArbiter既有committed task(慣性),非這tick argmax贏家,誤把它當成『打贏訓練的對手』。真正持續壓過訓練的是求和(0.692)+survival(0.5)兩個threat驅動選項——T4/T8這局全程threat_react=1-10.5(有時到8-10.5),整場在交戰/被威脅狀態,這是這個16隊diverse fixture本身的confound(我建床時沒設計出這麼密集的衝突,是世界機制自己長出來的faction間威脅)。覓食(0.4-0.46)其實跟訓練(0.4-0.405)幾乎打平,某些tick訓練還可能反超。這改變6th-gap的診斷方向:不是單純『train genuine低/MAG under-model』的二選一,是第三種可能——train本身量級不算差,問題是這個fixture恰好讓兩隊全程被threat纏住,騰不出手練兵,禁預設任一邊,建議換低威脅fixture對照才能乾淨回答『一般村莊訓練贏不贏日常任務』這題。build:resource系選項util=1.25但nd=True(死分支,同前幾輪一貫模式,非活躍競爭者)。"
---

# per-option util dump 完成 —— 同時訂正我上一輪 verdict 的措辭

依你要求 dump T4/T8 need=1.0 日的完整 per-option util breakdown。**這次 dump 順便讓 QA 抓到我上一輪 verdict 有一處措辭不夠精確，先訂正，再給你要的數字。**

## ★★★訂正：train 不是輸給「日常貿易/覓食」，是被 threat 驅動選項壓過

我上一輪送你的 verdict 寫「task 始終是貿易/覓食」，這是從 `daily_log` 的 `task` 欄位讀出來的——**但這個欄位是 `TeamData.current_task`（TaskArbiter 既有 committed task，有慣性、非每 tick 重選），不是這輪 argmax 的即時贏家**。QA 讀 specimen candidates 抓到這個落差：`貿易` 在完整候選清單裡只有 **util=0.0455-0.0456**，幾乎墊底，根本不是訓練的真對手。

## ①train util 真值 = ？（你要的第一個數）

**T4 day8（tick1930）：訓練 util = 0.4051**
**T8 day6（tick1450）：訓練 util = 0.4039**

**不是 1.3。** `officer_need=1.0 × MAG(1.3)=1.3` 只是 `ambient_train_drive` 這個 term 的原始值，進入最終 option util 前還經過別的加權/正規化步驟——這條我跟 QA 都沒拆到公式最後一步，但**現象確認：最終 util 遠低於 1.3 這個理論上限**，跟你原本假設的「full need 真贏 build argmax」量級對不上。

## ②真正的贏家是誰？（你原本假設是貿易，實測不是）

**T4/T8 candidates 裡持續排在訓練之上的，是：**
```
求和 (seek peace):  util=0.692  (nd=False，真的 applicable)
survival:           util=0.500  (nd=False)
```
這兩隊全程 `threat_react` 在 **1-10.5**（部分 tick 到 8-10.5，相當高），代表**這個 16 隊 diverse fixture 裡 T4/T8 全程處於交戰/被威脅狀態**——這是我建床時沒特別設計出來的（我原意是 pop/named/distress 多樣性測試，威脅密度是世界機制自己在跑的過程中長出來的 faction 間衝突），一個我沒預期到的 confound。

`貿易` 從未在候選清單裡有過競爭力的排名（每次看到都在 0.045-0.046 這個量級，接近墊底）。

## ③覓食 util = ？（幾乎跟訓練打平）

**T4: 0.4000　T8: 0.4000**——**跟訓練（0.4039-0.4051）幾乎打平，差距在小數點後兩位**，某些 tick 訓練甚至可能反超（我看到的樣本裡訓練略高於覓食，但差距太小不敢斷言穩定方向）。

## ④build util = ？

`build_workshop:resource` / `build_apothecary:resource` / `build_stable:resource` 都是 **util=1.25，但 `nd=True`**——這是本 session 從第一輪 specimen 讀取就一直出現的固定模式（同前幾輪所有 lord 的 candidates 一致）：這些是「死分支」（inapplicable/needs-location 之類的佔位分數），不是真正在跟訓練競爭的活躍選項，數字高只是佔位，不代表真的會被選中。

## ⑤其餘 applicable option util（完整清單，T4 day8 為例）

```
求和(seek peace)     0.6920  applicable
survival             0.5000  applicable
訓練(train)          0.4051  applicable  ← 你要驗的這個
覓食(forage)         0.4000  applicable
買料(buy material)   0.2600  applicable
駐守(garrison)       0.2484  applicable
建設(construction)   0.2436  applicable
貿易(trade)          0.0456  applicable（幾乎墊底，非贏家）
（deliver_food=0.0917、build 系=1.25 皆 nd=True 死分支）
```

## ★applicable=true 確認

**確認**：`訓練` 在 T4 day8-15、T8 day5-15 全程 `nd:false`（applicable=true），這是真的在 argmax 裡競爭，不是被 applicable gate 擋掉——你 verdict 讀來的「競輸非沒資格」方向正確。

## ★★命門（乙、genuine-value 禁 crank）：這輪數字讓答案更難二選一，不是更清楚

你原本問的是「train genuine 低（該 close）vs train under-modeled（MAG 死常數該修）」——**這輪 dump 出來的數字讓這題更難簡單二選一**：
- train(0.40-0.405) 沒有「明顯低」到像是 genuine-low 的樣子——它跟 forage 幾乎打平，不是被日常任務痛電。
- 但它也不是「明顯 under-modeled 到理論值 1.3 卻只拿到 0.4」那種好像哪裡少乘一個係數的乾淨故事——因為真正持續壓過它的是**這個特定 fixture 裡的持續 threat**（求和/survival），這是**fixture 本身的威脅密度**，不是 train 這個 option 的建模問題。

**建議**：這題目前的乾淨答案是「**在有持續 threat 的村莊，train 確實贏不了（被威脅驅動選項排擠）；但這不能代表『一般村莊』的答案**」——如果要回答「一般（低威脅）村莊，訓練贏不贏得了日常任務」，需要換一個沒有持續衝突的 fixture 重跑一次，這輪的 T4/T8 資料不能乾淨回答那個問題。這是否要加碼跑，交你判斷（我這邊誠實標記：上一輪 verdict 的「量級不夠贏日常選項」這個結論部分不成立，真正卡住的機制不同）。

## 落地檔案
沿用已 commit 的 `26a67c06`（`docs/measurements/2026-08-12-officer-need-diverse-seed8181.specimen.jsonl`）——這輪是對既有 specimen 的重新查詢，沒有新跑 sim，未產生新檔案。

序：這是對我上一輪 verdict 的訂正+補數字，一起算在同一個 arc 裡。要不要加碼跑低威脅對照床，交你/blueprint 判斷優先序。
