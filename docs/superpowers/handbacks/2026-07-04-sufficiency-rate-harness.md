# Hand Back: 全系統充足性率表 harness

> 分工（spec）：本軌=**系統備機器**（counters + 率表 bed + dump）；**跑+判=QA 驗收官**。
> 本 handback 附率表**原始輸出**，**不附判決**——判決（合理 0 vs 斷鏈 0）是 QA 的活。

## 實作摘要

- `scripts/debug/sufficiency_bed.gd`（新）：SceneTree harness。default 自然世界（`GameSetup.setup` 後 `player_id=-1`→全 NPC 自解、無 forced_event 卡死）× seed 1337+2674 × 6 月自跑。開 `Probe.enabled`→讀 `Probe.counts` 排率表。輸出：每列 `想要/可行/發生` 三元組＋率＋月切面 delta（非零 counter/月）＋表尾 `[SUFF_JSON]` 一行/列＋事件流 dump（`SUFF_DUMP`=global_messages+observer_messages headless 直讀落檔）。env：`SUFF_SEEDS`/`SUFF_MONTHS`/`SUFF_DUMP`/`SUFF_JSON`。
- `scripts/simulation/message_system.gd`（+counter）：`msg.sent`（emit_message）、`msg.prop_candidate`/`prop_done`/`delivered`/`distorted`（_exchange_one_way）、`g3.lie_claim`（_exchange_intel distorted claim）。
- `scripts/simulation/belief_system.gd`（+counter）：`bel.has_belief_call`/`_true`、`bel.best_call`/`_hit`、`bel.claim_fresh`/`_mid`/`_stale`（best_estimate 選中 claim age 桶）、`bel.reconcile_opportunity`/`_compared`（reconcile_firsthand）。
- `scripts/simulation/diplomatic_ai_system.gd`（+counter）：`dip.proposal_sent`/`_handled`/`_accept`；`rel.tribute_eval`/`_with_edge`/`_edge_flipped`（tribute_accept，snapshot 法算 score_no_edge 比對門檻穿越）。
- `scripts/simulation/faction_ai_system.gd`（+counter，讀側）：`intent.sel_<type>`（_update_goals 後 f.intent、_set_solo）、`intent.goal_emit`（_emit_goal）。**未碰** caravan/trade 區（1470-1477/1949-1964）、`_decide_unified` 內部（1487-1540）只讀。
- `scripts/simulation/event_system.gd`（+counter）：`_init` 預算 `_event_names`；process_events loop 改 index 迭代（同序）+ `evt.<name>.check`/`.fire`。
- `docs/progress.md`（+紀錄）。

## 與 spec 的差異

- **自然世界 = `player_id=-1`**：spec 說「default 自然世界自跑」。default.json 帶玩家；bed 於 setup 後設 `player_id=-1`→ex-player 隊以 NPC AI 跑、無人類 forced_event 卡死＝乾淨自然世界。
- **消費/送達列**：spec 要「被消費/送達」。訊息無明確 read-mark chokepoint；消費定義為 `g1.board_read`（訂單看板讀＝唯一有決策消費者的 msg 類）。非 order 類今無消費 chokepoint→率表註明「結構性缺（QA 素材）」，非計數。
- **意圖→行為非征服 intent**：征服走既有 `conq.intent`/`conq.winner_prosperity` 到 task 層。其餘 intent（致富/防衛/擴張/守成/建國）今僅到 `intent.sel_<type>`/`intent.goal_emit`（goal 層），未到實派 task 一致率——率表註明「未到 task 層，QA 素材」。擴 specimen 到全 intent = 後續軌（會碰 dispatch，本軌 scope 外）。

## 連動風險

- **`Probe` 新 key（~30 個）**：不入 `WarringHarness.PROBE_KEYS` 子集 → seeded warring JSON 輸出**不變**（逐點 diff=0 已證）。其他 bed（conquest_measure/longwindow）讀特定 key，無碰撞。無風險。
- **`event_system.gd` loop 改 index 迭代**：`for event in _events` → `for i in range(_events.size())`，迭代同序、`check`/`execute` 同參同序 → 行為不變（seeded diff=0 涵蓋，含 event 觸發鏈）。
- **`tribute_accept` snapshot 重構**：`score_no_edge = score` snapshot 後逐步加 feud/gratitude，與原碼**逐位元相同**（只多一讀）。seeded diff=0 證浮點無擾。
- **`diplomatic_ai` demand_tribute 拆呼**：原 `return "accept" if tribute_accept(...) else "refuse"` 拆成 `var _acc = tribute_accept(...)` 單呼再 return。`tribute_accept` 純函數（只讀，無 state 寫）→ 拆呼行為等價。

