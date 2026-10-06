# 決策 tap 能對準「某一隊、某一段時間」（HOW，小票）

```
票源 ＝ 量測員 2026-10-06（`5b07829eb`）：`raid.composition` 是 first-N 桶（cap 150，`decision_engine.gd:461`），
  **被早期評估佔滿** ⇒ 答不到 Team11 那段**晚期**承諾（tick 13357 → 14400 連續持守）
基準樹 ＝ `60e4e2fd5`
序 ＝ 威脅欄之後（不擋用戶；它擋的是 QA 那個「設計還是缺陷」的判定）
```

## §0 為什麼這是缺陷不是「設計的必然」

```
first-N 是一個**取樣設計**，本身沒錯 ——
★但這支 tap 是**為了一個具體問題接上的**（藍圖裁 `848e2aaea` ②：Team11 掠奪 util 倒數第二卻勝出，合成怎麼蓋過排序）
⇒ 而它**結構上看不到那個問題發生的時刻** ⇒ ＝ 「沒接電的閘」的一種：寫好了、接上了、**視窗不含目標**
⇒ 加大 cap 不是解（多少才夠？下一個問題又在別的時刻）⇒ 解是**能對準**
```

## §1 做什麼（兩處，都只在 `Probe.enabled` 時有作用）

```
①`_cmp`（`decision_engine.gd:319`）多帶兩鍵：`team`（team_id）、`tick`
  ⇒ ★今天 `_cmp` 沒有這兩鍵 ⇒ 就算取到樣本也**分不出是哪一隊**
  ⇒ `rank_scored_ctx` 的 `state`／`team` 參數可能是 null ⇒ null 時寫 -1，**不准因此跳過不記**
②`Probe.bump_sample`（`scripts/debug/probe_stats.gd`）加一個**可選的取樣窗**：
  `static var sample_window: Dictionary = {}`  ⇒ `{ event: {"team": id 或 -1, "tick_min": a, "tick_max": b} }`
  ⇒ 有設窗的 event：只收落在窗內的樣本；沒設的照舊 first-N
  ⇒ ★形狀照同檔的 `sample_mute`（它已是「按 event 調整取樣」的先例），**不另發明一套**
  ⇒ ★★而被窗**擋掉了多少筆**要計數並能印（同 `sample_mute` 那條：靜音了什麼必須印在交件裡）
```

### ③（systems 2026-10-06 追加，派工後；★不重送 R²：同一機制的參數化，交件寫明）

```
真實需求：QA 讀 30 天觀察輪要分隊看 `construct.stall`／`construct.start`
  ⇒ `outpost_system.gd:379` 的 `construct.stall` 樣本隊伍鍵叫 **`"ct_id"`**（`:361` 的 `construct.start` 才叫 `"team"`）
  ⇒ 而且兩者都是 `bump_sample` **預設 cap 8**（同一個 first-N 病，更嚴重）
⇒ `sample_window` 的設定可選帶 `"team_key"`（預設 `"team"`）
⇒ ★不准把各處 bump_sample 統一改名成 `"team"` —— 那會動到一堆床讀的鍵名（爆炸半徑在讀的那端）
P5 對 `construct.stall` 設 `{"team": X, "team_key": "ct_id", …}` ⇒ 樣本全是那一隊
```

## §2 驗收（P）

```
P1 [★不改世界] Probe 開／關、設窗／不設窗，同 seed：決策序列 hash 與 fp **逐位元組相同**
   （量測員今天剛跑過同一種對照 ⇒ 照那個做法）
P2 [對得準] 設窗 {team: 11, tick 13350–13400} ⇒ `raid.composition` 的樣本**全部** team==11 且 tick 在窗內，且 ≥1 筆
   ★母體地板：那一段 Team11 真的在評估掠奪（印出它那段的 current_option）
P3 [擋掉多少要說] 同上一輪印「窗外擋掉 N 筆」且 N > 0（否則窗沒在作用）
P4 [沒設窗的照舊] 其他 composition 桶（attack／recon／shelter）樣本數與改前相同
```

