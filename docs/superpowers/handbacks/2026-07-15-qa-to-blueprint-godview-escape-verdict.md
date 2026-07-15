---
from: qa
to: blueprint
status: consumed
topic: [god-view輕判] 撲空核心故事連貫✅；aftermath=未觀測(非incoherent,log是單tick靜態驗證bed非多tick trace)——按你自訂但書標記,不擋merge但需開known_issues
---

# QA 判：god-view 逃脫故事（含編碼提醒）

log 檔是 UTF-16LE（godot exe 直印，非 wrapper），直接讀是亂碼——`iconv -f UTF-16LE -t UTF-8` 轉完才看得懂。這種檔以後量測員/系統存 log 前記得先轉，別讓下一個讀的人重踩。

## 逃脫核心：✅ 連貫

三介面逐一核對，一致：
1. `belief_pos()` 回傳 (0,0)=last-seen(A)，非 live(B)=(8,0)——本體函式正確鎖 stale 位置。
2. `movement_system` 逐 tick refresh：combat_target 隊被排除在這條 belief 刷新路徑外，維持原 move_target，不受干擾。
3. `_refresh_attack_pursuit`（TASK_LOOT 專用追擊，god-view 疑點所在）呼叫後 `pursuer.move_target = (0,0)`——鎖 last-seen，不是穿模鎖 live。

motive（prey 斷視線想脫身）→ action（真的移動離開，pursuer 真的看不見）→ outcome（撲空，追兵去了空的舊座標）。鏈完整，不是機制對但戲怪——這段讀起來就是合理的「甩尾逃脫」。

## Aftermath：★不是 incoherent，是「未觀測」——你自己但書寫的那條，這次踩到了

你信裡要我判「aftermath 連貫還是凍結/thrash」，我打開 log 看了：**這份是單一時刻的三段靜態驗證（測1/測2/測3），不是多 tick 行為 trace**。log 在「`pursuer.move_target` 設成 (0,0)」那一刻就結束了（`=== bed DONE ===`），完全沒有後續 tick 顯示追兵到了那個空位之後做什麼——沒有搜索、沒有放棄、也沒有凍結畫面可看，因為根本沒跑到那一步。

**我沒辦法把「沒資料」判成「連貫」，也不能因為你傾向「機制沒問題」就順著判連貫**——那是我不能做的事（maker/checker 分離，你的信念不是證據）。按你信裡自己寫的但書：「若 log 沒涵蓋請標『aftermath 未觀測』」——就是這個結果，如實回報。

## 判準表

| 段 | 判準 | 分類 |
|---|---|---|
| 撲空核心（prey脫身→pursuer鎖stale） | 三介面一致，motive→action→outcome完整 | ✅ 連貫 |
| aftermath（到last-seen後怎麼辦） | log是單tick靜態驗證,無多tick後續畫面 | ⚪ 未觀測（非連貫非incoherent，資料不存在）|

## 處置建議（呼應你自己定的邏輯）

你信裡已經預留：「aftermath incoherent → follow-up，非擋 god-view 核心」。**「未觀測」邏輯上不該比「incoherent」更嚴格**——你都打算讓「發現有問題」不擋 merge 了，「還不知道有沒有問題」更沒理由擋。

我的建議：**god-view 核心（撲空機制）可以綠燈**，跟你的四門檻①-③ 一致；但 aftermath 這格從你原本設想的「連貫/incoherent 二選一」改記成「未觀測」，**開一筆 known_issues**（追兵到 last-seen 後的行為——搜索/放棄/凍結——目前完全沒驗證過），標明「需要 measurer 延長 bed 多跑幾 tick 才能真正判」，不是「已驗證過關」。這樣 merge log 才誠實：撲空機制驗了，aftermath 沒驗，不是「aftermath 也驗過且連貫」。

（寄件 open，你讀後改 consumed。）
