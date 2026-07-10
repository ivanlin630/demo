---
from: systems
to: implementer
status: open
topic: [C2 真根修] 整併升 survival-class——與 join sibling,絕境域競秤不被覆寫(blueprint 裁)
---

# C2 修：整併升 survival-class（絕境抱團求生）

blueprint 重裁 **C2 絕境併**（`c2-absdesperation-merge`）：整併升 survival-class（PRIO_SURVIVAL）= 與 join sibling 一致（join 本就是絕境 survival option）= 更統一非補丁。匹配 868/880 eligible 隊在絕境域的真實。join/整併=同求生本能不同尺度（join 個人脫離、整併整隊池化），fire 依凝聚力湧現。

## 改（5 點，我已讀完整條 survival dispatch 路確認）
1. **`options.gd:47` SURVIVAL_OPTION_SET += "整併"** → 整併經 `rank_survival`→`_trigger_survival` 派 @PRIO_SURVIVAL（不再被 survival-sticky 覆寫）。
2. **`options.gd:146` 整併 applicable + food gate**（比照 join `:99`）：`if ctx.consolidate_target_id != -1 and ctx.food_days < DecisionTerms.DESPERATION_DAYS: out.append(opt)`。
3. **`terms.gd` consolidate_drive 棄 C1 band → 復絕境 food-scaled**（比照 join `:91`）：
```gdscript
	"consolidate_drive":
		if opt != "整併" or ctx.consolidate_target_id == -1: return 0.0
		return DESPERATION_SCALE * maxf(0.0, DESPERATION_DAYS - ctx.food_days)
```
   （移除 C1 的 `< DESPERATION_DAYS: return 0` 與 CONSOLIDATE_DAYS；C1 band 作廢。weight 求生欲/1-野心 不變。）
4. **★`_trigger_survival` dispatch 尾補 order_target 接線**（`faction_ai:~3093`，combat_target/social_target 旁）——**此路真缺**（無 `_wire_threat_task` 呼叫，我讀確認）：
```gdscript
			if td.has("social_target"):
				state.set_social_target(team, int(td["social_target"]))
			if td.has("order_target"):
				team.order_target_id = int(td["order_target"])   # 整併 survival-class 需(此路缺,非 _decide_unified:1529 那條)
```
5. **A 到達重追蹤（已在 worktree）** 治 MERGE 追移動 absorber——C2 讓 task persist 到 movement 後才生效。

## 守則（blueprint 不可退）
- **★gate#1 非搬餓（絕境世界尤其關鍵）**：絕境併若「餓隊併餓隊」=搬餓加速集體餓死 → `_find_absorber` 餵養 gate 必須擋（併進有真 surplus absorber）。這是 C2 唯一防「絕境亂抱團」的閘。
- 隊數別崩塌（防過度併寡頭）。

## 驗（漏斗全站，你探針齊）→ measurer 依 blueprint 決策樹判
- `merge.set_ok`（整併 @PRIO_SURVIVAL）→ **`mv_reached>0`（不被覆寫）→ `pair_seen>0`（A re-track 追到）→ `merge_accept>0`（整隊合併真發生）**。
- gate#1 非搬餓（每 accept 事件 combined_days≫joiner 原餘命、absorber 併前 surplus>0）+ **隊數不崩塌**（隊數/最大隊 pop 佔比）+ 三 gate + churn。
- determinism/融合閘/憲法綠。**大窗用 detach+resume tooling（`godot-detach.ps1`+WARRING_RESUME，03b SOP）；worktree 記得 rebase main 拿新 bed。**

## 決策樹（blueprint 定，measurer 數字 to:blueprint）
- C2 產真聚合（accept>0/隊漸大/gate#1/不崩）→ blueprint signoff（flavor 誠實改「絕境抱團求生」）。
- C2 也≈0/marginal → **真願景 fork 升 user**（小-絕境隊世界結構抗拒 consolidation）。

worktree @93919f1 接著改。這是 C2 真根修（絕境域競秤）+ order_target survival-路接線（真缺口）+ A（已在）。
