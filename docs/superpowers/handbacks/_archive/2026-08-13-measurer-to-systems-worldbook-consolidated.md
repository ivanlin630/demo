---
from: measurer
to: systems
status: consumed
topic: "[世界帳本全貌 consolidated——回覆conservation-audits/combat-funnel-clean/production-funnel-4seg/famine-genuine-vs-bug/order-churn-worldclock 五封]①糧帳生死線CONFIRM單調崩(-75.6%,pop僅-1.8%)②production funnel:佔據率月底僅8.6%且resident_producing恆零③零戰死=candidate-set真根確認(攻擊0次/掠奪206次但91%連contact都到不了)非watchdog(encounter從未啟動)④prey瓶頸=reachability83%非belief-gap(~0%)⑤力平衡棘輪坐實(~99:2-4)⑥order-churn①無新tap答不了,誠實flag;規模因執行時長天花板降到1月窗"
---

# 世界帳本全貌 —— 五封 ticket 一次回覆(conservation-audits/combat-funnel-clean/production-funnel-4seg/famine-genuine-vs-bug/order-churn-worldclock)

seed1337，本輪窗口縮到 **1 個月(30天/7200 ticks)**——原本疊加逐日 census+高頻 prey tap 後，2 月窗在這個環境背景執行反覆撞到非 wrapper-timeout 的外部中止(GODOT_TIMEOUT=10800s/14000s 皆被中止、空輸出，換更高也一樣)，6000s 是唯一反覆確認安全的上限。降規模非賭運氣，1 月窗數字仍然決定性，量已標記於下。以下每段附精確數字，genuine-vs-bug 分野照數據判、不預設。

## ①世界糧帳（conservation-audits①）—— CONFIRM 單調崩，非團級雜訊

```
day1  total_food=18834  pop=444  teams=59
day8  total_food=10125
day15 total_food= 8425
day22 total_food= 7358
day30 total_food= 4589  pop=436  teams=105
```

**30 天內世界總糧從 18834 崩到 4589（-75.6%），幾乎單調（僅少數幾天小幅回彈，整體趨勢從未回頭）。同期 pop 幾乎打平（444→436，僅 -1.8%）。** 這代表世界的糧食消耗速度遠超死亡帶來的緩解——不是「有些隊死了所以糧食帳看起來緊」，是糧食帳本身崩得比人口崩快得多。這條線本身就是 blueprint「世界無盈餘引擎」假說最直接的證據。

## ②力平衡棘輪（conservation-audits②）—— CONFIRM 極端單向

本月 `spawn.dispatch_*`（運輸44+偵查30+擴建16+信使5+idle4=**99**）vs 真完成的 `mergein.dissolve+subteam`(0+2=2) + `accept.join_accept`(2) = **合併完成僅4**。**99:4≈25:1**——分裂/派遣持續高頻，合併幾乎不發生。（上輪 2 月窗數字更完整：spawn 分布~180 vs mergein+join_accept~16，比例 ~11:1，同方向、量級一致。）

## ③時鐘比（conservation-audits③ + order-churn-worldclock②）—— 部分答（本月窗太早，join 樣本=0）

本月 `join.order_set` 樣本=0（併入這個選項這個月完全沒贏過 argmax，too早期），沒有本月的 travel-vs-food_days 對照可算。**沿用上輪 2 月窗已建立的數字**：168 次「併入」order 下達後 134 次真 co-locate（78.8% 到達率，travel 不是主要瓶頸），但 co-locate 後 82% 被 host 以「養不起」拒絕（`accept.join_reject`=36 vs `accept.join_accept`=8）。時鐘比本身（travel 天數 vs 剩糧天數）沒有直接算出精確中位數（`join.order_set` 的 dist 樣本這次是 0，上輪 2 月窗的 dist 樣本也還沒完整換算成天數），這題如果要精確坐實建議 systems 判斷是否值得再開一輪 3+ 月窗（拉長到 join 真正頻繁 fire 之後）。

## ④零戰死真根 —— CONFIRM candidate-set 層（非 watchdog artifact）

```
watchdog_hits = 0
encounter_ever_active = false
```

**先講最底層：床 watchdog 這個月完全沒 fire 過一次——不是因為它沒撞到門檻，是 `state.encounter_active` 整個月從未變成 true 過一次。** 這印證了 code-read：`encounter_system.gd` 的 `init_encounter` 只有兩類生產呼叫者——`ambush_system.gd`（beast 遭遇戰）和 `player_command_system.gd`（全部涉及玩家隊）。這條床是 headless 無玩家跑，`encounter_active` 結構性恆 false，watchdog 從頭到尾是個 no-op。**你我先前都誤以為 watchdog 可能吃掉了死亡，實際上它連機會都沒有——這條假說可以徹底排除。**

