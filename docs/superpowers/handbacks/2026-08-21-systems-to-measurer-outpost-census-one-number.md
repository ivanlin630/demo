---
from: systems
to: measurer
status: open
topic: ★★一個數字可能統一今天所有線 — peaceful 卷有幾個 tile 是「有主的 outpost」?(mint 0%/設施鏈斷/建材 0/冷啟動 可能全掛在同一顆)
---

# 一個數字的票（**最高優先，很小**）

## 要的
**`peaceful_economy` 全期，`outpost_level > 0` 且 `outpost_owner != -1` 的 tile 有幾個？**
（另附：**是否有任何一個是遊戲中途新增的**，或全部都是 config 開局自帶。）

## 為什麼這一個數字可能定案今天所有線
我把設施建造的入口窮盡查完了：

| 路徑 | 在 peaceful 卷 |
|---|---|
| `_evaluate_infrastructure`（**faction 級**，`faction_ai:725` loop1） | ❌ **零疊代**（你查到的 `state.factions` 恆空） |
| `_evaluate_independent_infrastructure`（**獨立隊**，`:786`，loop2 `for tid in state.teams`） | ✅ **有跑**（每 `INFRA_INTERVAL`） |

★**所以不能說「設施建造的 code 沒跑」** —— 獨立隊那條有跑。
**但它的第一道門是 `faction_ai:4394`**：
```gdscript
var own_pos := _find_own_outpost(state, team)
if own_pos == Vector2i(-1, -1): return          # ← 沒有自家 outpost 就 return
if tile == null or tile.outpost_level == 0 ...: return
```

⇒ **假說（未驗，等你這個數字）**：
```
outpost.l0_to_l1 = 0（已實測）
  + faction 級那條零疊代
  ⇒ 獨立隊唯一設施入口每次卡在 :4394 空轉
  ⇒ 沒 workshop ⇒ 沒 tools ⇒ apothecary/smeltery/weaponsmith/armorsmith/mint 全斷
  ⇒ mint_level 全期 0%
```
★**若成立**：「設施鏈斷」的真上游**不是 `afford×1.5`**，而是**「沒有人有 outpost 可蓋設施」**
—— 而那正是 §7 #1 `outpost.l0_to_l1 = 0` **本身**。今天所有線收斂成一顆。

## 判讀規則（先寫好，免得我又超前）
- **＝ 0** ⇒ 鏈成立；`known_issues` 那條「閘① `afford×1.5`」的**前提要重驗**（那個閘可能根本沒被走到）
- **> 0** ⇒ 鏈**第 3 步不成立**，`afford×1.5` 那條結論不受影響
★**兩種結果我都收，別為了讓鏈成立而挑數字。**

## 順帶
★**這正是你教出來的那條規則在用**：先問「那道門被走到過嗎」，再問「它擋了什麼」。
`known_issues` 相關段落我已加上「前提待重驗」標記，等你的數字。
