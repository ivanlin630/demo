---
from: implementer
to: systems
status: consumed
topic: "[完] specimen 交易+威脅 tap — 新 HEAD 200d7e49；test ALL PASS(新欄入 jsonl)；determinism 不破；可 measurer 重跑"
---
# Hand Back：specimen 交易執行 + 威脅來源 tap

`feat/survival-execution-lock` @ `200d7e49`（已 push；先 merge origin/main `61f696d0` 拿最新 main）。

## 實作（照 spec `2026-07-14-specimen-trade-threat-taps.md`，2 檔純觀測 tap）
- **Fix 1（交易執行·缺口①）** `specimen_tracer._snapshot`：加 `active_buy_food_qty`（buy+food qty_remaining）+ `at_market`（tile.outpost_level>0）+ `orders`（{kind,res,qty_rem} 列）。純讀 `team.active_orders`/tile。
- **Fix 2（威脅來源·缺口②）** `decision_engine.gd` 兩呼點（`rank_scored:18`/`rank_survival:124`）`capture_options(state,team,scored,ctx)` 加傳 ctx；`specimen_tracer.capture_options` 收 `ctx: DecisionContext = null` → 存 scratch `threat{threat_id,threat_pos,threat_react}` → `capture_decision` 進「想什麼」block。**ctx 加參數不進 rank util 運算**（零行為改）。
- `write_jsonl` 自然涵蓋新欄（逐 entry 序列化）。

## 守則履行
- **純觀測**：只讀 active_orders/tile/ctx，append entry。零 state mutation、零 RNG、零行為改。
- **no-op-unless-specimen**：新欄全掛 `is_specimen` gate 後（capture_options/_snapshot 皆 specimen-gated）。
- **履行「全量暫態可觀測性」不變量**（決策依賴的暫態補進 tap）。

## 驗（TDD + sanity）
- **test ALL PASS**（`specimen_noninvasive_test.gd` 加 `_test_trade_threat_taps`）：jsonl entry 狀態含 `active_buy_food_qty`/`at_market`/`orders`；想什麼.threat 含 `threat_id`/`threat_react`。
- **determinism 不破**：`SPECIMEN_TEAM_ID=7 FORCE_FULL_HD=1` 兩跑 jsonl hash 相同（`0907df2af467a4d4bd5dd5de3c8f97e8`，各 264 行）——純觀測 tap 不擾世界。
- **headless ≥1000 tick**：3+3 baseline，零新增。
- **憲法閘 PASS** sites=29 removed=0（無新 try_set）。
- 既有 specimen 欄不壞（原 test 全綠）。

## 下一站需求（measurer 重跑 + QA 複判，spec §驗收法）
1. **交易執行可判**：seed1337 Team20（同世界）specimen → jsonl 含新交易欄 → QA 判 pop3→1 死亡窗口是「換皮(單卡 never 到市集)」vs「tap-miss」。
2. **威脅來源可判**：survival/flee entry 含 threat_id/threat_react → QA 判空鎖有無真威脅。
3. **★團滅 specimen**（blueprint #3）：measurer 指定死透 team_id 補一份完全滅隊 trace，驗死得連貫。
4. 不回歸（determinism/憲法/既有欄）→ QA 複判乾淨綠 → blueprint 批 execlock merge。

## 待確認
- 無 spec 未覆蓋決策。完成判定 = systems + reviewer/QA。context hold warm 等 measurer 結果 → 裁決信。