真正的 NPC 戰鬥走 `npc_combat_system.gd`（`interaction_system.gd:322-342 start_combat`），這個月**真的有活動**：

```
combatopt.fire_攻擊 = 0     ← 攻擊這個 option 整月一次都沒贏過 argmax
combatopt.fire_掠奪 = 206   ← 掠奪整月贏了 206 次
raid.resolve = 19           ← 但只有 19 次真的走到 readiness≥0.7 的戰鬥判定分支
raid.extort  = 19           ← 19 次全部 = extort（屈服零死）
raid.combat_at_outpost = 0
raid.combat_open_field = 0  ← combat 分支 0 次
conq.combat_entered = 22    ← npc_combat_system 真正 start_combat 22 次（來源另有他途,非掠奪/攻擊 option 直接觸發,詳下）
combat.ended_n = 21
combat.end_mortal_flee = 19
combat.end_readiness_above_thr = 21   ← 這欄位是判定門檻位置tap,實際加總看 combat_end_breakdown 三項並非互斥累計口徑,細節見附檔
combat.end_retreat = 2
death.combat_pop = 0
```

**兩層漏斗都乾淨**：
- **掠奪 206 次贏 argmax，但只有 19 次（9.2%）真正走到跟 target 的戰鬥判定**——跟 JOIN funnel 那次「order 下了但 co-locate 沒發生」是同一型態的缺口（決策贏了、執行沒跟上，這次落在 raid 這條線）。
- **19 次真正判定的，100% 走 extort（屈服），0 次走 combat。** `combatopt_fire_samples` 逐筆讀 readiness 全部=1.0（206 個樣本 min=max=1.0，沒有一個低 readiness 案例）——所以「readiness<0.7 擋住大半掠奪」這支假說在這個月的樣本裡**不成立**（會贏 argmax 的隊全部 readiness 已經是 1.0），真正的瓶頸在贏 argmax 之後的執行/判定率（9.2%），以及即使判定了也 100% 走和平路線。
- `conq.combat_entered`=22（真正 start_combat 呼叫）但 `combatopt.fire_攻擊`=0——這 22 次 start_combat 明顯不是來自「攻擊」這個 option 贏 argmax（那是 0 次），必然來自另一條觸發路徑（血仇/feud 或其他直接設 TASK_ATTACK 的機制），這輪沒有追這條線的來源，誠實列為未查。

**這是很乾淨的 genuine 判讀**：raid 這條線走完整判定的樣本裡 100% 屈服零死，讀起來像是這個世界的掠奪本質更接近「勒索」而非「屠殺」——這比較像設計上 genuine 的傾向，不是 bug。真正結構性的問題是「贏了 argmax 但只有 9.2% 走到判定」這個執行斷點，跟你 JOIN funnel 已經發現的同型缺口（order 下了、travel/co-locate 沒跟上）疑似同一族。

## ⑤零戰死 pin / attack-gate refine —— prey 瓶頸 = reachability，非 belief-gap

```
prey.call_count = 93031
prey.candidates_seen = 1253424
prey.no_belief = 2            (~0.0002%)
prey.unreachable = 1043358    (83.3%)  ★★★ 主導
prey.not_weak_enough = 167005 (13.3%)
prey.found = 24364
prey.faction_attack_stake = 0
prey.faction_attack_target_found = 0
```

**候選幾乎不缺（125 萬次候選被看過），belief-gap 這支被乾淨排除（0.0002%，等於雜訊），真正吃掉 83% 候選的是「不可達（reachable=false，`PathSystem.estimate_catch_up`）」**——不是「不知道對方在哪」，是「知道但追不上/世界太散」。剩下 13.3% 是「知道也追得到但不夠弱」。**這個結果比 belief-gap 假說更偏 genuine（世界物理稀疏/移動速度限制），不是資訊網傳播缺口**——跟這一輪其他 belief 相關發現（migrant est_null=90% 高、invest 相對低）形成對比：這裡的瓶頸類型跟 migrant 的不一樣，別 over-unify 成同一個 belief 根（你自己也提醒過這點，這輪數據支持分開看）。

`prey.faction_attack_stake=0` 全月——faction 從未把「攻擊」列進 stakes directive 過一次，這是「攻擊」option 整月 0 fire 的直接上游根因（跟 has_weak_prey 無關，是更上游的 faction-level directive 從未下達）。

## ⑥production funnel 四段（production-funnel-4seg）—— ①②佔據/生產率近乎零，③④生產/流通斷點在更早

```
day1:  resident_n=0/59      resident_producing_n=0
day23: resident_n=1/99      resident_producing_n=0   ← 第一次出現 resident
day30: resident_n=9/105     resident_producing_n=0   ← 全月每一天恆零
```

