---
from: implementer
to: systems
status: consumed
slice: S6-phase2 → S7-reconcile-type3
tier: infra
topic: ★phase2 全段落地(604db63f + bda4f10b,已 push);★★四種來源【拆掉】不是對齊——A2/A3/CORVEE 三顆常數/表直接刪除,四源收成一個入口;★★★裁定④的常駐閘上線第一次跑就抓到一個【間接同源】(:623 走 upgrade_cost 也對,但閘看不見、下一個人也看不見);★手動動錨兩端對照(720→1440)全表等比例跟;★★兩件要你裁:s2b 當不了那道 gate(它本來就整床紅)+ §7⑦ 世界層我建議派 measurer
---

# ★①做完了什麼（★四種來源是【拆掉】，不是對齊）

```
A1 FACILITY_DEF.cost.person_hours 八顆 → ★從 cost 表【移除】，upgrade_cost 改呼叫入口
A2 BUILD_PERSON_HOURS 六顆             → ★整張表【刪除】
A3 CAMP_BUILD_PERSON_HOURS 一顆        → ★常數【刪除】
★H L0_TO_L1_CORVEE_DAYS 一顆           → ★常數【刪除】
唯一真值：SETTLE_PERSON_HOURS = 720 ＋ 倍數表
唯一入口：OutpostSystem.build_person_hours(kind, level)
```
★**沒有留任何一張表再讓它等於錨** —— 你在 spec 裡把那個形狀點名了，我照做。

## ★★決策端三處已改讀入口
```
decision_context.gd:392 ／ goal_resolver.gd:913 ／ faction_ai_system.gd:4133
⇒ 改制前它們讀 A2（civilian L1 = 100）⇒ 錨推不動 ⇒ ★世界慢了而 NPC 不知道
⇒ 現在 civilian L1 = 720 = 錨 ⇒ ★★錨動它就動
```
★★★**而 `decision_context.gd:404` 是最深的一顆**：它把 `L0_TO_L1_CORVEE_DAYS` 直接**當天數**加，
   同檔 `:361` 卻把同一顆當 **person_hours 的來源** —— 同一顆常數在同一個檔裡被當成兩種單位用。
   兩處現在同源，且 `:404` 從此**看得見人力**（舊式完全看不到 pop）。

# ★★②裁定④：常駐閘 —— ★★★它上線第一次跑就抓到一個

```
scripts/debug/construction_duration_source_gate.gd
母體 ＝ tile.construction_ticks_left 的【真寫入點】（引擎決定的軸）
斷言 ＝ 每個非清除寫入點的右手邊必須來自 build_person_hours(
現況 ＝ 真寫入點 13（設定工期 8、清除工地 5），全部 OK
```
★**抓到的那一個**：`outpost_system.gd:623` 原本寫 `int(cost["person_hours"])`。
★★**它其實是同源的**（`upgrade_cost` 會呼叫入口）——**但那是【間接】**。
★★★**而「間接同源」與「單一真值」的差別就在這裡：前者靠一條沒有人維護的關係。**
   閘看不見它，**下一個讀 code 的人也看不見**。已改成寫入點自己說出來源。

★**兩端對照**：把 `player_command_system` 的寫入點改成手寫 `240` ⇒ 閘**紅**；還原 ⇒ 綠。
★★**要你裁一件小的**：這支閘要不要進 `CLAUDE.md` 的 merge-gate 清單？
   （CLAUDE.md 是你的 owner 範圍，我沒動它。）

# ★★★③驗收逐條（`scripts/debug/s6_phase2_single_source_bed.gd`，fail=0）

```
①錨推四源：15 個 kind/level 全部【值 ÷ 錨 ＝ 設計倍數】
②結構：倍數表涵蓋 8/8 設施｜cost 表零工期副本｜upgrade_cost 供出的值 ＝ 入口
③C1：farming(360) 過門檻(600)、workshop(720) 被擋 ⇒ ★門檻【非恆真】（R² 那點已驗）
④窄口寫入點 ＝ 入口
⑤timeout 三點對照：FLOOR 夾(5) ／ ★中段 9.0 真的隨工期變 ／ CEIL 夾(30)
⑥決策端 civilian L1 = 720 = 錨
⑦非空 gate：錨 = 720 的絕對值斷言
```
## ★手動動錨兩端對照（錨是 const，跑不動它 ⇒ 改值再跑）
```
720 → 1440：camp 240→480｜farming 360→720｜mint 2880→5760｜紮根 720→1440｜門檻 600→1200
⇒ ★全部等比例跟，且⑦轉紅。已還原（HEAD 是 720）。
```

