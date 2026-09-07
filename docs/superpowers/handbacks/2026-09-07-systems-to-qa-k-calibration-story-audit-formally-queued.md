---
from: systems
to: qa
status: open
topic: ★正式排給你：**k 校驗的故事稽核**（0.1395 月週轉是 genuine 還是症狀）；★★★它掛著多久，**所有涉幣結論就降級多久**——這不是背景票
---

# 一、★問題（而它不是 aggregate 能回答的）
```
GENESIS_K = 2.0 的前提 vs 實測月週轉 0.1395 ⇒ ★差 14.3 倍
90 日 18 隊 ⇒ coin 流量 316 筆 ⇒ ★★每隊每月不到 0.6 筆
```
★**兩種可能在數字上長得一樣**：
```
(a) genuine：世界本來就低週轉（自給自足為主，貨幣只在邊際交易用）
(b) 症狀：撮合/分配還有東西沒通（★GATE-B local-only 撮合仍在 backlog＝嫌疑有名有姓）
⇒ ★★★aggregate 分不出來 —— 要讀 motive → action → outcome
```

# 二、★★具體嫌疑（給你取樣方向，★但這是待驗不是判決）
```
①想買的隊與有貨的隊【是不是根本沒站在同一格】（GATE-B local-only）
②implementer 揭的 day0 事實：herb/gem/ore_gold/ore_iron/ore_steel/weapon_melee_low
   從 day0 到 90d 比值都是 2.00 ⇒ ★★【它們從創世到 90 日沒有被任何交易碰過】
   ⇒ 若「低週轉」其實是「一整批物資從未進入經濟」⇒ 那是 (b) 而且成因具體
```

# 三、★★★為什麼它急
```
未結案前，任何 ⑨ 世界的量測卷面都必須帶「貨幣量未過校驗（±14× 待判）」
⇒ ★價格/成交/收入/財富分配類的結論【全部降級】，不得當定論餵 blueprint、不得鎖 spec
⇒ ★★而人口儀器卷、市場厚度窗後量測輪都跑在 ⑨ 世界上 —— 它們的涉幣格都會被這條壓著
```

# 四、交付
```
docs/process/verdicts/genesis-turnover-story-audit.measure.json
★met_check 就是這個檔名（token `genesis-k-calibration`）⇒ 請用這個名字，否則閘會一直說沒交付
★★而判決只要三選一：genuine ／ 症狀（附成因） ／ ★讀不出來（誠實第三態，也算交付）
```
