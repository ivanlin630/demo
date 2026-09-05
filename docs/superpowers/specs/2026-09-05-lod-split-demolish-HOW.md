# HOW spec（草案；★待 R²）— **拆掉 near/far 分班本體**（第⑧票，★憲法債清償）

WHAT／裁定：blueprint 2026-09-05 —— **當年「排最後」的兩個理由都已消滅**
（①「花預算不賺預算」⇒ **它現在正在燒錢**：薪資相位病 ＋ B 議程整包證據作廢；②「依賴時間包層級制」⇒ **層級制已落地**）。
★**而 ⑦ 只治了症狀**（讓**排程事件**玩家無關），**分班本體還在**。

## §1 現況（★file:line，今天對帳過）
```
sim_runner.gd:583-589  _get_near_teams:  _hex_distance(team.tile_pos, player_pos) <= LOD_NEAR_RADIUS
sim_runner.gd:591-599  _get_far_teams :  同判準取反
sim_runner.gd:291      near pass = tick % NEAR_CADENCE(60)  == 0   → _run_systems(near_teams, 60, is_near=true)
sim_runner.gd:337      far  pass = tick % FAR_ZONE_INTERVAL(600) == 0 → _run_systems(far_teams, 600, is_near=false)
sim_runner.gd:222      if int(sys["lod"]) == LOD_NEAR and not is_near: continue
★而 27 個 SYSTEMS entry 裡只剩 2 個 LOD_NEAR:outpost_tick(:159)／regen(:163)——兩者 shape 皆 whole-state
```
⇒ ★**後果（今天已坐實一項）**：遠隊的 `vision`／`move`／`interactions`／`collect`… **有跑，但慢 10 倍**。

## §2 ★★★動作（我裁的形狀）：**單一 cadence，不是「事件密度」**
```
★①刪 `_get_near_teams`／`_get_far_teams` 與 far pass ⇒ 全世界【一個 pass、一個 cadence】
★★②cadence 取【現行 near 的 60】——★理由:它是【現在近隊已經在跑的值】,
    ⇒ 選它 ⇒ 近隊【行為完全不變】,而遠隊【補回到與近隊相同】
    ⇒ ★★★而【不要】取一個折衷值(例如 200):那會讓【近隊也變】⇒ 一次改兩件事,歸因不了
★③兩個 whole-state 的 LOD_NEAR(outpost_tick／regen)⇒ 改 LOD_BOTH(分班沒了,LOD_NEAR 這個概念也沒了)
   ⇒ ★連 `LOD_NEAR`／`LOD_FAR` 常數與 :222 那個 continue 一起退場
★④`force_full_hd` 旗標:★它的語意本來就是「全 near」⇒ 拆完之後它【等於預設】
   ⇒ ★★退場,而【退場要留反向斷言】(照「備戰」除名前例):有人重新引入分班會自動紅
```
### ★★而【事件密度計算】不在本票
```
憲法那句是【計算跟隨事件密度,不跟隨任何觀察者】—— 它有兩半
   ★前半「不跟隨觀察者」= 本票(拆分班)⇒ 憲法債清償
   ★★後半「跟隨事件密度」= 效能 arc(安靜地區便宜是【湧現】非裁判)⇒ ★★★不在本票
⇒ 而先做前半的理由:它讓後半有一個【乾淨的基準】(現在的基準被分班污染,近/遠是兩個世界)
```

## §3 ★★誠實的代價（★寫在動工前）
```
★遠隊的每 tick 工作量 ×10 ⇒ perf 一定變差,而【變多少要量不要猜】
   現況基準:64.2 ms/day(命令戳記誠實化後);起點 98.0 ms/day
★★而【perf 結果不擋 merge】:憲法已裁分班判死,perf 是【資訊】不是【否決權】
   ⇒ ★★★若超出可玩預算 ⇒ 【立刻開事件密度票】,而不是把分班放回去
★而前置量測要的是:近/遠隊數比例、單 pass 成本分佈 ⇒ 才知道 ×10 打在多大的母體上
```

## §4 驗收
| # | 判準 |
|---|---|
| 1 | ★**`player_pos` 不再出現在任何排程判斷裡**（★★窮盡搜索，`_hex_distance(..., player_pos)` 的呼叫點全列；★★★而 GUI／表現層的用法**不算**，要分開列不是混在一起） |
| 2 | ★★**同一世界內 per-team 的執行次數與距離無關** —— **沿用 ⑦ 的那張床**（`lod_phase_invariance_test.gd`），★★★但判準從「發薪次數」擴大到**至少三個不同系統**（例：`collect`／`interactions`／`vision`） |
| 3 | ★**鑑別力**：把這一刀撤掉，判準 2 的差距必須**回到 ~10×**（★★而不是「稍微變大」） |
| 4 | ★★**perf 前後對照**（同 seed 同床，wall/day ＋ 決策次數）——★★★**只報不否決**，且**若劣化 >2× 要具名回報 blueprint**（不是自己決定要不要繼續） |
| 5 | ★`fp` **會變且應該變**（遠隊開始正常跑）；determinism **三跑一致**（★★在**不會被編輯的樹**上跑） |
| 6 | ★★**反向斷言**：重新引入「按 `player_pos` 分批」會**自動紅**（照「備戰」除名前例）＋ 進 `merge-gates.tsv` |
| 7 | 全部 merge-gate（★含 `defer-open` 那支——本票落地後要**刪掉** `defers.tsv` 的相關行） |

## §5 不在範圍（★具名）
```
★①事件密度計算(憲法那句的後半)—— 效能 arc,本票只做前半
★★②`NEAR_CADENCE`(60) 這個【數值】—— 不動(動它＝一次改兩件事)
★★★③GUI／表現層的 LOD —— 憲法明文允許(鏡頭旁畫細＝表現非模擬)
★④`outpost_tick`／`regen` 的 cadence tier 歸屬 —— 本票只把它們從 LOD_NEAR 挪走;
   ★★而「它們該多久跑一次」是時間包層級制的問題,不是分班的問題
```
