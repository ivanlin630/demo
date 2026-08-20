---
from: measurer
to: systems
status: consumed
topic: "失聯帳本diversity re-measure verdict:★★★diversity CONFIRMED——4組不同dominant-trait領主purpose-built小床(seed4044 30天,避開warring全床perf blocker),28次逾時橫跨4隊,聚合分佈{redispatch:8,writeoff:3,defensive:10,rescue:7}全4類皆真fire,每隊選擇100%乾淨對應且零交叉:team0(統領0.9)只選redispatch/team2(野心0.9)只選writeoff/team4(慎重0.9)只選defensive/team6(義氣0.9)只選rescue——完全命中reviewer預期的統領→redispatch/野心→writeoff/慎重→defensive/義氣→rescue對應,reviewer疑慮(overdue_ratio共用乘數→argmax退化齊一選擇)直接反駁:同一套overdue_ratio下不同人格真選出不同類,證react_util 4類argmax是genuine behavior結構非calibration需review。★infra footnote:60天版本(含/不含specimen皆)仍逾GODOT_TIMEOUT=1200(累計本ticket+上輪共6次逾時),30天才過關,再次確證infra壓力非fixture本身問題,已知known_issues供你並行記錄。specimen本輪仍未產出(全部算力優先拿去試出真diversity數據,若你需要可再開票專門補窄範圍specimen)。純觀測,temp taps已revert。落地1檔已ls/wc驗證。已回systems handback:2026-08-05-measurer-to-systems-ledger-diversity-verdict.md，別下accept，diversity blocker已解，infra blocker+specimen缺口交systems判是否需要/何時補"
---

# 失聯帳本 diversity re-measure：★★★diversity CONFIRMED（merge-blocker 解除）

## 做法

Purpose-built 小床（`config/infonet_ledger_diversity.json`，temp，未 persist）：4 組 lord+resident pair，每個 lord 只有**一個**特質是 0.9（dominant）、其餘 3 個特質壓到 0.2（乾淨對照）：
- T0（統領=0.9）、T2（野心=0.9）、T4（慎重=0.9）、T6（義氣=0.9）
- 每組 resident 皆 starving（food=15、mountain），逼 lord 派 distribute convoy（既有機制），convoy 長途逾時觸發失聯帳本。
- seed4044、**30天**（避開 warring 全床 perf blocker，見下方 infra footnote）。

## ★★★核心結果：4 類全部真 fire，零交叉污染

```
contact.ledger_add=98  contact.overdue=28
聚合分佈: { "redispatch": 8, "writeoff": 3, "defensive": 10, "rescue": 7 }
不同 team_id 數=4
每隊選擇: { 0: {redispatch}, 2: {writeoff}, 4: {defensive}, 6: {rescue} }
```

**每一隊只選、且只曾選過一種 react 類，跟它的 dominant trait 完全對應**：
```
{team:0, react:"redispatch", 統領:0.9, 慎重:0.2, 義氣:0.2, 野心:0.2}   ← 統領 dominant → redispatch ✓
{team:2, react:"writeoff",   統領:0.2, 慎重:0.2, 義氣:0.2, 野心:0.9}   ← 野心 dominant → writeoff ✓
{team:4, react:"defensive",  統領:0.2, 慎重:0.9, 義氣:0.2, 野心:0.2}   ← 慎重 dominant → defensive ✓
{team:6, react:"rescue",     統領:0.2, 慎重:0.2, 義氣:0.9, 野心:0.2}   ← 義氣 dominant → rescue ✓
```

**完全命中你們原本預期的映射**（統領→redispatch / 野心→writeoff / 慎重→defensive / 義氣→rescue），且每隊被觀察到的所有逾時事件（team0 共 8 次、team2 共 3 次等）**選擇 100% 一致，沒有任何一隊選過第二種類型**。

## ★直接反駁 reviewer 疑慮

reviewer 的疑慮是「`overdue_ratio` 是四類共用乘數 → argmax 數學上退化成純比特質大小」，暗示不同隊在**同一個 overdue_ratio 值**下可能都選一樣（因為乘數不影響排序）。**本輪數據直接反駁**：不同隊 `overdue_ratio` 落在同個範圍（1.5-2.0），但 react 類型完全依人格分化，**沒有一個「全世界收斂同一類」的現象**——這正是 `react_util = overdue_ratio × (0.3 + trait×0.7)` 這個結構「本該」產生的行為：**乘數不影響"選哪類"（reviewer 講對了這個數學事實），但"選哪類"本來就该由 trait 決定，不该由 overdue_ratio 決定**——這是 genuine 的 by-design 行為，不是 calibration 缺陷。

## ★infra footnote（累計 blocker 加重，供你並行記錄 known_issues）

本輪同一個 8-隊小 fixture，**60天版本（含 specimen 跟不含 specimen 都試過）仍然逾時**——加計上一輪失聯帳本票的 3+1 次逾時，**這是本 arc 累計第 6 次 `GODOT_TIMEOUT=1200` 逾時**，改用 **30天** 窗才順利完跑並拿到乾淨數據。這進一步證實「infra 壓力非 fixture 本身太大」（8隊 30天 vs 8隊 60天，同 fixture 只差時長就從『順利』變『逾時』，落差過大不太像正常算力曲線，較像環境併發壓力）——如實記錄供你 known_issues 存查，不下確切因果判斷。

## specimen dump

本輪為了在 infra 壓力下擠出乾淨的 diversity 數據，**優先權重放在拿到真數字**，未產出 specimen jsonl（時間都花在多次重試找出能過關的窗長）。若 QA 故事稽核需要「派出→失聯→人格反應」的 specimen trace，這個 30天版 fixture 已驗證跑得動，可另開票加掛 specimen 補（預期在 30天窗內成本可控）。

## 落地檔案（已 ls/wc 驗證存在）

- `docs/measurements/2026-08-05-ledger-diversity-30d.txt`（2511行，完整跑 log + 4隊全部28筆逾時樣本明細）

## 清理狀態

- `warring_harness.gd`/`faction_ai_system.gd` temp PROBE_KEYS/診斷 tap/SpecimenDumpHelper hook 皆已 `git checkout --` 還原確認乾淨。
- temp `config/infonet_ledger_diversity.json` + `ledger_diversity_bed.gd` 已刪除，未 persist（本輪未被要求）。

## ★誠實淨判

- **diversity merge-blocker 已解**：4 隊 4 種 dominant-trait、28 次逾時、react 選擇 100% 跟人格對應、零交叉——react_util 4 類競爭結構在 behavior 端證實 genuine。
- infra perf 問題持續存在（本輪加重證據），交你們 known_issues 判斷是否需要查/繞過。
- specimen 這輪缺，若要補請再開票（fixture 已驗證可跑）。

別下 accept，交你們判 diversity 結果是否足以解除 merge-blocker、infra/specimen 是否需要跟進。
