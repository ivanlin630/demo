---
from: systems
to: implementer
status: consumed
topic: "[dispatch EWMA advance/gather 解耦(=specimen 非中立性【根修】、12mo 大考 blocker#1)·spec=2026-08-20-ewma-advance-decouple-HOW.md(含 §6 R²delta 判定表)·R²=CLEAN 零必查項·base main(§4c+繼承-lite 已 merged)·★根:gather 每呼一次就推進持久 EWMA(decision_context:565 need_urgency 非冪等 + :569 plan_phase 衍生)、全站 11 caller→同 tick 同隊推進次數=走過幾條路徑且取決於哪個選項贏=main 既存缺陷(你的 tracer 只是把它照出來)·★T1 gather(state,team,advance:bool=false):false(預設)→不寫 :565/:569、只保留 :566 c.need_urgency=team.need_urgency 拷貝;true→照現行推進+導 plan_phase·★T2 advance 判定表【spec 已定案別自己猜】:decision_engine:50/165=true;options.gd:167/185/219/251/383/395=false(to_task 是具體化非新評估);faction_ai:416=false(親讀 :410-432=threat 門檻 gate read、:432 呼 _decide_unified 內部再走 decision_engine:50 已 true、此處再 true=病徵本身);faction_ai:1881=false 且【通則擴及整個 side-dispatch 家族 distribute/migrant/herald/scout 全 false】;★faction_ai:917=true【條件式、要你親驗】它是獨立 ambient 決策入口但只在 current_task==TASK_IDLE(:916) 跑→【必須確認 uses_unified 隊會不會同 tick 先走 _decide_unified(已 advance)又因仍 IDLE 落到這段】、若會→對 uses_unified 隊降 false 只對非 unified/solo 維持 true·★T3 tap(憲法級):實推進處 Probe.bump('need.ewma_advance')、唯讀路 ('need.gather_readonly')→【驗收硬要求每隊每 tick 推進≤1 次】(這條 tap 就是 :917 判定的安全網)·★T4 零新結構:禁加 *_advanced_tick 欄或 TeamData 旗標·gate①★specimen_neutrality_bed(7specimens/seed1337/1200t)零分岔=oracle【若仍殘留分岔→gather 其餘寫入(ensure_fresh/labor_alloc/idle_employ_*/consolidate_* cache 群)也涉入→回報別自己擴大 slice】②推進≤1/隊/tick③det×3④constitution≤75+headless 0-new⑤fp intended-change+誠實說明(若求生/成長切換明顯變遲鈍→回報【禁自己 crank alpha】)⑥R²加固:長跑數百 tick 前後比 plan_phase 五層分佈、重心大幅位移=原病在餵養某被依賴行為模式→回報·worktree feat/ewma-advance-decouple·完→handback to:systems·地基KEEP"
---

# dispatch：決策狀態推進與讀取解耦（EWMA advance 出 gather）＝specimen 非中立性**根修**

spec=`docs/superpowers/specs/2026-08-20-ewma-advance-decouple-HOW.md`（含 **§6 R²delta 判定表**）。**R²=CLEAN、零必查項**。base=main（§4c + 繼承-lite 已 merged）。

你查出來的根**比 tracer bug 大一層**：`gather` 全站 **11 caller**，而它**每呼一次就推進一次持久 EWMA** → **同 tick 同隊推進次數 = 走過幾條路徑、且取決於哪個選項贏** ＝ **main 既存缺陷**，tracer 只是對每個候選呼一次 `to_task` 把它照出來。R² 親驗坐實 `consistency_coeff` 的回傳值**直接乘進每個 option 的 util**（`u *= _coeff`）→ `need_urgency` 是**直接改變 argmax 贏家**的乘數。

- **T1**：`gather(state, team, advance: bool = false)`。false（預設）→ 不寫 `:565`/`:569`，**只保留 `:566` `c.need_urgency = team.need_urgency` 拷貝**；true → 照現行推進 + 導 `plan_phase`。
- **T2 advance 判定表 → 見 spec §6（已定案，別自己猜）**。唯一要你親驗的是 **`faction_ai:917`**：它是獨立 ambient 決策入口（`rank_ambient`+`try_set`）語意上該 true，**但只在 `current_task == TASK_IDLE`(:916) 跑** → **確認 `uses_unified` 隊會不會同 tick 先走 `_decide_unified`（已 advance）、又因仍 IDLE 落到這段**；**若會 → 對 `uses_unified` 隊降 `false`**、只對非 unified/solo 隊維持 true。
- **T3 tap**（憲法級）：`need.ewma_advance` / `need.gather_readonly` → **驗收硬要求：每隊每 tick 推進 ≤1 次**（這條 tap 就是 :917 判定的安全網）。
- **T4**：零新結構，**禁**加 `*_advanced_tick` 欄或 TeamData 旗標。

## gate
①★`specimen_neutrality_bed`（7 specimens/seed1337/1200t）**零分岔**＝oracle。**若仍殘留分岔 → `gather` 其餘寫入（`ensure_fresh`/`labor_alloc`/`idle_employ_*`/`consolidate_*` cache 群）也涉入 → 回報、別自己擴大 slice**。②推進 ≤1/隊/tick ③det×3 ④constitution ≤75 + headless 0-new ⑤fp intended-change + 誠實說明（若求生/成長切換**明顯變遲鈍 → 回報，禁自己 crank alpha**）⑥R² 加固：長跑數百 tick 前後比 `plan_phase` **五層分佈**，重心大幅位移＝原病在餵養某個已被依賴的行為模式 → 回報。

worktree `feat/ewma-advance-decouple`。完 → handback to:systems。地基 KEEP。
