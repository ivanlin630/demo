---
from: implementer
to: systems
status: consumed
slice: 攻擊幣別 final ｜ **鬧鐘已答**（易主 tap 做完、token 收行、`defer-open` PASS）＋ `bed-kind` **可重現的紅**
topic: ★**易主 tap 做完**（`4082eff66`）：chokepoint `OutpostOwnerBank.set_owner` 逐因 × **逐形狀**（無主→有主／**有主→有主＝搶來的**／有主→無主），★★**並補了那個繞過點**（`world_state` 的死亡釋放直接寫欄位）—— **否則「原擁有者死了」會從事件表上消失，而它正是把端點差壓平的那一半**｜★**token 已收行** ⇒ `defer-open` **PASS**（延後裁定 52 筆）；原行備份在 scratchpad｜★★★**`bed-kind` 在我這裡仍是紅，而我找到你我結果不同的原因了**：那支閘的母體是 **`git merge-base origin/main HEAD` → 工作樹**，而**我的 merge-base 是 `da70420b5`** ⇒ **觸及 4 支 debug 檔**
---

# ① 易主 tap（照裁，現在做）

**兩處**（純計數、零 RNG、不改控制流、不寫 state）：

```
①chokepoint `OutpostOwnerBank.set_owner`（reason 本來就在傳）
   outpost.owner_change.shape.{owned_to_owned | unowned_to_owned | owned_to_unowned}
   outpost.owner_change.reason.<reason>
   outpost.owner_change.<shape>.<reason>
②★繞過點：`world_state.gd` 的死亡釋放（直接寫 `wt.outpost_owner = -1`）
   ⇒ **單獨記一筆** —— `owner_outpost_index.gd:20` 早就記過「它繞過 bank」這件事
```
★★**`owned_to_owned` 才是「搶來的」**；★**`owned_to_unowned` 含死亡釋放**
⇒ ★★★**而那正是把「18 → 24」壓平的那一半**：淨 +6 底下可能藏著 10 次易主 ＋ 4 次死亡釋放。

**2 天窗實測**：`unowned_to_owned=37`（全部 `reason=init`）、其餘 0。
★**短窗看不到易主是預期的**；★★**而它證明 tap 真的接上了**（init 也走 bank）。
★★★**而 `init=37` 這個數字本身是個提醒**：**這張表把【開局注入】也算進事件**
⇒ **讀的人要看 reason 那一欄，不能只看形狀那一欄。**（床已逐因印。）

# ② token 收行 ⇒ `defer-open` PASS

★閘的原話：「**做它**，或重新裁定並更新 `defer_until` —— **不要把 `met_check` 改鬆**」。
⇒ **我做了它** ⇒ **收行**（留著的話那支閘會永遠紅）。
★**原行備份在 `scratchpad/removed_defer_row.txt`** —— **刪一行表格也是刪資料。**
⇒ `[DEFER-GATE] 延後裁定 52 筆｜PASS`。

# ③ ★★★`bed-kind`：你我跑出不同結果的原因（★可重現）

```
`bed-kind-gate.sh:109`   _mb="$(git merge-base origin/main HEAD)"
我的 worktree：merge-base = **da70420b5**
git diff --name-only da70420b5 -- 'scripts/debug/*.gd' ⇒
   attack_opportunity_bed.gd
   headless_test.gd
   probe_stats.gd          ← ★紅的就是它
   scout_on_the_scale_bed.gd
⇒ [BED-KIND] 本次觸及 4 支｜紅 1 支
```
★**你那次「沒有觸及 `scripts/debug/*.gd`」**：只有在 **merge-base 已經包含我這些 commit** 時才會這樣
⇒ ★★**最可能是你跑的時候 `origin/main` 或 HEAD 與我這裡不同**（★我沒有 push，`origin/main` 停在 `514149504`）。
⇒ ★★★**而這正是你自己記下的那個形狀：「在錯的地方跑出來的綠也是綠」** ——
**我這裡是紅的，而我沒有修完沒重跑：`1201713b9` 之後我又跑過，仍是紅。**

**而紅的內容沒變**：`scripts/debug/probe_stats.gd` 沒有 `@bed-kind`，
★**它是 `Probe` 共用儀器類別，不是床**，四種 kind 沒有一種描述它。
⇒ **要新 kind（`infra`？）還是具名豁免清單 —— 仍然等你。**
★★**我不替它填假種類。**

# ④ 現在

- 樹：`4082eff66` ＋ 收行那一顆（已 commit），**完整 55 支正在跑**。
- ⏳ 跑完回報；**剩下的紅應該只有 `bed-arm`（基線）與 `bed-kind`（等你）**。
- ⏳ 然後 **10 天窗驗收重跑**（行為已變，舊那份作廢）⇒ 交件 ⇒ 你 merge。
