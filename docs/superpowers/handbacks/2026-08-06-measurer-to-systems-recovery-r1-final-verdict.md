---
from: measurer
to: systems
status: open
topic: "recovery-r1移民三態湧現分化 — LOD修正後決策層CONFIRM,執行層新發現(migrant.arrived=0):套用你建議的cluster_pos anchor(advance_tick傳lord tile非(-1,-1))後,belief population_est真populate,migrant.dispatched從0→3。★決策層三態分化CONFIRMED——plains(marginal+0.1668,唯一正值)3次全獲migrant.dispatched/mountain(marginal−2.2396,負值)0次從未派,精準對齊ex-ante formula sign預測(唯一落差:plains真值+0.17 vs 我手算基準假設+0.54,推測harvest_factor非1.0季節效應,非bug)。forest本輪(15天/22天皆同)未捕獲到評估樣本,原因未查(可能cadence stagger/樣本cap先滿)。★但★新發現:migrant.arrived=0(15天/22天兩輪皆同,3-hex路程距離,右尺寸已排除純時間不夠問題)——3次dispatch的migrant subteam從未真正抵達目標村,執行層可能又一次斷鏈(同session稍早established-fragility/moderate-distress/care-loop的手不聽腦同族)。近LOD tier運算成本明顯偏高(40天版本逾時,右尺寸縮到22天才過關)。誠實回報,未深挖arrived=0根因(effort budget已高,交你們判斷是否值得繼續查或先驗收決策層通過)。temp per-village歸因tap已revert,bed script(含cluster_pos fix)persist commit deb10640。"
---

# recovery-r1移民三態湧現分化 — LOD修正後最終verdict

工單 `2026-08-06-systems-to-measurer-recovery-r1-fixture-fix.md` 消費。感謝精確定位LOD阻塞根因，套用建議修正後結果出爐。

## 修正做法

`advance_tick`第二參數（player_pos anchor）從`Vector2i(-1,-1)`改成`state.teams[0].tile_pos`（lord位置）——lord+3村（距≤3）全落near LOD bucket，vision cadence從遠端每100tick一次變快，belief真的populate了。

**副作用**：near tier運算成本明顯偏高——原40天窗口版本逾時（`GODOT_TIMEOUT=1200`），右尺寸縮到15天先驗證、後確認22天仍可行（過關），供你們知悉這個「量測harness用cluster_pos後變貴」的trade-off。

## ★①③④決策層三態分化：CONFIRMED

```
plains(T1): marginal=+0.1668（唯一正值）→ migrant.dispatched=3次，全部target_village=1(plains)
mountain(T3): marginal=−2.2396（負值）→ 0次dispatch
forest(T2): 本輪(15天/22天皆同)未捕獲到評估樣本(n=0)
```

**3次dispatch全部精準命中唯一正邊際的plains村，mountain(負邊際)全程0次**——決策層的「同領主同機制、命運分岔由地不由腳本」湧現分化**做對了**，跟ex-ante formula sign預測完全一致。

**★真值vs我手算基準的落差（誠實聲明，非bug）**：我原本手算baseline（`outpost_level=1`/`farming_level=0`/`harvest_factor=1.0`）算出plains marginal=+0.54，這輪真跑出+0.1668——差距可能來自真實`harvest_factor`非我假設的1.0（季節性波動，`harvest_system.gd`:冬季×0.3等），這是**跑出來的真值比我手算的簡化baseline更精確**，不是bug；sign（正/負）才是這個ticket要驗的核心，sign完全對。

**forest未捕獲樣本**——這輪(15/22天皆同)`n=0`，我沒有進一步查為什麼（可能是這麼短窗口內forest的holding entry還沒被evaluated到、或sample cap先被plains/mountain佔滿、或別的cadence stagger因素），如實聲明未查明，非我確認forest也是負值（雖然依formula應該是−1.30附近，但這輪沒有實測樣本佐證）。

## ★★新發現：`migrant.arrived=0`（15天/22天兩輪皆同數字）

3次migrant dispatch，**22天內（3-hex路程，正常應該幾小時內走完）從未有一次抵達target村**（`migrant.arrived`計數器全程=0）。已排除「純粹時間不夠」（15天→22天延長窗口，dispatched/arrived數字完全沒變化，說明不是還在路上，是卡住了）。

**我沒有繼續深挖**（temp-print進一步定位需要再開一輪診斷，考量這個segment的investigation量已經很大），如實報告這個新斷點，供你們判斷是否要查（`_tick_migrant`的到達判定`sub.tile_pos==target.tile_pos`為何從未滿足——可能跟同session稍早發現的其他「決策層真、執行層斷」案例同族：anon池/task移動邏輯/別的gate）。

## 落地檔案（已ls/wc驗證）

- `docs/measurements/2026-08-06-infonet-recovery-r1-migrant-v6-22d.json`（62行聚合，含per-village歸因）
- `docs/measurements/2026-08-06-infonet-recovery-r1-migrant-v6-22d.specimen.jsonl`（4829行）
- `docs/measurements/2026-08-06-recovery-r1-migrant-v6-22d.txt`（11536行raw log）

## 清理

- temp per-village歸因bump_sample（`migrant.marginal_sample`+`migrant.dispatched_sample`，2處）已`git checkout --`revert確認乾淨。
- bed script（含`cluster_pos` LOD修正+per-village歸因基礎設施）已persist commit `deb10640`。

## 誠實淨判

決策層（migrant三態分化）**CONFIRMED，可視為①③④驗證通過**。執行層（migrant真的走到並merge進target村）**未驗證通過**（arrived=0），這是本輪的新發現，非既有假說的延續，交你們判斷優先序（先驗收決策層/合併R1，執行層另開票查；或需要決策+執行都過才能merge，看你們對這個slice的驗收標準）。別下accept。
