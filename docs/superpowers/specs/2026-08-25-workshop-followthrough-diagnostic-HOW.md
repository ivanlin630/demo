---
slice: workshop-followthrough-diagnostic
tier: probe
qa: not-required
from: systems
topic: ★診斷【非修】—— build_workshop 贏 45 次之後,到底有沒有真執行/真完工?
---

# `build_workshop` 的 follow-through：**診斷票，不修東西**

**來源**：blueprint 裁定 2026-08-25。
**背景**：`camp-construction-duration` 第一趟 —— **team 11 紮根輸了 45 次，全部輸給 `build_workshop:resource`，一次都沒贏過。**

★**blueprint 明令 scope ＝ 診斷，不是修** ——
「排不上隊」**過缺件表、不立新 arc**；**診斷回來定磚，不定 arc。**

## §1 唯一要回答的問題
★**`build_workshop` 贏了 45 次之後，有沒有真的執行？有沒有真的完工？**

## §2 三個分支，**判讀規則先寫死**（免得看到數字才編故事）

| 觀測 | 判定 | 歸屬 |
|---|---|---|
| ★**贏了卻不完工、然後【又重贏】** | **失敗反饋律該咬未咬**（`won → stall → 折價`，★**律已立，是接線沒接上**）**或死水** | 查 `failure-feedback` 的接線；死水兩欄先過 |
| ★**真的完工 45 個 workshop** | **另一回事** —— 那不是「排不上隊」，是**世界真的在蓋工坊** | 回頭重看「紮根為什麼不划算」 |
| ★**genuine 同類排序需求** | 需要**能比較兩種建設**的機制 | 脊椎 **means-end「拆得開」磚**；★**排序 ＝ 折現值比較的自然輸出，禁新增排序常數** |

★**三條都不准當場開藥** —— 本票只出分佈。

## §3 要的數字
1. `build_workshop` 的 **won → dispatch → start → complete** 全鏈計數（**同 A1 的漏斗形狀**）
2. ★**贏了幾次是【同一隊重複贏同一個目標】**（`won_by_team` × target）
   —— 對照 team 11 那 45 次是「45 個不同工坊」還是「同一個蓋不完一直重贏」
3. **死水兩欄**（`03b §④c`）：`build_workshop` 那條路的**呼叫頻率**與**輸入變異性**
4. ★**若出現「贏而未完工」** ⇒ 併報 **`failure-feedback` 的相關 counter 有沒有動**
   （★依 `patch_gate_first` 追加判準：**分清「律沒咬」與「律沒被執行到」**）

## §4 紀律
- ★**母體 vs 樣本**分開報（`03b §④e`）；**tap 語意標籤** peak/last/mean（`§④f`）
- ★**分母對齊語意**：「贏 45 次」的分母是什麼、有沒有混進不相干事件（`§④i`）
- **殘差稽核**：漏斗各分支要能對平，對不平 ⇒ 有沒想到的出口，**先別解讀分佈**
- ⛔ **不准為了讓某個分支成立而挑數字**；三種結果都收

## §5 閘
`tier: probe`（★**純診斷、零行為改動** —— 由 **`det fp` 不變 ＋ headless 0-new** 佐證；
★**fp 一變就不是 probe**，見 `01_architect` tier 判準）。
tap 全 Probe-gated、**禁耗 global RNG**。
