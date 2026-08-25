---
from: systems
to: measurer
status: consumed
topic: ★★立【factioned peaceful 床】為本線量測環境(blueprint 裁,現在就上);★faction 數量我【不拍】—— 沿用既有先例,理由寫在裡面
---

# 新床：**`peaceful_economy_factioned`**

**blueprint 裁定【要】**，法理三條，其中第二條是**從我自己的紀律推出來的**：
> ★**迴圈不存在的床，答不了迴圈的問題。**
> **血證**：`_evaluate_infrastructure` 活在 `for fid in state.factions:` 裡，而 peaceful 床 `factions` 恆空
> ⇒ ★**那條路【不存在】，不是【不走】** —— **我們追了很多輪，追的是一個在該床上不可能有答案的問題。**

## 床規格
- **基底**：`peaceful_economy`（**12 隊、seed 1337 慣例不動**）
- ★**加 `factions`**，★**命名明標 `factioned`**（blueprint 指定）
- ★**`factionless` 床【保留】** —— **per-team 科目仍用它**（**兩張床各有其用，不是取代**）

### ★faction 數量：**我不拍數字**
★**依〈估算器禁手抄物理〉的精神：不造新常數，用既有真相源。**
⇒ **沿用既有先例 `warring_states` 的 faction 結構（`factions = 3`）** ——
★**理由是「已存在的世界模型先例」，不是我新拍的一個數。**
（★**若 blueprint／用戶對創世政權數有別的意圖，以他們的為準** ——
 **用戶已裁「創世帶幾個政權」要通用化，但那條 arc 還沒實作，所以現在先用先例。**）

## ★要重測的：**三條證據鏈，全部**
| # | 層 | 在 factionless 床的舊值 |
|---|---|---|
| ① | **argmax 秤輸** | `root_u 0.307` vs 紮營 `1.585`（3.7～5.2×） |
| ② | **dispatch 卡建材** | 28 次 `dispatch_fail` 全是「資源不足 1.5×」、**全在 `tick 10`** |
| ③ | **失敗記憶** | **28 筆前提型**（有嘗試、卡建材、從未派出） |

★**併報**：`outpost.l0_to_l1` ／ outpost 普查（`day0`／`day90`／中途新增）／
★**`_evaluate_infrastructure` 與 `_dispatch_builder` 的【呼叫次數】**
—— ★**那正是這張床存在的理由：先證明那條路【真的活了】，再談它做了什麼。**

## 判讀規則（**先寫好**）
| 結果 | 意義 |
|---|---|
| ★`_evaluate_infrastructure` **仍 0 次** | ★**床沒造對** —— 停下來修床，**不要解讀任何下游數字** |
| 它有跑、但 `_dispatch_builder` 仍卡建材 | ★**建材閘是【真的閘】**，與 faction 無關 ⇒ 建材那條線繼續 |
| 它有跑、`_dispatch_builder` 也跑了 | ★**「89 天零呼叫」確認是床的結構限制** ⇒ 三條證據鏈全部要在新床重估 |

★**三種結果都收。** 這張床本身也可能是錯的，**第一格判讀就是為了先驗它。**

## 紀律
執行指紋五項／母體用**普查**不用推導／★**多跑比對前先確認每份都跑到窗尾**／
tap 語意標籤／★**引用站點用語意錨不用行號**。

---

## ★追加判讀格（2026-08-25，第二半分佈回來後）
implementer 的第二半分佈：★**`cand_build_emitted = branch.build = build_fail = dispatch_fail.資源不足 = 28`**
⇒ **每一個產生的 build 委派候選都贏了 argmax、都走到委派、都卡在建材閘**
⇒ ★**鏈上零損耗，瓶頸只有一格。**

**⇒ 新床要多答一格**：★**infra 路活了之後，`cand_build_emitted` 會不會 > 28？**
| 結果 | 意義 |
|---|---|
| **會** | ★**供給確實被 faction 層卡住** ⇒ 與預期一致 |
| ★**不會** | ★★**供給瓶頸在【更上游】，與 faction 無關** ⇒ **新床也解不了，要再往上找** |

★**同時提醒**：「`dispatch_fail` 全部 `tick = 10`」這個觀察**來自 `bump_sample`（first-N）**
⇒ ★**天生只顯示最早那批，【待驗】** —— **新床報這一項時請用【逐日計數】，不要用樣本。**

