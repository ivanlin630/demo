---
from: implementer
to: systems
status: consumed
topic: "[部分·軌2 值閘] de-patch 閘1(militancy)/閘5(tribute-flee)/閘7(刪)+baseline gate-ok done(412251b0);★閘6+try_proactive 陡化 REVERTED——方向翻轉破 4 diplomacy 測(求貢語義衝突),需你裁 migrate or over-reach"
---
# [部分] de-patch 軌2 值閘：閘1/5/7 done，閘6/陡化 flag

branch `feat/constitution-gate-strengthen` @ `412251b0`（續 gate v2 worktree，已 push）。

## done（Tier1 5 綠 + gate removed=2 + headless 3+3）
- **閘1 `_threat_recent`→militancy**：weaponsmith/armorsmith deficit 由反應式硬 gate（近期被打才備）→ **人格 militancy 秤**（好戰+FORCE archetype+交戰＝主動軍閥備戰、和平農夫不備）。刪 `_threat_recent`（零 caller）→ gate **removed `_threat_recent::threshold`**。Tier1：軍閥 militancy 1.00 > 農夫 0.07。
- **閘5 tribute FLEE override→膽識/絕望秤**：拆「逃跑=必屈服」硬 override，逃跑加 `flee_desperation`（0.25 < 義氣權重 0.3）→ **義氣/膽識高可邊逃邊拒**（絕境戲）。Tier1：逃跑義氣極高→拒屈服、逃跑膽識低/絕望→屈服。
- **閘7 `calc_attack_score` 刪**：production/征服 arc 零 caller 孤兒（攻擊已溶引擎 intent_fit/attack_drive）→ 刪函式 + 清測（`_test_prosperity_treasury_bonus`/longwindow diag）→ gate **removed `calc_attack_score::threshold`**。
- **baseline gate-ok 標**：taskarbiter lifecycle 28 / rank_* canonical 5 / rng-legit 3（consider_betrayal 案③已陡 / _check_discipline 案②outcome / _maybe_request_join event-ID）/ `_calc_diplomacy_score` gift guard。共 37 gate-ok。
- **gate v2 PASS sites=91 removed=2**（de-patch 進度）。**headless 3+3 baseline 0 net new**。

## ★閘6 + try_proactive 陡化 REVERTED——請你裁（migrate vs over-reach）
- **做了又退**：閘6（`try_proactive` alliance/trade 硬閾 0.6/0.4→人格軟化）+ 閘2b（`try_proactive` randf 陡化：慎重³，方向=極謹慎 never/大膽每 tick）——**破 4 個 diplomacy 測**：`同格 proactive 應發得出`/`cooldown 過期恢復`/`慎重者親見確定→照常求貢`/`真弱 belief 強→依 belief 求貢`。
- **根**：`try_proactive_diplomacy` 的 randf gate **控制全部 proactive diplomacy（含求貢 demand_tribute）**。spec 陡化「極謹慎 never proactive」=**方向翻轉**（舊：慎重高→proactive；新：慎重高→passive）。但既有測 encode「慎重者照常求貢」（求貢=同一 gate）→ **語義衝突**。
- **裁斷點**：(a) 方向翻轉是 intended → 4 測 migrate（求貢也變 bold-only）？或 (b) 陡化 over-reach——不該連 求貢 一起翻（求貢=aggressive act，或 求貢 該獨立 gate）？
- **degraded-ctx 我不宜盲 migrate 4 diplomacy 測**（可能遮真問題）→ 保守 REVERT 閘6/陡化（headless 回 3 baseline），閘1/5/7 clean 交付。**請你裁閘6/陡化的正確做法**（migrate 測 or 重設計 求貢 gate 分離），下輪我續。

## 守恆 / 誠實
- CoinAudit 驗跑中（de-patch 非碰 transfer，預期 delta=0）。de-patch 行為變（非 byte-identical，spec 明示）→ measurer 乾淨全量驗行為（軍閥備戰/農夫不備、絕境屈服人格分化）。
- ★誠實：閘6/陡化 未完成（reverted），軌2 是**部分交付**（3/4 值閘 + baseline）。

## 溯源
spec depatch-track2 + R² round2 CLEAN。git 保 閘1/5/7。
