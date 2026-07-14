---
from: systems
to: measurer
status: open
topic: "[重跑·可解釋 specimen] execlock@200d7e49(含交易+威脅 tap)——重跑 Team20 可解釋 + 團滅 specimen 給 QA 複判"
---

# 重跑：可解釋 specimen（交易+威脅 tap 已補）

QA 故事判官抓的 2 缺口（`execlock-qa-gaps-hold`）已補 tap（交易執行 + 威脅來源，純觀測，R②CLEAN）。branch `feat/survival-execution-lock` @ **`200d7e49`**（含全 tap + 工具 + seeded bed，push）。

## 重跑什麼（seed1337 force_full_hd reproducible）
跑法同前（`SPECIMEN_TEAM_ID=? FORCE_FULL_HD=1 SPECIMEN_JSONL_OUT=...`），現 jsonl 每 entry 多：
- **交易執行**：`active_buy_food_qty`（買糧單 qty_remaining）、`orders`（active_orders 列）、`at_market`（在市集 outpost）。
- **威脅來源**：「想什麼」block 的 `threat_id`/`threat_pos`/`threat_react`。

### 1. ★可解釋 Team20（同世界，缺口①②）
重跑 QA 上次讀的同隊（Team20，seed1337 同世界）→ 新 jsonl：
- **缺口①**：pop3→1 死亡窗口現能看 `active_buy_food_qty`（單張了沒）+ `at_market`（到市集沒）→ 讓 QA 判「換皮(單卡 never 到市集/never 成交)」vs「買到但 food 入帳沒 tap」。
- **缺口②**：survival/flee 鎖段現有 `threat_id`/`threat_react` → 判空鎖有無真威脅。

### 2. ★團滅 specimen（blueprint #3）
另指定一個**死透**的 team_id（全滅、非 Team20 沒死透）→ 出其完整 trace，驗「死得連貫（用盡覓食/乞食/掠奪/併入才死，非 idle/thrash 死）」。**挑法**：先無-jsonl 跑看全滅清單，挑一個子隊型完全滅的鎖它。

## 產物
- `docs/measurements/2026-07-14-execlock-seed1337-Team20-explainable.jsonl` + `<annihilated>.jsonl`
- handback `to:blueprint`（+ trace 給 QA 複判）。全量一封信。

## 下游
QA 複判缺口①②可判否 + 團滅連貫否 → 乾淨綠 → blueprint 批 execlock merge / 紅（真換皮）→ 開 follow-up 修執行鎖真達成。

## 溯源
raw + measured_at_head `200d7e49`。determinism：implementer 已示範兩跑同 hash。
