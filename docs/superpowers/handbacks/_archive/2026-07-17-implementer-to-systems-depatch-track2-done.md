---
from: implementer
to: systems
status: consumed
topic: "[DONE·軌2 完] de-patch 值閘 閘1/5/7 + try_proactive 陡化(retry alone)+4 測 migrate + 閘6 gate-ok(裁) (03e203dc);Tier1 8綠+gate PASS sites=91 removed=2+headless 3+3+CoinAudit=0"
---
# [DONE] de-patch 軌2 值閘（全完）

branch `feat/constitution-gate-strengthen` @ `03e203dc`（續 gate v2 worktree，已 push）。

## de-patch（行為閘→人格/情境秤，per-gate）
- **閘1 `_threat_recent`→militancy**：weaponsmith/armorsmith deficit 拆反應式硬 gate → **人格 militancy 秤**（好戰+FORCE archetype+交戰＝主動軍閥備戰、和平農夫不備）。刪 `_threat_recent`（零 caller）→ gate **removed `_threat_recent::threshold`**。
- **閘5 tribute FLEE override→膽識/絕望秤**：拆「逃跑=必屈服」硬 override，逃跑加 `TRIBUTE_W_FLEE`（0.25 < 義氣權重）→ **義氣/膽識高可邊逃邊拒**（絕境戲）。
- **閘6（你裁 over-reach，revert stays）**：readback 確認 `_calc_diplomacy_score` 已是加權人格 util（非硬門檻）→ 不軟化；flagged 的 `::threshold` = `if gift_food>0.0` 禮物存在 guard → **標 gate-ok**。
- **閘7 `calc_attack_score` 刪**：production 零 caller 孤兒 → 刪函式 + 清測 → gate **removed `calc_attack_score::threshold`**。
- **try_proactive 陡化（retry alone，blueprint 明裁 legit 案③）**：`randf()<慎重³`（極謹慎 never proactive、大膽近乎每 tick，骰只斷中間）vs 舊 `×0.5+0.2` 平。**非拆 RNG**（改曲線）。

## ★4 diplomacy 測 migrate（你裁：assert 舊平行為→migrate 到陡）
- **診斷（逐 code 驗）**：4 測用 **out-of-range 慎重=2.0**（測內註解自承「繞 RNG」force-fire hack，舊公式 慎重≥1.6→always fire）/ 極端 慎重=1.0。陡化下 `2.0³=8` 恆 skip、`1.0³=1` 恆 skip → 破。
- **判定＝rate 變非求貢語義破**：真 sim 慎重∈[0,1]，很謹慎(0.9)fire ~27%、中性 ~87%——**cautious 仍 fire 求貢，只 rate 降非 never**。out-of-range hack 是測 artifact。
- **遷移**：belief-gate 測 慎重 2.0→0.8（valid cautious 仍觸 belief-caution hold）+ `loop 40×`（cautious 陡化下仍 fire，cooldown 防重送）；正控/cooldown leader 1.0→0.3（bold fire；remote-spam gate 是 randf-independent 仍 block）。

## 驗（Tier1 + sanity）
- **Tier1 8/8 PASS**：閘1 軍閥 militancy 1.00>農夫 0.07 / 閘5 逃跑義氣拒+膽識低屈服 / 閘2b 陡化 慎重推兩端(0.2→skip 0.008、0.9→skip 0.729)。
- **gate v2 PASS sites=91 removed=2**（_threat_recent + calc_attack_score）。**headless 3+3 baseline 0 net new**（4 測 migrate）。**CoinAudit delta=0×4**。**determinism byte-identical MD5 F85E975A**（陡化 randf seed-決定性=同 seed 兩跑 bit-identical，行為變非 baseline-identical）。

## baseline gate-ok（legit 標）
37+ gate-ok：taskarbiter lifecycle 28 / rank_* canonical 5 / rng-legit 3（consider_betrayal 案③/_check_discipline 案②/_maybe_request_join event-ID）/ gift guard。

## ★誠實 / detector 限制
- **detector gap**：`try_proactive_diplomacy`/`respond_to_diplomacy` 的 caller `score>0.6/0.4` 硬 cut **未被 threshold detector 抓**（DECISION_FUNC_RE 未涵蓋 diplomacy decision func 名）——非本軌 de-patch 標的（閘6 是 util-decision 合法），但若你要納 detector，widen DECISION_FUNC_RE（會增 baseline，建議下 slice）。
- 行為變（非 byte-identical，spec 明示）→ **measurer 乾淨全量驗行為分化**（軍閥備戰/農夫不備、絕境屈服人格分化、try_proactive 陡曲線、無回歸、閘 removed）。

## 溯源
spec depatch-track2 + R² round2 CLEAN + 閘6/陡化 ruling `depatch-track2-ruling-616`。軌1 seam#1 控制流(route/dispatch_entry)另大 slice。
