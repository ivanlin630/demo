# Spec：wave1 序2 — solo 子系統溶入引擎 + capability-grounded attack

> arc wave1 序2。承序1 threat 融合模式。**溶=融合非刪**。含藍圖 tag-soft-ruling 裁定：tag 不硬鎖、「不攻」由真實戰力湧現（attack eval capability-grounded）。系統 owner spec。

## 1. 目標與藍圖裁定

**現況違憲**（constitution-audit 序2）：`faction_ai_system.gd:1710` `_evaluate_solo` = 非 unified solo 隊自建 `scores` dict 手算 argmax = 平行第二決策引擎。

**目標**：solo 手算 argmax → 引擎 `rank_scored`（solo 隊語意同構主決策，鏡射 `_decide_unified`）。

**藍圖 tag-soft-ruling 三裁**（納入）：
1. **tag 不硬鎖**（去 `_tag_weight` hard-gate）。tag→軟 context 偏向（次要層）。
2. **「不攻」由真實戰力湧現，非 tag、非純人格 weight**：attack/loot eval **capability-grounded**（吃 self 戰力）——無牙商隊 attack eval 自然趨 0（送死沒人幹，非被禁）。= 憲法分辨線：硬鎖=「不准」（違憲）；戰力歸零=「送死」（世界事實，合憲）。
3. **融合驗含反向**：商隊沒變隨機劫匪、軍隊沒變雜貨商；常態不越界、只絕境/機會+有本錢才越界（率表看得出）。

## 2. 現 repertoire（融合驗錨——必保）

`_evaluate_solo`（fai.gd:1710-1779）scores over：

| task | 現權重公式 | REGISTRY option 對應 |
|---|---|---|
| ATTACK | (野心×0.4+好戰×0.4)×`_tag_weight` | 攻擊 |
| LOOT | (貪婪×0.5+好戰×0.3)×`_tag_weight` | 掠奪 |
| DIPLOMACY | max(野心×0.4−好戰×0.2,0)×`_tag_weight` | 外交 |
| FLEE（food_pc<2）| 求生欲×0.8 | survival |
| MANUFACTURE（_can_manufacture）| (貪婪×0.4+0.2)×`_tag_weight` | 生產 |
| TRADE（_can_trade）| (貪婪×0.5+0.3)×`_tag_weight` | 貿易 |
| GOVERN（own outpost + vault<target）| (慎重×0.4+野心×0.2+0.15)×`_tag_weight` | 駐守 |
| CAMP（無 own + farmable）| 求生欲×0.3+慎重×0.3+野心×0.3 | 紮營 |
| JOIN（無 own + strong neighbor）| 義氣×0.4+求生欲×0.4 | 投靠 |
| IDLE | 0.1 baseline | default |

**scaffolding（保留）**：idle-gate（`current_task != IDLE and not _is_stuck` return）、`solo_task_last` 承諾慣性（`SOLO_COMMITMENT_BONUS`）、征服名實 Probe（`conq.*`）。

**★所有 REGISTRY option 已存在**（序1 已補 threat option；solo 全部 9 option 皆在）。序2 主體 = 刪手算、route rank_scored、去 tag hard-gate、補 capability grounding。**無新 option**。

## 3. capability-grounding 缺口（藍圖裁 2 的 HOW）

現引擎 attack/loot 的 self-戰力 grounding：
- **掠奪 loot_drive**：`has_weak_prey` gated。但 prey weakness = `1 − prey_armed_est / self_**population**`（fai.gd:186-187）——**用 self POP 非 self ARMED**。→ 大 pop 無武器商隊仍視 prey「弱」→ 被誘攻（藍圖怕的洞）。
- **攻擊 attack_drive**：僅 `"攻擊" in faction_stakes` fire（solo fid=−1 恆 0）。
- **_intent_fit 征服**：`攻擊` boost 需 `intent_target != -1 or has_weak_prey`。has_weak_prey 分支同上 self-POP 問題。
- **舊 _evaluate_solo**：ATTACK/LOOT 純人格×tag-gate，**零 grounding**（比引擎更糟；tag-gate 是唯一擋商隊攻擊的東西——去掉它必須補 grounding，否則商隊劫匪化）。

**修（capability-grounded）**：引入 **self combat capability 因子**，attack/loot（及 prey-weakness 判定）吃之：
```
self_armed_ratio = effective_armed(team) / max(team.population, 1)
# effective_armed = Σ 武器裝備 + 戰兵 anon（既有 combat 力估，鏡射 threat_assessment 的 self_power=pop×avg_combat_skill 或 armed_anon）
```
- **prey weakness 改比 self ARMED**：`weakness = 1 − prey_armed / max(self_armed, ε)`（非 self_pop）→ 無牙商隊 self_armed≈0 → weakness→負/趨0 → prey 不再「可打」→ has_weak_prey=false → 掠奪/攻擊 eval 0。
- **attack/loot eval 疊 self-capability 閘**：`loot_drive`/`_intent_fit 攻擊` 乘 `capability_factor = clampf(self_armed_ratio / VIABLE_ARMED_RATIO, 0, 1)`（無牙→0，武裝足→1）。
- **憲法**：這是「送死不划算」的世界事實（像無糧不能行軍），非行為腳本。合憲。VIABLE_ARMED_RATIO = TEST VALUE 待平衡校。

**範圍守**：capability-grounding 只加 self-戰力**事實**進 eval，**不**加「商隊 tag→禁攻」的 label 判斷（那才違憲）。tag 完全不進 gate。

