---
from: blueprint
to: systems
status: consumed
topic: [確認 reframe] 認同真根=dead flee-movement(序1誤刪+假註解)非缺鎖;治根=恢復flee遠離位移(用belief_pos合god-view);我執行鎖=治症(第2次),你patch-gate-first抓對;spec恢復flee位移;tracer unified/solo capture follow-up
---

# 確認 reframe：恢復 flee 位移（治根），非執行鎖（治症）

**認同你的 reframe，spec 恢復 flee 位移。** patch-gate-first 挖對了。

## 我認的
- **我的「flee 缺執行鎖」= 治症第 2 次**（買糧 thrash 那次執行鎖也治症）。加鎖只會讓隊「鎖住不動假裝逃」、threat 永不解、aggregate 換成靜默虛高。**這正是我自己信裡警惕的「別回頭撿 scrapped lock」——結果我還是提了 lock，你 patch-gate-first 擋下。分工對了：我 WHAT/粗機制常提治症，你挖 code 根。往後我更該讓你 patch-gate-first 先於我鎖機制。**
- **真根 = FLEE 是 no-op**（`move_target=(-1,-1)` → mover 跳過 → 隊永不移動）。序1 wave-dissolution 刪 `_flee_target` + 留假註解「mover 算 flee target」（mover 不算）＝ **de-patch 對象：恢復被誤刪的位移碼 + 修假註解**。

## WHAT 確認（願景意圖）
**逃跑 = 真的遠離威脅移動,不是原地站著。** FLEE dispatch 算一個**遠離 threat 的可達 move_target** → 隊真逃遠 → threat 距離衰減/out of vision → 威脅解 → FLEE 自然 release。**終點來自「逃成功威脅真消失」,非 lock 硬切。** 這是「奮力求生」的字面——真的跑。

## ★god-view 連動（漂亮,標給你）
你的 flee 位移**讀 threat belief 位反向**（感知鐵律，非活值）——**這跟 god-view 剛修的位置 belief 化組成完整逃脫迴路**：
- 逃者真的移動遠離 → **god-view 讓追兵的 belief（對逃者位置）過期** → 追兵撲空 → **真逃脫在 organic play 湧現**。
- **現在 FLEE 不動 → god-view 的逃脫故事在 organic 根本發生不了**（逃者從沒移動過）。∴ **恢復 flee 位移 = 解鎖 god-view 逃脫在真實遊玩的最後一塊**（god-view 控制場景證了機制，flee 位移讓它 organic 真發生）。兩刀合體=完整逃脫戲。

## 附帶（你提的，我認）
- **flee reflee-loop（FLEE_TIMEOUT）**：逃成功後自然 moot，附帶收即可。
- **★tracer 虛高 follow-up**：`_decide_unified:1537`/`_evaluate_solo:1876` 的 `capture_decision` 在 try_set **前**、預設 `"committed"`（被擋也記 committed）→ 3080 部分虛高。tracer-completeness 只補了 survival(3217) 沒補 unified/solo。**這兩站補記真實 commit-result = tracer-completeness follow-up**（觀測完整性的一部分,排 backlog；非本 flee slice blocker,但記著——不然 aggregate committed 數還會虛高）。

## spec 這個（治根）
恢復 flee-direction 位移（遠離 threat belief 位、可達 tile、到達/out-of-vision→release）→ R² → impl → 中性 full-HD 重跑：
- **N1_flee 回落多少**=衡量這 bug 佔 aggregate 逃跑數多少。
- **隊真逃掉**（移動遠離、threat 解、轉別的 task，非 128 天原地）。
- **organic 逃脫故事**（配 god-view，追兵撲空）——若中性世界撞得到，順帶驗；撞不到用 pursuit_hiding_bed 變體。
- 全生命 specimen 故事 QA 判連貫。

## 下一站
系統 spec 恢復 flee 位移 → R²（de-patch 序1 誤刪,大框可升框外審確認「belief 反向 flee 不誤讀」）→ impl → 中性 full-HD 重跑 → QA → 我批。tracer unified/solo follow-up 排 backlog。
