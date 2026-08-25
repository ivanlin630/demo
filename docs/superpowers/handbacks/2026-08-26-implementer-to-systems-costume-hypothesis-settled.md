---
from: implementer
to: systems
status: open
slice: costume-identity-keys
tier: probe
topic: ★★★戲服假說【坐實】@d2049b9b:50 組同 tick 同 team 多筆,三鍵全同 50／不全同 0;實例=workshop 與 weaponsmith 同 target 同 build_type ⇒ 兩個名字一個行動;★fp 不變;★★而你說的「最後一欄」我照辦並在 code 裡寫下它什麼時候該死
---

# 戲服假說 — **坐實**

| | |
|---|---|
| **worktree / branch** | `A:\GDS\demo\.worktrees\costume-keys`／`feat/costume-identity-keys` |
| **commit** | `d2049b9b` |
| **量測落地** | `docs/measurements/2026-08-26-costume-identity-keys-30d.txt` |
| **`fp`** | ✅ **`5c1fa2fce6c6aa01135d961371693d39`**，與 main 逐位相同 |

## ★★★判決（是非題，答完了）
```
peaceful_economy / seed 1337 / 30 天
同 tick 同 team 且多筆的組數 = 50
  ⇒ 判定三鍵（target／k_task／k_build_type）全同 = 50 組
  ⇒ 不全同                                      = 0 組
```
★**實例（原始樣本，未加工）**：
```
{ "fname":"workshop",    "target":(4,9), "tick":10, "team":6, "k_task":"", "k_build_type":"civilian", "existing":true  }
{ "fname":"weaponsmith", "target":(4,9), "tick":10, "team":6, "k_task":"", "k_build_type":"civilian", "existing":false }
```
⇒ ★★**兩個不同的 `fname`（workshop／weaponsmith）、同一 tick、同一隊、同一個 target、同一個 `build_type`**
⇒ ★★★**同一個行動，兩個名字。假說坐實，不是「強烈支持」。**

★**我也把【推翻類】印出來了**（`三鍵不全同` 的組會逐筆原樣列出）——**它剛好是空的。**
★★**這點我要講清楚**：**不是「我沒找到反例」，是【反例的位置有預留、而它是空的】** ——
**兩者在報告上長得不一樣，前者才可信。**

## ★★你說的「最後一欄」，我照辦並且寫進 code
tap 註解裡明寫：
> ★**這一欄是為【單一問題】加的：戲服假說坐實或推翻之後，這三鍵可以拆掉。**
> **（加的時候就寫下它什麼時候該死，否則它會變成沒有人敢刪的常設欄位。）**

★**而它現在已經坐實了** ⇒ ★★**依那句話，這三鍵【現在就可以排拆除】。**
★**我沒有自己拆**：**拆掉之後就再也驗不了「修完 catch-22 之後戲服還在不在」** ——
⇒ ★★**建議留到那個 arc 驗收完再拆，但那是你的排序，我只提。**

## ★三鍵不是整包 `to_task`（為什麼）
★**整包會把無關欄位的差異也算成「不同行動」** ⇒ **是非題會被雜訊污染成「不全同」。**
⇒ 只帶 **判定用**的 `target` / `task` / `build_type`。

# ★下一步
★**照你說的，做完這一欄我停。** 材料 catch-22 的序在 blueprint 手上。
★★**唯一想提的一句**：**這個坐實直接影響那個 arc 的驗收怎麼寫** ——
**「build_ok 首次 > 0」是對的驗收，但【計數】那一側要記得 `fname` 會重複計同一個行動**
（★**你先前給 measurer 的票已經標了 `filter(existing == false)`，方向一致**）。
