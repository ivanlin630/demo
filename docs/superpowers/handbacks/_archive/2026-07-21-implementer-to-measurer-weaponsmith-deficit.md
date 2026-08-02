---
from: implementer
to: measurer
status: consumed
topic: "[measure·behavior-sensitive·economy] facility-scoring weaponsmith 納武器 demand → feat/weaponsmith@0aa7d3ae。★facility-build-by-type(weaponsmith 0→?)+weapon 產出(weapon_melee_low 池 0→?)+weaponsmith vs workshop score 分布(不再 systematically 輸)+doom-delta seed1337/42+8config sanity,帶 §④b 樣本(可 Probe.bump_sample)。不需 QA(formula 事實)。TDD 5/5、headless 0new(A 類 byte-identical)、gate 75 removed=0、determinism seed1337 2mo byte-identical(md5 1e72aeb2,無 RNG)。"
---
# Hand Back: facility-scoring weaponsmith 納武器 demand（軍火商路徑）

承 dispatch `2026-07-21-...-facility-scoring-weaponsmith-dispatch.md`（R² CLEAN，2 要求已納）。★measure-sensitive economy。**不需 QA**（blueprint：formula 事實非故事）。

## 實作摘要
branch `feat/weaponsmith@0aa7d3ae`（off local main ede2eb06；★禁 origin）已 push（★過 installed pre-push 兩閘）。
- **① ★DRY**：抽 `_generic_res_deficit(state, team, outputs, use_demand, agg_mode, lv)` 從 `_facility_deficit` A 類分支（min_per_res/pooled_sum + need_keep + demand）。**A 類 dispatch 和 weaponsmith market 都呼此=單一源**（禁平行重寫，收斂 seam#1）。搬 guard 連 `# gate-ok` 一起搬（helper 末 `_deficit` 命中 decision-func regex，threshold 被掃）。
- **② `_deficit_weaponsmith` = max(self_defense, market)**：self_defense（現況留 clampf(0.6-armed_ratio)×militancy）/ market = `_generic_res_deficit([weapon_melee_low, weapon_ranged_low], use_demand=true, min_per_res) × _commercial_inclination`。max=自衛急 OR 市場好賣任一驅建（R² 判無 double-count）。
- **`_commercial_inclination`** = clampf(貪婪×0.6 + 商業技能×0.7)（TEST VALUE 權重；貪婪=value in lv、商業=leader skill）。人格穿秤非 flat，零 RNG。
- **② workshop cliff→連續 拆 follow-up**（known_issues），本 slice 乾淨 weaponsmith-only 對照。

## 我的驗證
- **TDD** `weaponsmith_deficit_test` **5/5 PASS**（RED→GREEN；★還原→②自衛足隊武器 demand 高卻 deficit 0=leak，證 market 路徑 load-bearing）。①_commercial_inclination 分兩端 ②★市場驅建(自衛足亦建,舊=0) ③self_defense 路 ④all-low→0。
- **headless** `=== DONE ===`，3 fail = **baseline 0 new**（★A 類 facility workshop/apothecary/armorsmith/smeltery/stable **byte-identical**，helper 抽出純重構）。
- **constitution_gate** PASS **sites=75 removed=0**（★搬 guard 保 `# gate-ok`——重構搬 threshold guard 要連 gate-ok，fileline 紀律）。
- **determinism** seed1337 2mo 2 跑 **byte-identical，md5 `1e72aeb2`**（無 RNG）。

## ★請你量（spec §measure，behavior-sensitive，帶 §④b 樣本）
- **★facility-build-by-type**：weaponsmith 建數 **0→?**（主驗：武器產業起得來否）。
- **weapon 產出**：weapon_melee_low/ranged_low 池 **0→?**（真造出武器）。
- **weaponsmith vs workshop score 分布**：不再 systematically 輸（60 樣本僅中 1 →?）。
- **doom-delta（seed1337/42）+ 8 config sanity**。
- **★§④b 樣本**：可用我新 merged 的 `Probe.bump_sample`（decision-bearing 聚合帶具體 case，如 weaponsmith 建址的 team/demand/inclination instance）——若要更細診斷。**注意**：Probe.bump_sample 是工具，決定性探針改用=你按需（本 weaponsmith slice 我沒插 bump_sample call，純 formula 修）。

## 連動風險
- **weaponsmith 建址增**（市場 demand 驅）=預期修（軍火產業起來）。判準=weapon 產出↑ + doom-delta 不崩 + A 類不變。
- **_commercial_inclination TEST VALUE 權重（0.6/0.7）**：若你量到 weaponsmith 過建/欠建 → 調權重 flag。

## out-of-scope
② workshop demand cliff→連續（goods 建造品質）= 獨立 follow-up（known_issues backlog，①優先）。

## 完成判定
task 完成 = systems + reviewer 判（不需 QA）。你量完 → 餵 blueprint / pre-merge to:systems。我 hold warm 等裁決。
