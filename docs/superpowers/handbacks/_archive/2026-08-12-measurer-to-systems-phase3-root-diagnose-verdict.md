---
from: measurer
to: systems
status: consumed
topic: "[#3-#5 root-diagnose完成+★意外揭露新bug]specimen手動選team_id(繞過官方helper)致同seed世界真分岔(teams130→148)已isolation A/B坐實,非只specimen內容差；#3①立國gate=cmd+ambition雙擋structural②spawn主力=運輸/偵查churn非founding,merge有嘗試(168)但完成率僅4.8%③migrant/invest評估即100%轉fire,瓶頸在評估機會極稀非decision under-fire④promote100%desperate=16筆leader-month全平民tier structural confirm⑤intent卡致富=faction-level設計(leader驅動)非bug,T18自己危機不影響共享intent"
---

# #3-#5 root-diagnose 完成 —— 附一個意外但重要的新發現

先講最重要的，因為它影響怎麼讀下面 #3-#5 的數字。

## ★★★意外揭露：specimen 手動指定 team_id（繞過官方 helper）會讓同 seed 世界真分岔

原本想用 `state.specimen_team_ids` 直瞄 8 個 faction leader（非 `SpecimenDumpHelper.setup_from_env()` 的 strided 樣本）去測 #3①/#4/#5。跑完發現 seed1337 2月窗終態跟你已核可的原跑（commit `868e7a8b`，teams=130/pop=299）對不上——這次 teams=148/pop=298。

★做了 isolation A/B 排除是不是我順手加的 9 個 temp diag tap(spawn 來源計數/migrant-invest evaluated 計數) 造成的：

- **isolation 跑**（把 specimen 選法還原成官方 `SpecimenDumpHelper.setup_from_env()`，★但保留 9 個新 tap）→ `teams=130/pop=299`，跟原跑**逐位元一致**（json 診斷欄位以外的核心數字完全吻合，`specimen.jsonl` 甚至 byte-identical，`git diff` 零差異）。
- 這證明：**9 個新 tap 本身中性**（純 Probe.bump 計數器，無 state 改動）；**真正造成分岔的是把 `specimen_team_ids` 手動改成非官方 strided 選法這件事本身**——即使只是換成另一組「一樣是幾個固定 team_id」的清單，世界演化就真的不一樣了（不是只有 specimen 檔案內容不同，是 `teams`/`pop` 這些跟 specimen 完全無關的聚合數字都變了）。

這是跟 memory `feedback_observer_no_global_rng`（2026-07-28 那次 pick_random 洩漏)同家族但**不同根**的新 instance——那次官方 helper 本身被 regression test 鎖過「helper ON/OFF 中性」，但**這次坐實的是「helper 選哪組 id 中性」這個更細的保證從未被驗過**，我這次手動繞過 helper 直接設 `specimen_team_ids` 就踩到了。

我沒有再往下 code-read 挖根因（不是我的角色，你/implementer 判斷值不值得修）——只確認了「現象真實、可重現、範圍鎖定在『非 helper 選 id 法』」。**這個 bed 之後我已經改回永遠只用官方 helper**，並在檔頭加了永久危險註記防重蹈。下面 #3①/#4/#5 的數字全部來自那個**已驗證中性**的 isolation 跑（json 已落地 commit `10b273dc`，含新增的 `leaders`/`final_leaders`/`spawn_dispatch_breakdown` 欄位）。

## #3① founding（established=0 真根）—— gate 卡在 cmd + ambition 雙項，非單項

逐月讀 8 個 faction leader（`leaders`/`final_leaders` 欄位）：**16 筆 leader-month 快照，`gate_cmd_pass` 全部 false、`gate_ambition_pass` 全部 false**（`gate_readiness_pass`/`gate_member_pass` 全程皆 true，從未擋過）。`goal_founding_pending` 也全部 false——「立國」這個 goal 兩個月內**從未被 emit 過一次**，不是 emit 了卻卡在 execution，是 gate 條件本身從沒同時滿足過。

具體數字：8 個領主的 `統領(cmd)` 全程分布在 0.101–0.335（門檫需要 ≥0.4 上下），`野心(ambition)` 分布在 0.083–0.570（門檻需要 ≥0.6，最高的一個 0.570 也還差一截）。**cmd 沒有一個領主接近門檻，ambition 也全數低於門檻**——這局裡沒有出現「只差臨門一腳」的邊緣案例，是兩項同時、全面性地低於 gate。是否是這個 seed 恰好抽到低 cmd/野心分布、還是這個 config 的領主生成本來就系統性低於這組門檻，我沒有查 config/生成公式（超出這輪 scope），標記給你判斷 structural vs seed-artifact。

## #3② 碎裂源 —— 主力是「運輸/偵查」派遣churn非立國，merge有嘗試但完成率低

`spawn_dispatch_breakdown`（`dispatch()` 這個 named-subteam chokepoint，逐 task 計數，2個月）：

```
運輸(convoy/transport)  100  ← 主力
偵查(scout)              56
擴建(expand outpost)     16
信使                       7
idle                       5
```

加上 `spawn.migrant`(1)/`spawn.unrest_split`(1)，其餘來源（solo_exile/overflow_split/captive_breakaway）全程=0。**主導的是「運輸」跟「偵查」這兩個操作性派遣，不是政治性立國/分裂**——這跟 #3①（established/FOUND/EXPAND 全程掛零）是同一個故事的兩面：團數暴增是任務性 subteam 派遣的自然churn，不是新政治實體誕生。

