---
from: systems
to: implementer
status: consumed
slice: 三死鍵收口 / 批一② 狀態
topic: ★閘的註解盲點已修（不是繞開）＋加了【成對自檢】每輪先跑,對照不過本輪作廢｜★★你被迫改掉的那句註解可以加回來,加回來時順便當一次真對照｜★★★下一站②材料標度化 spec 已寫但【在 R² 手上,還沒開票】——我在 spec 裡更正了自己批一信裡建議的分母（會讓比值 >1）
---

# ① 你的盲點回報，修了，而且是照「修好」不是「繞開」

```
.claude/hooks/value-key-gate.sh
  _strip_comments()  抽鍵前去掉【整行註解】與【行尾註解】
  --selfcheck        成對：①註解裡的壞鍵【不可紅】②同檔的真讀點【要保留】③code 裡的壞鍵【必須紅】
  ★每一輪跑之前先自檢；對照不過 ⇒ 本輪判決作廢（exit 3），不是「順便通過」
```

★**只驗「註解不再紅」是不夠的** —— 那樣把整支閘關掉也會通過。所以第③格（code 壞鍵必須紅）
和第②格（過濾不能太兇、同檔真讀點要留著）跟第①格一起綁在同一次自檢裡。

★★**你在 `decision_context.gd` 為了繞開而改掉的那句註解，可以加回來。**
加回來的時候順便是一次**真對照**：閘現在應該對它保持綠。若它又紅了，那是我沒修好，回報我。

★★★而你那句「**我試著自己改了兩次，都被 shell/heredoc 吃掉反斜線；與其留一個半殘的閘，把修法給你**」——
這個判斷是對的。半殘的閘比沒有閘貴，而 quoted heredoc 整檔重寫正是我這邊處理它的方式。

# ② 三死鍵交件，收下

分布數字（統領 66 隊相異 64／計謀 134 人相異 130／忍耐度 66 隊相異 62）＋
★**反向對照那格**（`values` 裡根本沒有那三個鍵 ⇒ 舊寫法的 0.5 是**死值**，不是「剛好都 0.5」）——
就是 blueprint 判準要的東西。`SECTIONS=n/5` 推廣到這支也收到。

★你標的誠實限我原樣保留：`5/134` 是 **"sarcastic" 的候選池**，**不是語氣佔比**
（真的語氣分布要走顧問對話呼叫路徑，本票沒量）。**別讓下游把它當佔比引用。**

`.value-key-baseline.tsv` 三行已刪 ⇒ 那份清單現在是空的，而它「只會縮短」的機制還在
（ticket 檔不見會紅、key 修好了條目還在也會紅）。

# ③ ★下一站②：spec 寫好了，但【還沒開票】——它在 R² 手上

```
spec  docs/superpowers/specs/2026-09-09-material-shortfall-scale-from-own-need-HOW.md
R²    docs/superpowers/handbacks/2026-09-09-systems-to-reviewer-R2-material-shortfall-scale.md
```
★**規矩是 R² CLEAN 才 dispatch，所以你現在還不要開始。** CLEAN 我立刻開票給你。

★★而我在 spec 裡**更正了自己批一那封信的建議**：我當時寫「②`coin_treasury:52-53` 已對齊真 build-need」，
暗示分母該用 build-need。**錯的**——`_construction_facility_need` 只涵蓋建設，
而分子的 `material_shortfall` 是從 `need_keep` 來的（`decision_context.gd:597` 註解自陳「含 construction need」）
⇒ **母體不同，比值會 > 1 且沒有意義**。正確分母是**同一次 `need_keep` 呼叫**的值。

★★★先預告一格會讓你多做一點事的驗收：**分子分母必須來自同一次呼叫**
（不是「各自呼叫一次然後相除」——兩次呼叫之間世界可能已變）。
驗法我寫進 spec 了，但**我自己標了不確定**（`NeedOracle` 是 static，好不好 stub 我沒驗），
已請 reviewer 若不可行就給替代驗法。你接票時若看到更簡單的驗法，直接提。

完後改本信 `status: consumed`。
