---
from: implementer
to: measurer
status: consumed
topic: survival-path 交付(latch重選+FLEE威脅gate) — churn接點systems已確認;branch feat/survival-path已push,待終驗餓隊換策略/不spurious FLEE/churn連貫
---
# Hand Back: survival-path 解鎖（latch 重選 + FLEE 威脅 gate）

branch `feat/survival-path`（已 push，疊 origin/main 含 cadence）。spec `docs/superpowers/specs/2026-07-13-survival-path-unlock.md`。churn 接點 **systems 已確認**（`churn-seam-confirm`：rank_survival 比對 previous_task = 等價 + blast radius 限 + BEG-restore OK）。

## 實作摘要
- **① survival-latch 重選**（`_evaluate_survival`）：仍餓 + cadence 到（或 crisis）→ **release-then-retrigger**（R² 坐實同-prio try_set no-op → 必先 release→IDLE→`_trigger_survival` 成立）→ 餓隊 forage 失效可換買糧/掠奪/併入。proactive_camp 豁免。複用 `decision_eval_next_tick`/`_decision_crisis`/`DECISION_CADENCE`（crisis 短 cadence /4）。
- **churn 防抖接點**（R² 提，systems 確認）：`rank_survival` COMMITMENT 比對 `current_task`→release 後 IDLE 破基準。改：relatch release **前**存 `previous_task=current_task` + `_trigger_survival` guard（`if current_task!=IDLE` 才設，不以 IDLE 覆蓋）+ `rank_survival` 比對 `previous_task`。常態路 `previous_task==current_task` **零行為變**，僅 relatch differ（=防抖目的）。
- **② FLEE 威脅 gate**（`terms.gd threat_pressure`）：`threat<=0→0`（撤 T1 0.6 floor），真威脅→`clampf(threat+panic×0.4)`。食足隊不 spurious FLEE 餓死；panic 僅威脅時計（斷 death spiral）。
- **③ known_issues**：stress 累積不釋放 = death spiral 根層（person 情緒 arc 待；本 slice 決策層斷 FLEE 螺旋）。
- TDD：`_test_survival_relatch_repick`（餓+cadence→relatch 重評）+ `_test_flee_threat_gate`（threat0→0/真威脅→值）PASS；T1 threat asserts 機械更新（②撤 floor）。

## 我方自驗（融合閘全綠）
- headless **0 新增 SCRIPT ERROR**（3 pre-existing 同 baseline）；relatch/flee test PASS。
- **constitution PASS**（sites=29）；**determinism byte-identical**（1337×1mo 兩跑 cmp；純算術/整數推進）。

## 待終驗（dispatch §驗收）
1. **★餓隊換策略**（Team7 式）：forage 失效 → 重選換買糧/掠奪/併入（單隊 trace survival option 有變，非死鎖 FORAGE）。
2. **★食足隊不 spurious FLEE**：食足無威脅隊 FLEE 選中率~0、不再餓死。
3. **真威脅不回歸**：真威脅隊仍 FLEE/threat 反應。
4. **★churn 連貫（重點）**：餓隊重選不每 cadence 亂跳——**驗 previous_task 防抖真生效**（單隊 trace 連貫非鋸齒）。
5. **① cadence 頻率**：螺旋斷後決策次數（2023次/90天）是否降。
6. **不回歸**：TC2/survival-dominance/consolidation/combat/established organic + determinism + 融合閘。

## 連動風險 / 註
- ① 移除永久 survival-latch → 餓隊每 cadence 重評（行為改動，baseline 位移非 regression）；churn 靠 previous_task COMMITMENT 防。
- ② 撤 threat floor → 食足隊 FLEE 消（解 spurious FLEE 餓死）；真威脅路徑不變。
- 承接前 cadence slice（T-cad1/2）+ 序① capture_decision probe（同 arc）。9-zero 若仍殘 → 承接 T1-T5 的 3 organic 觀察項帶數據裁。
