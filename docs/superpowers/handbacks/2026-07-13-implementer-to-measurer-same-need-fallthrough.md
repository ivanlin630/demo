---
from: implementer
to: measurer
status: open
topic: 同需求 fallthrough 交付 — rank[0]不可派→同被動求生組次佳;branch feat/same-need-fallthrough已push,待餓隊換食物策略終驗
---
# Hand Back: dispatch 同需求 fallthrough（PASSIVE_SURVIVAL_SET）

branch `feat/same-need-fallthrough`（已 push，疊 origin/main 含 survival-path）。spec `docs/superpowers/specs/2026-07-13-dispatch-same-need-fallthrough.md`（裁 A + PASSIVE 定案，2 輪 R² delta CLEAN）。

## 實作摘要
- `DecisionEngine.reorder_same_need_first(ranked)`：同 `_need_category` 在前、餘在後，穩定 partition 保 util 序。**rank[0] dispatchable→仍首試=NO-OP（byte-identical）**。
- `_need_category`：**`PASSIVE_SURVIVAL_SET=["覓食","買糧","乞食","返家補給","紮營","併入"]`**（被動求生：食物+投靠認慫）→"survival" 組；**★排攻擊型 掠奪/佔村**（主動侵略，靠人格 weight 主導，否則溫和 fed 隊誤 loot）；非→按 affinity 主層。
- wire：`_decide_unified` + `_evaluate_solo`（`rank_scored` 後加一行；loop body/conquest scout-verify/threat aux 不動）。
- TDD `_test_reorder_same_need`：同 need 優先 / 併入同組 / 掠奪不同組(esteem) / 全同層 NO-OP / 單空原樣。PASS。

## 設計歷程（2 卡點皆 systems 裁）
- 卡點1：main_layer 分組 → 併入(belonging affinity) 被埋破 p2a 投靠 → 裁 A survival-set 分組。
- 卡點2：survival-set 納 掠奪 → fed 溫和隊 fallthrough 誤 loot → PASSIVE 定案(排掠奪/佔村)。
- 我 gate 判斷（撞 spec-flagged 即停呈報，不自改準則）獲 systems 確認精準。

## 我方自驗（融合閘全綠）
- headless **0 新增 SCRIPT ERROR**（3 pre-existing 同 baseline）；`_test_reorder_same_need` PASS；**p1(`_test_p1_loot_option` 溫和 fed 不 loot) + p2a(`_test_p2a_survival_options`/`_join_player_forced` 投靠) 皆綠**。
- **constitution PASS**（sites=29）；**determinism byte-identical**（1337×1mo 兩跑 cmp；純迭代序改零 randf）。

## 待終驗（dispatch §驗收）
1. **★餓隊覓食失敗→試買糧/紮營/併入**（被動求生，非落生產）：Team7 式重跑，覓食 undispatchable → winner=食物類/投靠替代非生產。
2. **掠奪只靠 util**（殘忍/好戰隊）非 fallthrough：溫和隊不因 fallthrough 誤 loot。
3. **rank[0] dispatchable 不回歸（NO-OP）**：既有 dispatch byte-identical（determinism 已初驗）。
4. **p1(溫和 fed 不 loot)/p2a(忠義投靠) 綠**（我已驗 unit）。
5. **融合閘/9-zero 分布/consolidation/combat 不回歸**。

## 連動風險 / 註
- 純迭代序改（reorder），不動 rank_scored/util/coeff → rank[0] dispatchable 時 byte-identical；僅 fallthrough case 改次佳落點（同被動求生組）。
- 承接 survival-path（latch 重選 + FLEE gate）+ cadence（T-cad1/2）同 arc——共同解餓隊鎖死鏈。