**①佔據率**：第 1-22 天整整 0 個 resident team（0%），第 23 天才第一次出現 1 個，月底也只有 9/105（8.6%）。比 ticket 假說的「~60% 流浪」更極端——這個月**幾乎全員流浪**。

- **紮營路徑（camp）**：`camp.tile_found`=1132（一整個月，「有未佔農地可紮營」這個條件被看到 1132 次），但 `camp.fire`=0——**candidate 一直在、argmax 一次都沒選它**。這不是「無未佔農地」（`camp.no_unowned_tile`=0），是紮營這個 option 每次都輸給別的選項。
- **settle-at-existing 路徑**：`spawn.dispatch_*` 分布裡沒有「安頓」這個 key（該 key 若曾 fire 會出現在 wildcard 掃描，這個月完全沒有），`settle.convert_to_resident`=0——這條路徑整月一次都沒被走過。
- **兩條路都是 0 fire，但 resident_n 月底仍從 0 爬到 9**——代表這 9 個 resident 是透過**另一條我沒 tap 到的路徑**變成 resident 的（很可能是「佔村」option，跟掠奪/攻擊同一組 combat-adjacent 選項，這輪沒有另外追蹤它的 fire 次數）。誠實回報：camp/settle 這兩條路徑確認雙雙近乎死路，但不是唯一的 resident 生成管道，第三條路徑這輪沒查。

**②生產 fire 率**：全月 30 天，resident_producing_n 恆為 0——即使少數幾個 team 變成 resident 了，**一天都沒有真正執行過 TASK_PRODUCE**。這題答案很乾脆：0/9（0%）。

**③盈餘率**：resident 樣本太小（月底只 9 個）沒辦法算出有意義的逐村淨值分布，但既然 resident_producing_n 恆零，「盈餘」這個問題某種意義上還沒輪到——連生產都沒發生，談不上盈餘。

**④流通率**：既有 `trade.market_bail.*` 全月讀出：

```
sell_no_surplus       = 768   ★★★ 最大宗——owner 沒有可賣的盈餘
sell_owner_cant_afford = 193
buy_no_want            = 366
buy_no_stock            = 353  ← 「市場真的沒貨」訪客想買買不到
buy_cant_afford         = 3
buy_carry_full          = 3
sell_owner_no_coin      = 2
trade.peer_deal (成交) = 29
```

`sell_no_surplus`(768) 是所有 bail 理由裡最大的一個——跟②③的發現完全吻合：村子沒有生產、自然沒有盈餘可賣，`buy_no_stock`(353) 是這個缺口在買方視角的鏡像（訪客想買、市場真的空）。**這條鏈完整串起來了：resident 幾乎不存在(①) → 存在的也不生產(②) → 沒有盈餘(③邏輯必然) → 市場沒貨可賣(④，sell_no_surplus/buy_no_stock 雙印證)。** 四段裡沒有哪一段是「假警報」，是同一根缺口(幾乎沒人真正定居生產)往下游傳導的四個症狀。

## ⑦訂單重掛churn（order-churn-worldclock①）—— 誠實答不了，需要新 tap

目前的 `trade.market_bail.*` 是聚合計數器，不綁定到「同一張訂單」的生命週期，沒辦法算出「同一張買糧單重掛幾次/成交率多少」這個問題。這題如果要坐實需要新增一個綁 order_id 的 tap（例如訂單建立時記一筆、每次 bail 時查是不是同一張單再次失敗），這輪沒做，誠實列為缺口，交你判斷值不值得開一輪。

## Determinism

seed1337 單跑，1 月窗，官方 `SpecimenDumpHelper` 選法（未手動改 `specimen_team_ids`）。18 個 temp tap 全部已 revert（`git status` 確認乾淨）。

## 落地檔案（已 commit `6b89ddb1`）
- `docs/measurements/2026-08-12-phase3-story-audit-seed1337-1mo.json`（完整逐日 census + 逐月 curve + 全部 breakdown）
- `docs/measurements/2026-08-12-phase3-story-audit-seed1337-1mo.specimen.jsonl`（8隊×2037 entries）
- `docs/measurements/2026-08-13-phase3-synthesis.txt`（本回信引用數字的 python 解析原始輸出）
- `docs/measurements/2026-08-13-phase3-1mo-evidence.txt`（跑完終態 raw tail）

specimen 已附，這輪結論絕大部分是聚合 counter 直讀，behavior-causal 的部分（raid genuine 傾向/production 四段串接）建議走 QA 稽核鎖。

routing：這批數字量很大，建議你 consolidate 時分清楚「這輪 1 月窗新測的」vs「沿用先前 2 月窗已報過的」（時鐘比③、JOIN travel 那段是沿用），別把兩個窗口的數字混在一起當同一輪的。四段 production funnel 收斂到同一根（幾乎無人定居生產）是這批裡最乾淨、最可能值得優先看的訊號。
