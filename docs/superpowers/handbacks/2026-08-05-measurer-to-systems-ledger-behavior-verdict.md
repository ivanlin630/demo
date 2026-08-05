---
from: measurer
to: systems
status: consumed
topic: "失聯帳本behavior量verdict:★infra blocker先報——warring_states.json全尺寸床連4次跑逾GODOT_TIMEOUT=1200(3mo/2mo/45天+specimen/45天無specimen皆逾時,非我單次失誤是系統性),改用小床infonet_whole.json(10隊)才在60天內順利跑完,強烈懷疑是warring全床本身在此branch/環境perf重(不只我這輪的問題)或機器同時多session競爭資源,非機制本身問題,如實回報供你們評估是否要查perf或改用小床當標準驗收床。★小床結果(60天,infonet_whole.json,convoy.dispatch=14驅動):contact.ledger_add=35/contact.overdue=7/全部7次選redispatch,但★關鍵限制=全部7次逾時事件來自同一team(team0,統領0.8最高特質),不同team_id數=1——樣本太窄,無法回答reviewer真正關切的『不同人格的隊是否選不同react類』(需要多個不同dominant-trait的隊各自逾時才能測),本輪只證實:單一隊(統領最高)argmax正確選中redispatch(跟手算一致,非bug),但diversity問題本輪未能回答。help.letter_dispatched=0/scout.dispatched=0(此branch/seed下未fire,只convoy驅動了7次逾時)。specimen因infra blocker本輪未產出(擱置)。純觀測,自建溫度探針已revert。落地1檔已ls/wc驗證。已回systems handback:2026-08-05-measurer-to-systems-ledger-behavior-verdict.md，別下accept，diversity問題+infra perf問題皆需後續補測，交systems判"
---

# 失聯帳本 behavior 量：★infra blocker + 小床部分結果（diversity 問題未解）

## ★★infra blocker（先報，優先）

`warring_states.json` 全尺寸床（既有標準驗收床，上百隊規模）**連續 4 次跑逾 `GODOT_TIMEOUT=1200`**：
- 3mo（含 specimen）→ 逾時
- 2mo（含 specimen）→ 逾時
- 45天（含 specimen）→ 逾時
- 45天（無 specimen）→ **仍逾時**

四次配置不同（時長/是否掛 specimen）都逾時，**非單次巧合或我單次跑法失誤**——換成小床（`config/infonet_whole.json`，10隊）跑 60 天則順利在額度內完成。**強烈懷疑這是全尺寸 warring 床本身在這個環境/時段有 perf 壓力**（可能跟同時段多個角色 session 併發搶算力有關，或 branch code 本身有變慢；我沒有獨立切開這兩種可能，如實回報，不下因果判斷）。建議你們評估是否要把 warring 全床的長跑（＞1mo）標準驗收流程另外挪到不搶時段/加大 timeout，或考慮用小床當常規驗收替代。

## 小床結果（`infonet_whole.json`，seed1337，60天，省算力）

```
attrition=19.20% final={teams:12, factions:1}
contact.ledger_add=35  contact.overdue=7  contact.react_redispatch=7
contact.react_defensive=0  contact.react_rescue=0  contact.react_writeoff=0
help.letter_dispatched=0  scout.dispatched=0  convoy.dispatch=14
```

## ★關鍵限制：diversity 問題本輪未能回答

**全部 7 次逾時反應都來自同一個 team（team0）**：
```
{team:0, react:"redispatch", overdue_ratio:1.5~2.0, 統領:0.8, 慎重:0.6, 義氣:0.6, 野心:0.2}
```
`不同 team_id 數=1`——**這 7 筆樣本全部來自同一隊反覆逾時，不是 7 個不同人格的隊各自一次**。這隊的 `統領=0.8` 明顯是 4 個特質裡最高的（`0.3+0.8×0.7=0.86` vs 其他三項最高 `0.72`），選 `redispatch` 完全符合手算 argmax——**證實機制對這一組人格值算對，但沒有回答 reviewer 真正關切的「不同人格的隊是否真的選出不同 react 類」**（因為本輪只有這一隊的人格值被真正測到）。要回答這個問題，需要**多個 dominant-trait 不同的隊各自真的逾時**（例如 4 隊分別統領/慎重/義氣/野心最高，各自都遇到逾時事件），本輪受限於 infra blocker 沒能跑出這樣的樣本。

`help.letter_dispatched=0`/`scout.dispatched=0`——這個 seed/branch 組合下 herald/scout 完全沒 fire，只有 `convoy.dispatch=14` 驅動了帳本活動，樣本來源單一也是巧合的一部分。

## specimen dump

因 infra blocker 反覆撞牆，本輪**未產出 specimen jsonl**——時間/算力都被拿去試跑 warring 全床，如實聲明擱置。等 diversity 問題有更好的多樣本 fixture 後可一併補 specimen。

## 落地檔案（已 ls/wc 驗證存在）

- `docs/measurements/2026-08-05-ledger-behavior-infonetwhole-60d.txt`（1895行，完整跑 log + 逐 tap 數字 + per-team react 樣本）

## 清理狀態

- `warring_harness.gd` temp PROBE_KEYS/SpecimenDumpHelper hook 已 `git checkout --` 還原。
- `faction_ai_system.gd` temp 診斷 tap（`_step_contact_ledger` 內 1 行 `Probe.bump_sample`）已 `git checkout --` 還原確認乾淨。
- temp `ledger_behavior_measure_bed.gd` 已刪除。

## ★誠實淨判

- 機制本身（單一已測人格值）算對，argmax 選擇跟手算一致。
- **diversity 問題（reviewer 的核心關切）本輪未能回答**——樣本太窄（只1隊），需要更多不同人格的隊真的逾時才能下結論。
- infra blocker（warring 全床 4 次逾時）值得單獨留意，不確定是環境併發還是 branch perf 問題。

別下 accept。diversity 問題建議另建一個「多隊各自遠距離派出、各自不同 dominant-trait」的小型專用 fixture（類似我 faction-cohesion 那輪的 matched-對照手法）來真正測，infra blocker 交你們評估要不要查/繞過。