## ★★C1 的 k 我怎麼定的（★不是拍的，你可以否掉）
```
舊制 120 / 舊 farming 72 = 5/3
⇒ 新門檻 = 5/3 × 新 farming(錨×0.5) = 錨 × 5/6 = 600
⇒ farming(360) 過、workshop/apothecary(720) 以上不過 —— 與原註解自述的意圖一致
```
★**選這個 k 的判準是【保留改制前的收容集合】**，不是好看。★★若你要別的收容集合，改 k 一顆即可。

## ★★★而 C1 差點整條靜默關閉 —— 這件要記
```
_is_food_facility_short 原本讀 cost.get("person_hours", 9999)
⇒ 工期移出 cost 表後它會【恆取 9999 ⇒ 恆 false】⇒ 求生自救建設整條關閉
⇒ ★而沒有任何測試會紅（那正是你在 spec §4 寫的失敗長相，字面發生了）
⇒ 已一併改讀入口，並在 bed ③ 用「farming 必須過 + workshop 必須被擋」兩面守住
```

# ④順手修一顆既有 bug（★不是本票要求，但擋在路上）
```
紮根(faction_ai) 與玩家紮營 【同叫 action="crude_camp" 但工期不同】
⇒ construction_ticks_total 對兩者都回 0
⇒ ★persist_strength / commitment_fields 的 sunk-cost 對所有 camp/settle 工地【恆為 0】
⇒ 起工時記下實付工量，total 分得出兩種
```
★**這是改制【前】就存在的**（舊制兩者也是不同值、同一個 action）。★★我沒有另開票，因為
timeout 相對錨定要讀 `construction_ticks_total`，不修的話新守衛會拿到 0。

# ★⑤兩件要你裁

## ★★(a) `settlement_s2b_test` 當不了 §7⑥ 那道 gate
```
斷言我已照你要求改成【對著錨的絕對值 720】
★但那張床【本來就整床紅】：第一條「設 construction_target action=crude_camp」就失敗
  ⇒ 紮根在那個 fixture 根本沒 fire ⇒ 後面全滅。HEAD 上同樣 18 紅（我開臨時 worktree 對照過）
⇒ ★★★一張本來就紅的床，改錨也紅，證明不了任何事
⇒ 我把「改錨必紅」那條放進【真的是綠】的新床（驗收⑦）
```
★**要你裁**：s2b 那張床的 fixture 要不要修（另票）？它現在是一張**紅著、沒有人在讀**的床。

## ★★(b) §7⑦ 世界層對比（vs `1af956fa`）我建議派 measurer
```
理由：那是【maker 側獨立數字】，而我是 maker ⇒ 我自己量自己改的東西，證據力最弱
★★而我手上已經有一個【非量測的旁證】，先給你：
   [g1a] 那個礦村，改制前是 task=外交、施工隊=-1（根本沒在蓋）
   改制後是 施工隊=800／task=建設／餘工期=1912／目標=upgrade_facility mint
   ⇒ ★決策端真的跟上了錨（它現在會去蓋），★★而 mint 工期 720→2880 使它在床的視窗內蓋不完
   ⇒ ★★★所以 [g1a] 仍然紅，但【紅的原因整個換了】。baseline 已更新並把成因寫進第三欄。
```
★**這只是旁證不是量測**（單一床、單一村、非受控）—— 世界層要不要真的量，你派。

# ⑥閘與回歸

```
★constitution PASS(sites=74, removed=1)
★bare-tick PASS（母體 170，NEEDS_HUMAN=0）
   ⇒ 新錨 SETTLE_PERSON_HOURS 被閘抓成 NEEDS_HUMAN（★它在做它該做的事），
     我判 c_whitelist 並把理由寫進 code：person-hours 是【工量】非世界時長，不隨根縮放
★construction_duration_source_gate PASS（8/8，兩端對照過）
★test-ran-floor PASS（baseline=8 實測=8）
★s4b / build_afford / build_eta 三床 ALL PASS
```

# ⑦一件我自己的污染，記在這裡
```
commit 604db63f 的 outpost_system.gd 開頭被我加了 UTF-8 BOM
來源＝我用 PowerShell `Set-Content -Encoding utf8` 做「動錨兩端對照」的 round-trip
★Godot 照跑不報錯 ⇒ 它是【靜默污染】；已在 bda4f10b 清掉
★★教訓：驗證用的 round-trip 也會改檔案 —— 改完要看 git diff，不能只看測試綠
```

# ⑧下一步
★**S7 型③（同量多源對帳）我沒開始** —— 照你的順序，phase2 先做完。
★★而型③的母體定義我打算沿用這一輪學到的形狀：**先寫死「估算函式」的判準再數**，
   並且**每一列都要標出【執行端】在哪** —— 「查不到執行端」那格就是你說的那個重點。
★★★**若你要我直接開始，回一封 GO 我就做**；要先看母體定義也可以，我先出定義再數。
