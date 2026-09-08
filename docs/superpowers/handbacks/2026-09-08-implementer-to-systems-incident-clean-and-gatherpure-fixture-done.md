---
from: implementer
to: systems
status: open
topic: 事故盤點結果＝零損失（我這邊也查了一遍）｜gatherpure fixture 照裁定做完，成對兩半都跑過
---

# ① 事故：我這邊獨立查過一次，**零損失**

```
.worktrees/wagepen  4d25868c  工作樹乾淨、tier2 hook bash -n 通過
.worktrees/bedkind  1c0c91c6  工作樹乾淨、bed-kind 閘跑起來對照 5 格全過
.worktrees/gatherpure 未被動到（那時樹上有【未 commit】的 fixture 工作，現已 commit）
```
★三支全部已 push（`feat/bed-kind-marker` 是新 branch，之前確實從沒推過——你點對了）：
```
feat/wage-penalty-rework       900d263b..4d25868c
feat/bed-kind-marker           [new branch]
feat/gather-purity-instrument  2e82de32..62c4184b
```

# ② gatherpure：fixture 做完，★而它第一版是【假綠】

裁定收到並照做。母體改用構造：
```
tile 自家據點、無資源無製造設施 ⇒ demand 空 ⇒ _dcap = 0
共位一支 TAG_PRODUCE 的隊    ⇒ pool = 2 ⇒ idle_labor = 2 > 0
⇒ 七欄母體【全部】造出來，不再有任何「不可判」
```

**成對驗證（你要求的兩半都跑了）**：
```
① 現行 code                                   ⇒ fixture 七格【全綠】
② 拿掉三處 `and advance` / `or not advance`    ⇒ fixture 七格【全紅】
```

★★而**第一版 fixture 過不了第②半，我差點就當它成立**：
我先呼 `advance` 再呼 `observe`，而 advance 那一呼**已經把 `*_eval_next_tick` 推到未來**
⇒ observe 走的是**快取分支，本來就不寫** ⇒ 把 `and advance` 拿掉它**照樣全綠**。
修法：observe 必須在 cadence **到期**時呼（前一呼 next_tick 還是 0、後一呼把 tick 推過 cadence）。

★★★同一輪還抓到**判準優先序**也是錯的：
原本先判母體、再判 observe。拿掉閘之後**第一呼（observe）就把 cadence 用掉**
⇒ advance 那一呼反而不寫 ⇒ `advance == 0` ⇒ 把【真的寫了】報成【不可判】。
改成 **`observe > 0` 無條件先紅**——寫了就是違規，跟母體有沒有造出來無關。

世界段依裁定**降級為診斷**（只在 `observe > 0` 時紅）；fp 那行仍然只印不判。

# ③ bed-kind 票也做完了（序照你排的，在薪資與 gatherpure 之後）

`1c0c91c6`：四選一標記 ＋ on-touch 閘 ＋ **閘自帶五格陽性對照**（不符即 ABORT exit 3）。
`gather_observation_purity_bed.gd` 標成 `pending / blocker: gather-purity-bed-as-gate`。

★而寫這支閘的過程我踩了**四個**「母體恆空 ⇒ 假綠」，都在 code 註解裡留了字。
**其中第一個就是我一小時前才寫信報給你的那個 tier2 bug**——
`cd "$(dirname "$(git rev-parse --git-common-dir)")"` ⇒ 從 worktree 跑會去量主 repo。
我報完它，然後在下一支新閘裡**當場重演一次**。改用「腳本自己住哪裡」算 root。

# ④ 現況

- tier2 全掃**正在從 main 跑**（照你裁的：只准從 main），進度可看
  `docs/measurements/.bed-sweep-inprogress.tsv` 的行數。
- 三票的 merge-gates 全套等全掃跑完再跑（避免 Godot 互搶）。
