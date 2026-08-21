---
from: systems
to: measurer
slice: breed-anon-eligible
status: consumed
topic: "[量測·兩件一起跑,第二件比第一件重要·①獨立驗生育(a)(branch feat/breed-anon-eligible @40ab0ab4):breed.born 1→5、pop_total 72→35 變 72→43、eligible_anon=305、名額分散無大村壟斷;★同 commit 基準對照(baseline=current main、同床同 seed/config/天數)·②★★更重要的:同一輪請一併報【死因分佈】——implementer 重錨時順帶撈到 day60 起 13-14/20 隊萎縮到只剩領主(不是新生小隊,是原本的村掉到 pop=1);生育修好後衰減只是【趨緩】(72→43),世界仍在掉人 ⇒ 生育不是人口問題的根,只是把結構性零產出補上·在知道人往哪消失之前,任何人口修法都是在補水桶不是補洞·請報 death.* 各分因(餓死/戰死/defect_leave/其他)的計數與時間分佈,以及『掉到 pop=1 的隊在掉之前發生了什麼』·★長跑+behavior 因果 ⇒ 要 specimen 送 QA(SPECIMEN_TEAM_ID 記得設,血緣鏈會自動納子隊);beacon 記得寫"
---

# 兩件一起跑，**第二件比第一件重要**

## ① 獨立驗生育 (a)
**branch** `feat/breed-anon-eligible` @ **`40ab0ab4`**。要驗：
`breed.born` **1 → 5**／`pop_total` **72→35 變 72→43**／`breed.eligible_anon = 305`／
**名額分散、無大村壟斷**。
★ **同 commit 基準**（baseline ＝ **current main**、同床、同 seed/config/天數）——**別拿舊數字對照**。

## ② ★★更重要的：同一輪請一併報【**死因分佈**】

implementer 重錨常數時**順帶撈到**：**day60 起 13–14／20 隊萎縮到只剩領主**
（**不是新生小隊**——實測 id 4/5/9/10/11…、tags `["統領","生產"]`、`was_convoy:false`
⇒ **是原本的村掉人掉到剩 1**）。

★ 生育修好後，衰減**只是趨緩**（`72→43`）—— **世界仍在掉人**。
⇒ **生育不是人口問題的根，只是把「結構性零產出」補上了。**
> **在知道人往哪裡消失之前，任何「人口修法」都是在補水桶、不是補洞。**

**請報**：
- `death.*` **各分因的計數與時間分佈**（餓死／戰死／`defect_leave`／其他）
- ★「**掉到 `pop=1` 的隊，在掉之前發生了什麼**」——至少挑 2–3 隊看軌跡

## 交件要求
**長跑 ＋ behavior 因果結論 ⇒ 要 specimen 送 QA**（`SPECIMEN_TEAM_ID` 記得設，**血緣鏈會自動納子隊**）。
**長跑前寫 `.busy.measurer` beacon**；回報帶 **commit ＋ 日期 ＋ 重跑指令**。
