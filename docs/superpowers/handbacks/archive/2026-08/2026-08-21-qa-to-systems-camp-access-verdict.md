---
from: qa
to: systems
slice: camp-access
status: consumed
topic: "[QA故事稽核:camp-access世界層正式判決]★join reject暴增(1→8)——code-read坐實機制是deterministic食力門檻(feed_ok=combined_days/ABSORBER_MIN_SURVIVE_DAYS,accept_util<門檻即拒),非隨機/非明顯bug;joiner側(team10等)行為連貫真實(pop=1餓死邊緣連續43天換多個目標猛投靠,非thrash);但host側狀態specimen沒錄到(host不在15隊抽樣名單內),無法用真數字證實genuine vs bug,建議下輪把join.accept_check這個既有tap(cap40,已在code但這輪沒dump)的內容印出來就能一次坐實;①②(root funnel/棄置率)specimen查無對應決策log(這兩類是背景反應式事件,不走候選陣列,跟breed/convoy同款architecture,判不了非specimen缺陷"
---

# QA 故事稽核：camp-access 世界層 — 正式判決

## ★③join reject暴增（最優先項）——機制查清楚了，但完整坐實仍差一塊

**code-read 坐實機制本身（`interaction_system.gd:1241-1269 _absorber_accepts`）**：
```
combined_days = (ef_absorber + ef_joiner) / ((pop_absorber+pop_joiner) × FOOD_PER_PERSON_PER_DAY)
feed_ok = clamp(combined_days / ABSORBER_MIN_SURVIVE_DAYS, 0, 1)
accept_util = (野心×0.6 + 統領×0.4) × feed_ok
接受 iff accept_util >= ACCEPT_UTIL_THRESHOLD
```
**這是 deterministic、食力驅動的門檻，不是隨機骰、字面上也看不出明顯 bug**——joiner 自己餓（`ef_joiner≈0`）會直接拖低 `combined_days`，若 host 自己也緊（peaceful_economy 這個世界很多隊食力本來就吃緊，前一輪 breed-deathcause 稽核已驗證過），`feed_ok` 很容易掉到 0，`accept_util` 隨之歸零 → 拒。

**joiner 側行為（specimen 直接讀得到）連貫、真實，非 thrash**：team10（`pop=1`，`effective_food` 大部分時間 `0.00`）從 tick10330 到 tick20700（**跨越約 43 天**）持續嘗試「投靠」，目標換過至少 6 個不同座標（`[11,9]→[10,8]→[10,10]→[10,8]→[8,10]（連續6次）→[9,8]→[8,6]（連續8次）`）——**這是一個瀕死團隊鍥而不捨地到處求收容，每次被拒就換下一個目標**，不是卡死單一目標、也不是算完 util 沒真切換（`result=committed` 一致）。team7/9/14/0/3/4 也各自出現過同款投靠嘗試（pop 從1到6都有）。**joiner 側的故事完全講得通：世界裡到處都有餓到快死、拚命找人收留的隊。**

**★缺的最後一塊**：host 側（team10 投靠目標所在座標，如 `[8,6]`、`[10,8]`）**不在這次 specimen 的 15 隊抽樣名單內**，我查了 tick18000-21000 這個窗口，沒有任何抽樣到的隊 `tile_pos` 落在 `[8,6]`——**沒辦法直接讀到 host 那一刻的 `effective_food`/`pop`，無法用真數字驗證 host 是不是真的也緊、拒絕合不合理**。

**★但有個現成的解法沒被用到**：`_absorber_accepts` 本身已經內建一個診斷 tap——`interaction_system.gd:1256-1259`：
```
Probe.bump_sample("join.accept_check", {"host":.., "joiner":.., "host_rep":.., "feed_ok":.., "accept_util":.., "accepted":..}, 40)
```
**這個 tap 逐筆記錄每次判定的 `feed_ok`/`accept_util`/是否接受，cap=40，已經在 code 裡、Probe-gated**——但這輪的 branch report（`camp-access-worldlayer-BRANCH-90d.txt`）沒有把它印出來（我 grep 過，零命中）。**下一輪只要在 bed 裡把這個 tap 的內容 dump 出來，就能一次直接看到每次拒絕當下的 `feed_ok` 數字，不需要猜、也不需要重建 host 側 specimen**——比起擴大 specimen 涵蓋範圍，這是更便宜、更直接的驗證路徑。

**verdict（目前信心）**：機制本身**沒有明顯 bug 嫌疑**（deterministic、食力驅動、跟世界整體食力吃緊的背景一致），joiner 側行為**genuine**（真的在到處求生，非決策盲派）。但「這次 8 個拒絕是不是每一個都合理」**沒有 `join.accept_check` 數字撐，只能說『機制合理、方向可信』，不能說『每筆都驗證過』**——建議下輪補這個 tap 的 dump 就能徹底結案。

## ①②（紮根funnel / 棄置率）——specimen 裡查無對應決策 log，判不了

搜尋 specimen 全檔的「紮營」「擴建」「establish」「crude_camp」等字樣——**全部零命中**。跟 breed（生育）、convoy（車隊）之前查到的架構一致：**settlement/camp 這類事件是背景反應式系統驅動（scripted reaction，非 AI 決策候選引擎），本來就不會出現在「做什麼/想什麼」這個 tracer 抓的資料格式裡**。這不是這次 specimen 的缺陷（不是漏抓），是這類事件的性質本來就在這個 tracer 的觀測範圍外——跟 convoy porter 的移動、breed 的繁殖事件同一種「background reaction 不過 AI 候選引擎」架構。**①②這兩條我判不了，不是 specimen 壞了，是問錯層——要驗這兩條需要另一種 tap（像 `[PopMgmt]`/`[Merge]` 那種 print 或?專屬 Probe），非本輪 specimen 能覆蓋。**

## 建議

1. **join reject**：下輪把 `join.accept_check`（已存在的 code tap，cap=40）dump 出來即可一次坐實，不需要重跑或擴大 specimen 範圍——這是最省成本的路徑。
2. **①②**：若真要故事驗證，需要專屬的 settlement/camp 事件 tap（不是 specimen 的候選陣列），交 systems/measurer 判是否值得開一輪。

地基 KEEP。
