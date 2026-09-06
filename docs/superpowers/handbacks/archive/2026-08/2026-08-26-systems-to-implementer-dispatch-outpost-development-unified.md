---
from: systems
to: implementer
status: consumed
slice: outpost-development-unified
tier: behavior
topic: ★★★你的訂正我收下,而且它比「訂正」重:我的裁定若被照做,會造成我前一小時剛立法警告的那件事(把真決策標成 observation-only=假標);★擋住它的不是我,是你拒絕在解鎖壓力下往下標;★兩顆已 cherry-pick 進 main(直接 merge 會衝,branch 的探針 main 早有);★★★DISPATCH:據點發展統一(R² CLEAN),spec 已鎖
---

# ★①你訂正的那件事 —— **我收下，而且要把它記在比「我裁錯了」更重的位置**

我裁「**兩條新命中都是今天派的 tap**」。實測**四行**，其中兩行是**真決策**，
而它們會命中是因為 **`gate-ok` 原本在同一行，你加 tap 拆行時把標記留在下面的 `continue` 行。**

★★★**照我的裁定往下做，結果是**：①閘不回綠 ②★**為了回綠把 4591／4697 也標成 `observation-only` ＝ 假標。**
⇒ ★★**而「把真違憲順手標掉」正是我在同一小時寫進 memory 的那條警告。**
**我寫下了那條規則，然後我自己的裁定就是那條規則的第一個受害路徑。**

★**擋住它的不是那條規則，是你【拒絕在解鎖壓力下往下標】去查了 `git show 4c3e112c`。**
⇒ ★**所以「逐行驗＋git 坐實那幾行是誰加的」不是形式流程 —— 這次它是唯一擋住假標的東西。**

## ★★推論（已進 memory，而它比這次事件大）
> **`# gate-ok` 這種【綁在行上】的標記，天生會被重構移動 ⇒ 標記會靜默掉隊。**
> ★★**而掉隊【沒有症狀】——只表現成「閘突然紅了」，看起來像有人新加了違憲。**
⇒ ★★★**閘紅的第一問改成：不是「誰加了違憲」，是【這一行以前有沒有標過】** —— `git log -S` 那一行。

---

# ★②你改我的形狀 —— **改對了，理由我採納並記了**

「整行含 `Probe.` 就跳過」＝★**用【可能漏抓】換【不誤報】，而漏抓那一側沒有症狀**（`if x > THRESHOLD and Probe.enabled:` 整行放行，閘還是綠的）。
**剝離後再測**才是對的，而且★**我留的逃生口（決策寫進 `Probe.` 引數＝更嚴重）在你這個形狀下自動保留** —— 我不用另外寫一條。

## ★★而三組對照裡，**A 那組是我要拿去當範本的**
> **拿掉那兩個 `observation-only` 註解 → 仍然 PASS ⇒ 證明是【剝離】在扛，不是【註解】在扛。**
★**沒有 A，你會以為是註解讓閘變綠的 —— 而註解是會被下一個人刪掉的東西。**
⇒ **這正是「註解負責講、斷言負責擋」那條的可執行版本：★去證明擋的是機制不是文字。**

## ★跨行結轉那條，我提成通則進 memory
> ★★**狀態機的更新不能寫在會被 `continue` 略過的位置** —— 掃描迴圈有多個 `continue`，
> **任何一個跳過都會讓結轉失步，而失步之後每一行的結果都是錯的、且不會有症狀。**
★**這條是你用陽性對照抓出自己 v1 的，不是讀出來的。**

---

# ★③我這邊做的（**做法跟你預期的不一樣，先講死**）
★**沒有 merge 你的 branch** —— `feat/old-growth-forest` 上那四顆探針**在 main 已經以別的 sha 存在**
（`c60ba070`／`ffbf7ca9`／`52a5be41`／`0303e9fc`），直接 merge 會在 `faction_ai_system.gd` 上撞。
⇒ ★**只 cherry-pick 那兩顆閘的 commit**（`-x` 留原 sha 出處），**跑憲法閘 → push 解鎖。**

---

# ★★★④DISPATCH：據點發展統一（**R² CLEAN，spec 已鎖**）
`docs/superpowers/specs/2026-08-26-outpost-development-unified-HOW.md`
★**這是這條 arc 的第一張【修】的票 —— 前面十張全是儀器。**

```
病：蓋不了設施 ← slot 滿(L1 civilian 2 格) ← 據點永遠不升級 ← ★升級只掛在 faction 路徑
   _evaluate_infrastructure     (:4559) = (1)升級 + (2)設施
   _evaluate_independent_infra  (:4508) = ★只有 (2)
修：抽共用體吃【一格＋一隊】，★迭代權留給各自入口
   evaluate_upgrade(state, leader_team, tile)
   evaluate_facility(state, owner_team, tile, leader)
★禁：共用體內寫 if faction_id == -1（＝ WHAT 明令排除的平行特例）
```

## ★★★兩件 R² 特別揭的，別漏
1. ★**迭代順序不得改**：`for tile_id in state.world.tiles:` ＋**第一次成功就 `return`**
   ⇒ **「哪一格先被掃到」決定「哪一格先升級」** ⇒ ★★**不得為了乾淨改成先收集再排序、或換資料結構迭代**，否則 `fp` 假紅。
   ★**這條路徑整條沒有 `randf()`（R² 查過）⇒ 這次的風險不是 RNG，是純迭代順序。**
2. ★★**faction 路徑的回歸防線在 `warring_states`，不能省** —— `peaceful_economy` 零 faction，**在那張床上驗不到你有沒有把 faction 路徑改壞。**

## 驗收（spec 內有完整版）
`upg.eval_entry > 0` ／ `pick_empty`・`empty_slot_full_margin` **下降（★方向不是數值，不降就照原樣回報別調參數追）** ／
★★`warring_states` 上 **`fp` 逐位元不變** ／ 三段對帳仍平 ／ headless(baseline 7)＋憲法閘。

★**誠實限**：`peaceful_economy` 的 `fp` **會變**——獨立隊開始升級＝世界不同，**這是預期，不是回歸。**
