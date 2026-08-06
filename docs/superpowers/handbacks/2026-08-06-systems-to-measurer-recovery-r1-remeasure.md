---
from: systems
to: measurer
status: open
topic: "[重量 recovery-r1(執行層 arrived 修後、feat/recovery-r1 commit 14203b57)·systems R² merge-gate CLEAN(核 _tick_migrant 直接 move_target=target.tile_pos 靜態 own-faction 鏡射 convoy/settle、棄 predict_intercept 錯工具、determinism byte-identical FCE1BAC4 去 RNG 更乾淨、r1_test 8/8 含驗執行端 pop2→5 併入、constitution 74)·★決策層三態上輪已 CONFIRMED(plains+0.17→3/3 dispatched/mountain−2.24→0)、本輪補執行層真效果+forest 樣本·量(沿用你 deb10640 bed+cluster_pos anchor=player_pos 傳 lord tile 讓隊 near→hourly vision→belief populate):①★migrant.arrived>0(執行層修證:plains 欠人村真收到 migrant→AnonTierSystem 併入→target village pop 真升)②三態全譜:plains 派+抵達 pop 升/forest(marginal−1.30 負)不派/mountain(−2.24 負)不派——forest 樣本上輪沒捕到、本輪確認 forest 也 0 dispatched(補全三態)③分化:plains 村獲移民回補真站起來 vs forest/mountain 不獲(命運由地不由腳本)·★禁靜態斷言 dump 真 per-target migrant.marginal/mini_util+arrived 計數·避 warring perf、落地 docs/measurements/·回 systems→QA→merge·地基 KEEP"
---

# 重量 recovery-r1（執行層 arrived 修後）

feat/recovery-r1 commit `14203b57`。**systems R² merge-gate CLEAN**（核 `_tick_migrant` 直接 `move_target=target.tile_pos`（靜態 own-faction、鏡射 convoy/settle）、棄 predict_intercept 錯工具；determinism byte-identical `FCE1BAC4`（去 RNG 更乾淨）；r1_test 8/8 含**驗執行端 pop2→5 併入**；constitution 74）。

## 量（沿用你 `deb10640` bed + cluster_pos anchor）
★決策層三態**上輪已 CONFIRMED**（plains +0.17 → 3/3 dispatched / mountain −2.24 → 0）。本輪補**執行層真效果 + forest 樣本**：
1. ★**`migrant.arrived>0`**（執行層修證）：plains 欠人村**真收到 migrant** → `AnonTierSystem` 併入 → **target village pop 真升**。
2. **三態全譜**：plains 派+抵達 pop 升 / forest（marginal −1.30 負）不派 / mountain（−2.24 負）不派——forest 樣本上輪沒捕到、本輪**確認 forest 也 0 dispatched**（補全三態）。
3. **分化**：plains 村獲移民回補真站起來 vs forest/mountain 不獲（命運由地不由腳本）。

## 守 / 序
- ★禁靜態斷言、dump 真 per-target `migrant.marginal`/`mini_util` + `arrived` 計數。
- 避 warring perf。落地 `docs/measurements/`。回 systems → QA → merge。地基 KEEP。
