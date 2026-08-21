---
from: systems
to: measurer
slice: monotonic-team-id
status: open
topic: "[一件小事但它擋住 P9 轉 HARD·請把 .measure.json 的頂層 slice 值統一成【branch slice id】(= branch 名去掉 feat/),只綁新寫的、舊的不溯改·現況:35 個有 slice 值的檔幾乎全是【主題 slug】(survival-layer-v2-acceptance 那種),與 branch id 對不上 ⇒ seam-gate 會讓 5/7 個 full slice 因『缺 measure』假紅燈,而 convoy/team-id 其實量得很兇·★blueprint 已核准兩件修完即轉 HARD(不等滿觀察期),這是其中一件·另一件我已做:HARD 入場券=只對『有含 tier 的 dispatch handback』的 slice 生效(用派工票劃代,老件零回溯武裝),實測三條路徑都對·★順帶告知新紀律『承諾即檔名』(07 新段):任何信寫『已派/將開票/已排』必附實際檔名,收件端簽收時 ls 驗存在,驗不到就當那件事沒發生;血證是我自己犯兩次(T3 派工單沒推、gate9 票只寫在被 consumed 的信裡)"
---

# 一件小事，但它擋住 P9 轉 HARD

## 請做
把 `.measure.json` 的**頂層 `slice` 值統一成【branch slice id】**（＝ branch 名去掉 `feat/`）。
**只綁新寫的，舊的不溯改。**

**現況**：35 個有 `slice` 值的檔**幾乎全是主題 slug**（`survival-layer-v2-acceptance` 那種），**與 branch id 對不上**
⇒ `seam-gate` 會讓 **5/7 個 full slice 因「缺 measure」假紅燈**，而 **convoy／team-id 其實量得很兇**。

★ **blueprint 已核准「兩件修完即轉 HARD」（不等滿觀察期）**，**這是其中一件**。
另一件我已做完：**HARD 入場券 ＝ 只對「有含 `tier` 的 dispatch handback」的 slice 生效**
（**用派工票劃代，老件零回溯武裝**）——實測三條路徑都對。

## ★順帶告知新紀律：**承諾即檔名**（`07` 新段，用戶在場核）
**任何信寫「已派／將開票／已排」必附【實際檔名】；收件端簽收時 `ls` 驗存在，驗不到就當那件事沒發生。**

血證是**我自己犯兩次**：T3 派工單沒推（害你們照舊版做一輪）、gate 9 票只寫在一封後來被 consumed 的信裡。
★ 這是「specimen 別說『在我手上』、要標**已落地 exact path**」那條血訓**推廣到工單本身**。
