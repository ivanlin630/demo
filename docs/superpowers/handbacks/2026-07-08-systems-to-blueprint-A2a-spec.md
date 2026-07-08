---
from: systems
to: blueprint
status: open
topic: A2a spec 審——子隊決策路由進引擎(D7)；子集{掠奪,攻擊}秤+回歸=lifecycle fallback(不 capture)；兩取捨要你裁：①子集 vs 全 menu ②deviation randf 存廢
---

# A2a Spec 重點（給藍圖審，別啃全 spec）

全文 `docs/superpowers/specs/2026-07-08-A2a-subteam-decision-routing.md`。觸及集 `docs/process/verdicts/A2a.scope.json`。

## 一句
子隊（`parent_team_id!=-1`）現在手寫 argmax+randf 派 loot/attack **繞引擎**（A1a 後剩最大宗手不聽腦）。A2a = 把子隊決策搬進成員/solo 用的同一個 `DecisionEngine`，行為變引擎輸出。

## 做了啥設計決定
1. **子集秤，非全 menu**：子隊既有 repertoire={掠奪, 攻擊, 回歸母隊}。引擎已有 `掠奪`(greed→loot_drive) / `攻擊`(martial→attack_drive+血仇+faction 令)。→ 子隊走 `rank_subteam(ctx)` 子集（鏡射既有 `rank_ambient` 收窄法），把「greed→搶、martial→打」的手算搬成引擎人格權重秤。
2. **回歸=lifecycle fallback，不進統計**：`rank_subteam` 只吐掠奪/攻擊；無可派→`move_target=parent`（歸建），**不呼 HandBrainProbe.capture**。→ 直接避開你們 review 上輪抓的坑（「winner=回歸→恆算違規→灌高 subteam 率誤導 QA」）。
3. **deviation randf 保留為 world-mechanic**：`_check_deviation` 的 greed·(1-loyalty) 脫韁概率＝指揮鏈鬆動的世界機制（對稱既有 `_check_discipline` 逃亡 randf，憲法允許），但 fire 後**行為交引擎**（release+rank_subteam）而非手寫恆 loot。
4. 憲法閘 baseline +`_decide_subteam`（引擎 path，同 `_decide_unified` 正當）；舊兩 site 標 removed=arc 進度。

## 風險點
- **子隊野外行為忠實度**：子集擋掉了全 menu 會冒出的野外建設/練兵/貿易（無條件 applicable 的 `建設` 尤其）＝守「lifecycle 不動、最小改」。代價：子隊統一度只到 loot/attack，非全引擎。
- **抖動**：拆手寫最怕子隊每 cadence 亂換 task → 靠 `sub.current_option`+COMMITMENT_BONUS 防震（bed 抖動檢驗）。
- **deviation 語意微移**：舊=脫韁恆 loot；新=脫韁後引擎秤（有 prey→掠奪、無→漂回家）。近似但非逐位元同。

## ★要你批的兩疑慮（只此兩點，其餘 HOW 我定）
1. **子集 {掠奪,攻擊} vs 全 `rank_scored`**？我取子集（忠實/安全/可量 bypass 歸零）。全 menu=最大統一但子隊野外長新行為（違最小護欄）。**你要更純的全 menu 我就改，但那超出 A2a「只換怎麼決定、不動 lifecycle」的縮範圍**。
2. **deviation randf 存廢**？我保留（世界機制/對稱 discipline）。全刪=更純但需引擎每 cadence 重評在途子隊=抖動風險+超 A2a 範圍（那是「引擎中斷任務」另 arc）。

兩點都傾向「本 slice 忠實最小、更純的留給後續」。你點頭我就寫 plan → 實作。

## 殘留（非本 slice）
- 子隊離家 starve 不接 survival option＝忠實現況，backlog。
- leader dispatch=A2b（撞同檔，序列在 A2a 後）。

## 沒動
別人 owner 的檔全沒碰；`game-design.md` 未動（此為 HOW，無 WHAT 變）。只寫了 spec，**未寫 plan、未跑 godot**（等你審）。
