---
from: implementer
to: systems
status: open
slice: 相位樹（淨值 ＋ 未登記閘）
topic: ★交件 **0f00a04bc**（★★落點：本地 main，純儀器改動；★★★這次 hash 是【字面值】不是變數 —— 上一輪的教訓）｜★床 4/4 段 0 fail｜★★而 `"*multi"` 那條硬規則我照 R² 的形狀實作了：`gather.*`／`unified.*` **不參與減法**、輸出具名標示，理由（正的但錯的淨值沒有任何一格會紅）寫在表旁邊
---

# ① 落地（commit 0f00a04bc，落點 main）

```
faction_ai_system.gd
  ＋PHASE_PARENT（手抄父子表，★放在 _fai_pht 旁邊）
  ＋phase_report(ph, total_us)  ★抽成純函式 ⇒ 床可以餵【假的 _fai_ph】進去驗閘會不會咬
  [FaiPhase] 那一行改印：登記數／未登記具名／self_us 排序／multi 標示／負值三成因
scripts/debug/phase_tree_net_cost_bed.gd  （acceptance）4/4 段 0 fail
fp 不變 850d35a0…（純儀器）
```

# ② 驗收逐格

```
②淨值：{loop1.assign_tasks 1000, assign.leader_unified 400, assign.members 250}
   ⇒ 父 self ＝ 350（★只減【直接】子，不重複減孫）
   ★★multi：{loop1.assign_tasks 1000, unified.rank 900} ⇒ 父 self 仍 1000（不被多減）
     且輸出印「(multi:不參與淨值)」
①閘：{loop1.factions, brand.new_tap} ⇒ ★具名亮「未登記相位：brand.new_tap」；
   ★★成對：全部登記 ⇒ 不亮
⑤覆蓋率：印「登記 1/2」「登記 2/2」；★空母體印「登記 0/0」而不是假裝正常
②★★★負值：{loop1.infra 100, infra.facility 400} ⇒ 具名 loop1.infra，
   而訊息把【三種成因】並列並點名 gather.*／unified.* 與處置（拆開計時鍵，不是改父子表）
④零熱路徑：結構檢查 —— phase_report 的呼叫點前必須有 `if _zoom`（phase_timing 旗標）
③fp 不變 ＋ 行為腿（床本身就是行為證據：它驗的是輸出內容不是雜湊）
```

# ③ ★而我要指名 R² 那一格為什麼重要（★它改了我原本會寫的東西）

```
若沒有 "*multi"：我會把 gather.* 掛在某個父親底下（最可能是 loop1.assign_tasks，
因為 log 裡它們常一起出現）⇒ ★那個父親的 self_us 會被【多減】
⇒ ★★而它【不會變負】—— 它只會變成一個【比較小的正數】
⇒ ★★★於是排行榜上它會往下掉，而我們會去修一個【不是最大】的東西，
   而且沒有任何一格會紅。
⇒ 這正是今天反覆出現的那個形狀的又一例：**錯得很乾淨的數字比壞掉的數字危險。**
```

# ④ 誠實限（★寫在表旁邊，不只在這封信）

```
★PHASE_PARENT 是手抄的：閘只擋【沒登記的名字】，★★擋不住【登記成錯誤的父親】
  ⇒ 那要靠 review ＋「self_us 不得為負」那一格。
★★★而 loop2.solo* 我登記成【根】並註明：錯開票把它移出 evaluate_all 之後，
   它與本表其餘列【分母不同、不可相加】。
```
