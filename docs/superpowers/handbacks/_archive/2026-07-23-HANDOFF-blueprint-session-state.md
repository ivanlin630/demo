---
from: blueprint
to: blueprint
status: consumed
topic: "[HANDOFF·blueprint session state 2026-07-23] 這場=god-view arc完全收官(machine零殘留)→economy arc深挖。武器經濟六層鏈(facility-argmax撤回/material afford/demand-routing/tools/workshop-build)全部收斂到食物地方分配根因(GATE A/B+carrying-capacity確認是設計)。★教訓:技術性診斷越深越容易鬆懈QA故事驗證,連續被用戶戳破好幾次;我自己也犯過『判斷完沒主動推systems繼續』的病;覓食速率低是刻意carrying-capacity設計差點被我誤判成bug要buff,被用戶問邊界問題攔下。現在:GATE-A measure中+smeltery/armorsmith cost對齊中,facility-build keystone調查排GATE-A後(優先驗長程計劃means-end缺口假說)。"
---

# HANDOFF：blueprint session state（2026-07-23）

## 開場程序（resume）
1. arm 信箱 Monitor（先於一切）+ 5h watchdog（`bash .claude/hooks/inbox-watch.sh` persistent + status.md 快照 watchdog）。**watchdog 響了一律當真查，不猜假警報**（今天教訓，別重犯）。
2. 讀 `game-design.md`（我 owner，本場加了不少 durable，見下）。
3. 掃 handbacks `to:blueprint status:open`。

## 這場一句話
god-view belief-化 arc **完全收官**（A/F/E/D/B/C+null-belief-flee+1119+followup 全 merged，constitution_gate v3 machine 證零殘留）→ 轉進 economy arc。從「food vs goods」入口診斷一路深挖進武器經濟六層鏈（facility-argmax→material afford→demand-routing→tools 生產→workshop-build），每層都是真 bug 且修好，最終**收斂到食物地方分配才是所有問題的共同根**（GATE A/B + carrying-capacity 邊界確認是設計意圖非 bug）。目前在修 GATE-A + smeltery/armorsmith cost 對齊。

## 遊戲實質狀態

### god-view arc = 完全收官
A（slice2 belief 化）/F（fallback+死欄）/E（4 dispatch）/D（path+威脅最大塊）/B（創世②③+relay-discovery）/C（市場 belief-gate）+ null-belief-flee + 1119（can_reach）+ followup（jhost+enemy_outpost）**全部 merged**，`constitution_gate` v3 machine-verified 零殘留。感知鐵律機械執行漏洞全部治好。

### economy arc = 深挖進行中
- **武器經濟鏈（已收斂，非獨立問題）**：facility-argmax「系統性壓過 weaponsmith」判斷**撤回**（QA 揭穿樣本不完整+反例矛盾，全 7 分數 trace 證明選址正常，mil tile 贏 12/22）。真根鏈：material afford 短缺（cost 80→70 修）→ demand-routing 缺口（buy-material 動作+produce_need demand-responsive 兩處修）→ tools 生產鏈打通 → **weaponsmith 仍 0→0**，追到底＝workshop-build 太少太慢（3mo 才 1 座）→ 根＝farming 吃光求生優先權（subsistence trap，正確機制非 bug）→ **武器 gap = 食物經濟下游症狀**。
- **smeltery/armorsmith 同款 afford-ceiling 洞**：已確認（非臆測，數字驗證），現在跟 weaponsmith 一起修 cost。
- **食物地方分配 = 新 arc keystone**：盤點 meta-pattern（今天 food/goods/tools/material 全同款「world 夠、local 不夠」）→ 兩面互鎖：分配薄（死法②成交牆）+ subsistence-trap。
  - **GATE-A**（settled 隊離開高產家去買糧，"買不到+家裡沒人採+平原溢出"）＝主體 **56-61%**（跨 seed proper 分類，糾正了先前單一 specimen 過度概括到 no-outpost 的誤判）。**正在 measure**，序最優先。
  - **settled-productive 薄利**（有設施但人口太多，採集追不上消耗）＝23-36%，**已確認是合法 carrying-capacity 壓力非 rate 洞**（harvest = sqrt(pop/5) sub-linear、burn = pop×0.8 linear，設計意圖），死因＝逃生閥（升級設施/擴地/分隊/貿易）被堵，**不獨立修，併入 GATE-A+facility-build+GATE-B**。
  - **no-outpost forage**（無據點只能弱覓食，trickle<burn）＝少數 **8-13%**，裁 (a)（可 forage 到 subsistence 率，不到 full-farm 效率，不弱化建設意義），**降為第三序，仍要做**。
  - **GATE-B**＝local-only 撮合（死法②），排 GATE-A 後。
  - **facility-build 稀少 = keystone**：HOLD 住等 GATE-A 結果，因為現在測會被 survival 雜訊蓋住（confound）。★用戶連結：這可能就是 2026-07-19「長程計劃」筆記講的 means-end/discounting 缺口（隊伍不是不想升級，是決策模型缺乏「為未來投資現在資源」的機制）——facility-build 查證時**優先驗這個假說**，今天已做的 material means-end 是這套機制的雛形。

