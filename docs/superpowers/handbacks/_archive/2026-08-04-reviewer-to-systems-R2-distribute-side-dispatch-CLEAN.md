---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN] distribute side-dispatch(症1雙端對稱完成)——①主argmax零改動親驗坐實:goal_resolver.gd:117 out.append_array(_distribute_candidates(...))跟:115 _deliver_candidates同款standalone append,移除不牽動frontier_candidates其他行,determinism-neutral;★順便確認上輪要求的:122-124舊god-view自辯comment已被訂正(『舊「讀本勢力自有居民deficit=合法god-view」自辯已被用戶資訊網arc否定』字面寫入,非只刪程式碼留矛盾說明,上輪要求真被聽進去);②mini-util genuine=reuse同一份_distribute_candidates util body(relief_term+coin_term)零改動,親比對跟distribute-descan輪讀過的公式逐字一致,只換觸發路徑非重新發明;③side-action邊界scope硬限:spec:7-10親讀確認『三型明列(herald/scout/distribute)+每新增型需blueprint sign-off』已正式寫進spec文字非我方要求後才補;④reuse點親驗:_try_herald_side(faction_ai_system.gd:1652)確認既有_try_X_side模板(throttle/need-gate/mini-util/Probe tap一致結構)給distribute抄同款不是即興;_dispatch_convoy(3311)/_has_inflight-like throttle既有機制在;⑤determinism/economy沿用;CLEAN→build續feat/info-network-whole→re-measure症1端到端(首次閉環)"
---

# R②判決：distribute side-dispatch（症1雙端side-action對稱完成）— CLEAN

## ①主argmax零改動——親驗坐實
親讀worktree `goal_resolver.gd:107-118`（`frontier_candidates`函式尾段）：`:117 out.append_array(_distribute_candidates(state, team, ctx, lv))`是跟`:115 out.append_array(_deliver_candidates(...))`**同款standalone append呼叫**——各自獨立一行、互不依賴中間變數。移除:117對:115跟函式其餘候選生成邏輯零影響，這個「移loser對主argmax中性」的claim結構上站得住，跟前一輪(Part2 side-action求援/偵察移出REGISTRY)驗證過的同款cleanliness一致。

## ★上輪要求的comment訂正——親驗確實被聽進去
上一輪(distribute de-scan)我要求implementer順手訂正`:122-123`那段舊god-view自我辯護comment，不能只刪程式碼留矛盾說明文字。這輪親讀`:120-124`確認：

> ★感知鐵律（資訊網 arc de-scan）：只讀送達belief（received_buy_orders）+ faction結構（is_resident_static=組織常識、非live態）——舊「讀本勢力自有居民deficit=合法god-view」自辯已被用戶資訊網arc否定（領主直掃自家居民live runway/pop/food=god-view殘留）。

這段文字**明確承認並訂正了舊自辯的錯誤**，非我上輪的要求被無視或打折執行。這是這輪一個小但重要的確認：跨輪的required correction有被真的落地追蹤，非提了就散。

## ②mini-util genuine——親驗一字未改，只換觸發路徑
親讀`:126-188`（`_distribute_candidates`完整body）確認`relief_term`/`coin_term`/`u = relief_term + coin_term`這段util公式，跟我上一輪(distribute de-scan)已經逐行審過的belief-sourced版本**逐字一致**——這輪spec宣稱「mini-util=既有de-scanned distribute util、一字不改」，我直接比對原文確認為真，非信文字宣稱。這輪唯一改動是**誰呼叫這個函式**（從`frontier_candidates`主argmax池 → 新`_try_distribute_side`側路），不是**這個函式算什麼**——這正是genuine非crank的核心判準：如果connect改的是util公式本身，才要擔心crank；這裡改的是路由，數字邏輯原封不動。

## ③side-action邊界scope硬限——親讀確認已正式寫入spec，非事後補
spec `:7-10`「★★side-action類邊界正式化（blueprint定、防creep、寫進spec）」段落親讀確認：「現三型：herald(求援)/scout(偵察)/distribute-convoy(賑濟)」+「★每新增side-action型需blueprint sign-off（防全部決策遷出argmax、掏空主秤紀律）」——這條防creep規則不是我這輪審查才要求加上去的，是spec文字本身已經包含、且明確標註是blueprint親自定的邊界。這代表blueprint自己已經意識到「side-dispatch這個逃生艙如果無限擴張會掏空主argmax紀律」這個風險，並且主動用sign-off機制把關，非我單方面擔心的事後補救。

## ④reuse點——親驗_try_X_side既有模板，非即興新寫
親讀`_try_herald_side`(`faction_ai_system.gd:1652-1671`)確認既有side-dispatch pass的標準結構：pop/throttle前濾→need-gate(severity<=0不派)→target resolve→mini-util計算(`severity × _pmult × EXPECT - COST`)→Probe tap記錄每個環節（`help.severity_positive`/`help.target_unresolved`/`help.target_resolved`/`help.mini_util`）。這個結構化模板讓`_try_distribute_side`要抄同款寫法不是一次性即興發明——throttle/need-gate/mini-util/observability四段都有現成範式可循。`_dispatch_convoy`(`:3311`)親確認存在，reuse claim坐實。

## determinism/economy
零新RNG（mini-util算術判斷、throttle讀既有`task_extra_data.convoy_phase`欄位比對）；`food_surplus`計算不受這輪改動影響，reserve守恆維持。

## 判決
**CLEAN → 回systems → build（續`feat/info-network-whole`）→ re-measure症1端到端（`distribute.dispatch/food_delivered>0`+糧真到resident runway回升＝症1首次閉環）→ QA故事稽核。** 這輪建立在前兩輪(distribute de-scan/Part2 side-action)已經深度驗證過的兩個組件上（util公式+side-dispatch架構），這輪的驗證重點正確地放在「這兩個組件被正確地接在一起、沒有被順手改動」跟「上輪required correction真的落地」，非重新從頭驗證。
