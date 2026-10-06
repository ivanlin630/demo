---
from: measurer
to: qa
status: open
slice: 「玩家死後 7 天」specimen 重產（★開 Probe）＋驗觀測不改世界
topic: ★回應 systems 派工（`2026-10-06-systems-to-measurer-respecimen-probe-on-for-plunder.md`）：Probe 開著重產 specimen，已先驗證「觀測不改被觀測物」（A/B 兩輪逐位元組相同）才放行。重點更新：Team11 的掠奪不是 5 次離散事件，是 1 段連續 1044-tick 承諾；raid.composition 桶因 cap=150 被早期事件佔滿，答不到 Team11 那段。副本：systems（SendMessage 已敲）。
---

# 一、②先驗結果：觀測沒有改世界（逐位元組相同，放行）

```
PASS A（Probe=OFF／SpecimenTracer=OFF，對照）vs PASS B（Probe=ON／SpecimenTracer=OFF）：
  ·決策序列筆數：A=14400｜B=14400｜一致
  ·決策序列 hash（sha256，逐 tick 全隊 current_option 串接）：
    A=b438f3a6083c8ed90a0ecf3cffe141d5712df00a8e0983125feb4b01093d06d0
    B=b438f3a6083c8ed90a0ecf3cffe141d5712df00a8e0983125feb4b01093d06d0
    ⇒ 一致
  ·世界 fp（sha256，逐隊 tile_pos/population/task/option/priority/food/coin/material
    ＋ current_tick/game_over/game_over_reason）：
    A=b18952fc846e39e296644b9b7a414a582deb656cc0bb0bf932612d83caf40894
    B=b18952fc846e39e296644b9b7a414a582deb656cc0bb0bf932612d83caf40894
    ⇒ 一致
★★★結論：Probe 開／關兩輪逐位元組相同 ⇒ Probe 本身零 RNG、零世界副作用 ⇒ ★★★讀 code 的那份誠實限
  （只看過 `_cmp` 是字串拼接，沒量過）現在補上了量測那一半。
附加複查：PASS C（也開 SpecimenTracer）世界 fp 仍 == PASS A（true）⇒ 本輪沒看到 SpecimenTracer 自己另外動世界
  （它的中性早有 2026-07-28 regression 鎖，這只是順手複查，非初次證明）。
```

# 二、已落地 exact path（開檔驗過存在）

```
docs/measurements/player-death-7day.specimen.jsonl
  ·存在：是（1712 entries，較上一輪 1587 多——因 Probe 開著跑同一條世界軌跡，
   SpecimenTracer 本身捕捉到的事件數隨決策內容略增，世界本身 byte-identical 已驗證）
  ·注意：*.specimen.jsonl 在 .gitignore（既有慣例），本機 docs/measurements/ 下讀
```

# 三、樹／種子／母體邊界

```
·樹：commit 636deb4c0（已 push origin/main，≥ 要求的 a97946412）
  （床：scripts/debug/player_death_7day_specimen.gd，零碰 scripts/simulation|data/*.gd）
·種子：1337｜母體：Team15（原玩家隊）＋ Team11／Team3／Team16（最近鄰 3 隊）
·時窗：殺玩家後 7 天（tick 4320→14400），殺前先推 3 天暖身（tick 0→4320）
```

# 四、③raid.composition 桶（四欄「真的出現」）＋★重要糾正

```
·桶內 150 筆（cap=150，已滿）。抽 8 筆樣（全部 opt=掠奪，drive/after_weight/after_coeff/final）：
    #0~4,6,7：drive=0/after_weight=0/after_coeff=0/final=0（該隊當下沒有掠奪驅力）
    #5     ：drive=0/after_weight=0.004/after_coeff=0.002/final=0.002（★非零，證明四欄真的在動，
             不是恆零的死 tap）
·★誠實限（production 現狀，非本床能改）：`_cmp` dict 沒有 team_id／tick 欄位，桶裡 150 筆**不能**
  逐筆對應「哪支隊、哪個 tick」。而且 `bump_sample` 是 first-N cap（禁 reservoir，零 RNG 設計）⇒
  ★★★這 150 筆**結構上必然是全程最早出現的 150 次「掠奪」評估**，不可能包含 Team11 在本輪的那段
  （tick 13357 起，接近尾端）——cap 設計本身就會把晚發生的事件排除在外，這不是 bug，是這支儀器
  目前的形狀；要讀到晚期特定隊的 composition，現有 raid.composition 桶答不到，需要另一個 per-team
  或 per-window 的 tap（交 systems 判要不要開）。

·★★★糾正 systems 信裡「Team11 那 5 次掠奪」的描述：我自己追蹤的決策序列（讀 current_option，
  零碰 production）顯示 Team11 不是 5 次離散掠奪，是**一段連續 1044 tick 的單一承諾**（tick
  13357 → 14400，一路持守到窗期結束，沒有中斷）。這對應「持守統一」的承諾慣性機制（current_option
  黏滯），不是反覆出兵。
·★但 specimen trace 本身（非 Probe）在 tick=13357 捕到 Team11 承諾那一刻的完整「想什麼」：
  candidates 列出全部 option 的 util（掠奪=0.000932…），strategic_intent="防衛"/mode="hold"，
  threat_react=0.11，「做什麼」winner_opt=掠奪／task=掠奪 ——這比 Probe 桶更適合 QA 讀 motive→action，
  已在檔內，tick 13357 搜 `"team_id":11` 可見。
```

# 五、附加題：Team15（原玩家隊，補領袖票故事層驗證）

```
day｜tick｜leader_id｜population（day=第幾天，殺玩家在 day3 開頭）
 0 ｜ 1440｜41｜10
 1 ｜ 2880｜41｜10
 2 ｜ 4320｜41｜10   ← 死前一天
 3 ｜ 5760｜44｜ 6   ← 殺玩家當天：leader 換成 44（新領袖，非 -1）、population 6（非 1）
 4 ｜ 7200｜44｜ 6
 5 ｜ 8640｜44｜ 6
 6 ｜10080｜44｜ 6
 7 ｜11520｜44｜ 6
 8 ｜12960｜44｜ 6
 9 ｜14400｜44｜ 6

★確認補領袖票成立：有新領袖（44）、population 沒被切成 1。
★但 population 整整 7 天完全不變（6→6），逐隊 snapshot（population/tile_pos/task/food/coin/
material）比對過不是「全欄位凍結」（food/coin/task 有變化，只 population 沒變）——這是否「7 天零
人口變動」合理，是故事層問題，我不下結論，留 QA 判。
```

# 六、機械面

```
·無 SCRIPT ERROR / Parse Error，wrapper child exit=0。
·current_tick 如期 4320→14400（+10080）。
·無隊「population>0 且全欄位零變化」。
```

# 七、交件

```
·commit：636deb4c0（床：scripts/debug/player_death_7day_specimen.gd）
·床跑法：GODOT_TIMEOUT=1200 .\tools\godot.ps1 --headless --script scripts/debug/player_death_7day_specimen.gd
·SendMessage 已敲：qa（本封）＋ systems（副本，含②的驗證結果＋Team11 糾正）
```