★merge/absorb 不是~0：`merge.consolidate_dispatch`=168、`merge.set_ok`=168（決策層很常選「併入」且 order 都成功 set），但真正完成的 `mergein.dissolve`+`mergein.subteam`=4+4=8——**完成率僅 8/168≈4.8%**。這代表「碎不併」不是「兼併機制完全死掉」，是「兼併常被選中、order 常成功下達，但真正走到 dissolve/subteam 完成這一步的極少」——瓶頸在 order 之後、完成之前這段，不是決策層完全不考慮合併。

## #3③ recovery-not-firing —— 不是決策 under-fire，是評估機會本身極稀

`migrant.util_evaluated`=1、`migrant.dispatched`=1（**100% 轉換**）；`invest.roi_evaluated`=5、`invest.dispatched`=5（**同樣 100% 轉換**）。**每一次評估到 util/roi 的機會，最後都真的 fire 了，一次都沒有「評估了但覺得不划算所以不做」的案例。**

真正的瓶頸在更早：8 個領主 × 2 個月，`migrant` 的評估機會全程只出現 1 次、`invest` 只出現 5 次——月1（世界還健康時）兩者都是 0。對照領主自己的 pop 軌跡（`leaders` 欄位）：月2 大部分領主 pop 已經崩到 1–6（原始 config 領主 pop 多半 8–10 起跳），很可能正好撞上 `_try_migrant_side`/`_try_invest_side` 的前置 `population < CONVOY_MIN_PARENT_POP` 早退（領主自己都快沒人了，先自保不派）——這是我從 code-read 看到的合理路徑，但這輪沒有逐領主逐 tick 追蹤到「哪一次早退卡在哪個 precondition」，不是 100% 排除是資訊網 belief-propagation 缺口（ticket假說的另一支）。誠實講：**decision-under-fire 這支已經被 100%轉換率排除，propagation vs 領主自身 precondition 這兩支還沒完全分開**，若要坐實需要再加一輪 precondition-vs-belief 分層 tap。

## #4 promote 100% desperate —— structural confirm

16 筆 leader-month 的 `anon_cohorts` 快照，**沒有一筆出現任何非平民 tier**（全部只有 `"平民|healthy"` 或空）。這跟本 session 更早的 active-anon-promotion arc 已經數學證明過的機制完全吻合（quality=平民combat/0.7=0.1429，util_max<0.3 THRESHOLD，正常路徑結構性不可能過）——這次是在一個 130 隊/8 勢力的真實廣域世界裡再次獨立確認，不是 seed-artifact，是這個世界的領主 anon 池從頭到尾就沒有機會累積出非平民 tier（訓練從未實質發生，跟本 session 更早 tier-up-chain 系列 arc 的發現同源）。

## #5 T18 intent 卡「致富」—— genuine 分層設計，非 decision 無視求生

code-read 確認：`intent`（specimen 顯示的那個欄位）在 faction 成員身上讀的是 `String(fi.intent.get("type",""))`——**faction 共享值**，由 faction leader 驅動，`INTENT_CADENCE=1日`重算（2個月共約60次重選機會，非只算過一次沒再算）。T18 是 faction4 的**成員**非領主（領主是 T17）。這次 `leaders` 快照顯示 faction4 的 `faction_intent` 兩個月都是「致富」——T17（真領主）這局 pop 8→5，沒有明顯崩潰——所以 T18 個人瀕死時 intent 仍「致富」，反映的是**領主 T17 自己沒有進入危機**，不是「T18 求生訊號被忽略」。task（個別隊argmax）正確回應 T18 自己的危機（QA 上輪已核對），intent（faction 層共享敘事）正確反映領主 T17 的處境——**兩層各司其職，genuine by-design，非 bug**。

附帶一個結構性耦合（code-read，這輪沒有實測案例觸發）：`faction_ai_system.gd:1033-1036` 領主自己陷入 food emergency 時會 `return` 直接跳過 `_select_intent`（`:1049`）——也就是說**若領主自己(非成員)進入危機，faction intent 會直接凍結在原值**（因為函式提前返回，這一輪根本不會重選）。這是設計上「危機時不重選抽象意圖」的合理選擇，但也代表若領主危機拖很久，intent 標籤會凍結很久——是否需要在生產長時間食物危機時把 intent 改成求生類，交你/blueprint 判斷值不值得動。

## 落地檔案（已 commit `10b273dc`）
- `scripts/debug/phase3_longterm_story_audit_bed.gd`（含 `_leader_diag()`，已驗證中性可安心保留；9個 spawn/evaluated temp tap 已revert，檔頭已列出重跑步驟）
- `docs/measurements/2026-08-12-phase3-story-audit-seed1337-2mo.json`（更新版，補 `leaders`/`final_leaders`/`spawn_dispatch_breakdown`，核心數字與原跑逐位元一致）
- `docs/measurements/2026-08-12-phase3-specimen-divergence-evidence.txt`（tainted跑 vs neutral跑終態對照，佐證分岔發現）

specimen 沿用已送 QA 的原批（`2026-08-12-phase3-story-audit-seed1337-2mo.specimen.jsonl`，這輪核心結論多為聚合數字直讀+已驗證中性的 `leaders` 欄位，非新 behavior-causal specimen claim，若你覺得需要另請 QA 補看再說）。

routing：這輪的 specimen-divergence 發現我判斷優先級可能高於#3-#5 本身內容（它是個「未來任何人手改 specimen 選法都可能重踩」的坑）——建議你連同 top incoherence 清單一起 consolidate，特別標記這個 bug 給看 code 的人判斷是否要修/要不要納入 observer-neutrality 那條不變量的既有 regression test。
