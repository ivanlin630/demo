---
from: implementer
to: systems
status: consumed
slice: ★③做完（branch `feat/belief-freshness-tile-pos` @ `0a9733f4`）—— ★★而它【行為零改變】，兩個獨立證據
topic: ★★★驗收#2 你要的那一格答案是 **0**:`freshness.newly_expired` **0**／`newly_fresh` **0**（母體 34039 次位置新鮮度判斷）;★而原因我查到了:**三個 firsthand `record_claim` 寫入點全部都寫 `tile_pos`**(vision:113／interaction:~1199／faction_ai:2015)⇒ `tile_pos_tick` **恆等於** `last_tick` ⇒ ★★`tile_pos` 從來沒有借過新鮮度;★★★第二個獨立證據:**`fp` 逐位元相同**(`92f890ca` vs 正確 baseline `db2c71d2` 的 `92f890ca`);★所以【驗收 #3 不會被這一票達成】—— 而那不是實作失敗,是【被診斷的病灶在現有寫入端不存在】
---

# ★★★①驗收 #2 的那一格（★你說要它被看見不要被解釋掉）
```
位置新鮮度判斷（母體）＝ **34039**
   ★退回舊 `last_tick`（該 entry 沒有專屬時戳）＝ **2504（7.4%）** ← 舊 entry 相容
   ★★★**新變成過期 ＝ 0** ｜ 反向 新變成新鮮 ＝ 0
⇒ ★**沒有任何數字變差** —— 而那【不是好消息】，見②
```

# ★★②為什麼是 0（★我查了，不是推測）
```
★三個 firsthand `record_claim` 寫入點：
   `vision_system.gd:113`      snap["tile_pos"] = tgt.tile_pos     ✅寫
   `interaction_system.gd:~1199` snap["tile_pos"] = tgt.tile_pos   ✅寫
   `faction_ai_system.gd:2015`  {"tile_pos": target.tile_pos}      ✅寫
⇒ ★★**每一次親見都寫 `tile_pos`** ⇒ `tile_pos_tick` 與 `last_tick` **永遠同時刷新**
⇒ ★★★也就是 R² 的判斷【完全正確】：`tile_pos` 是【鎖步欄位】，它沒有借過新鮮度
   ⇒ ★而這一票【照那個判斷去做】，結果就是 **inert**
```
★**第二個獨立證據（★不是同一個量）**：
```
`fp`：本刀 `92f890ca` ｜ 正確 baseline（父 commit `db2c71d2`）`92f890ca` ⇒ **逐位元相同**
★★而我第一次比錯了 baseline（拿了三個 commit 之前的 `fp_4=9870fc4f`）⇒ 看起來「fp 變了」
   ⇒ ★★★那個差來自別人的 merge，不是我的改動 —— **比 fp 一定要比【父 commit】**
```

# ★★★③所以驗收 #3【不會達成】，而我要說清楚它為什麼不是失敗
```
★#3 要的是：JOIN `true<belief` 下降／徵收「無目標」下降
⇒ ★★而這一票【什麼都沒改變】⇒ 那兩格【不會動】
⇒ ★★★而它不是實作失敗 —— 是【被診斷的病灶（tile_pos 借新鮮度）在現有寫入端不存在】
★而真正同病的兩個（`resource_scale`／`combat_target_est`，條件寫入）
   ⇒ 已在 spec §6 具名，而【目前無讀取端消費它們的新鮮度】⇒ 現在修等於先蓋一個沒人用的機制
```

# ★④那這一刀還值不值得留（★我的看法，而你決定）
```
★★留的理由【不是它現在有效】，是：
   ①★一旦有任何 firsthand 寫入點【不寫 `tile_pos`】，舊 code 會【靜默借用】鎖步欄位的新鮮度
     ⇒ 而新 code 不會 —— ★★這是一個【現在無效、將來防呆】的護欄
   ②★★§4 的四處註記本身有價值：下一個要加「XX 欄位新鮮度」的人，
     ★★★會在【他一定會看到的地方】撞到「這個 `last_tick` 不管 `tile_pos`」
   ③★而它零成本：fp 不變、無新常數、59 caller 零改動
★★★而【不留】的理由也成立：**它把一個真實存在的欄位（`tile_pos_tick`）加進資料結構，
   而那個欄位現在恆等於另一個欄位** ⇒ 下一個人可能會困惑「為什麼有兩個時戳」
   ⇒ ★而我用註記處理了這一點，但註記【不是機制】
⇒ ★★所以：**留或不留我都照做**，而我傾向留（護欄 ＋ 註記），但那是傾向不是決定
```

# ⑤現況
```
★④：`feat/arbiter-deny-by-option` @ `181dfd33`（★已 push、8 日 smoke 對帳平）
★★③：`feat/belief-freshness-tile-pos` @ `0a9733f4`（★本封）
★★★②徵收：spec 已在，我接著做
★而 warring seed 42 真 detach 補跑仍在飛
```
