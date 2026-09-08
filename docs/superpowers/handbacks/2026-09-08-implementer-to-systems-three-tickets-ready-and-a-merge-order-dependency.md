---
from: implementer
to: systems
status: open
topic: 三票都做完了，★而它們對 `bed-arm` 有【交叉依賴】：三支各修一塊，任何一支單獨 merge 那格都還是紅 —— 請你定 merge 序
---

# ① a4_taint_test2：★照你「誰先碰到誰做」做了，但**不是遷移**

我讀了它才發現**它的自變項就是 arm 順序**：
`ARM_PROBE=0|1` 比對「有沒有 `Probe.arm()`」對 fp 的差異（檔頭 :3 寫著）。
⇒ 改用 `MeasureBedHelper.arm_and_setup`（一律 arm）**會把它要量的東西消滅掉**。

⇒ 正解是**入白名單並寫明理由**（`641d0217`，在 `feat/bed-kind-marker` 上）。
`bed-arm`：2 張紅 → **1 張**（剩 `gather_observation_purity_bed.gd`）。

★**候你裁的一句我寫進名單裡了**：
表頭寫「條目數應該**單向下降**」，但**【不適用】的那些永遠不會消失**
⇒ 計數註定降不到零，而「降不到零」會慢慢被讀成「這個指標沒用」。
要不要拆成【待辦】與【不適用】兩欄？（我不自己改別人的表頭。）

# ② ★★交叉依賴：三支各修 `bed-arm` 的一塊

| 修法 | 在哪支 branch |
|---|---|
| `gather_observation_purity_bed.gd` 改走 helper | `feat/gather-purity-instrument` |
| `a4_taint_test2.gd` 入白名單 | `feat/bed-kind-marker` |

⇒ **任何一支單獨 merge，`bed-arm` 那格都還是紅**（各缺對方那一半）。
★而 `bed-kind` 閘要求 `kind=invariant` 必須在 `merge-gates.tsv` 有一行，
而 `gather-purity` 那一行在 **gatherpure** 那支上 ⇒ 兩票**互相**是對方的前提。

**我的建議序**（你裁）：
```
① feat/gather-purity-instrument   （帶 gather-purity 註冊 + 那張床的 helper 修法）
② feat/bed-kind-marker            （帶 a4 白名單；merge 後把那張床的標記從 pending 翻成 invariant）
③ feat/wage-penalty-rework        （最獨立，何時都可以）
```
★而②merge 之後**必須**把 `@bed-kind: pending` 翻成 `invariant`，否則
`defers.tsv:113` 的 token 一撤，`bed-kind` 閘第⑤條會自己紅 —— 這是好事（不會靜默留著），
但要有人知道那一下紅是**預期的**。

# ③ 各票現況

```
feat/wage-penalty-rework   behind=0  已 push  merge-gates 33/36（三紅：bed-arm / defer-open(舊) / tier2）
feat/bed-kind-marker       behind=0  已 push  重跑中
feat/gather-purity-instrument         已 push  35 支跑完，同三紅（該樹尚未併今天最新的 main）
```
★`defer-open` 那格你說得對：我在 **main** 上實測現在是 `PASS`（50 筆，你把 5 條縮到 max 374 之後）。
我三支已重新併過 main，這一格下一輪就會綠。

⇒ ★★剩下唯一**真的**擋著的是 `tier2-sweep-staleness`：需要一次**成功的**全掃。
而現在**有別的 session 在跑掃描**（14:27 那份 inprogress 不是我）——
★★★兩個人同時掃會互蓋 `.bed-sweep-inprogress.tsv`。**請問是誰在跑？** 我先不啟動第二份。
