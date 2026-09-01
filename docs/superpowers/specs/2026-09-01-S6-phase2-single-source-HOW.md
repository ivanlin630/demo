---
status: DRAFT(待 R²)
owner: systems
slice: S6-phase2（工期單一真值 + 錨推四源 + timeout 相對錨定）
what: §3c 表（用戶核可）／表值 blueprint 正式簽署 2026-09-01（錨 = 720 person_hours）
law: ★用戶 2026-08-21 估算器立法 ——【②手抄物理常數全禁】,修法形狀＝改接線非改數值
     ★★blueprint 2026-09-01：決策端自帶另一張工期表 ＝ 該法的本尊 ⇒ ★★★禁「同步兩張表」
---

# ★★★§1 病：**工期有四種來源，而決策端讀的是【另一張】**
```
A1  FACILITY_DEF[*].cost.person_hours     八顆  ←【簽署表】
A2  BUILD_PERSON_HOURS                    六顆  ←★另一張表
A3  CAMP_BUILD_PERSON_HOURS               一顆  ←★第三張
★H  L0_TO_L1_CORVEE_DAYS × TICKS_PER_DAY  一顆  ←★第三種換算
★★而 decision_context:392 ／ goal_resolver:913 ／ faction_ai:4133 讀的都是 A2
⇒ ★★★只推 A1：世界工期 ×4~8 變慢，而 NPC 心裡的「蓋一座要多久」【完全不動】
```
★**這是【手不聽腦的鏡像】：腦不知手。** ★★**它不會報錯、不會有測試紅 —— 只會表現成「隊伍一直做不完事」。**

# ★★§2 修法：**一個查詢取代四張表**（★禁同步）
```
唯一權威（新）：
  OutpostSystem.SETTLE_PERSON_HOURS = 720                      ★唯一數字
  OutpostSystem.build_person_hours(kind, level) -> int          ★唯一入口
     內部 = SETTLE_PERSON_HOURS × 倍數表（倍數＝WHAT §3c，設計，不動）
⇒ A1/A2/A3/H 全部改成【呼叫這個入口】，★★它們不再是表，是查詢
```
★★★**禁止的形狀（明寫，因為它是最誘人的那個）**：
> **保留 A2 那張表、然後在某處「讓它等於 A1」。**
> ★**那是【同步兩張表】—— 而同步關係沒有人維護，它只在寫下的那一天成立。**
> ★★用戶原話：**把 2 改成 5，三個月後又爛。修法形狀＝改接線，不是改數值。**

# ★★★§3 CORVEE：**拆開兩個語意的唯一乾淨解 ＝ 讓那顆常數退場**
```
現況 faction_ai:5645  construction_ticks_left = L0_TO_L1_CORVEE_DAYS * TICKS_PER_DAY
   ★舊根 240 ＝【24 小時】×【假設 10 人】兩個語意黏在一個乘法裡
新法：construction_ticks_left = build_person_hours("settle", 1)   # ＝ 錨 720
⇒ ★★L0_TO_L1_CORVEE_DAYS 退場 —— ★★★常數不存在，就沒有第二個語意可黏
```
★**同批必改**（否則錨改了它還在加 3 天，而它不會報錯）：
```
decision_context.gd:404  camp_flow_delay_days = dist + L0_TO_L1_CORVEE_DAYS   ←★把常數當【天】
  ⇒ 改為 dist + build_eta_days(build_person_hours("settle",1), pop)  ★pop-aware 且同源
decision_context.gd:361  settle_eta_days 同一條式子 ⇒ 一併改讀入口
debug/settlement_s2b_test.gd:61/131  ★斷言目前是「等於那條式子」⇒ 式子改它跟著改 ＝【空 gate】
  ⇒ ★★改成【對著錨的絕對值】(720)，否則這道 gate 什麼都沒守
```

# ★★§4 兩顆「拿工期當門檻」
```
★C1 faction_ai:5079/:5086  SURVIVAL_BUILD_MAX_TICKS = 120（死值）
   ⇒ 錨推後 farming = 360 ⇒ ★★120 連 farming 都擋掉 ⇒【求生自救建設整條靜默關閉】
   ⇒ ★★★硬條款：改成接線（綁 farming 工期 × 倍數），不得留死值
      ——★而那不是「平衡變了」，是【一整類行為消失】且沒有測試會紅
★C2 faction_ai:5133  int(cost.get("person_hours", 72))   ← 72 是 farming 工期的手抄副本
   ⇒ ★判 bug 非設計：改成缺鍵【直接爆】(fail loud)，不留 fallback 副本
   ⇒ ★★理由：它現在是死路徑，但【會醒過來】——新增設施漏填就吃到它，而沒人在看它
```

# ★§5 timeout 相對錨定（承機制段）
```
CONSTRUCTION_TIMEOUT = 30 * TICKS_PER_DAY（絕對）
⇒ timeout_days = clampf(k * build_eta_days(初始 person_hours, ★動工當下 pop), FLOOR, CEIL)
★硬條款：pop【動工當下凍結】(即時 pop→0 ⇒ 預期工期→∞ ⇒ timeout 永不觸發 ⇒ 黑洞回歸)
★★CEIL 必要；FLOOR 防短工地秒取消
★★★reviewer 已判：凍結風險真實但【不是新卡死】(舊 flat-30 天同類風險) ⇒ 不在本票解
```

# ★★§6 附帶（工具層，同批）
```
★零命中檢查從 b_defer 擴到【所有 bucket】，輸出【註記】非 FAIL
   ⇒ 理由：★★改名會製造死規則（本輪 CAMP_BUILD_TICKS 就殺死一條），而它靜默
   ⇒ 現存 5 條零命中 c_whitelist 一併印出
```

# ★★★§7 驗收（★綁引擎決定的窄口，不綁「八項」）
```
①★改錨 ⇒ 【tile.construction_ticks_left 的 8 個真寫入點】全部等比例跟
   ★★不綁「八項」——★★★綁八項的話 A2/A3/CORVEE 永遠在帳外（本輪的血證）
②★決策端一致性：decision_context:392／goal_resolver:913／faction_ai:4133
   讀到的工期 == 執行端實際扣的工期（★同一顆錨，逐點比對）
   ★★失敗長相＝世界慢了而估算沒跟 ⇒ 這條就是專門抓「腦不知手」的
③★C1：錨推後 farming 仍必須通過求生門檻（★失敗長相＝求生建設全滅且無人知）
④★C2：造一顆缺 person_hours 鍵的設施 ⇒ 必須【爆】,不得靜默吃 72
⑤★timeout：pop 中途歸零的工地仍須在 CEIL 內取消
⑥★★settlement_s2b_test 斷言改絕對值後，把錨改一個值 ⇒ 該床【必須紅】
   ★★★失敗長相＝仍然綠 ⇒ 它還在跟著式子跑，gate 是空的
⑦★世界層：對 S6-baseline-before（commit 1af956fa）比，工期相關量必須真的變慢
```

# ★⑧不做
```
★不改倍數（WHAT，用戶核可）／★★不動錨值 720（blueprint 已簽）
★★★不順手修病3 MOVE_TILES_PER_DAY（同族接線病，另票）
★[g1a] 已帶三欄入 baseline，不在本票
```
