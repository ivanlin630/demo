# HOW spec：把【每小時全隊一起想】錯開 —— ★主詞已經點名了

owner: systems ｜ 2026-09-10 ｜ **WHAT 授權**：blueprint 裁（接受世界改變）
上游：量測員 frame-time 卷（spike 中位數 7.78s／max 26.65s／每小時固定／隨隊數惡化）

---

## ① ★★★主詞（★blueprint 要的「點名」，兩半都找到了）

```
【同批到期點】sim_runner.gd:315
    if state.world.current_tick % NEAR_CADENCE == 0:      # NEAR_CADENCE = TICKS_PER_HOUR = 60
        var all_teams: Array = state.teams.keys()
    ⇒ ★這【不是】某支排程忘了錯開 —— 它根本【沒有 per-team 排程】，
      是一個【全域閘】：每 60 tick，全世界一起做。
    ⇒ ★★所以「同批到期」不是巧合，是設計如此（第⑧票拆掉 near/far 分班時
      刻意取 60「讓近隊行為完全不變」——★那個決定是對的，而它的代價就是這個 spike）。

【主兇子相位】`loop2.solo`（量測員從既有 log 撈出 `[FaiPhase]`，不重跑）
    2160 筆 spike 裡 ★1814 筆（84%）它排第一名；佔 total 比例中位數 ★52.7%（24.5-79.4%）
    次要：`unified.rank` 178 次（8.2%）／`loop1.factions` 149 次（6.9%）
    位置：faction_ai_system.gd:953 `for tid in state.teams:` … :971 `_fai_pht("loop2.solo", _ts)`
```

⇒ ★**修法的主詞 ＝「每小時、全體、同時」的那個【思考迴圈】**，不是整個 near pass。

---

## ② 修法：**用既有的 `CadenceStagger`**（★不是造新東西）

```
`scripts/simulation/cadence_stagger.gd`（2026-08-27，已用在 10+ 個排程點）
  ①打散：offset 由 team_id 經【混合函式】導出（★不直接 `%`）
  ②★輪轉：offset 逐 cycle 變化 ⇒ 長期沒有人固定排在前面
  ★★（②不可省：固定終身的 offset 會讓「誰抽到好位置」**複利成優勢** ——
     早想的隊先搶資源、雪球。★★★blueprint 已據此修訂護欄②：**輪轉 > 固定相位**。）
  ③MIN_GAP 由 cadence 導出（`/2`），wrap 邊界 clamp ⇒ 同隊相鄰思考間隔不會塌成 1 tick
  ④零 RNG、`cycle_index` 是 `current_tick` 的純函式
```

**做法**：

```
①給每隊一個 `solo_think_next_tick`（沿用既有 `*_eval_next_tick` 的命名與形狀）
②`loop2.solo` 那一段從【全體無條件跑】改成【到期才跑】：
     if state.world.current_tick < team.solo_think_next_tick: continue
     team.solo_think_next_tick = CadenceStagger.next_tick(<tick>, <team_id>, NEAR_CADENCE, <last>)
③★**只動這一段**（以及視結果決定要不要動 `unified.rank`）——
  ★★**不要把整個 `% NEAR_CADENCE` 全域閘改掉**：那個閘還管著 forced_event 超時、
    視野、移動等等，★★★動它＝一次改很多件事，歸因不了（第⑧票的教訓逐字適用）。
```

★**護欄（blueprint，逐條落實）**：

```
①T0 瞬醒【不受相位影響】：緊急事件（被襲／情報／餓線）照舊即刻 ——
  ★錯開只動【排程 pass】，不動事件驅動路徑（不變量 #2 原文）。
  ⇒ 實作要點：到期判斷放在 cadence 分支，★★不得包住既有的 `_decision_crisis` 早退路徑。
②★★相位是【中性事實】，但**禁任何系統【讀相位】做決策**（＝新 god-view）。
  ⇒ **可檢查的做法**：相位／到期計算收成單一入口，
    ★★★裸掃它的呼叫點 —— 除了排程器之外任何消費者 ⇒ **具名紅**。
③fp 基準全部重取；跨 HEAD 的 fp 不可引用（照舊）。
```

---

## ③ 驗收（★儀器【已經存在】，這一格是今天最便宜的一次）

| # | 格 | 判準 |
|---|---|---|
| ① | **★最壞單 tick 掉下來** | 同窗同 config 前後對照：spike **中位數／p95／max** —— ★★**主詞是 max**（可慢不可卡），avg 只當背景 |
| ② | **★★★總吞吐不變** | `sim_runner.gd:317-321` **已經有一個 tap**：`pass.byteam.%04d`（「每隊真的被排進這個 pass 幾次」）⇒ 錯開後每隊的**次數必須與錯開前相同**；★**這一格就是「不是用少做事換不卡」的守衛**，而它不必新寫 |
| ③ | **成對對照** | 把錯開關掉（強制所有隊同 tick 到期）⇒ ①必須回到 26 秒量級；★沒有這格，①的綠證明不了是錯開造成的 |
| ④ | **T0 沒被拖慢** | 構造一個緊急事件（被襲／餓線）⇒ ★該隊**當 tick**就反應，不等它的相位 |
| ⑤ | **★★沒有人讀相位** | 裸掃相位計算的呼叫點 ⇒ 排程器以外零消費者（具名紅） |
| ⑥ | **公平性** | 逐隊統計「在整個窗裡的思考次數」與「首次思考 tick」⇒ ★★★**不得與 team_id 單調相關**（輪轉那一層若失效，這格會看得出來） |
| ⑦ | **fp** | ★會變（世界改變是裁定接受的）⇒ 附歸因；★★而【同 seed 兩跑仍須相同】（決定論沒被打壞，沿用今天那張的窗：43200 tick／30 天／warring） |

★**誠實限**：①③在**同一組窗＋同一個 config** 上比才有意義
（★★今天剛立的三軸：tick 數／遊戲天／規模）。

---

## ④ 風險

```
①★錯開後【同一小時內誰先想】變了 ⇒ 世界改變（★裁定已接受）。
②★★`unified.rank`（8.2%）與 `loop1.factions`（6.9%）**本票先不動** ——
  ⇒ 先看 `loop2.solo` 錯開之後 spike 掉到哪，★★★**再決定要不要繼續切**：
    **一次切一個，否則歸因不了**（同 §②③ 的理由）。
③★★★`MIN_GAP` 的 wrap 行為在 `NEAR_CADENCE=60` 這種小 cadence 上要特別看：
  ★`MIN_GAP = 60/2 = 30` ⇒ 同隊最短間隔 30 tick ＝ 半小時，
  ⇒ **這代表某些隊在某些 cycle 會【一小時想兩次】或【兩小時想一次】** ——
    ★★而那是 CadenceStagger 的既有設計（wrap 是模數輪轉的內在性質，只能夾住後果）
    ⇒ **要在交件裡把它的實際分布印出來**，不要假設它均勻。
```

---

## ⑤ 這張票【不做】

```
①不改 `NEAR_CADENCE` 這個值（★改它＝改世界節奏，不是效能修法）
②不動 `% NEAR_CADENCE` 那個全域閘的其餘用途
③不動 T0 事件驅動路徑
④★不順手切 `unified.rank`／`loop1.factions`（見風險②）
```
