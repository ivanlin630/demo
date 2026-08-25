---
from: systems
to: reviewer
status: consumed
slice: acquisition-paths-wire-in
tier: full
topic: ★R² 設計審:讓 dormant 的 means-end 磚真的進決策;★★請重點咬三處:阻抗不匹配的裁定(c)、③fp 該變的理由(與上次不同)、感知鐵律自檢有沒有漏
---

# R² 請審：`docs/superpowers/specs/2026-08-25-acquisition-paths-wire-in-HOW.md`

## 為什麼是這張票
**`AcquisitionPaths` 已 merged，但 `dormant-module-scan` 列它【零 production caller】** ⇒
★**它算得出「為了取得 X 先做 Y」，但沒有任何決策讀它 ⇒ 對遊戲行為【零影響】。**
★★**B 型驗收的 ④ 之所以是「空真」，正是這個原因。**

**接入點已定位到行**：`goal_resolver.gd:494-496` 的 fallthrough ——
★**那行既有註解自己就寫著「缺的是【製造】那條手段」** ⇒ **接口是前一票留下的，不是我發明的。**

## ★★★請特別咬這三處
1. ★**§3 的阻抗不匹配裁定**：`_resolve_resource_prereq` 回**單一 `Dictionary`**、`for_resource` 回 **`Array`**。
   我列了三個選項並裁 **(c) 回傳多條**。
   ★**請咬 (b) 我是不是排錯了** —— 我說「挑最淺的會丟掉其他路徑 ⇒ 最淺那條不划算時隊伍什麼都不做」。
   ★★**如果 (b) 其實可接受，(c) 就是不必要的 caller 改動。**
2. ★★**§6 的 ③「`fp` 該變」** —— **我上一次寫這條判準寫錯過**（`_sellable_qty` 只走 player 路徑、a4 無玩家 ⇒ 不可達）。
   ★**這次我聲稱「這條在 NPC 主決策路徑上，a4 一定會跑到」。請獨立驗這句** ——
   ★★★**如果又錯，那就是我第四次寫出不可達的 acceptance。**
3. ★**§5 感知鐵律自檢有沒有漏**：我聲稱 `for_resource` 只讀 `team.resources`（自己的）＋ `tile.<facility_key>`（腳下的）。
   ★**請窮盡確認它沒有讀任何「世界上哪裡有」的東西** —— **那會是新的 god-view。**

## ★判準
**CLEAN 才 dispatch implementer。** `premise_contradiction` → halt 回我改 spec。

## ★背景（供你判 scope）
**工作流凍改中**（用戶令），**專案票照推**（blueprint 確認）。
⇒ ★**本票是純專案票**：不碰 hooks、不碰流程 doc。§7 已列明確不做四條。
