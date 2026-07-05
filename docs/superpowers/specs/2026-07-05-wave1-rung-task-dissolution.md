# Spec：wave1 序3 — rung_task 查表判斷器溶入引擎

> arc wave1 序3（wave3 清掃首張，arc-order 排 threat→solo→rung→vendetta→灰項）。承序1/2 融合模式。**溶=融合非刪**。系統 owner。

## 1. 目標

**現況違憲**（constitution-audit 序3）：`ambition_ladder.gd:105 rung_task` = `(archetype, rung) → 固定 task` 查表 = 教科書判斷器（prescribe 而非 weigh）。**唯一真 caller** = `faction_ai:774`（loop3, PRIO_AMBIENT, `current_task==IDLE` idle-filler）。

**目標**：查表撕除 → rung/archetype 當 **weight** 驅動對應 option（非塞 task）；idle-filler 走引擎 rank。

## 2. 現 repertoire（融合驗錨）

`rung_task` 查表：
| rung × archetype | → task | 既有 option 覆蓋 |
|---|---|---|
| ACCUMULATE × FORCE | TASK_TRAIN（練兵，`training_system`）| **✗ 無 option（序3 補）** |
| ACCUMULATE × TRADE | TASK_TRADE | ✓ 貿易（economic_opp/貪婪）|
| ACCUMULATE × SETTLE | TASK_PRODUCE(MANUFACTURE) | ✓ 生產（produce_need/ambition_drive）|
| EXPAND × FORCE | ""（讓 `_evaluate_prosperity_attack`）| ✓（序2 yield 保）|
| EXPAND × TRADE | TASK_TRADE | ✓ 貿易 |
| EXPAND × SETTLE | TASK_BUILD | ✓ 建設（settle_fit/ambition_drive）|
| else（SURVIVE/STATE/HEGEMON）| ""（讓 survival/faction strategic）| ✓ |

**★關鍵發現**：TRADE/SETTLE mapping **已冗餘**（既有 option+term 覆蓋：TRADE-archetype 隊 貪婪高→貿易 option 自然勝；SETTLE-archetype→生產/建設 ambition_drive）。**唯一真缺 = 訓練 option**（FORCE-archetype 累積階練兵）。

## 3. 目標架構

序2 後 solo 隊已走 `rank_scored`（loop2）→ loop3 idle-filler `rung_task` 只剩**未經 solo/unified 派發的 idle 隊**（多為 faction member，序6 域）+ 邊角。序3：

1. **補 訓練 option**（REGISTRY + train_drive term + train weight + to_task + applicable）。
2. **idle-filler 走引擎 rank**：`faction_ai:773-786` 的 `rung_task` lookup + 手動 dispatch → 換 `DecisionEngine.rank_scored` 取首 dispatchable（PRIO_AMBIENT）。archetype/rung 當 weight（train_drive 讀之），非查表塞 task。
3. **刪 `rung_task`**（ambition_ladder.gd:105-111 整函數）。

**憲法**：archetype/rung 成 weight term（context 權重），非 `(archetype,rung)→task` 查表。合「身分/狀態=權重非路徑」。

## 4. 具體改動

### 4a. 訓練 option（options.gd）
```gdscript
# REGISTRY
"訓練":   [["train_drive", "train"]],
# applicable：FORCE archetype + 累積/擴張階 + 有兵可練（有 anon）
"訓練":
	if ctx.archetype == AmbitionLadder.ARCHETYPE_FORCE and ctx.has_trainable: out.append(opt)
# to_task
"訓練": return {"task": TeamData.TASK_TRAIN, "target": team.tile_pos}
```

### 4b. train_drive term + train weight（terms.gd）
```gdscript
# eval（opt-gated；FORCE 累積階練兵驅力，rung 低=更該攢實力）
"train_drive":
	if opt != "訓練": return 0.0
	return ctx.ambient_train_drive   # 見 4c（archetype/rung 導出）
# weight（人格：好戰/野心=練兵傾向；ambient 低 magnitude 讓位緊急決策）
"train":
	return 0.3 + 好戰 * 0.4 + 野心 * 0.2
```

### 4c. DecisionContext（ctx.gd）
加 `ctx.archetype`（`team.ambition_archetype`）、`ctx.rung`（`team.ambition_rung`）、`ctx.has_trainable`（有 anon 可練）、`ctx.ambient_train_drive`（FORCE + 累積/擴張階 → base，否則 0；低 magnitude ~0.3-0.5 讓位）。

### 4d. faction_ai:773-786 idle-filler 換引擎 rank
```gdscript
	# G2c 野心階梯常態行為（最低優先，只填 idle）：查表撕除 → 引擎 rank（ambient weight）
	if team.current_task == TeamData.TASK_IDLE:
		var ctx := DecisionContext.gather(state, team)
		for opt in DecisionEngine.rank_scored(ctx):
			var td: Dictionary = DecisionOptions.to_task(state, team, opt)
			if int(td.get("task", TeamData.TASK_IDLE)) == TeamData.TASK_IDLE: continue
			if TaskArbiter.try_set(state, team, td["task"], td.get("target",...), TaskArbiter.PRIO_AMBIENT, "ambition"):
				if td["task"] == TeamData.TASK_TRADE: Probe.bump("trade.dispatch.ambient")
				break
```
（貿易 target 走 `_merchant_trade_target` 已在 to_task「貿易」內；ambient 語意保。）

### 4e. 刪 rung_task
`ambition_ladder.gd:105-111` 整函數刪。caller fai:774 已換（4d）。

## 5. 融合驗（`rung_dissolution_check.gd`）
- **repertoire**：FORCE-累積隊（有兵）→ rank 含 訓練 可達；TRADE-archetype 隊 → 貿易；SETTLE-累積 → 生產；SETTLE-擴張 → 建設；FORCE-擴張 → 讓位 prosperity（不搶）。
- **該出現還出現**：seeded 練兵 dispatch 率 > 0（`TASK_TRAIN` 發生）；貿易 ambient 率保（`trade.dispatch.ambient` probe 不歸零）。
- **回歸**：seeded（現 52/8/1/380，漂移允許 QA wave 判）+ framework PASS=7（S3 scout 不 DORMANT）+ threat/solo 融合驗仍綠 + 憲法閘。

## 6. 憲法閘 baseline
`rung_task` 在 `ambition_ladder.gd`，**無 TaskArbiter 呼叫**（回字串）→ 不在 32 指紋（coverage 誠實限制內，序0 已聲明）。刪它不動閘指紋。fai:773 idle-filler 的 `try_set` 在 `_evaluate_all_body`（已在 baseline）→ 換引擎 rank 後 try_set 仍此 func → 指紋不變。**閘應無變**，實作確認。

## 7. 待藍圖 / 後序
- **無新 WHAT 待裁**（rung_task 溶入語意同構，訓練 option 是既有 TASK_TRAIN 的 option 化）。train weight 係數 = TEST VALUE 待 wave QA。
- spec → plan → 子 session。序3 綠 → 序4 vendetta（feud_pull term 掛攻擊 option）。
