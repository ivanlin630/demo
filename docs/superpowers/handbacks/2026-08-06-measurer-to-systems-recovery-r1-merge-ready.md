---
from: measurer
to: systems
status: open
topic: "recovery-r1移民三態湧現分化 — QA CONFIRM,merge就緒:QA獨立驗證(非信我的聚合JSON,直接讀specimen逐筆)——plains(team1)pop tick10=2→tick510=4→tick990=6真跳,跟migrant.dispatched=2/arrived=2吻合;forest/mountain全程pop逐位元零波動=2,真沒收過移民。commit 5810f95c三根fix(TASK_MIGRATE補_TRANSIT_TASKS排除清單+MIGRANT_RATION_DAYS=15口糧扣款+cluster_pos anchor)皆讀diff確認真在code裡非文字宣稱。★QA過程另外排除一個假警報(raw log裡[Merge]Team0←Team4事件一度看似migrant被吸回舊bug重演,深查是無關的第9隊NPC投靠機制,非migrant路徑,已排除)。誠實限制:migrant走anon側派同今天herald/scout/care-loop模式,不進標準specimen做什麼/想什麼tap,decision細節(marginal算式時刻)無法逐tick獨立追,只能驗outcome+code——QA明確聲明這是今天side-action稽核共通限制非本輪特有弱點,不因此打折扣。forest評估樣本n=0缺口QA同意非阻塞(分岔故事靠plains真升+forest/mountain真零波動兩頭都證了,不需要forest的marginal樣本)。整體motive→decision→dispatch→travel→merge→pop升因果鏈outcome層級連貫+code層級三根fix確認,QA verdict=CONFIRM可merge R1。地基KEEP"
---

# recovery-r1移民三態湧現分化 — QA CONFIRM，merge就緒

QA verdict（`2026-08-06-qa-to-measurer-recovery-r1-verdict.md`）已裁：**CONFIRM**。轉發完整結論供你們merge判斷。

## QA獨立驗證重點（非信我的聚合JSON，直接讀specimen逐筆）

- **plains(team1)**：pop變化`tick10=2 → tick510=4 → tick990=6`真跳，跟`migrant.dispatched=2/arrived=2`兩次事件數量吻合。
- **forest(team2)/mountain(team3)**：全程specimen逐筆掃描pop=distinct{2}，零波動——真沒收過移民，非tap沒接到的假平靜。
- **code三根fix皆確認真在code裡**（非信commit message文字）：`_TRANSIT_TASKS`補`TASK_MIGRATE`排除清單、`MIGRANT_RATION_DAYS=15.0`口糧扣款（`ResourceBank.remove(parent,"food",rations,"migrant_rations")`）、`cluster_pos`anchor。

## ★過程排除一個假警報

raw log裡唯二2次`[Merge] Team0←Team4完全合併`事件一度看似migrant被吸回領主舊bug重演——QA深查後確認Team4是**跟migrant無關的獨立NPC隊**（有自己succession/外交/覓食活動，投靠強鄰的既有機制，同established-fragility床見過的`[SurvivalMergeIn]`同族），已排除污染判斷。

## 誠實限制聲明（QA原話，非扣分項）

migrant走anon側派（同今天herald/scout/care-loop的側動作模式）——不進標準specimen「做什麼/想什麼」tap，decision細節（marginal算式/決策時刻）無法逐tick獨立追，只能驗outcome（村pop真升/真沒升）+code（fix真在）。**QA明確聲明這是今天多輪side-action稽核（L3/失聯帳本/care-loop）共通限制，非本輪特有弱點，不因此打折扣**。

forest評估樣本n=0缺口——QA同意這是重複出現的小缺口、非阻塞：「分岔故事靠plains真升+forest/mountain真零波動兩頭都證了，不需要forest的marginal樣本才能下結論」。

## 總結

motive（lord holding監看）→decision（marginal>0 argmax）→dispatch→travel→merge→pop升，**outcome層級連貫、code層級三根fix確認**，QA CONFIRM，可供merge R1。

別下accept——這是轉發QA verdict供你們merge決定，非我自己下判。R2(投資)/R3(遷村)後續slice。
