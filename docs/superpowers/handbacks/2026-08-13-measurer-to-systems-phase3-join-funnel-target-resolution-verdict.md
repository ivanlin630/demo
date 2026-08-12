---
from: measurer
to: systems
status: consumed
topic: "[#3②JOIN funnel精確定位+#3③target-resolution genuine-vs-bug分野,兩機制答案不同]①belief-gap(領主不知host位置)乾淨排除(0/4636次to_task);168次併入決策134次真co-locate(78.8%到達,travel非瓶頸);co-locate後8完成+36reject(82%已解決案例是host「養不起」拒收=吻合這局pop崩潰背景,偏genuine)+90次co-locate無對應結果(缺口未追根,誠實flag);②migrant瓶頸=belief-propagation缺口(est_null 9/10=90%,一旦有belief幾乎都正邊際)=偏bug;invest瓶頸=already_farming排除(9/16=56%)非belief缺口(僅12.5%)=偏genuine結構限制(target pool本身就窄)——migrant跟invest答案不同,別合併判"
---

# #3② JOIN funnel 精確定位 + #3③ target-resolution genuine-vs-bug —— 兩題都有乾淨答案

## #3② JOIN funnel —— belief-gap 乾淨排除，真瓶頸在別處

```
join.to_task_no_host       4      （併入 to_task 找不到 host 候選——罕見）
join.to_task_belief_gap    0      （★host 存在但不知位置——4636 次評估中一次都沒發生）
join.to_task_ok         4632      （成功回 TASK_JOIN——遠大於168，to_task 顯然也在候選評分階段被呼叫，非只贏家才算）
merge.consolidate_dispatch/set_ok 168  （「併入」真的贏 argmax 並成功下 order 的次數）
join.dispatch             134      （TASK_JOIN 隊出現在任一 pairwise 接觸對＝co-location 發生）
join.arrived_no_handler     0      （combat 早退擋——從未發生）
accept.join_accept          8      （真完成）
accept.join_reject         36      （host 秤 `_absorber_accepts` 的 feed_ok 未過，拒收）
```

★**belief-gap 這支被乾淨排除**：`join.to_task_belief_gap`=0，橫跨全部 4636 次 to_task 評估，一次都沒有「決定要投但不知道 host 在哪」的情況。這不是 propagation/info-net 的問題。

168 次「併入」order 下達後，134 次真的走到跟 host co-locate（78.8% 到達率）——travel 本身不是主要瓶頸。co-locate 之後：8 次 accept、36 次 reject——**已解決的 44 筆裡，82% 是 host 以「養不起」為由拒絕**（`_absorber_accepts` 的 feed_ok gate）。這跟這局的背景故事完全吻合（2個月 pop -32.9%、starve 死亡暴增14倍）——多數 host 自己也在崩潰邊緣，沒有餘糧收留投靠者。★這符合你上輪點名的「genuine-candidate」情境（strong 世界強沒餘糧餵弱→拒收=survival-bounded 自保），不像 bug。

★誠實缺口：134 次 co-locate，只有 8+36=44 次有對應的 accept/reject 結果，剩下 **90 次（67%）co-locate 沒有對應到任何結果**。這代表 `_resolve_join` 實際觸發的條件比我 `join.dispatch`（純 pairwise 接觸偵測）觀察到的更窄——可能是另一個以 tile/place 為準的 resolver（interaction_system.gd 註解提過"M2 交界：市集走 step3c 到場 resolver"，或許 JOIN 也走類似分流），這輪沒有追到根，交你判斷值不值得再開一輪查這 90 次的去向。

## #3③ target-resolution —— migrant 跟 invest 答案不同，別合併判

```
migrant: holding_seen=10 → est_null=9(90%) → marg_nonpositive=0 → util_evaluated=1
invest:  holding_seen=16 → est_null=2(12.5%), already_farming=9(56.3%) → roi_nonpositive=0 → roi_evaluated=5
```

**migrant**：瓶頸幾乎全部是 `est_null`（90%，9/10）——絕大多數已知的 holding 村，領主連 belief population estimate 都拿不到，連邊際值都算不出來。★好消息side：`marg_nonpositive`=0，代表一旦真的拿到 belief，邊際值幾乎都是正的（值得移民）。**這強烈支持 belief-propagation 缺口這支——偏 bug**。

**invest**：瓶頸主要是 `already_farming`（56.3%，9/16）——超過一半已知的 holding 村**已經有 farming 設施了**（這個投資機制的 scope 本來就只評「還沒有 farming 的村」，升級走另一條路），`est_null` 只占 12.5%（遠低於 migrant）。`roi_nonpositive`=0，代表一旦真的進入 roi 計算，幾乎都可行。**這支比較像 target pool 本身結構性就窄（多數村已經開發過），不是 belief-propagation 缺口，偏 genuine scope 限制，不是 bug**。

★關鍵：**migrant 跟 invest 這兩個機制的瓶頸類型不同**（migrant=belief缺口偏bug；invest=already-developed排擠偏genuine），建議 consolidate 時分開列，別當同一根因合併處理。

## Determinism

第五次確認：這輪換了 12 個新 temp tap（3 個 options.gd JOIN to_task 分流 + 9 個 faction_ai_system.gd migrant/invest target-loop）重跑，`specimen.jsonl` 逐位元跟前四輪完全一致，聚合數字全部吻合——bed 持續穩定中性。

## 落地檔案（已 commit `c5fef6bf`）
- `docs/measurements/2026-08-12-phase3-story-audit-seed1337-2mo.json`（補 JOIN funnel + migrant/invest target-loop 欄位）
- `docs/measurements/2026-08-13-phase3-join-funnel-evidence.txt`（跑完終態 raw tail）
- 12 個 temp tap 皆已 revert（`git status` 確認乾淨）

specimen 沿用已送 QA 的批次（這輪結論全部是聚合 counter 直讀）。

routing：這輪把 #3②③ 兩題都收斂到相對乾淨的答案（belief-gap 在 JOIN 側被排除、host-reject 偏 genuine；migrant 側 belief 缺口偏 bug、invest 側 target-pool 窄偏 genuine）——唯一沒追到根的是 134→44 的 90 次 co-locate 缺口，交你判斷這個殘餘缺口值不值得再開一輪。
