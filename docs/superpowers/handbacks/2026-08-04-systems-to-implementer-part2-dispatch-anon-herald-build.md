---
from: systems
to: implementer
status: consumed
topic: "[dispatch build Part2 dispatch fix(R²CLEAN+1輕追蹤,spec=2026-08-04-infonet-part2-dispatch-anon-herald-HOW.md,blueprint裁GO)·root=bootstrap修好applicable但dispatch=0(_dispatch_help_herald:1446 _pick_subteam_leader==-1整段return false,小餓resident無spare named送不出)+seed1337 regression·fix兩part:①applicable gate於spawn-ability(DecisionContext加can_send_herald=population>=2/can_send_scout=named_members.size()>=2,options.gd求援/偵察applicable加此flag,look-before-leap同has_buyable_food,治regression+誠實)②求援herald reframe=anon 1人messenger(_dispatch_help_herald spawn路換:不用subteam_system.dispatch(結構需named),新_spawn_anon_herald建1-pop team leader_id=-1[既有phantom pattern:153/200]+從mother anon扣1[AnonTierSystem.transfer_proportional既有],current_task=TASK_HERALD task_reason=help_call[branch:1852已存在],物理走+delay沿_tick_help_herald,抵達deposit simple distress進目標team_known,途中可死走既有encounter)·偵察保留named subteam互補·★R²輕追蹤(硬守):anon信使空手走=只搬1 anon pop零resource carry(dispatch() proportional-split會搬母隊全部資源類型糧/材/coin,缺糧小resident任何流失都在乎,別沿用proportional-split信使空手)·守:util一字不改genuine/anon carrier零特權只送distress守5界/determinism零新randf/★全量tap(help.herald_dispatched·can_send_herald gate命中)·branch續feat/info-network-whole·完HANDBACK to:systems我路measurer re-measure whole(canonical harness,驗herald_dispatched>0+distribute>0+regression消+scout領主spare named假設)→QA"
branch: feat/info-network-whole
---

# dispatch build — Part2 dispatch fix（①gate + ②anon 信使、R² CLEAN + 1 輕追蹤）

**spec**：`docs/superpowers/specs/2026-08-04-infonet-part2-dispatch-anon-herald-HOW.md`（R² CLEAN）。**branch**：續 `feat/info-network-whole`。

## 建什麼
### ① applicable gate（look-before-leap、治 seed1337 regression + 誠實）
- DecisionContext 加：`can_send_herald = team.population >= 2`、`can_send_scout = team.named_members.size() >= 2`（純算術零 RNG）。
- `options.gd` 求援 applicable += `and ctx.can_send_herald`；偵察 applicable += `and ctx.can_send_scout`。
- → unexecutable option 永不進 rank（治 regression）+ 誠實。

### ② 求援 herald = anon 1人 messenger（reframe `_dispatch_help_herald`）
- **spawn 路換**：不用 `subteam_system.dispatch`（結構需 named sub_leader）→ **新 `_spawn_anon_herald`**：建 1-pop team、**`leader_id = -1`**（既有 phantom-leader pattern `subteam_system:153/200`）、**從 mother anon 扣 1**（`AnonTierSystem.transfer_proportional` 既有）、`current_task=TASK_HERALD`、`task_reason="help_call"`（tick branch `faction_ai:1852` 已存在）。
- **內容 simple distress**（母隊 need「我餓、在 X」）、**非複雜情報**。
- tick 沿 `_tick_help_herald`：物理走 target_pos（delay）→抵達/co-located deposit distress 進目標 team_known→畢。**途中可死**（1-pop 走既有 encounter/attrition 結算、不特赦）。
- gate：`population >= 2`（同 ①）。

## ★R² 輕追蹤（硬守）
- **anon 信使空手走＝只搬 1 anon pop、零 resource carry**。`dispatch()` 的 proportional-split（`subteam_system:36-42`）會按 pop frac 搬母隊**全部資源類型**（糧/材/coin）——**缺糧小 resident 任何非必要流失都在乎**。**`_spawn_anon_herald` 別沿用 proportional-split**、信使空手（只帶自己 1 pop）。

## 守（build 硬守）
- **genuine 非 crank**（[[feedback_genuine_value_not_crank]]）：help/scout **util 一字不改**（發不發=leader 人格秤）；① gate=可執行性 look-before-leap（同 `has_buyable_food` 前例）非 crank。
- **②非新感知（守 5 硬界）**：anon carrier **零特權知識**（不讀 target live state、只送 simple distress；名冊 target_pos 仍 position-only 組織常識）；`constitution_gate` 綠。
- **determinism 零新 randf**（spawn/travel 確定性；途中死走既有 encounter RNG=既有非新引）。
- **★全量 tap**（[[feedback_full_transient_observability]]）：`help.herald_dispatched`/`can_send_herald` gate 命中/anon spawn——餵 measurer 驗 Part2 真活。

## 驗收（re-measure whole、我路 measurer）
- **`help.herald_dispatched > 0`**（小餓 resident 現能送 anon 信使）+ **`distribute.dispatch / food_delivered > 0`**（症1：distress 達領主→distribute fire→convoy 送糧）。
- **seed1337 regression 消**（① gate 後 can't-send neutral）+ scout 領主 spare named 假設驗（scout.dispatched）。
- 人格分化保留、Part1+3 不退、determinism byte-identical、economy 不爆（+ 追蹤：無異常資源流失）。

**完 → HANDBACK `to:systems` → 我路 measurer re-measure whole（canonical `WarringHarness.run()` 掛 specimen 中性、禁手寫 loop）→ QA 故事稽核（回溯三因果+whole、verdict ref）→ blueprint 對用戶驗收。** 卡 → 報 `to:systems`。
