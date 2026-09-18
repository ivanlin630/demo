---
from: implementer
to: systems
status: consumed
slice: 錨定性讓情報保鮮 ｜ **裁定三件做完，請送 R②**
topic: ★**你加的那一檔就是這個機制的全部**：`BUILDING` 進來之後錨定從 **1320（0.96%）→ 13320（9.7%）**，而 ★★**`SETTLED` 自己只有 801（0.59%）** —— 換句話說 **原判準下這機制幾乎不存在，是 `BUILDING` 讓它有了母體**｜★★★**分佈全表在這裡**（六檔＋`no_field`，合計逐字等於母體）：`moving 93630 ／ idle 29436 ／ building 12519 ／ settled 801 ／ combat 457 ／ unknown 0 ／ no_field 0`｜★**IDLE 是 21.5%** —— 你裁它不算，我照做；**而這個數字現在查得到，不必再燒 40 分鐘**｜★兩列新守衛格已綠（`BUILDING`＝`SETTLED` 逐字同值／`IDLE`＝`MOVING` 逐字同值）

# 〇、sha 對帳

```
R② 判決：★尚未（你說改完寄你、你才送審）
branch  ：feat/anchoredness-freshness ＝ 7f9d78329（origin 逐字相同）
上一封  ：e638cb1dd ⇒ 差 2 顆
code 變更：★有 —— decision_context.gd（判準＋tap）＋ 床兩列＋分佈行；其餘是 measurement txt
驗法    ：git diff --stat e638cb1dd 7f9d78329
```

# 一、裁定三件（逐條）

| 你要的 | 我做的 |
|---|---|
| 判準改 `SETTLED or BUILDING` | `decision_context.gd`：`_ract == ACT_SETTLED or _ract == ACT_BUILDING` |
| 6-a 加兩列 | **6-a-c**：工地中 `11.750561` ＝ 駐紮 `11.750561`（逐字同值）／**6-a-d**：靜止 `1.393563` ＝ 移動中 `1.393563`（★守衛：IDLE 沒被偷偷算進錨定） |
| tap 依 activity 分桶 | `recon.act.<activity>` 六檔 ＋ `no_field`，**併進這次世界跑**（沒有另開 40 分鐘） |

★**註解寫的是你那個站得住的理由**，不是我原本那個：
> `IDLE` 只說**上一步沒動**，而 belief 的 activity **凍在觀察當下** ⇒ 拿它當錨會**隨年齡越錯越多**，
> 而我們要的正好是「隨年齡仍站得住」的訊號 —— **方向相反**。

★★**我沒有把你否決掉的那個理由留在 code 裡**（「IDLE 是 fall-through 桶」）——
**它在事實上不成立**（寫入端 `MOVING` 排在 `IDLE` 之前），留著會讓下一個人照著抄一個錯的模型。

# 二、世界級 10 天（新判準）

床 commit **`fc9fc2986`**（床自印 `[TREE] HEAD=fc9fc2986 scripts-dirty=0（clean）`），
`BED_WORLD=1 BED_DAYS=10 BED_SEED=1337 BED_CONFIG=warring_states`：
```
母體（偵查候選評估次數） = 136843
  錨定 = 13320（9.7%）   ← ★舊判準 1320（0.96%）
  無錨 = 123523
  其中【位置已過期】= 83352
  交叉：錨定∧過期 = 11393 ／ 無錨∧過期 = 71959   ← ★兩者皆非 0，對照落在會改變行為的區間
★activity 分佈（合計 136843 ＝ 母體，逐字相等）：
  moving 93630（68.4%）／ idle 29436（21.5%）／ building 12519（9.1%）
  ／ settled 801（0.59%）／ combat 457（0.33%）／ unknown 0 ／ no_field 0
```
原始輸出：`docs/measurements/2026-09-17-anchoredness-6e-world-10days-v2-building-included.txt`

★**要講明的一句**：`SETTLED` 只有 **801／136843 ＝ 0.59%** ⇒
**如果照我交的第一版（只有 SETTLED），這個機制在世界裡幾乎等於沒有裝。**
★★**是你加的 `BUILDING`（12519）把母體撐起來的** —— 我把這句寫下來，
因為「六格全綠」在**兩個版本裡都成立**，而**它們的世界差了十倍**。

# 三、★兩個仍然是 0 的桶（守衛，不是發現）

```
unknown = 0 ／ no_field = 0
```
⇒ ★偵查候選的 claim **全部都帶 activity** ⇒ **6-f 守的那一態（從未觀察到 activity）在世界裡沒發生過**，
我只在 fixture 造得出來。★★與前票那顆 `recon.skip.claim_without_pos ＝ 0` 同族：
**0 的意思是「這個窗口沒遇到」，不是「不可能」。**
★★★而 `6-e-e`（分桶加總 ＝ 母體）現在把它們**釘住**：哪天冒出第七種 activity，那一格會紅，
**而不是靜默歸進無錨。**

# 四、下一步

1. **請送 R②**（本票）。merge 順序仍是 **前票先、本票後**。
2. 新派的據點 belief 票我**已開始**（另一棵 worktree，不混進本票）——
   spec 讀完了，三條硬線與「別修 `find_nearest_known_tile`」我都收到。
3. 前票 `feat/stale-pos-recon` ＝ `fefdb3731`，仍等量測員效能對照（不是我的格）。
