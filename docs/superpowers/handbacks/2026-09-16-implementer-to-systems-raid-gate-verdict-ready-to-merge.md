---
from: implementer
to: systems
status: open
slice: 掠奪票 ｜ **一輪完整閘：判準達成** —— `FAIL` 只剩 `bed-arm`（基線）＋ `defer-open`（鬧鐘）⇒ **可 merge**
topic: ★**raw（exact path）**：`docs/measurements/2026-09-16-raid-merge-gates-final2.txt`（★另存前一輪 `…-postlevers.txt` ＝ **bed-arm 修正【之前】那一輪**，兩份並存才看得出那一格動過）｜★★`[TREE] HEAD=0b5136a58 registry=clean runner=clean code-dirty=0`／`runner-self=7f2a725a lines=247`／**單一 `run-id=38413-193022`**／**註冊表 56 支｜682s**｜★★★**而我先自報一件差點被當成基線放過去的事**：加絕境格時我自己 `WorldState.new()` ⇒ `bed-arm` 未涵蓋 **27 → 28**（**我讓基線變糟 1**）⇒ 已改走 `MeasureBedHelper.arm_and_new()` ⇒ **回到 27**｜★恩怨帳那一輪**還在跑**（它剛抓到同型的兩件，也都是我造成的）
---

# ① 判決（raw：`docs/measurements/2026-09-16-raid-merge-gates-final2.txt`）

```
[TREE] HEAD=**0b5136a58** registry=clean runner=clean code-dirty=0
runner-self=**7f2a725a** lines=247｜run-id=**38413-193022**（★單一 ⇒ 沒有兩輪疊在一起）
註冊表 **56 支**｜總時 **682s**｜✗ 共 **2** 支
FAIL：**bed-arm defer-open**
   `bed-arm`    ＝ **27 張 ＝ main 基線**（baseline 檔 `main@2fb10d7c1` 紅數 1）
   `defer-open` ＝ **鬧鐘**，條件逐字「**掠奪走期望價值票 merge 後**」⇒ 你先前裁「不擋、merge 時收行」
⇒ ★**判準達成**（你的原話：「FAIL 只剩 `bed-arm`（＋`defer-open` 那個鬧鐘）＝ 可 merge」）
```

# ② ★★★我自報：**那一格差點被當成基線放過去**

```
我加絕境格（格8）時自己寫 `WorldState.new()`
⇒ `bed-arm` 的「未涵蓋」**27 → 28** ⇒ ★**那一支不再是純基線紅，是【我讓它變糟 1】。**
⇒ ★★**而基線紅最危險的地方，正是它讓人不看數字** ——
  **「跟 main 一樣紅」這句話會把一個【我造成的 +1】整個吃掉。**
處置：改走 **`MeasureBedHelper.arm_and_new()`**（手工組世界的正規入口，閘檔頭 `:28` 逐字列了它）
   ⇒ 已遷移 **101 → 102**、未涵蓋 **28 → 27**（實測）
★★★**而白名單【不是】出路**：`docs/process/bed-arm-whitelist.txt` 檔頭逐字寫
  「**新增床【不得】加進來（那是閘要擋的東西）**」
  ⇒ ★**閘的 FAIL 訊息（「才加進白名單」）與白名單檔頭在這一點上不一致** ——
    **我照【比較嚴的那一份】做，並把這個不一致寫在這裡讓你決定要不要統一。**
```

# ③ 兩份 raw 都留著（★**它們的差就是那一格**）

```
`docs/measurements/2026-09-16-raid-merge-gates-postlevers.txt`  ＝ bed-arm 修正【前】（**28**）
`docs/measurements/2026-09-16-raid-merge-gates-final2.txt`      ＝ bed-arm 修正【後】（**27**）
⇒ ★**兩份並存，那一格動過這件事才看得見** —— **只留後面那一份的話，它會看起來像從來沒發生過。**
```

# ④ 恩怨帳（`feat/grudge-ledger-a`）：**還在跑，而它抓到同型的兩件**

```
①「tick 更新」紅 ⇒ ★**紅的是我插隊**：我把「飽和永不破 1」那一步（`add_edge tick=130`）
   放在它【前面】⇒ 下一行斷言的 tick 從 120 變 130
   ⇒ ★★**它驗的是別的東西，卻因為我插隊而紅** ⇒ 已移到後面
   ⇒ ★★★**在共用 fixture 上追加步驟，等於改變它【後面每一行】的前提。**
②`bed-arm` 27 → 28 ⇒ **同一個病、同一天、第二次** —— 恩怨帳床也自己 `WorldState.new()`
   ⇒ 已改走 `arm_and_new` ⇒ 回到 27
★**而第二次是我在第一次修完【之後】犯的**：我修了掠奪票那張，
  **卻沒有問「我今天還新增了哪些床」** ⇒ ★★**同型缺口重複＝架構信號，
  而這次的信號是【我沒有把修法套到同一批東西上】。**
⇒ 那一輪的 raw 會落在 `docs/measurements/2026-09-16-grudge-merge-gates-final2.txt`，**跑完我寄第二封。**
```

# ⑤ 現況

```
`feat/raid-expected-value` @ **`0b5136a58`**（工作區乾淨）⇒ ★**等你 merge**
`feat/grudge-ledger-a`     @ 新 commit（tick 順序＋`arm_and_new`）⇒ ⏳ 56 支跑中
★兩票合併 merge 的順序與時機是你的格；★★而 `defer-open` 那個鬧鐘照你說的「merge 時收行」。
```
