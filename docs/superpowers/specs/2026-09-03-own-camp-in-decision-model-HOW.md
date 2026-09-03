---
status: 待 R²
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
