# Plan — capture 完成 depth（征服者 last-mile,measure-first）

> spec = `specs/2026-07-02-capture-completion-depth-design.md`。measure 先、別猜。守四關。不鬆 survival gate。
> 前置：headless 基準 PASS + coin_eq(全池)0 + framework 7/7 記下。

## Task 0 — measure 漏斗（先,別猜）
- 探針埋 `npc_combat`/攻擊 dispatch：`conq.attack_dispatch`/`combat_entered`/`combat_win`/`combat_draw`/`combat_lose`/`win_absorbed`/`win_no_absorb`(+原因)。
- warring seed 跑 → 讀漏斗:243 攻擊→1 capture 崩在「打不贏」(draw/retreat/lose 多) 還是「贏了不吸收」(absorb 條件窄)。
- **DoD**：漏斗數在手、崩點定（別猜下一步修哪）。

## Task 1 — 修崩點（按 Task0）
- **若打不贏主崩**：戰不決勝(draw/retreat 先於殲滅,連舊教訓)→ readiness/決勝門檻 or 潰逃俘擴(`_force_retreat` capture_wounded 也 PAY)。
- **若贏了不吸收主崩**：`absorb_as_captive` 條件(敗方殘 anon>0)窄/casualty 死光→沒得吸 → casualty-vs-capture 平衡調(讓贏方真得人)。
- **測**：修後 win→absorb 率升;capture.total 顯著升。
- **DoD**：崩點修、capture 轉化升(單元+bed)。

## Task 2 — 以戰養戰閉環（PAY）
- 攻擊/搶**贏→PAY**：糧(loot food 確認征服攻擊也 loot)+人(captive→`assimilate_captives` 成 free pop)+資源。接既有 AnonTierSystem/ManpowerSystem 鏈。
- **測**：winner 贏後 food/pop 升(壯大)。
- **DoD**：以戰養戰閉環通、winner 真壯大。

## Task 3 — survival-trap 自解驗
- conqueror specimen(food_days≈3 高野心) → 搶→PAY→food 升→脫 survival-loot→發乾淨征服。
- **DoD**：specimen trace 顯 餓→搶→餵飽→escalate 征服(非困劫掠)。survival-trap 自解、**不鬆 gate**。

## Task 4 — 四關 + 活世界
- 四關:①specimen 征服計畫像 ②tick-time 沒爆 ③trace 可讀 ④bed CONQUER 起+established 多+capture 升+**不 over-war**+不 mass-starve。
- warring(bg/seeded 若軌3先好):capture.total 升、CONQUER 起、established 多。
- **DoD**：四關過 + 誠實標征服者 emergence 到哪。

## Task 5 — 守恆閘
- headless PASS≥基準、coin_eq(全池)0、**pop 守恆**(吸收/casualty 平衡不憑空)、framework S1-S6 PASS、InvariantAudit 0。

## 不碰（scope + 並行 guard）
- combat_target chokepoint(軌2)、決策 intent(means-end done)、鬆 survival gate(藍圖否)、tile-bank。**只碰 npc_combat(absorb/casualty/loot 函數)+manpower/anon_tier(吸收鏈)+probe+bed**。

## 完成
- handback：漏斗崩點 + 修 + 以戰養戰閉環 + survival-trap 自解 + 四關 + 誠實標 capture/CONQUER emergence。
- ⚠ 與 combat_target 軌並行同觸 npc_combat 不同函數(absorb vs combat_target 寫)→ 系統 merge 序解。
