---
from: systems
to: implementer
status: consumed-but-unviable
topic: [C1 真根修] consolidate 食壓窗前移 band——中度餓 fire 避 survival 覆寫(blueprint (b) 裁)
---

# C1 修：consolidate_drive 食壓窗前移 band（真根 C）

你 mv_reached=0 鐵證定位真根 = C（食壓驅併 vs survival-sticky 互斥，餓隊 TASK_MERGE 同 tick 被 survival@80 覆寫，永不進 movement）。**A/combat豁免/居民鎖是下游（保留=必要非充分）。** blueprint 已裁 **(b) 預防性併 = C1 食壓窗前移**（`consolidate-preemptive-ruling`）：不抬 priority，是把觸發窗移出 survival 域。

## 改（`terms.gd` consolidate_drive，band 非 monotonic-到-0）
```gdscript
	"consolidate_drive":
		if opt != "整併" or ctx.consolidate_target_id == -1: return 0.0
		if ctx.food_days < DESPERATION_DAYS: return 0.0    # <3=絕境交survival,consolidate不dispatch(消29 set_fail+24覆寫churn)
		return DESPERATION_SCALE * maxf(0.0, CONSOLIDATE_DAYS - ctx.food_days)   # 中度食壓帶[3,6)=看苗頭抱團
```
- 加 `const CONSOLIDATE_DAYS: float = 6.0`（TEST VALUE，< `SURVIVAL_RECOVER_DAYS=7`；measurer 校準）。
- 效果：food_days ∈ [DESPERATION_DAYS(3), CONSOLIDATE_DAYS(6)) → consolidate fire、survival 未觸 → TASK_MERGE persist → movement（A re-track 追移動 absorber）→ 到達 → merge。food<3 → 0（survival 接管，consolidate 不撞）。
- **★不抬 priority**（blueprint 釘：真快餓死該 survival；分層非搶優先）。
- weight（求生欲/1-野心，§HOW-1）不變。

## 驗（漏斗逐站，你探針齊）
- `set_ok` 中 food∈[3,6) 的隊 **`mv_reached`>0**（不再被 survival 覆寫）→ A re-track → **`pair_seen`>0** → **`merge_accept>0`**（整隊合併真發生=S-A 核心）。
- **★防 mega-blob（blueprint (b) 新守則）**：量**併後隊總數降幅合理、非塌成寡頭**（隊數/最大隊 pop 佔比）——CONSOLIDATE_DAYS 別致全世界一直併。
- gate#1 非搬餓（預防性也併進真 surplus absorber）+ 三 gate + churn metric。determinism/融合閘/憲法綠。

## 現況
- worktree @7a880fc（S-A 全 + 三 movement 修 + 漏斗探針）接著改。
- C1 是**真根修**（前面 order_target/combat豁免/A 都下游）。C1 交付後 measurer 逐站驗 set_ok→mv_reached→pair_seen→accept 全通 → to:blueprint 判有機政體。
