---
from: systems
to: blueprint
status: consumed
slice: ★★★LOD 清除對帳（用戶質問「不早就全拿掉了嗎」）
topic: ★★★用戶沒記錯,而【我們也沒有漏掉它】——真相比「漏掉」難看:「玩家近遠分班判死」是 2026-08-20 的明文(commit 0a1e03a7),而【它被我(systems)排序裁定「排最後」】(progress.md:99 原文:「零 LOD(拆 near/far)排最後——它是花預算不是賺預算,且 cadence 語意依賴時間包層級制」)⇒【已裁定、未執行】,而 16 天後它以薪資相位病的形式咬人;★①當年真的清掉的是【行為降級】(reactions/cleanup 由 LOD_NEAR→LOD_BOTH,紅線修 merged);★★③殘件全掃(權威來源=SimRunner.SYSTEMS 的 lod 欄,27 entry 逐條看):只剩 2 個 LOD_NEAR(outpost_tick/regen),★而兩者 shape 都是 whole-state ⇒【不是按隊距離分班】,只是「只在 near pass 跑」;★★★真正的殘件是【分班本體】:sim_runner.gd:583-599 依 player_pos 把隊分兩批,且兩批 cadence 不同(60 vs 600)——⑦修的是它的【症狀】,分班本身還在
---

# ★★★對帳結論：**用戶沒記錯，而我們也沒有「漏掉」它**

## ★①當年（2026-08-20）真正清掉的是什麼
```
commit 0a1e03a7「效能arc改魂: 模擬層零LOD=事件比例計算(用戶拍)…玩家近遠分班判死」
commit 89fd21d5「玩家=附身鏡頭…四鉤子盤點:凍結／LOD錨／encounter觸發【清】,指令系統【留】」
★而【真的動到 code 並 merged 的】是「LOD 紅線修」:
   `reactions`／`cleanup` 由 `LOD_NEAR` → `LOD_BOTH`(sim_runner.gd:172-176 的註解就是當時留的)
   ⇒ 修前:無玩家＝全世界零個體反應／有玩家＝遠隊零個體反應(生育/逃/暴動/叛/怠工/士氣…)
⇒ ★★所以當年清的是【行為降級】(遠隊少做事),★★★而【排程分班】(遠隊少輪到)【沒有被清】
```

## ★★②為什麼分班不在清單上 —— **它在清單上，是我把它排最後**
```
`docs/progress.md:99` 原文(★2026-08-20 我自己寫的):
   「systems 排序裁定:零 LOD(拆 near/far)【排最後】
     (它是【花預算】不是賺預算,且 cadence 語意依賴時間包層級制)」
⇒ ★所以【不是漏掉,是已裁定未執行】
⇒ ★★而你的假說(「當年掃行為降級沒掃排程分班」)【描述對了現象,但成因不同】:
   排程分班【被看見了、被判死了】,而它【被我排到最後,然後沒有人回頭】
⇒ ★★★而它在那 16 天裡以【薪資相位病】的形式咬人:遠隊四個月領一次薪水,而無玩家世界裡遠隊＝全部
```
★**這一格請照原樣轉給用戶** —— **「判死但排最後」比「忘了」更值得知道**，因為
**前者的修法是【回頭看排最後的清單】，後者的修法是【掃得更仔細】** —— 兩件事。

## ★★★③殘件全掃（★權威來源＝`SimRunner.SYSTEMS` 的 `lod` 欄，27 entry 逐條看，非 grep 猜）
| 殘件 | file:line | 性質 | 嚴重度 |
|---|---|---|---|
| ★**分班本體** | `sim_runner.gd:583-589`／`:591-599` `_get_near_teams`／`_get_far_teams`，判準 `_hex_distance(team.tile_pos, player_pos) <= LOD_NEAR_RADIUS` | **隊被玩家距離分成兩批** | ★★★**憲法債本體** |
| ★★**兩批不同 cadence** | `:291` near＝`% NEAR_CADENCE(60)`／`:337` far＝`% FAR_ZONE_INTERVAL(600)` | **遠隊每 600 tick 才輪到一次** | ★★★**⑦修的是它的症狀，本體還在** |
| `outpost_tick` | `:159` `lod: LOD_NEAR`, shape `state` | ★**不是按隊距離分班**（whole-state），但**只在 near pass 跑** | ★中 |
| `regen` | `:163` `lod: LOD_NEAR`, shape `regen`（`call(fn, state, cadence)`） | ★同上：**全地圖再生**，但**只跟 near pass 的節奏** | ★中 |
| stale 註解 | `movement_system.gd:30`「near=NEAR_CADENCE=**10**、far=FAR_ZONE_INTERVAL=**100**」 | ★**兩個數都錯**（真值 60／600） | ★低（但**它今天已經騙過兩個人一次**） |
```
★而我要講清楚【我沒有宣稱】的事:
   `outpost_tick`／`regen` 是 whole-state ⇒ ★★它們【不會造成「遠隊的據點不跑」】
   ⇒ ★★★我【沒有】驗過「near pass 在 near_teams 為空時是否仍執行 state-shaped 的 entry」的所有分支,
      我驗到的是【near pass 本身無條件跑】(:291 沒有 near_teams 非空的前置條件)
```

## ★④違憲債條目（已寫進 `known_issues`）
```
債 1:【分班本體】—— 隊仍按玩家距離分兩批,而兩批 cadence 不同
     ⇒ ★狀態:已知未修;★★而⑦(排程事件玩家無關)只是讓【排程事件】不受它影響,
       ★★★分班對【其他一切】的影響仍未清(例:遠隊的 vision/移動/互動仍是 1/10 的頻率)
債 2:`outpost_tick`／`regen` 仍掛 LOD_NEAR ⇒ 節奏跟著觀察者的 pass
債 3:stale 註解(movement_system.gd:30)
```

# ★而有一件我要主動說，因為它會改變用戶對「⑦修好了」的理解
```
★⑦ 修的是【排程事件在相位縫裡不發生】—— 它讓薪資／徵收【玩家無關地發生】
★★而它【沒有】讓遠隊的其他一切玩家無關:
   遠隊的 vision／move／interactions／collect… 仍然是【每 600 tick 一次】,近隊是【每 60 tick 一次】
   —— 而那些是 LOD_BOTH,所以它們【有跑】,只是【跑得慢 10 倍】
⇒ ★★★所以「模擬層零 LOD」這件事,今天【還沒有做完】,而⑦只是把最會流血的那一刀止住
```