## 本場 durable（都在 game-design.md）
- material→weaponsmith 裁 ②（純貿易為主，連商隊追財/軍閥追武，不建 bespoke 管道）。
- relay-discovery 需建（2026-07-20，Slice B 擴，已 merged，兌現 2026-07-18 make-or-break 前置承諾）。
- 市場零豁免（C 裁，已 merged，invariants:187 已改）。
- 創世②+③（B 裁，已 merged）。
- 食物地方安全 arc 願景：解鎖「綜合發展模型」多元 archetype specialization 的前提。

## 流程修（本場落地）
- **§④b 決策級探針必存 bounded 樣本**（寫進 `03b_measurer.md`，任何餵 WHAT 決策的聚合數字必附具體案例，非事後補）。
- **verdict/acceptance judgement 必 cc systems**（避免 out-of-loop 空等，今天抓到過一次全員停工是這個縫）。
- **watchdog v1（記憶體變數,bug）→v2（status.md 磁碟快照,證實有效但一度被我誤判噪音）→v3（handback 活動,一度誤用取代 v2）→回 v2**。教訓：**響了一律當真查，不猜是不是假警報**（v2 沒被證實有誤報過，是我自己理論猜測沒實證）。

## ★★大教訓（別重犯）
1. **技術性越強的診斷（進 formula/code trace）越容易鬆懈「這裡有沒有故事維度」的檢查**——今天連續好幾次跳 QA（facility 樣本自判合理、afford verdict 沒送 QA），被用戶連續戳破（「連續好幾次要 QA 沒 QA 了」「不是說過有長跑必 QA 嗎」），補了整批稽核才發現 facility-argmax 判斷本身是錯的。**任何聚合數字包裝成技術報告≠免檢查**。
2. **我自己也犯過「判斷完沒主動推 systems 繼續做」的病**——跟 systems 漏發工單同一種結構性缺口，只是換我犯。用戶明講規則：QA 給我判決後，只要我判斷沒問題，**必須主動寫信告訴 systems「確認繼續」**，不能只在心裡確認完就跟用戶報告「等下一輪」。
3. **覓食速率低是刻意的 carrying-capacity 設計，不是 bug**——我一度裁定要 buff 覓食率讓 no-outpost 隊活下去，被用戶問「我們不是已經針對人數做覓食邊界了嗎」當場攔下，後來查證確認邊界真實存在（sqrt scaling），buff 下去會破壞設計。**任何「這數值是不是太低」的判斷，先確認這個數值背後有沒有刻意的設計意圖，別急著當 bug 修**。
4. **facility-argmax「系統性壓過」的最初判斷是錯的**——樣本不完整（漏印真正贏家分數）+ 反例矛盾（低分選項贏了高分選項卻沒人查為什麼），被 QA 用完整 trace 推翻。**逐 tile 分數比較前，先確認候選集有沒有印全，別只看幾個熟悉的欄位就下結論**。
5. **「世界夠、地方不夠」是貫穿全場的 meta-pattern**（food/goods/weapons/material 全同款）——真根常是分配/deal-flow 機制薄弱，不是產量問題。看到「XX 短缺」先問是產不出來還是送不到，別預設是前者。
6. **end-state 分類要用跨 seed 的 proper 統計，別憑單一 specimen 過度概括**——systems 自己犯過一次（T48 單點就把 keystone 從 GATE-A 重新定位到 no-outpost），下一輪跨 seed 分類又糾正回來。

## 工作流紀律（下場照守）
- QA verdict/aggregate 數字用於任何 WHAT 決策前，先問「這有沒有故事維度」，別因為包裝成技術報告就免檢查。
- 判斷完沒問題＝主動寫信告訴 systems 繼續做，別只在心裡確認就跟用戶報告「等下一輪」。
- watchdog 響了＝一律當真查，不猜假警報。
- 通用 fix vs 專屬補丁要盤點，專屬的檢查其他同類（設施/資源）有沒有同款洞，別讓 whack-a-mole 一直重演。
- 別跳過「先量測再開藥」——覓食速率、facility-argmax 兩次教訓都是「感覺該改」但沒先查證計意圖/資料完整性。

## 下一站
systems 正在做：①GATE-A measure（結果決定 GATE-A 解掉多少、要不要繼續處理其他薄利案例）②smeltery/armorsmith cost 對齊（cheap，應該很快）。等這兩個回來 → 我判 release-pass（照走 QA 故事稽核，不跳站）→ 序進 facility-build keystone 調查（優先驗長程計劃 means-end 缺口假說）→ GATE-B（死法②局部撮合）。durable 都在 game-design；流程 owner=systems（`03b_measurer.md`/`invariants.md` 已更新本場協議）。
