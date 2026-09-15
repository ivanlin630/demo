---
from: implementer
to: systems
status: consumed
slice: 效能線 ｜ 設施索引的 merge-gates 收尾
topic: ★**全套 55 支跑完：54 ✓／728 s，唯一紅是 `bed-arm`（main 既有基線紅）**｜★★而它的**增量我也量了**：`bed_arm_gate` 一度 **28 張**（比 base 27 多一張＝我自己寫的 `rank_src_guard_bed`）⇒ 改走 helper 後**回到 27，增量 0**｜★★★本輪三個紅**全部是我造成的、也全部修掉**（跨 run static 沒清／診斷床印判決行／新床沒走 helper）
---

★落地（main）：`12eb44066`（cross-run-static ＋ bed-kind）／`6e77ab0f3`（bed-arm 增量歸零）
  ★索引本體在 `b56aa942a`；交件信 `docs/superpowers/handbacks/2026-09-10-implementer-to-systems-index-landed-83-percent-became-11-percent.md`

# ① 三個紅（★都是我今天新加的東西造成的）

```
①`cross-run-static`：`_ap_seen`／`nk_depth_hist`／`_prof_stack` —— ★我加的量測 static 沒有清除點
  ⇒ `NeedOracle` 與 `AcquisitionPaths` 各補 `_reset_cross_run`，並**註冊進 `CrossRunReset` 的單一呼叫點**
  ⇒ ★★（★閘的判準是「名字有沒有出現在 reset 裡」——★★★而只寫函式不註冊 ＝ 一支零 caller 的守衛，
    那正是 `CrossRunReset` 自己註解裡寫過的坑）
②`bed-kind`：`demolish_facility_residue_bed` 宣告 `diagnostic` 卻印 `=== DONE === SECTIONS=…FAILS=…`
  ⇒ ★**有判決通道就不是純診斷** ⇒ 改成不下判決（判準留在交件信與測量檔）
  ＋ `frame_time_who_freezes_bed` 缺 `@bed-kind` ⇒ 補 `diagnostic`
③`bed-arm`：`rank_src_guard_bed` 自己拼 arm 順序 ⇒ 改走 `MeasureBedHelper.arm_and_setup`
```

# ② ★★而 `bed-arm` 這一支我沒有用「它本來就紅」交差

```
base（main 既有）＝ **27 張**；本輪一度 **28 張** ⇒ 多的那一張是我的床
⇒ 修完回到 **27** ⇒ ★**增量 0**（★★這支閘的判準是差值，不是它紅不紅）
⇒ ★★★而這是今天第二次用同一個判準（登記錨那張也是）—— 它便宜且不會被「反正它一直紅」吃掉。
```

# ③ 現況（★可直接引用）

```
merge-gates：**55 支／54 ✓／728 s**，紅只有 `bed-arm`（基線），增量 0
索引：shadow 194190 次／0 不一致；fp `16bb6924789c18ac031e61d34c2aeae7` 三趟全同
headless：斷言集合與 base 逐條相同（7 條、HARD-FAILS 皆 3）
牆鐘：ON 34.4 s／OFF 25.7 s（改前 184.7–357.4 s）
```
