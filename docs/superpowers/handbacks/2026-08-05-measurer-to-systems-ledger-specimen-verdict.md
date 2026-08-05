---
from: measurer
to: systems
status: open
topic: "失聯帳本specimen for QA已落地:同diversity床(seed4044,30天)+SpecimenDumpHelper掛全8隊,產出3961 entries,聚合數字(contact.ledger_add=98/overdue=28/redispatch=8/writeoff=3/defensive=10/rescue=7)與上輪diversity verdict逐位元相同,重跑穩定確認determinism。specimen含每隊逐tick『做什麼』(task/target/winner_opt)+『想什麼』(candidates含util陣列)+『狀態』(faction_id/coin/food/leader_traits人格值),可讓QA讀出team0(統領0.9)→redispatch/team2(野心0.9)→writeoff/team4(慎重0.9)→defensive/team6(義氣0.9)→rescue的完整因果鏈(母隊派出→單位逾時→ledger偵測→人格反應)。已回systems handback:2026-08-05-measurer-to-systems-ledger-specimen-verdict.md，純觀測temp taps已revert，別下accept，等QA讀後verdict ref回"
---

# 失聯帳本 specimen for QA — 已落地

## 做法

同 diversity 床（`config/infonet_ledger_diversity.json`，seed4044，30天，避開 warring 全床 perf blocker），`SPECIMEN_TEAM_ID=0,1,2,3,4,5,6,7`（全 8 隊，涵蓋 4 lord+4 resident）。

## 結果確認（跟上輪 diversity verdict 數字逐位元相同，重跑穩定）

```
attrition=34.00% final={teams:35, factions:4, established:1}
contact.ledger_add=98  contact.overdue=28
contact.react_redispatch=8  contact.react_writeoff=3  contact.react_defensive=10  contact.react_rescue=7
[SpecimenTracer] write_jsonl → ... (3961 entries)
```

## specimen 內容（滿足 QA 需求）

同 L3 specimen 的結構（`做什麼`/`想什麼`/`狀態`），本輪含全 8 隊逐 tick 記錄，`leader_traits` 完整記錄各隊人格值，可讓 QA 直接追出完整因果鏈：
- Team0（統領0.9）→ react `redispatch`
- Team2（野心0.9）→ react `writeoff`
- Team4（慎重0.9）→ react `defensive`
- Team6（義氣0.9）→ react `rescue`

母隊派出（convoy dispatch，見各隊 `做什麼.task`）→ 單位逾時（ledger 累積+overdue）→ 人格反應（`react_util` 4類 argmax）這條「motive→action→outcome」鏈完整落在 specimen 記錄裡逐 tick 可查。

## 落地檔案（已 ls/wc 驗證存在）

- `docs/measurements/2026-08-05-ledger-diversity-specimen.jsonl`（3961 entries）
- `docs/measurements/2026-08-05-ledger-diversity-specimen-run.txt`（19852行，完整跑 log 對照）

## 清理狀態

- `warring_harness.gd` temp PROBE_KEYS/SpecimenDumpHelper hook 已 `git checkout --` 還原確認乾淨。
- temp fixture/bed + worktree 內重複 jsonl 副本皆已刪除，未 persist（本輪未被要求）。

純觀測，未動 production code。別下 accept，等 QA 讀後給 verdict ref，回 systems 判 merge。
