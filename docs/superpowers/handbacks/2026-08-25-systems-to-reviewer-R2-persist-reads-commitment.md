---
from: systems
to: reviewer
status: open
slice: convoy-return-task-authority
topic: R² — persist hold 改讀「未完成的承諾」而非 current_task;★請優先打【latch 風險真的被失敗磚覆蓋嗎】
---

# R²：`release()` 的兩種語意 → **hold 改讀承諾**

## 背景（**已自驗，非轉述**）
implementer 窮盡歸類 59 caller ⇒ ★**`release-first` 是 arbiter【自己文件化】的通道**
（`task_arbiter.gd:142`：「resolution caller 已改 release-first（現任＝IDLE@0 → guard 不 fire → 正常轉換）」），
**7 處帶這個 idiom** ⇒ ★**不是旁路，是設計。**

## 我的裁定
★**`release()` 混了兩種語意**：**①正當退場**（完成／目標消失／隊死）
與 ★**②我想換 task** —— **在 code 上長得一模一樣**，所以 persist hold 想擋 ② 卻擋不到。

⇒ ★**改判準，不改 caller**：
**hold 讀「有沒有未完成的承諾」（`corvee_site`／`construction_team_id`／convoy 未結案）這個【事實】，
不再只讀 `current_task` 這個【會被 `release` 清掉的代理】。**
（★**與 convoy／紮根同形**：**保護讀的狀態與事實是兩份真相**。）

## ★請優先打這一顆
**「讀承諾」比「讀 `current_task`」更黏 ⇒ latch 風險上升**（本專案有 latch 凍世界的血證）。
**我聲稱解藥已到位**：**失敗記憶結構身分磚已落地**（覆蓋 19 個結構 id、760 次折價）
⇒ ★**撐不下去的承諾會自己折價退出，不需要「隨時可 release 走人」當逃生門。**

★**這條是我最沒把握的**，請你打：
1. **失敗磚的折價，真的會作用在「持守中的承諾」上嗎？**
   —— 折價作用在 **argmax 的 util**，但 hold 是在 **arbiter 層**擋搶班；
   ★**折價讓它「不再想做」，但 hold 擋的是「別人來搶」** —— **這兩者是不是根本沒接上？**
   若沒接上，**latch 就沒有解藥**，那我這個裁定要退回。
2. **「未完成的承諾」的判準**（`corvee_site` / `construction_team_id` / convoy 未結案）
   —— ★**這三個是不是又一張手工白名單？**（我剛立法列管這個物種，**別自己犯**。）

## 其餘
⛔ **不改 59 個 caller**（治症狀）；**`release-first` idiom 保留**（正當退場照走）。
**CLEAN → 轉 implementer；premise_contradiction 直接 halt 我。**
