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

---

## §6 ★★診斷結果：**落在①分支**，且接線缺口有 `file:line`

**implementer 的發現（我已自驗）**：
- `decision_engine.gd:76` `u *= FailureMemory.mult_for_option(...)` ⇒ **只乘在【靜態 option】那個迴圈**
- ★`decision_engine.gd:104` `scored.append({"u": float(cand.get("util", 0.0)), ...})`
  ⇒ **goal candidate 用【生 util】進池，完全不過折價**
- `FailureMemory.mult_for_option` production 全樹 **只有 1 個 caller**（就是 `:76`）

⇒ ★**`build_workshop` 是 goal candidate ⇒ 失敗多少次都不折價 ⇒ team 11 連贏 45 次。**

## §7 ★★★systems 追查：**接上去也不會生效** —— 真正的問題是【接線面積】

```gdscript
const OPTION_FAIL_KEY: Dictionary = {
    "買糧": ["買單", "food"],
    "買料": ["買單", "material"],
}
...
var m = OPTION_FAIL_KEY.get(option)
if m == null: return 1.0          # ★不在表上 ⇒ 恆 1.0
```

★★**失敗反饋律目前的接線面積 ＝ 【2 個 option】**（買糧／買料）。
**其餘所有 option 恆 1.0** —— 這也解釋了為什麼「有咬」的 339 筆**全是買單**。

⇒ ★**把 `:104` 接上 `mult_for_option` 也沒用** —— candidate 的 label 不在那兩筆裡，一樣回 1.0。

### ★這不是 bug，是【宣告過的未完成】
`decision_engine.gd:74` 註解自己寫著：
> **「未接線的 option 恆 1.0 ＝ 對其餘 option 零行為。」**
⇒ **它被誠實宣告過**。問題不在隱藏，在**沒有人把「接線面積」當成一個要追蹤的量**。

### ★★由此立一條通則：**「機制已立」≠「機制已覆蓋」**
帳上把一條律記成 `done` 時，**必須同時記【覆蓋率】** ——
「失敗反饋律已落地」與「**它對 2/N 個 option 生效**」是**兩件事**。
★**同族**：`PROGRESSIVE_HOLD_TASKS`（手工白名單，已兩次漏列：CONVOY、TASK_CAMP）
／`OPTION_FAIL_KEY`（手工白名單，2 筆）—— ★**第三次同型。**

## §8 修法形狀（**待 blueprint 定磚，我不自選**）
★**手工對照表在這裡註定漏**：candidate 的 label 是**組合出來的**
（`goal_resolver.gd:447` `gt + ":" + frontier_kind`、`deliver_<res>`、`<label>:delegate`）
⇒ **label 空間近乎開放，白名單永遠追不上。**

⇒ ★**修法方向應是「失敗記憶以【動作的真實身份】為 key，而不是靠一張人工對照表」**
—— **同〈禁手抄物理〉家族：第二份人工維護的真相必然 drift。**
（**且與 blueprint「排序＝折現值比較的自然輸出、禁新排序常數」同精神**：
 折價是「這條路我試過、失敗了」的**真實資訊**，不是排序旋鈕。）

★**但「動作的真實身份」怎麼定義**（動作類別？目標？兩者組合？）**是設計問題，需 R²。**

