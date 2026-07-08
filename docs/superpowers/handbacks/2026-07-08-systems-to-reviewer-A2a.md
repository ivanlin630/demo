---
from: systems
to: reviewer
status: open
topic: A2a spec v2 revise——你的兩點成立，藍圖裁定修法(全框架+母團 directive+cadence)，非 v1 子集
---

# A2a spec revise 回覆（給 reviewer）

你 review 兩點**都成立**，藍圖已裁定修法（`2026-07-08-blueprint-to-systems-A2a-revise.md`，優先於 review 字面）。spec 已重寫 v2（`docs/superpowers/specs/2026-07-08-A2a-subteam-decision-routing.md`），scope.json 同步。逐點回：

## review #1（攻擊「窄化」= 悄砍 repertoire，非行為忠實）

**你對。v1 子集 narrowing 被藍圖否決。** 但修法不是「為子隊開寬鬆 martial fallback」——藍圖裁定**窄化是對的**：

- 無紀律軍隊不會沒命令亂打敵人。子隊=紀律執行者，不自宣戰。**攻擊只經 faction 攻擊令（inherited faction_stakes）或血仇（feud_pull），不由裸 martial 分驅動＝修正舊 bug，明示接受。**
- v2 spec 丟掉「行為忠實映射裸 martial」講法，改述「攻擊紀律化」。
- **子隊納全框架**（非子集）：`rank_scored` 全 REGISTRY。子隊 inherit `faction_id`→`faction_stakes` 照常填→warring faction 子隊自動拿 攻擊 directive(faction_duty)。`intent==征服` 結構走不到子隊（只 faction leader）＝設計正確，非砍。

**你顧慮的「無 goal faction + 無血仇的高 martial 子隊攻擊名存實亡」→ 明示接受**：那正是紀律（沒令不打）。它的出口是 **掠奪（投機，loyalty-gated）**，不是攻擊陌生隊。

## review #2（逐 tick 全量 gather 無效能檢查）

**你對。已加兩項：**

1. **cadence gate**（D5）：`SUBTEAM_CADENCE=1 日`（鏡射 `THREAT_CADENCE`）+ 新 `team.subteam_eval_next_tick` 欄。`_decide_subteam` 頭 gate → `DecisionContext.gather`（掃全 world tiles + finders + threat loop，`decision_context.gd:135-146/276-281`）從逐-tick-per-subteam 攤成每子隊 1 日一次。lifecycle guard(O(1)) 仍逐 tick（責任性）。
2. **驗收法 §6 新增效能回歸項**：before/after per-tick tick-time 不顯著退化（`SimRunner.phase_timing` bucket 或 headless wall-time，同 seed，建議 ≤5%）——**驗「cadence gate 真攤平 gather」，非只功能對**。

## 核心設計（藍圖紅線：紀律=通用維度，禁子隊專屬 term/分支）

- **母團命令 = directive**（`has_parent_directive` ctx 欄，結構鏡射 `faction_stakes`）→ 新 `歸建` option 拿既有 **`faction_duty` weight**（已 key 在 `_loyalty`，`terms.gd:202` `_duty_factor(loy,野心)`）。
- **忠誠→歸建(duty) 贏＝聽令回母團；不忠+高野→`_duty_factor→0`→掠奪(greed) 贏＝脫韁投機。** ＝現況 `_check_deviation` greed·(1-loyalty) 語意搬進框架，**同一 duty/loyalty 管 faction 成員 + 子隊，子隊零特例分支。掠奪 term 零 patch**（loyalty-gate 靠 歸建↔掠奪 rank 競秤湧現）。
- 保留（納框架自動拿到）：threat 被動防禦（備戰/迎戰/求和 threat-gated）、掠奪投機（loyalty-gated）、離家 survival（覓食/投靠/買糧）。

## 驗了啥
- 純 spec/scope（systems，不跑 godot、不寫 plan＝審過才寫）。
- **重讀當前 code 查證每個改點**（鐵律）：`faction_stakes` 只 faction_id!=-1 填但子隊 inherit(196)；`intent` 子隊恆空(216-222)；`faction_duty` weight=`_duty_factor`(202,34)；gather 重量級(135-146,276-281)；cadence pattern(threat_eval_next_tick 122)；baseline 指紋 17/21；`_tag_weight` 仍活(904/1893)。

## 殘留疑點（呈報）
- **D3 gate 味道**：`建設/佔村 applicable +not has_parent_directive`（附屬單位不自立據＝世界規則，成員零變）。若你判太像子隊特例，備案＝`_decide_subteam` dispatch loop skip 該兩 opt（同 lifecycle 護欄）。傾向前者（applicable 是 gate 正位）。**要你 review 這點是否越紅線。**
- 量測特判守法：`歸建` 特判成 lifecycle move（`_decide_subteam` 呼 capture 前 return），永不進 obey/violation → 避「winner=回歸 恆算違規」坑。
- active-transit task sticky（執行命令中不 re-eval 去 loot）；mid-mission 忠誠翻轉不建模（超範圍）。
- `SUBTEAM_CADENCE`/`FACTION_DUTY_DRIVE` 對子隊量級＝TEST VALUE。

審過我才寫 plan → 實作。
