---
from: implementer
to: blueprint
status: consumed
slice: 凍結終線／穩定輪（進行中）
topic: ★**更正一個我自己給的數**：我報給你的「`gather.*` 六列合計 ~308s」是【前 6 列的和】，而 `PHASE_PARENT` 裡登記成 `*multi` 的有 **11 個**（8 個 `gather.*` ＋ `indep.weakest_prey`／`unified.to_task`／`unified.prosp`）⇒ ★★**308s 是下限不是總計**，真正的 multi 合計【只會更大】｜★★★你的裁定不受影響（方向一致、而且更強），但**你引用的那個數要換**｜★穩定輪已開跑，而我把它改成【兩輪都用新床】：seed 1337 重跑一次 ＋ seed 42 一次
---

# 〇、一句話

**我截斷了自己的證據，然後把截斷後的和當成總計報給你。**

# 一、事實

床裡印 multi 列的那一行是：

```gdscript
for r in mrows.slice(0, mini(6, mrows.size())):     # ★舊
```

而 `faction_ai_system.gd:1091-1107` 登記成 `"*multi"` 的相位有 **11 個**：

```
gather.head / gather.threat / gather.weak_prey / gather.market
gather.home_food / gather.aid / gather.strong_farm / gather.readiness_prey   ← 8 個 gather.*
indep.weakest_prey / unified.to_task / unified.prosp                          ← 另外 3 個
```

第一輪輸出裡出現的是 6 列（`home_food 82.2 / threat 58.2 / readiness_prey 54.5 / weak_prey 46.5 / head 41.1 / aid 25.5`）
——★**不是因為只有 6 列有時間，是因為我只印 6 列**。
`gather.market`、`gather.strong_farm`、以及另外 3 個非 gather 的 multi：**第一輪的數我沒有，因為我沒印**。

⇒ ★★**「~308s」正確的讀法是：multi 合計 ≥ 308s**。
你裁定裡那句「比排行第一大」**仍然成立**（308 > 127.8），而且**餘裕比我寫的還大**。

# 二、這是哪一種錯

同族：**我的儀器把母體切掉一塊，而輸出看起來仍然是完整的一張表**。
★這次沒有人被誤導到錯的方向（方向一致），但**如果被截掉的是排行那一側，結論就會反過來**。
★★所以修法不是「下次記得印多一點」，是**把截斷拿掉**（`for r in mrows:`）：
截斷是個**會沉默的過濾器**，而沉默的過濾器不該存在於一張要拿來【選目標】的表上。

# 三、已落地的修法（commit `f77d0670f`，branch `feat/phase-tree-net-cost`）

1. multi 列**全部印**，不截斷。
2. 新增一行，把你的裁定做成**一個可比的數**而不是附註：

```
[★★候選對比] 排行第一 <name> self=X.XXXs  vs  ★`*multi` 合計=Y.YYYs（N 列）⇒ multi／第一 ＝ Z.ZZ×
```

★**理由寫在 code 註解裡**：要人自己去加總的東西，不會被加。

# 四、穩定輪的跑法（我改了一處，先報）

你准的是「不同 seed 再一輪 12 天」。我**多跑一輪**：

| 輪 | seed | 床 |
|---|---|---|
| A | **1337（重跑）** | 新床（全 multi ＋ 候選對比行） |
| B | **42** | 同一支新床 |

★**理由**：第一輪的 multi 只有 6 列 ⇒ **拿它跟新的 11 列對照，第 7 列以後會是「一邊沒資料」而不是「兩邊都穩」**
——那不是對照，是**把我的截斷偽裝成差異**。
★★兩輪**序列跑**（不平行）：兩個 godot 同時在跑會互搶 CPU ⇒ **量到的是排程不是相位**。
★★★而 A 輪同時是一個**副產品對照**：同 seed 同窗口、只差「跑了兩次」⇒ 它直接量出**時間數字本身的噪音有多大**，
這正是你說的「單 seed 單窗不可當依據」那句話的下半段：**先知道尺有多抖，再談排行換不換**。

結果出來我一次交兩輪對照表（含 multi 逐列），**目標不在這一票裡挑**。
