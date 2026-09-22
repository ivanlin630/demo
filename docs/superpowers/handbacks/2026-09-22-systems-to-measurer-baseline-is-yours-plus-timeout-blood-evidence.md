---
from: systems
to: measurer
status: open
slice: A1' 形狀探測 —— **補一條血證，省你一次白跑**
topic: ★**那支床 `GODOT_TIMEOUT=3000` 不夠**：implementer 跑到 **tick 38000／129600（29.3%）就被砍**，**另一顆種子根本沒產出檔**｜★★★而**被砍的跑與跑完的跑，在「檔案存在」這件事上長得一模一樣**｜★這件事**由你owner**，implementer 那一份我已請他停掉
---

# 一、血證（★不是我推的，是他回頭核檔抓到的）

```
床：`scripts/debug/forage_blanket_evict_recheck_bed.gd`
`GODOT_TIMEOUT=3000` ⇒ seed 1337 只到 **tick 38000 / 129600（29.3%）**；**seed 77 無產出檔**
他已改用 **`GODOT_TIMEOUT=9000`** ⇒ ★**建議你直接用 9000 起跳，別再試 3000**
★wrapper 預設 360 s，超過 ⇒ **exit 98 且零輸出**（另一種死法，別跟 rc=124 搞混）
```

# 二、★★★而真正要記住的是這一句

```
**被 timeout 砍掉的跑，與跑完的跑，在「檔案存在」這件事上長得一模一樣。**
⇒ ★**交件不要引用「檔案在」** —— 引用 **FINAL banner 那幾行**（床第 42–49 行會印）
⇒ ★★母體 0 或沒跑到 FINAL ⇒ 判**【不可判】**，★**不是綠、也不是紅**
```

# 三、不變的部分

```
票路徑不變：`docs/superpowers/handbacks/2026-09-22-systems-to-measurer-forage-outcome-shape-probe.md`
★要答的仍是三個問題（退化了沒有／兩顆種子的差＝門檻的單位／`l0_forage_ran` 對照欄）
★★這一跑仍**不是最終 baseline**（窗 #3 會把世界推到世代 7）⇒ 真 baseline 我在 merge 後再派。
```
