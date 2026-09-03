---
status: R² issues（三點已吸收，2026-09-03）
owner: systems
slice: own-camp-in-decision-model
what: blueprint 裁 2026-09-03 —— ★給腦補上「自己的營地」這個念頭（新病型：**腦裡沒有那個念頭**）
premise: ★控制場景床兩腿（母體各 30）＋結構搜索坐實，非推論
---

# ★①病（★兩腿都是量到的，不是推的）
```
腿A（站在自家 L0 營地＋已承諾紮根）：30/30 applicable → 30/30 贏 → ★30/30 真 dispatch
   ⇒ ★★銜接【本身沒問題】；「紮根 util 太低」這個方向【排除】
腿B（不在營地＋已承諾紮根）：30/30 not_applicable ⇒ 全部改選【紮營】，
   ★在【站著的那一格】重紮，move_target ＝ 自己現在的位置，committed 由紮根翻成紮營
★★★結構事實：`camp_team_id` 全樹 1 寫入（`faction_ai_system.gd:5811`）
   ／2 讀取（`harvest_system.gd:61` 衰敗歸屬、`state_fingerprint.gd:138`）
   ／清除 2 處（`harvest_system.gd:67` 衰敗、`outpost_system.gd:470` 升 L1）
   ⇒ ★決策路徑【零讀取】—— 沒有任何 ctx 欄位或 option 指向「我自己的營地」
```
⇒ ★★**「走回去」不是被擋掉，是【不存在於決策空間】。**
★★★**新病型（blueprint 立）**：**腦裡沒有那個念頭** —— **與【手不聽腦】外觀一模一樣（都是「他不回家」），
判別法＝【決策路徑零讀取】的結構讀**，而修法完全不同（前者修執行/派工，後者要新增一個被表徵的概念）。

# ★★②三件要做的（blueprint 定 WHAT）
```
①ctx 加 own-camp 欄位  ——★自身狀態＝self-knowledge，零 god-view（不違感知鐵律）
②紮根 option 的執行含【回自家營地】的移動腿 ——★★means-end 全鏈：承諾＝【去那裡做】，不是【站哪做哪】
③營地沒了（衰敗／被佔）→ 走【解承諾重秤】那條既有的路，★★★禁死旗
```

# ★★★③HOW（★三個接線點，逐個給形狀）
## (a) `own_camp_pos` 從哪裡來 —— **兩案，我傾向 A，交 R² 裁**
```
★案A（我傾向）：延伸 `OwnerOutpostIndex` 也索引 camp（owner→tile）
   ＋理由：★★它已經有 `epoch` 失效與 `shadow`/`shadow_check` 對帳機制 ——
     ★★★而「索引與真值漂掉」正是那套機制被造出來要抓的病，白拿
   －代價：多一份衍生狀態
★案B：在 `TeamData` 存 `camp_pos`，由既有的 1 寫 2 清三個站同步
   ＋便宜、零掃描；－★兩份真值可能漂，而【沒有現成的對帳機制】
⇒ ★兩案都【不得】在決策路徑上做全圖掃描（LOD／O(N²) 那條老帳）
```
## (b) 紮根 applicable／to_task
```
applicable：`can_settle_here or settle_resume_site != (-1,-1)` ★＋ `own_camp_pos != (-1,-1)`
to_task   ：★若不站在 own_camp_pos ⇒ 產生【移動到 own_camp_pos】的 task（走既有 to_task→try_set 那條路）
            ★★站上去之後，下一次評估自然落回腿A 已驗證的那條（30/30 fire）
```
## (c) 營地沒了 ⇒ 解承諾（★接既有路，不新增旗標）
```
既有路：`_detect_survival_stall`（`faction_ai_system.gd:6146-6172`）——
   `STALL_RESOLVING` / `STALL_STALLED` 兩支都是 `team.survival_committed_option = ""`
⇒ ★新增的失效條件走【同一個出口】：committed==紮根 且 own_camp_pos 失效 ⇒ 解承諾＋`Probe.bump`
★★禁：新增一個「camp_lost」布林旗標掛在 team 上（★★★死旗＝下一個人得記得清它）
```

# ④驗收（★判讀表寫在數字之前）
```
①控制場景床腿B 重跑（母體 ≥30）：★預期【走回去】——而若仍 30/30 原地重紮，是修法沒生效，不是世界性質
②★新增一腿 C：走到一半營地被衰敗清掉 ⇒ ★★必須【解承諾重秤】，不得卡在移動中
③`fp` 逐位元不變【不適用】（本刀改行為）——★改用：organic 床上 `camp` churn 的次數變化，原樣報不歸類
④★★陽性對照：把 own_camp 欄位改成恆 (-1,-1) ⇒ 腿B 必須退回「30/30 原地重紮」
```

# ★⑤與 camp churn 一族的關聯（blueprint 要求註明）
腿B 的「原地重紮營」**順帶解釋 camp churn**：★**人不回家 ⇒ 到處留下無主的舊營地** ——
★★而**「該格已有據點」正是 `can_settle_here` 的第二支支配子條件（42.9／77.8／53.8%）**
⇒ ★★★**兩者可能是同一個迴圈**：churn 製造的舊營地，回頭擋住 `can_settle_here`。
**本刀修好之後，那個比例應該下降** —— ★**列為觀察項，不列為驗收**（★★因為我沒有量過它們的因果，只量到共存）。


---

# ★★★⑥R² 三點吸收（reviewer 2026-09-03，★三點都改了 spec，其中一點是我不敢猜的那格）

## ①「延伸 `OwnerOutpostIndex`」——**延伸的是【機制】不是【同一張表】**
```
★reviewer 查 `_rebuild_owner_outpost`／`_oo_map`：outpost 與 camp 是【不同欄位】
   （`outpost_owner`/`outpost_level` vs `camp_team_id`/`camp_level`）⇒ ★★不能塞同一個 map
⇒ ★★★正解：建一張【同架構的姊妹索引】——自己的 `epoch`、自己的 3 個 chokepoint
⇒ 我原文寫「延伸」會被讀成「塞進同一張表」⇒ 措辭訂正：**複製那套機制，不是共用那張表**
```

## ★②我不敢猜的那格：**距離【已經】折進 util 了**
```
★reviewer 查 `rooting_drive` + `settle_eta_days` ⇒ ★★距離已折入
⇒ ★★★「橫跨全圖走回家」被既有 feasibility 機制自然壓低 —— **不是新風險**
⇒ 本刀【不需要】為它加任何東西（★而我先前把它列為未知，現在有 file:line 了）
```

## ★★★③churn 疑慮是真的，而 reviewer 找到具體漏洞
```
★「紮營」的 `applicable` 【沒有排除「已經有 own_camp_pos」】
⇒ ★★人走回家的半路被打斷 ⇒ 重秤 ⇒ 紮營贏過紮根 ⇒ **沿途一路重紮**
⇒ ★★★修法 ＝ 紮營 `applicable` 加 `own_camp_pos == (-1,-1)`
   —— **與當日稍早 `recamp-candidate-exclusion`（站在自己 L0 營地上不再把該格當紮營候選）是【同一家族的延伸】**
```
⇒ ★**所以本刀是【兩半】，缺一不可**：**給紮根念頭** ＋ **讓紮營在你已經有家時不要 fire**。
★★**而只做前一半會【看起來沒效】** —— 人會走一段、被打斷、就地紮營，數字上跟現在幾乎一樣。
