# capture 完成 depth（征服者 last-mile：搶要 PAY / 以戰養戰）— 設計 spec

> 系統 HOW spec。承藍圖 `capture-pay-conqueror-lastmile`（下燒）。統一矩陣征服 measure follow-up。
> **收斂根**：survival-trap（餓 conqueror 困劫掠）+ capture-depth（243 攻擊→1 capture）= **同一根「搶了不 PAY」**。真解=**capture 完成（贏→吸收→糧+人+資源=以戰養戰）** → 餓 warlord 搶→餵飽長大→升級征服 → **survival-trap 自解**。**不鬆 survival gate**（flat 作弊）。
> **measure-first（藍圖鐵律,別猜）**：先量「贏了不吸收 vs 打不贏」哪個崩 → 修。

## 現況（征服 measure）
- means-end 已收攻擊路徑統一（征服→prosperity route 6.6×）,但 **capture.total 未升**（3→1 噪級）。243 攻擊決策→1 capture = 轉化崩。
- 既有 capture 鏈：`npc_combat._end_combat` `absorb_as_captive`（:287,敗方殘 anon>0→captive）+ `_force_retreat` `capture_wounded_as_captive`（:318,潰逃俘 wounded）。
- 未知（measure 定）：攻擊決策 → 多少到真戰鬥？戰鬥多少贏？贏的多少 absorb 成功？崩在「打不贏」(draw/retreat/lose) 還是「贏了不吸收」(absorb 條件不成立)？

## Task 0 — measure 斷點（先,別猜）
探針量攻擊→capture 漏斗：
- `conq.attack_dispatch`：攻擊 task 派出。
- `conq.combat_entered`：真進戰鬥（vs 追不到/target 消失）。
- `conq.combat_win` / `conq.combat_draw` / `conq.combat_lose`：戰鬥結局。
- `conq.win_absorbed` / `conq.win_no_absorb`：贏了有無 absorb（+ no_absorb 原因:敗方無殘 anon / 敗方 erase 前沒吸 / subjugate 條件不符）。
- warring seed 跑 → 漏斗哪段崩。

## 修（按 measure,兩候選）
### 若「打不贏」主崩（戰鬥不決勝）
- 戰鬥多 draw/retreat 先於殲滅（連舊「戰不決勝」教訓）→ 攻擊 readiness/決勝門檻調 or 失能-capture(`_force_retreat` 潰逃俘)擴（潰逃也 PAY）。

### 若「贏了不吸收」主崩（absorb 條件窄）
- `absorb_as_captive` 條件（敗方殘 anon>0 + guard room）太窄 → 多數戰鬥敗方 anon 已在 casualty 死光 → 沒得吸。修向：**贏→PAY 對稱化**——除 captive 外,**搶到糧+資源**（loot 已有？確認征服攻擊也 loot）+ 敗方殘 pop 吸收比例調（casualty vs capture 平衡,讓贏方真得人）。

### 以戰養戰閉環（核心）
- 攻擊/搶**贏→PAY**：糧（loot food）+ 人（captive→吸收成 free pop）+ 資源 → winner 壯大 → 餓 warlord 餵飽 → escalate 征服。接既有 `absorb_as_captive`→`assimilate_captives`（受控人力鏈,ManpowerSystem）。
- survival-trap 自解驗：conqueror specimen food_days≈3 → 搶到糧 → food 升 → 脫離 survival-loot → 發乾淨征服。

## 四關驗收（藍圖）
1. **真變好戲**：conqueror specimen 想=征服→搶→餵飽→escalate 征服（非困劫掠）。
2. **跑得動**：capture/吸收 O(戰鬥),LOD-scale;tick-time 沒爆。
3. **看得懂**：specimen trace 顯 攻擊→贏→吸收→壯大鏈;漏斗 probe 可讀。
4. **還在賺**：bed CONQUER 起 + established 多 + capture.total 顯著升 + **不 over-war**（搶要 PAY 不等於全民劫掠潮）+ 不 mass-starve。

## believability / 守恆
- 以戰養戰=歷史真實（征服自維持）。餓則搶→搶到壯大=正確 emergence。
- 守恆（命脈）：吸收/loot 全經既有 `AnonTierSystem.absorb_as_captive`/`ResourceBank`（pop/coin 轉移非憑空,連 [[project_combat_unification]]）。coin_eq 全池 0、pop 守恆。

## 檔案
- `scripts/debug/`：capture 漏斗探針（measure Task0）+ conqueror survival-trap 自解驗 bed。
- `npc_combat_system.gd`：absorb 條件/casualty-vs-capture 平衡（按 measure）+ 征服攻擊 loot PAY 確認。
- `encounter_system.gd`：若 player/tactical 側 capture 也崩（prisoner_population 死路,連 F-M1,但本 spec 聚 NPC 征服）。
- `manpower_system.gd`/`anon_tier_system.gd`：吸收→同化鏈（複用,確認接上）。
- 驗證：warring seed capture.total 升 + conqueror 脫 survival-trap。

## 風險 + 緩解
- **over-war（搶 PAY 太肥→全民劫掠）**：PAY 量級 TEST VALUE,bed 驗不 over-war;搶仍 gated（means-end 匱乏+野心 gate 已在）。
- **casualty vs capture 平衡**（吸太多→戰爭無損耗人口膨脹）：守恆下 casualty/capture 比例 TEST VALUE,pop 守恆驗。
- **與 combat_target/seeded harness 並行**：本軌碰 npc_combat(absorb/casualty 函數)+manpower+probe;combat_target 軌碰 npc_combat 的 combat_target field 寫（不同函數）;seeded 碰 debug seed → 同檔不同函數,merge 序解。
- **scope**：capture 完成 + 以戰養戰。**不碰** combat_target chokepoint（軌2）、決策 intent（means-end done）、鬆 survival gate（藍圖否）。

## 開放細節（plan 定,measure 後）
- 崩點（打不贏 vs 不吸收）→ 對應修（Task0 定）。
- PAY 內容（糧/人/資源比例）+ casualty-vs-capture 平衡 TEST VALUE。
- 潰逃俘 vs 殲滅後吸收 的觸發窗。
