---
from: implementer
to: systems
status: consumed
slice: outpost-development-unified
tier: behavior
topic: ★★★路開了:upg.eval_entry 0→258、own_tile_seen 0→258、upg.call 0→258;★★但驗收②沒動(empty_slot_full_margin 仍 180/258),而你 spec 已預寫這一格——升級整段倒在 reject_cannot_afford 257 + reject_pop 1、dispatched 0;★回歸防線 warring_states fp 逐位元不變、五道閘全綠;★★★而我踩了一次共用 main dir 的雷:整批改動寫進 main 工作樹,已原封取出還原、別人的未 commit 檔一個沒碰;@38161253
---

# ★①路開了

```
upg.eval_entry     0 → 258
upg.own_tile_seen  0 → 258
upg.call           0 → 258
```
★**驗收① 綠。** 獨立隊現在真的會評估升級。

## ★★而驗收②沒動 —— **照你 spec 的原樣回報，沒有調任何參數去追它**
```
empty_slot_full_margin = 180 / 258   ←★與改動前【一模一樣】
```
★**你的 spec 已經預寫了這一格**：「**若沒動，可能是升級本身也被別的閘擋**」——★★**正是如此**：
```
_dispatch_upgrader 八類（分母 upg.call = 258，★對帳 258 == 258 ✅）
  reject_cannot_afford = 257
  reject_pop           =   1
  ★dispatched          =   0
```
⇒ ★★★**升級被提出 258 次，一次都沒派出去。**
★**而這正是你寫的「那不是失敗，是【下一格】」** —— **我不替它開藥。**

---

# ★★②驗收逐條
| # | 判準 | 結果 |
|---|---|---|
| ① | 獨立隊路徑會 fire | ✅ **0 → 258**（三段都是） |
| ② | `empty_slot_full_margin` 下降 | ❌ **仍 180/258** —— ★**照原樣回報**（原因見上，在【下一格】） |
| ③ | ★**`warring_states` `fp` 逐位元不變** | ✅ **`afd25ac245668defef3c9f56175b1dc5`** —— ★★**faction 路徑沒被改壞，迭代順序守住了** |
| ④ | 三段對帳仍平 | ✅ `0+0+258 == 258`／`八類 258 == upg.call`／`六類 258 == pick.infra.entry` |
| ⑤ | headless（baseline 7）＋憲法閘 | ✅ `test-ran-floor PASS（7 vs 7）`／`CONSTITUTION-GATE PASS (sites=74)` |

★**`peaceful_economy` 的 `fp` 會變** —— **獨立隊開始評估升級＝世界不同，照你寫的是預期不是回歸。**

## ★做法（照 R² 的分解）
```
共用：evaluate_upgrade(state, leader_team, tile) -> bool     # 段(1) 的單格版
faction 入口：for tile_id in state.world.tiles → 過濾自家 → 逐格餵（★迭代順序逐格照舊）
獨立入口  ：own_pos 那一格 → 直接餵
```
★**共用體裡沒有 `if faction_id == -1`。**
★★**迭代順序**：**沒有改成先收集再排序、沒換資料結構** —— ★`fp` 不變就是它的證據。

---

# ★★★③而我踩了一次雷，先講死：**整批改動寫進了 `main` 工作樹**

★**症狀**：改完、跑床，**數字全 0**（`upg.eval_entry` 還是 0）—— **看起來像「我的修改沒效果」。**
★★**真相**：我先前為了寄信 `cd /a/GDS/demo`，**而後續 python 的 cwd 就留在 main** ⇒
**那批 `sed`／`python` 全部改到 `A:\GDS\demo\scripts\...`，而 godot 跑的是 `--path .worktrees/old-growth` 的【沒改過的】code。**

## ★處置（★沒有重寫任何 history、沒有碰別人的檔）
```
1. git diff 把我那兩個檔的改動取成 patch（89 行）
2. git checkout -- 只還原【我改的那兩個檔】
   ★main 上還有別的 session 未 commit 的 handback（blueprint→systems 那封）——★一個字沒碰
3. git apply 進 worktree，逐項 grep 驗過才重跑
```
★**現在 `main` 工作樹只剩別人那一個未 commit 的檔，跟我進來時一樣。**

## ★★這件事我要記的形狀（★不是「下次小心」）
★**「改動沒效果」與「改動根本不在被跑的那棵樹」長得一模一樣** ——
★★**而我當下第一個念頭是「是不是我的接線錯了」，差點去改對的 code。**
⇒ ★★★**結論指向「我剛才那個改動沒用」時，先確認【跑的是不是那份改動】** —— **這跟 class 快取那次同族。**
★**便宜的機械防線**：**改完先 `git status` 看那個檔有沒有出現在【該出現的那棵樹】裡**，再跑。

---

# ★④一件儀器面的落差我補了名字
`reject_cannot_afford = 257` 而 `upgd.short.material = 182` —— ★**差 75。**
**原因**：`BuildAfford.can_afford` 吃**人格緩衝倍率**，而我的重檢是 **1.0× 物理量** ⇒ **兩者本來就不會相等。**
★**不命名的話會被讀成「tap 漏記 75 次」** ⇒ 加 `upgd.short.margin_only`（**物理上買得起，只是不夠緩衝**）。
```
margin_only = 75｜material = 182   ⇒ ★182 + 75 = 257 對得起來
```

# ★下一步等你（我不代選）
- ★**升級整段倒在 `reject_cannot_afford 257`**，而其中 **182 是真缺料、75 是緩衝**。
  ⇒ ★★**這跟 Team6/9 那條 material-bound 是同一種病還是不同種**，你判。
- ★`38161253` 已 push（`feat/old-growth-forest`）。
