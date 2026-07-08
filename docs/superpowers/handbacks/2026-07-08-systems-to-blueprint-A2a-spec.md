---
from: systems
to: blueprint
status: consumed
topic: A2a spec rev2 審——子隊決策路由進引擎(D7)；★三取捨要你裁：①子集 vs 全 menu ②子隊攻擊觸發面塌陷是否可接受(新，審回饋揭) ③deviation randf 存廢
---

# A2a Spec 重點（給藍圖審，別啃全 spec）

> **rev2（審回饋後）**：reviewer 抓兩點——(1) commitment 防抖機制矛盾＝我的錯已修（rank_subteam 改疊 COMMITMENT_BONUS）；(2) **子隊「攻擊」觸發面遷入後大幅收窄可能塌陷**＝新增要你裁的 #2 + 補硬量測。詳 `2026-07-08-systems-to-reviewer-A2a.md`。下方新增 §裁 #2。

全文 `docs/superpowers/specs/2026-07-08-A2a-subteam-decision-routing.md`。觸及集 `docs/process/verdicts/A2a.scope.json`。

## 一句
子隊（`parent_team_id!=-1`）現在手寫 argmax+randf 派 loot/attack **繞引擎**（A1a 後剩最大宗手不聽腦）。A2a = 把子隊決策搬進成員/solo 用的同一個 `DecisionEngine`，行為變引擎輸出。

## 做了啥設計決定
1. **子集秤，非全 menu**：子隊既有 repertoire={掠奪, 攻擊, 回歸母隊}。引擎已有 `掠奪`(greed→loot_drive) / `攻擊`(martial→attack_drive+血仇+faction 令)。→ 子隊走 `rank_subteam(ctx)` 子集（鏡射既有 `rank_ambient` 收窄法），把「greed→搶、martial→打」的手算搬成引擎人格權重秤。
2. **回歸=lifecycle fallback，不進統計**：`rank_subteam` 只吐掠奪/攻擊；無可派→`move_target=parent`（歸建），**不呼 HandBrainProbe.capture**。→ 直接避開你們 review 上輪抓的坑（「winner=回歸→恆算違規→灌高 subteam 率誤導 QA」）。
3. **deviation randf 保留為 world-mechanic**：`_check_deviation` 的 greed·(1-loyalty) 脫韁概率＝指揮鏈鬆動的世界機制（對稱既有 `_check_discipline` 逃亡 randf，憲法允許），但 fire 後**行為交引擎**（release+rank_subteam）而非手寫恆 loot。
4. 憲法閘 baseline +`_decide_subteam`（引擎 path，同 `_decide_unified` 正當）；舊兩 site 標 removed=arc 進度。

## 風險點
- **★子隊攻擊觸發面塌陷（rev2 新，reviewer 揭）**：舊碼夠好戰即打最近獨立隊（`_tag_weight`=1.0 無方向、target 無條件）；新引擎「攻擊」需 faction 戰 / 征服 intent / 血仇≥0.5 三選一，子隊 intent 恆空、僅 parent 開戰或有血仇才成立→一般離家子隊攻擊可能近乎消失。=重演 invariants.md:15 序5/6 raid 暫失舊坑。**已補硬量測 #4b（攻擊/掠奪派工前後對照，ATTACK→0 未經批=FAIL）+ 升為要你裁 #2。**
- **子隊野外行為忠實度**：子集擋掉全 menu 會冒的野外建設/練兵/貿易（`建設` 無條件 applicable 尤險）＝守「lifecycle 不動」。代價：子隊統一度只到 loot/attack。
- **抖動**：rev2 修正——`rank_subteam` 疊 COMMITMENT_BONUS（鏡射 rank_scored 非無 commitment 的 rank_ambient）→掠奪↔攻擊真防震。
- **deviation 語意微移**：舊=脫韁恆 loot；新=脫韁後引擎秤（有 prey→掠奪、無→漂回家）。

## ★要你批的三疑慮
1. **子集 {掠奪,攻擊} vs 全 `rank_scored`**？我取子集（忠實/安全/可量 bypass 歸零）。全 menu=最大統一但子隊野外長新行為（違最小護欄）。
2. **★子隊攻擊觸發面塌陷是否可接受（rev2 新）**？系統立場：舊「純好戰打最近獨立隊、無 belief 無理由」本身=hand raid script，溶進引擎後攻擊需理由（faction戰/征服/血仇）＝**更可信**；多數子隊轉掠奪/回歸、攻擊留給有理由者。**建議接受收窄，以 #4b（主動出擊不得歸 0）為硬閘**。你若要保舊觸發面→需加子隊攻擊路徑（=搬回 hand script，違憲精神）。**#4b 數據會說話：若子隊本就極少攻擊（多為 settle/construct 保護任務），塌陷影響本就小。**
3. **deviation randf 存廢**？我保留（世界機制/對稱 discipline）。全刪=超 A2a 範圍。

三點都傾向「本 slice 忠實最小、更純留後續」。#1/#3 你點頭 + #2 你裁（或等 #4b 數據）我才寫 plan → 實作。

## 殘留（非本 slice）
- 子隊離家 starve 不接 survival option＝忠實現況，backlog。
- leader dispatch=A2b（撞同檔，序列在 A2a 後）。

## 沒動
別人 owner 的檔全沒碰；`game-design.md` 未動（此為 HOW，無 WHAT 變）。只寫了 spec，**未寫 plan、未跑 godot**（等你審）。