## 4. tag hard-gate 移除（藍圖裁 1）

- **去 `_tag_weight` 乘數**：solo route rank_scored 後不再乘 `_tag_weight`。
- **tag→軟 context（次要層，最小落地）**：藍圖允許 tag 明顯偏向但次要。**本 slice 最小化**：不新建 tag-weight 系統（那是 F-D5 另軌）；tag 的行為傾向主要由 **capability grounding（§3）+ 既有人格 weight** 承載（軍隊 leader 通常好戰高→attack weight 高 + 有戰兵→capability 足；商隊 leader 通常好戰低 + 無戰兵→capability 0）。**驗證若顯示 tag 傾向不足**（如軍隊不夠好戰 / 商隊誤攻）→ 再議加輕量 tag context term（記 known_issues，不擋本 slice）。
- **unified 側不改**（藍圖裁：已軟）。只 solo 對齊 + capability grounding（capability grounding 進共用 eval → unified 隊也受益，一致化，非改壞：unified 商隊本就能攻，加 grounding 後無牙 unified 商隊也趨不攻=更對）。

## 5. 目標架構（鏡射 _decide_unified）

`_evaluate_solo` 非 unified 分支（fai.gd:1719 後）改：
```gdscript
	# 手算 argmax 撕除 → 引擎 rank_scored（融合非刪；鏡射 _decide_unified）
	var ctx := DecisionContext.gather(state, team)
	for opt in DecisionEngine.rank_scored(ctx):
		var td: Dictionary = DecisionOptions.to_task(state, team, opt)
		if int(td.get("task", TeamData.TASK_IDLE)) == TeamData.TASK_IDLE: continue
		# 征服名實 Probe（保留，opt→task 映射後判）
		_solo_conq_probe(team, opt)
		if not TaskArbiter.try_set(state, team, td["task"], td.get("target", ...), TaskArbiter.PRIO_DISPATCH, "solo"): continue
		_wire_threat_task(team, td)   # 序1 共用 helper，接 aux target
		team.solo_task_last = td["task"]   # 承諾慣性（保留 scaffolding）
		break
```
- **idle-gate/stuck-recheck/solo_task_last 承諾**：保留（scaffolding）。承諾慣性 = 引擎 `COMMITMENT_BONUS`（current_option）已有 → 評估用 `team.current_option` 或保 `solo_task_last`？**對齊**：solo 走 rank_scored → 用引擎 current_option 承諾（消 solo_task_last 雙軌）；若行為漂移則保 solo_task_last 疊加。實作驗。
- **刪 `_evaluate_solo` 的 scores dict + argmax（fai.gd:1722-1770）**。`_tag_weight` 若無其他 caller 一併刪（grep 確認——subteam idle 1690 也用，故 `_tag_weight` 可能保留給 subteam；查）。
- 征服 Probe：opt=="攻擊"→conq.winner_prosperity、"掠奪"→conq.winner_loot、其他→conq.winner_other（映射保 probe 語意）。

## 6. 融合驗（★含反向，藍圖裁 3）

`scripts/debug/solo_dissolution_check.gd`（鏡射 threat_dissolution_check）：

### 6a. repertoire 沒少（9 反應可達）
人格×情境原型，assert rank_scored 首選對應：好戰野心+有戰兵+弱prey→攻擊；貪婪+弱prey→掠奪；貪婪+市場→貿易；慎重+own outpost→駐守；求生欲+無own+farmable→紮營；義氣+strong neighbor→投靠；絕境→survival。每個可達。

### 6b. ★反向驗（capability-grounding，藍圖核心）
- **無牙商隊不劫匪化**：商隊隊（好戰低、**無戰兵/武器**）+ 弱 prey 在場 → assert 攻擊/掠奪 **不**在首選（capability_factor≈0 壓平），常態選貿易/survival。
- **重甲商隊絕境可揮刀**：商隊隊（**有戰兵護衛**）+ 絕境 + 弱 prey → 掠奪可成立（capability 足 + 匱乏→搶 intent_fit）。→ 證「鎖來自戰力非 label」。
- **軍隊不變雜貨商**：軍隊隊（好戰高+有戰兵）→ 常態 attack/patrol 傾向在（人格 weight + capability），非誤選貿易。

### 6c. 率表 + 回歸
seeded warring：solo 隊 task 分佈，assert 商隊隊攻擊率≈0（除絕境+有本錢）、軍隊隊攻擊率保持。seeded 漂移允許（QA wave 級判）+ framework PASS=7 + 憲法閘（`_evaluate_solo` 手算指紋處理）。

## 7. 憲法閘 baseline
`_evaluate_solo` 現有 `TaskArbiter.try_set`（1702 subteam、solo dispatch）→ 指紋 `faction_ai_system.gd::_evaluate_solo`。溶入後 dispatch 仍在此 func（trigger 保留），try_set 仍在 → 指紋不變或微調。實作跑閘確認 removed/add，同 commit 更新 baseline，標 `# 序2 solo 溶入`。

## 8. 待藍圖 / 交付後序
- **無新 WHAT 待裁**（tag-soft-ruling 已定 capability-grounded 方向）。
- VIABLE_ARMED_RATIO / capability_factor 係數 = TEST VALUE，平衡校待 wave QA。
- spec → plan（TDD，融合驗+反向驗 first）→ 子 session。序2 綠 → 序3 rung_task（查表判斷器溶進 ambient_drive term）。
