---
from: systems
to: implementer
status: consumed
topic: "[dispatch build distribute side-dispatch(R²CLEAN無新追蹤,spec=2026-08-04-infonet-distribute-side-dispatch-HOW.md,blueprint RATIFY,症1雙端對稱最後一步)·root(RE-measure#5坐實):de-scan解候選生成candidate_eval 0→680但dispatch仍0 T0領主恆覓食=distribute留主argmax輸覓食(同herald/scout舊病)·fix=distribute脫主argmax→平行side-dispatch:1移goal_resolver frontier_candidates:117 out.append_array(_distribute_candidates(...))(主argmax winner不變determinism-neutral移loser)2新_try_distribute_side(faction_ai抄_try_herald_side:1652模板:pop/throttle前濾→need-gate→target→mini-util→Probe tap四段)每faction領主reuse _distribute_candidates算最佳賑濟候選(已de-scan belief+人格零god-view零死常數),mini-util=該候選util>0且not throttled(一領主一in-flight distribute convoy,讀task_extra_data.convoy_phase kind=distribute)→_dispatch_convoy(:3311 reuse,kind=distribute)·置side-dispatch pass(_try_herald_side/_try_scout_side旁:1648-1649)·守:主argmax零改determinism byte-identical(除relief convoy效果)/mini-util genuine=既有de-scanned util一字不改只換觸發路徑非crank/★side-action邊界=只herald/scout/distribute三型明列非泛化框架(新增需blueprint sign-off,spec已寫)/determinism零新randf/economy food_surplus守reserve/★全量tap(distribute.dispatch·mini_util·throttle命中同_try_herald款observability)·branch續feat/info-network-whole·完HANDBACK to:systems我路measurer re-measure症1端到端on FACTION bed(distribute.dispatch>0+糧真到resident runway回升=症1首次閉環)→QA"
branch: feat/info-network-whole
---

# dispatch build — distribute side-dispatch（R² CLEAN、blueprint RATIFY、症1 雙端對稱最後一步）

**spec**：`docs/superpowers/specs/2026-08-04-infonet-distribute-side-dispatch-HOW.md`（R² CLEAN）。**branch**：續 `feat/info-network-whole`。
**root（RE-measure #5 坐實）**：de-scan 解候選生成（`candidate_eval 0→680`）但 dispatch 仍 0、T0 領主恆覓食＝distribute 留主 argmax 輸覓食（同 herald/scout 舊病）。

## 建什麼（distribute 脫主 argmax → 平行 side-dispatch）
1. **移主 argmax**：`goal_resolver frontier_candidates:117` 刪 `out.append_array(_distribute_candidates(...))`（distribute 不再進 rank_scored 主池、winner 不變 determinism-neutral）。
2. **新 `_try_distribute_side`**（`faction_ai`、**抄 `_try_herald_side:1652` 模板**：pop/throttle 前濾 → need-gate → target → mini-util → Probe tap 四段）：每 faction 領主：
   - **reuse `_distribute_candidates`** 算最佳賑濟候選（已 de-scan：belief+人格、零 god-view、零死常數）。
   - **mini-util=該候選 util > 0** 且 **not throttled**（一領主一 in-flight distribute convoy、讀 `task_extra_data.convoy_phase` kind=distribute）→ **`_dispatch_convoy`（`:3311` reuse、kind="distribute"）**。
   - 置 side-dispatch pass（`_try_herald_side`/`_try_scout_side` 旁 `:1648-1649`）。

## 守（build 硬守）
- **★主 argmax 零改動**：移 `_distribute_candidates` 出 frontier → 主決策 winner 不變（**determinism byte-identical**、除 relief convoy 世界效果）；不動主秤。
- **mini-util genuine 非 crank**（[[feedback_genuine_value_not_crank]]）：mini-util=**既有 de-scanned distribute util（relief+coin）一字不改、只換觸發路徑**（主 argmax → side）。非 crank。
- **★side-action 邊界**：只 **herald/scout/distribute 三型明列**、**非泛化/可插拔 side-task 框架**（新增型需 blueprint sign-off、spec 已寫）。
- **determinism 零新 randf**（mini-util 算術、throttle 讀既有 convoy_phase）+ **economy 不爆**（food_surplus 守 reserve）。
- **★全量 tap**（[[feedback_full_transient_observability]]）：`distribute.dispatch`/`mini_util 值`/throttle 命中（同 `_try_herald_side` 款 observability）——餵 measurer 驗症1 閉環。

## 驗收（re-measure 症1 端到端 on FACTION bed、我路 measurer）
- **`distribute.dispatch / food_delivered > 0`**（領主現平行派賑濟 convoy、不再輸主 argmax）。
- **★糧真到 resident runway 回升**（端到端真效果、[[feedback_verify_execution_end]]、**症1 首次閉環**）。
- 人格分化（仁慈/責任高領主救子民）+ 主 argmax determinism + letter delivered/scout/Part1+3 不退 + economy 不爆 + 不凍。

**完 → HANDBACK `to:systems` → 我路 measurer re-measure 症1 端到端（`lord_distribution_bed`/`peaceful_economy_bed`、糧真到 resident、`GODOT_TIMEOUT=1200`）→ QA 故事稽核（回溯三因果+whole、verdict ref）→ blueprint 推用戶驗收。** 卡 → 報 `to:systems`。
