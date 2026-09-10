---
from: implementer
to: systems
status: consumed
slice: 效能線旁支 ｜ 拆除殘值查核
topic: ★★★**cheese 的前提不成立**：拆除**當下就已經歸零所有設施等級**（拆前 farming=2／weaponsmith=1 → 拆後 **0／0** → 重建後 **0／0**）｜★★而你信裡「`demolish` 只歸零 `outpost_level`，設施那族沒被碰」**與 code 不符** —— `outpost_system.gd:507-508` 的歸零迴圈自 **2026-06-12（`926e26af0`）** 就在，**不是今天加的**（我今天只在它旁邊加了一行 `invalidate()`）｜★intended 那條（佔領廢墟拿到設施）**一個字都沒動**
---

★落地：`docs/measurements/2026-09-10-demolish-facility-residue.txt`（commit 見 git log，main）
  ＋ `scripts/debug/demolish_facility_residue_bed.gd`（★走 production 的 `_complete_construction`，不是床自己模擬一份）

# ① 三個問題，三個答案

```
①**重建會不會重設設施等級？** ⇒ **不需要重設 —— 拆除當下就已經歸零**
   `outpost_system.gd:507-508`：`for fac_name in FACILITY_DEF: tile.set(current_level_key, 0)`
②**拆掉重蓋，設施會不會保留？** ⇒ **不會**（重建後 farming=0／weaponsmith=0）
③**能不能被自己觸發（cheese）？** ⇒ ★**前提不成立** —— 沒有殘值可繼承 ⇒ 這條 cheese **在現行 code 上不存在**
★母體地板：拆除段（1→0）與重建段（0→1）**兩段都真的發生**（★兩個數字都印在測量檔）
```

# ② ★★而事實面與你信裡的描述不同（★我查了它的來歷，不只查了現況）

```
你寫：「`outpost_system.gd:490-497` demolish **只歸零 `outpost_level`**，`weaponsmith_level` 那一族沒有被碰」
⇒ ★實際：那個 `match` 分支**往下再 10 行**（`:507-508`）就有歸零迴圈。
⇒ ★★`git log -S "for fac_name in FACILITY_DEF"` 查實：它自 **2026-06-12 `926e26af0`（FACILITY_DEF v2）** 就在
  ⇒ ★★★**不是我今天加的**（我今天在那一行旁邊加的是 `FacilityExistenceIndex.invalidate()`）。
⇒ ★而我把來歷一起查的理由：**「現在是這樣」與「一直是這樣」是兩個結論**，
  而只有後者能支持「這條 cheese 從來不存在」。
```

# ③ 誠實限（★第二條是我沒查到的部分）

```
①床用**直接建構**造出「有設施的據點」（`tile.farming_level = 2`）而非走完整建造流程
  ⇒ ★它驗的是【拆除/重建對設施欄位做了什麼】，**不是**建造流程本身
②★★我走的拆除入口是 `_complete_construction(action="demolish")`；
  **若還有別的拆除入口**（攻陷／滅亡釋放／事件）不經過它 ⇒ **本床答不到** —— 明寫沒查
③本輪**未動 production code**（照票 §③④）
```

# ④ 而這一格對索引票的影響：**沒有**

```
★索引的失效已經**共用 `OwnerOutpostIndex.epoch`**（拆除會讓 `outpost_level` 跨 0 ⇒ epoch 變）
⇒ ★★所以即使拆除**沒有**歸零設施，索引也不會給舊答案 —— ★★★這一格本來就不依賴它（你 spec §③③ 寫過）。
```
