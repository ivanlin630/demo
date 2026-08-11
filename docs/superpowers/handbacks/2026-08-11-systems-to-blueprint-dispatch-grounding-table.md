---
from: systems
to: blueprint
status: open
topic: "[★統一派遣模型 grounding 表(用戶拍 B、code-read file:line 嚴謹=4 次錯教訓禁 inference)→餵你 spec·★核心發現:drain 只在 anon-messenger 那族(leaderless anon-alone→succession 誤升)、named-led dispatch()族已符 target(歸隊循環)、migrant permanent genuine=fix scope 窄(不是每 dispatch 都壞)·【DRAIN 點=leaderless anon-alone、succession 安全網 faction_ai:784 無 phantom guard 升 named→不歸隊 monotonic】:①scout _try_scout_side:2045→dispatch_anon_messenger:2062(info_scout、1anon、leader_id=-1)②care-scout _dispatch_care_scout:5110→:5137(info_scout、care-loop dormant)③rescue :5231(contact_rescue reuse scout)④herald _try_herald_side:2004→dispatch_anon_messenger(求援、1anon leaderless)·【target-compliant=named-led dispatch()、named sub_leader→非 leaderless→succession 不誤觸→merge 歸隊還 named+anon crew】:envoy _dispatch_envoy:1339/builder _dispatch_builder:3376,3452/settler:3590/convoy _dispatch_convoy:3633/facility-builder _dispatch_facility_builder:3737(皆 SubteamSystem.dispatch(sub_leader_id=named))·【permanent genuine】:migrant _try_migrant_side:1727→dispatch_anon_migrants(k anon 永久離、migrants 落地 target 村=設計 genuine 非 drain-bug)·★drain 機制證(code-read+既有 trace 非 re-run):leaderless messenger→faction_ai:784『if leader_id==-1: on_leader_death』無 subteam/phantom guard→下 tick succession『無 named→anon 晉升』(person_generator:103)→messenger 變 named 獨立團(trace Team4=P3002)→merge 也 named→anon 池不回補·★∴統一模型 fix 方向(你 spec、用戶 target 名帶匿+歸隊+機械升格除+湧現保留):選項(a)messenger dispatch 也走 named-led(給記名領隊、如 dispatch()、succession 不誤觸=結構解、但 1-anon scout 需借 spare named 領隊)vs(b)succession 安全網加 phantom/subteam guard(reason=info_scout/herald/contact_rescue 的 leaderless subteam 不升、讓 recall 歸隊還 anon)·湧現升格(領隊死接班/不爽脫隊)保留=genuine 事件另路非安全網機械·★output=此表·序:你 spec 統一模型(一套非每種補丁)→R①/R²(硬數據此表)→build F0 fp→re-measure 下游(relief/care/builder anon 漏光疑真根、修後量不預設)·地基 KEEP"
---

# ★統一派遣模型 grounding 表（code-read file:line、4 次錯教訓禁 inference）

## ★核心發現：fix scope 窄
drain 只在 **anon-messenger 那族**（leaderless anon-alone→succession 誤升）；named-led `dispatch()` 族已符 target（歸隊循環）；migrant permanent genuine。**不是每 dispatch 都壞**。

## 【DRAIN 點】leaderless anon-alone、succession 安全網 `faction_ai:784` 無 phantom guard 升 named→不歸隊 monotonic
| dispatch | site | manpower | spawn |
|---|---|---|---|
| scout | `_try_scout_side:2045`→:2062 | 1 anon、leader_id=-1 | dispatch_anon_messenger |
| care-scout | `_dispatch_care_scout:5110`→:5137 | 1 anon（care-loop dormant） | dispatch_anon_messenger |
| rescue | :5231 | 1 anon（contact_rescue reuse scout） | dispatch_anon_messenger |
| herald 求援 | `_try_herald_side:2004` | 1 anon、leader_id=-1 | dispatch_anon_messenger |

## 【target-compliant】named-led `dispatch()`（named sub_leader→非 leaderless→succession 不誤觸→merge 歸隊還 named+anon crew）
envoy `_dispatch_envoy:1339` / builder `_dispatch_builder:3376,3452` / settler:3590 / convoy `_dispatch_convoy:3633` / facility-builder `_dispatch_facility_builder:3737`（皆 `SubteamSystem.dispatch(sub_leader_id=named)`）。

## 【permanent genuine】
migrant `_try_migrant_side:1727`→dispatch_anon_migrants（k anon 永久離、落地 target 村=設計 genuine 非 drain-bug）。

## ★drain 機制證（code-read + 既有 trace、非 re-run）
leaderless messenger → `faction_ai:784 if leader_id==-1: on_leader_death` **無 subteam/phantom guard** → 下 tick succession「無 named→anon 晉升」（person_generator:103）→ messenger 變 named 獨立團（trace Team4=P3002）→ merge 也 named → anon 池不回補。

## ★統一模型 fix 方向（你 spec、用戶 target 名帶匿+歸隊+機械升格除+湧現保留）
- **(a)** messenger dispatch 也走 named-led（給記名領隊、如 dispatch()、succession 不誤觸=結構解；但 1-anon scout 需借 spare named 領隊）。
- **(b)** succession 安全網加 **phantom/subteam guard**（reason=info_scout/herald/contact_rescue 的 leaderless subteam 不升、讓 recall 歸隊還 anon）。
- 湧現升格（領隊死接班/不爽脫隊）保留=genuine 事件另路、非安全網機械。

序：你 spec 統一模型（一套非每種補丁）→ R①/R²（硬數據此表）→ build F0 fp → re-measure 下游（relief/care/builder anon 漏光疑真根、修後量不預設）。地基 KEEP。
