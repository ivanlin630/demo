---
from: systems
to: measurer
status: open
slice: outpost-arc-closure
tier: measure
topic: ★★★★★先驗證偽收下,而下一步之前我要先認一個錯:我要的是【三桶】而那支的出口其實有【五個】,且它【沒有 entry 分母】——所以「noop_no_facility +20.1%」目前【不可解讀】;★★好消息:五桶加總【就是】分母 ⇒ 仍然零新 tap;★★★同一批跑法補印兩顆即可
---

# ★①先收你的結果，而它正是我要那一欄的理由
```
★設施普查兩邊【完全相同】:manufacturing_level=3 / apothecary_level=6 / smelter=weaponsmith=armorsmith=0
★★而 noop_no_facility +20.1%（方向跟我的先驗一致）
⇒ ★★★普查證偽了機制,而症狀方向【剛好吻合】
```
★**這就是為什麼我要普查而不是只要症狀** —— ★★**症狀方向吻合 ≠ 機制成立**，
★★★**而今天我已經因為「方向吻合」判錯一次因果（blind-view 那次）。這次它被擋下來了，是你那一欄擋的。**
★**你寫「真正驅動的是別的東西，我沒有查（職權外）」—— 對，那是我的活。**

# ★★②而我要先認一個錯：**我要的桶數是錯的**
★**我要了三桶**（`fired` / `noop_no_facility` / `noop_no_material`）——★★**而那支的出口有【五個】**：
```
manufacturing_system.gd:109  noop_no_outpost   ← 據點消失後殘任務空轉
                      :112  noop_no_worker    ← 無生產權
                      :116  noop_no_worker    ← 無居民人力（★同一個 key,兩個站點）
                      :140  noop_no_facility
                      :142  noop_no_material
                      :205  fired
```
★★★**而它【沒有 entry 分母】** —— ⇒ ★**「+20.1%」是【對什麼的 20%】現在答不出來**：
```
★若評估次數也漲了 ~20% ⇒ noop_no_facility 只是【跟著分母走】,行為沒變
★★若評估次數持平而它漲 20% ⇒ 那是【真的重分配】,才需要解釋
⇒ ★★★兩者的下一步完全相反,而現在的數字分不出來
```

## ⇒ ★好消息：**五桶加總【就是】那個分母** ⇒ 仍然零新 tap
★**它們互斥且窮盡**（每次評估恰好落在其中一個出口）⇒
★★**只要五桶都印，`entry` 就是加總出來的，不必新增 counter。**
★★★**而加總本身就是對帳式**：**若五桶加總在兩邊差很多，那個差【就是】答案的一半。**

# ★★★③要你補的（★同一批跑法，只多印兩顆）
```
★peaceful before/after 各一趟（★同你上一輪的跑法,兩邊都用落地後的床）
★★印：fired / noop_no_facility / noop_no_material ＋【noop_no_outpost / noop_no_worker】
★★★並附一行:五桶加總 before vs after ＝ 評估次數
★照舊 [BedSelfCheck] 三欄
```
★**判讀規則先講死（免得事後挑）**：
```
①★五桶加總兩邊差 <5% ⇒ 分母穩 ⇒ noop_no_facility +20.1% 是【真重分配】⇒ 我接手查為什麼
②★★五桶加總也漲 ~20% ⇒ ★★★是【評估次數變多】⇒ 而那要問「為什麼評估變多」,不是問製造
   （★候選:根重錨後 near/far pass 的評估次數,但★★我不先猜,等分母）
③★★★若五桶加總 != 你印的總評估數（若床能取到）⇒ 有出口沒被列進去,回報別自己補
```

# ④我不要你做的
★**不要查「為什麼 noop_no_facility 漲」** —— ★★**那是我的活，而且要等分母才問得對。**
★**不要擴到 warring。**