## §3 之後

```
量測員設窗重產（同 seed 1337）⇒ QA 讀 Team11 承諾那一刻的四欄 ⇒ 判「設計還是缺陷」
★在那之前 QA 讀現有 specimen 時，要寫明「合成那一層這一份看不到」—— 不下「決策壞了」的結論（藍圖逐字）
```


## §4 ★★★藍圖票 B 併入（`2bde7dcfc`）：候選分數與 winner 不一致時，卷面要說為什麼 —— **第二階段，另一顆 commit、另送 R²**

```
藍圖 WHAT（逐字）：候選清單每一個 opt 要嘛可選、要嘛帶**機器可讀的 ineligible 原因**；
  winner ≠ argmax(util) 的那一行必須印出理由。沒有理由＝bug。
樣本：Team11 20 次決策 16 次 top＝*:location:delegate（util 1.05–1.10），winner＝駐守（0.23–0.35）；
  ＋Q-raid（util 最低的掠奪成 winner）—— 同一個判準失守
```

### ★我讀 code 得到的一個關鍵區分（先寫出來，因為它決定 B 是哪一種病）

```
`rank_scored_ctx` 回的是**按最終合成排序**的 `scored`，winner ＝ `scored[0]`（`decision_engine.gd:186` 等處）
⇒ 卷面上的「util」若是**原始 util**（合成前），那「winner ≠ argmax(util)」可能只是
  **合成層（持守加成／需求係數）把順序翻了** —— 那是設計，缺的是**卷面沒印哪一層翻的**
⇒ ★而另一種可能是**下游沒照 `scored[0]` 做**（例如 delegate 選項排第一、卻派不出人 ⇒ 換成別的）
  —— 那是「列的條件≠做的條件」＝ 票 A 的 (a) 出口，不是 B
⇒ ★★這一階段的第一件事是**分辨這兩種**，不是先寫理由字串
```

### 做什麼

```
B1 在 `rank_scored_ctx` 的**同一處**（合成完成、排序之後）：若 `scored[0]` 不是原始 util 最高的那個
   ⇒ 記一筆 `rank.flip`：{team, tick, winner, winner_raw, winner_final, raw_top, raw_top_raw, raw_top_final,
     flipped_by: 哪一層讓 raw_top 掉到 winner 之下（persist／coeff／need_weight…，取自既有四欄）}
   ★只讀已算好的值，不重算（不耗 RNG；同 §1 的紀律）
B2 ★先查（R² 請核）：`scored[0]` 之後有沒有任何下游**換掉** winner（dispatch 失敗、閒人不足、guard）
   ⇒ 有 ⇒ 那條路也要記一筆 `rank.override`：{原 winner, 實際做的, 原因}
   ⇒ ★若 Team11 的 16 筆落在 override 而不是 flip ⇒ 交票 A（列的條件要等於做的條件）
B3 ineligible：候選若因前提不足而不該被選 ⇒ **不列**，或列而帶 `ineligible: <原因>`（機器可讀 enum，不是自由文字）
   ⇒ ★範圍：本階段只做**記錄**，不改任何選擇行為（改行為是票 A 的事）
```

### 驗收

```
PB1 [不改世界] fp 與決策序列逐位元組不變（只加記錄）
PB2 [分得出兩種] seed 1337、30 天、窗對 Team11 ⇒ 那 16 次各自落在 flip 或 override，且每筆有 flipped_by／原因
    ★母體地板：16 筆都要有歸屬；落在「兩者皆非」的筆數 ＝ 0（判準庫：二分法的 else 吞掉第三格 —— 最後一格永遠是「以上皆非」並數它多大）
PB3 [負對照] 把 flip 偵測改成永遠不記 ⇒ PB2 必紅
```
