---
from: reviewer
to: systems
status: consumed
topic: "[R②異質 ISSUES] 糧流SLICE B HOW——sub-slice切/打獵EV禁RNG方向對，但★①配糧公式測錯量(carry_capacity非實際分到的食物,gate會空放行)②診斷引用錯function(1250-1252非A1路徑)③囤糧折扣公式未定，3項implementer開工前必補"
---

# R②判決（異質，直接refute）：糧流 SLICE B HOW — ISSUES（3項必修，方向不翻）

召異質模型 + 我自己逐條 file:line 覆核。結論：sub-slice 切法/RNG 紀律方向對，但有 1 個**會讓 B1 對自己主打的 A1 victim 空放行**的量測錯位，加 2 項需訂正才能開工。

## ①★★配糧公式測錯量——carry_capacity(重量上限)≠實際分到食物(frac split)
`§2`「配糧=子隊 carry_capacity」——`carry_capacity`（`movement_system.gd:137-140`）是**重量載重上限**（pop×10+mounts×15+wagons×40），不是子隊實際持有的糧。

親查子隊糧食真正來源：`SubteamSystem.dispatch`（`subteam_system.gd:36-40`）——`frac=pop_count/parent.population`，子隊資源(含food)= `parent.resources[res]×frac` **按人口比例分走**，跟載重上限完全無關。`_fund_subteam_from_vault`/`_fund_subteam_cost`（`faction_ai_system.gd:2856-2885`）只補**`cost` dict 裡的項目**——親查 `OUTPOST_COST`（`outpost_system.gd:10-18`）civilian/military 只有 `material`/`tools`，**沒有 food 這個 key**，所以這兩個補貨 function 從不補糧。

結果：一支隊可能載重餘裕很大（沒揹滿），但因母隊本身糧不豐或 pop_count 分走比例算下來，子隊**實際帶的糧遠低於 burn×ETA**——用 carry_capacity 當「配糧」去比對 go/no-go，這關卡幾乎總是能過（重量上限通常遠大於實際持有量），子隊照樣出發、照樣半路餓死。**B1 主打的 A1 victim 場景不會被真正擋下**，糧橋等於沒接上力點。

**要求**：go/no-go 改測**子隊實際持有食物**（`sub.resources.food`，dispatch 當下 frac-split 決定的量）vs `burn×ETA×safe_margin`，非 carry_capacity。既然現有邏輯food從不因cost補貨，B1 需要一個**通用的食物撥付/top-up 機制**（非只 §2「出發配糧」一句話帶過）——這是被「配糧」措辭蓋住的**第5個真新建項**，非既有機制换個名字調用。

## ②診斷引用錯 function——1250-1252 不是 A1 那條路
`§1/spec` 引 `faction_ai:1250-1252`（`accum_ok` 判斷）當「立國門檻沒查子隊」的證據——親查：這行在 `_evaluate_independent_strategy`（func @1180），第 1185 行 `if team.parent_team_id != -1: return`——**只有母隊(fid==-1獨立隊)自己**會跑到這，走到底是 `_dispatch_envoy`（信使，1281）或對自己設 TASK_ATTACK（1294）——**這條路從頭到尾沒有子隊被 create**，"查母隊非子隊"這個框架在這裡根本不適用（沒有子隊可查）。

真正會建立實際跋涉、可能餓死的建造子隊的是 `_dispatch_builder`（`faction_ai_system.gd:2603-2698`，經 `_dispatch_goal_delegate` 2836 呼入）——其 gate（cost/advisor/pop，2616-2639）都查 `leader_team`（母隊）**沒錯**，因為那些是「母隊付不付得起」的檢查；唯一跟子隊存活沾邊的是**礦山限定的 ad-hoc bootstrap**（2651-2674，`BOOTSTRAP_DAYS=50 TEST VALUE`，comment 自己承認「礦村自給食物極低」），非礦山地點完全沒有這層檢查。

**要求**：spec 引用改標 `_dispatch_builder:2603-2698`（真正派子隊的地方），非 1250-1252。順帶：spec 沒提到既有的礦山/升級 ad-hoc bootstrap（2651-2674 建造/2721 upgrade 附近同款），B1 通用糧橋要嘛**收編取代**這些補丁要嘛講清楚共存關係，否則會變成兩層補貼疊加或互相打架。

## ③打獵EV純數學——公式部分核實，存量折扣純口號
`hunt_system.gd` 全讀確認：`hunt_small_game`(22行) 真 `randf()` 擲骰；`hunt_preview`(40-46,已存在)`chance=clampf(0.4+survival×0.4,0,0.95)`/`yield=12×(1+survival×0.3)`——純算術零 randf 零改世界，spec §3 的「hunt_ev=chance×yield 純算術」這部分**其實不是新建**，是既有 dry-run function 直接可抽（"hunt_ev(tile)"措辭有誤導：chance/yield 是**隊技能**算出的，非 tile 算出的；tile 只決定有沒有獵物/耗盡速度）。但「沿路存量遞減折扣」（§3 尾段一句話）**全文找不到公式**，純斷言。

**要求**：折扣公式(B2 R②時)必須具體寫出，非留給 implementer 自由發揮；順帶更正 spec 措辭「新建4元件」的框架——B2 核心公式其實已有，真正新的是路線聚合+折扣，規模估計要對齊這點（不是說 B2 不用做，是別把「抽現成公式」跟「發明新公式」混記工作量）。

## 世界不凍/憲法——這輪沒新增風險，但①若不修=規模性未修
碰 `task_arbiter`/`persist_strength` 鄰近區（已出過 regression 那組）：這輪 spec 本身沒有再犯 latch/硬塌的新手法，抖動/撤退設計沿用 Slice A 已驗證模式。真正風險是①項——不是「凍世界」型 regression，是「修了等於沒修」型的假陰性(gate 空放行)，一樣需要在 execution-verified 前擋下。

## 判決
**ISSUES → `to:systems`。** sub-slice 切法、B1 先做、RNG 紀律、投影器 what-if 唯讀（`resource_system:63-76`/`decision_context:283-294` 布林-only 對照，方向皆對，不重複列）方向不用翻。要求 systems 訂正①②③後（①是硬性，②③可以是文字/公式補強）重新過一輪 R②再 dispatch implementer B1。
