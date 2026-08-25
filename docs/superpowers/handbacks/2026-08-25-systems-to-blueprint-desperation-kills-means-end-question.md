---
from: systems
to: blueprint
status: consumed
topic: ★★★一個 WHAT 層問題浮出來(我不自裁):絕境時「為了活下去而必須先做的事」被 dev_coeff 當成發展慾望壓死了嗎?★★這是五層雞生蛋的形狀;★我已要量測分辨,不推論
---

# 一個 WHAT 層問題浮出來 —— ★**我不自裁，呈你**

## ★背景（兩個查證過的 code 事實）
1. ★**`goal_resolver.gd:634`**：`dev_coeff = clampf(food_days / DESPERATION_DAYS, 0, 1)`，`util = payoff × dev_coeff × discount`
   ★**註解原文**：「**遠慾望歸零讓 survival 奪 argmax**」⇒ ★**絕境時所有 goal-derived candidate 的 util ＝ 0。**
2. ★**既有 build 候選有 `desire` 門檻，means-end 沒有** ⇒ **means-end 能在「還不想」時就推出「為了 X 得先做 Y」。**

## ★★★問題
**means-end 的存在理由是「為了取得 X，先做 Y」。**
**而 `dev_coeff` 對【所有】goal-derived candidate 一視同仁。**

| 目標型 | 絕境歸零 |
|---|---|
| ★**發展型**（擴張、求繁榮） | ★**正確** |
| ★★**求生型**（**我快餓死，而我缺的是 `material` 去蓋糧倉／工具**） | ★★★**那正是要救命的前置行動** |

> ★★**「為了活下去而必須先做的事」，跟「發展慾望」，現在走同一個係數。**

★**這是 `project_established_chain` 那個「五層雞生蛋」的形狀**：**沒糧 → 沒餘裕 → 不能建設 → 永遠沒糧。**

## ★我沒有做的事
- ★**沒有裁「改 `dev_coeff`」** —— ★★**那是引擎核心護欄**（它的作用是「絕境時 survival 必須奪 argmax」），**動它要有證據，不能靠我推論。**
- ★**沒有假設它是 bug** —— ★★**它也可能完全正確**（沒餘裕就是不該做，先去覓食才對）。

## ⇒ ★我要的是一個判斷，不是一個修法
**已請 implementer 把那 380 個 means-end candidate 按【服務的 goal 型別】分類**：
| 全部發展型 | ★**票無病，收工** |
|---|---|
| ★**有一批求生型** | ★★★**那批被誤殺 ⇒ 是真問題，需要你裁 WHAT** |

★★**在那個數字回來之前，這題不用你答** —— **我先報備，免得它變成又一個「沒人知道在等什麼」的懸案。**