## 驗收結果（原始，不判決）

- ✅ bed 兩 seed 出完整率表（全列有值、全帶分母三元組、`[SUFF_JSON]` parse 得動）。
- ✅ 事件流 dump 檔可讀（seed0 global=166 條 + observer channel）。
- ✅ 回歸：headless `=== DONE ===` 無 SCRIPT ERROR、framework `PASS=7 DORMANT=0`、coin_eq `delta=0.0`。
- ✅ **中立性：seeded warring 三 seed（1337/42/7）逐點 `total_diffs=0`**（counters 零行為變硬證）。

### 率表原始輸出（seed 1337）

```
────────── [充足性率表] seed=1337 ──────────
鏈              列                         率   想要/可行/發生   定義
貿易             六站漏斗                      —   [佔位——引貿易軌六站，本軌不重做]
消息傳播           送達/發出                 70.2%   3694/1263/886
消息傳播           失真/傳播                 26.9%   886/886/238
消息傳播           消費/送達                  1.7%   886/886/15    (非 order 類無消費 chokepoint=結構性缺)
belief         實質讀/問                 40.8%   859299/859082/350181
belief         口碑比對/機會               69.8%   11195/11195/7814
G3識破           識破/謊言                 15.9%   416/416/66
G3識破           scout 收斂/派出             n/a   0/0/0
外交             提案 accept/發出          70.6%   15/17/12
外交             envoy 送達/派出            0.0%   4/4/0         (delivered=0)
RelationGraph  邊改結果/含邊評估               n/a   1/0/0
意圖→行為          征服 想=做                  n/a   1386/0/0
捕俘             capture/戰             27.3%   11/11/3
同化             assimilate/capture    66.7%   3/3/2
佔村             flip/dispatch           n/a   0/0/0
立國             found/夠格               0.0%   26713/4287/2
── 事件系統（各型 fire/check）──
事件             event_unrest_split     0.0%   8144/8144/0
事件             event_unrest_replace     0.0%   8144/8144/0
事件             event_faction_defect     0.0%   8144/8144/0
事件             event_tag_shift        0.0%   8144/8144/4
```

### 率表原始輸出（seed 2674）

```
────────── [充足性率表] seed=2674 ──────────
消息傳播           送達/發出                 69.3%   4271/1445/1001
消息傳播           失真/傳播                 33.2%   1001/1001/332
消息傳播           消費/送達                  3.3%   1001/1001/33
belief         實質讀/問                 40.0%   738480/738296/295177
belief         口碑比對/機會               91.1%   9939/9939/9057
G3識破           識破/謊言                  9.3%   246/246/23
G3識破           scout 收斂/派出             n/a   0/0/0
外交             提案 accept/發出           0.0%   2/5/0
外交             envoy 送達/派出           20.0%   5/5/1
RelationGraph  邊改結果/含邊評估               n/a   0/0/0
意圖→行為          征服 想=做               100.0%   363/2/2
捕俘             capture/戰             66.7%   12/12/8
同化             assimilate/capture    50.0%   8/8/4
佔村             flip/dispatch           n/a   0/0/0
立國             found/夠格               0.0%   19272/2429/0
── 事件系統（各型 fire/check）──
事件             event_unrest_split     0.0%   9492/9492/0
事件             event_unrest_replace     0.6%   9492/9492/61
事件             event_faction_defect     0.0%   9492/9492/0
事件             event_tag_shift        0.0%   9492/9492/2
```

（完整 machine-readable JSON 見 `[SUFF_JSON]` stdout 行 / `SUFF_JSON` 落檔；事件流 dump 見 `SUFF_DUMP`。）

## 待主 session 確認

- **縮減版常駐回歸固化排程**：spec 提「表尾 machine-readable 供之後固化常駐回歸（縮減版每 merge 跑）」。本軌出 JSON 格式；固化為 CI gate（哪些率設閾/斷言）= 後續，需藍圖/系統定閾值（本軌純機器不設判準）。
- **消費 chokepoint 補否**：非 order 類訊息今無決策消費點（結構性缺）。補 = 決策讀 message 時 mark，屬機制擴（後續軌）。
- **意圖→行為全 intent specimen 擴**：非征服 intent 到 task 層一致率需碰 dispatch（本軌 scope 外，貿易軌領地部分重疊）。
