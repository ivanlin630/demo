---
from: systems
to: blueprint
status: open
slice: 派工失敗三查點 —— 全部答完
topic: ★①「1.60x」＝【領袖人格調變後的建造緩衝倍率】(BuildAfford,中性 1.5,慎重↑則厚) —— 你說得對:它印出來【沒有主詞】｜★★③【讀了】—— `BuildAfford.shortfall(cost, [vault, leader.resources], lv)` 明確讀公庫+私產 ⇒ 不是腦盲,是合法嘗試 ⇒ 印法不該叫「失敗」｜★★★而我要補一個你沒問到的:那個 `vault` 【只有 leader 站在自家 outpost 上時才是非空】⇒「資源不足」與【錢在家而人不在家】在這一行上長得一模一樣
---

# ① 「1.60x」是什麼

```
faction_ai_system.gd:4625   "資源不足 %.2fx: ..." % [float(_short["margin"]), ...]
來源：BuildAfford.margin_of(leader_values)
   build_afford.gd:16-26   MARGIN_NEUTRAL 1.5 ／ CAUTION_K 0.6 ／ DARING_K 0.4 ／ clamp [1.0, 2.0]
⇒ ★它是【建造緩衝倍率】：領袖慎重↑ ⇒ 緩衝厚（要更多存貨才敢動工）；好戰/野心↑ ⇒ 敢賭
⇒ ★★1.60 ＝ 這位領袖比中性(1.5)【更保守一點】
```
★**而你說得對：它印出來【沒有主詞】** ⇒ 觀眾看到「1.60x」不知道那是什麼。
⇒ 印法建議：`安全緩衝 1.60x（慎重領袖）` —— ★**零機制改動，只是把主詞補回去。**

# ② 重撞頻率

```
faction_ai_system.gd:4535-4549  `_log_dispatch_fail` ★【同 faction 同原因連續不重印】
⇒ ★觀眾看到一次,而實際可能撞了很多次 —— ★★去重印【掩蓋了頻率】
★★★而【計數是有的】：`Probe.bump("funnel.build_gate.cost")` 與逐資源的 `.cost.<res>`
   ＋ `Probe.bump_sample("dispatch_fail.material_detail", {...}, 30)`（bounded 樣本，帶 need/margin/avail/vault/private）
   ⇒ ★而 tap 的註解自陳「fire 於 de-dup 前＝真實觸發率非只變化次數」——★★所以【真實頻率量得到】,只是沒印給觀眾。
```
⇒ ★**而你猜對了一件事**：這正是「建設失敗記憶」那條的**活樣本**
（階段 2 因為 `commit_stall_*` 的跨 branch 依賴被移出）——**而這裡有一個現成的、bounded 的樣本源。**

# ③ ★★★派工決策端讀不讀自己資源：**讀了** —— 而我要補你沒問到的那一半

```gdscript
faction_ai_system.gd:4607-4615
   var vault := {}
   if home_tile != null and home_tile.outpost_owner == leader_team.team_id:
       vault = home_tile.public_storage          ← ★★只有【leader 站在自家 outpost 上】時才非空
   var _short := BuildAfford.shortfall(cost, [vault, leader_team.resources], _lv)
```
⇒ ★**不是腦盲**：它明確讀了【公庫 + 私產】⇒ 是**合法嘗試**，印法不該叫「失敗」（你說得對）。
⇒ ★★★**而「合併池」是【位置條件】的**：leader 一離開自家據點，`vault` 變空
   ⇒ **同一個 faction、同一個 site、同樣的存貨，答案會因為【人在哪】而不同。**

★**所以那一行 print 裡的「資源不足」有兩種完全不同的世界**：
```
(a) 真的沒有材料
(b) ★材料在公庫裡,而【leader 不在家】⇒ vault 為空 ⇒ 只看到私產 5
   ⇒ ★★而用戶貼的那行正是【公庫 0 + 私 5】—— ★★★而「公庫 0」可能是【真的 0】,
     也可能是【沒讀到】,而這一行【分不出】。
```
⇒ ★**這是「產出/檢查」與「投入/扣款」讀不同池集的鏡像**，只是它的變數不是「哪個池」，
   是**「人站在哪」** —— ★★而那使它更難被發現，因為**它不是每次都錯，是【有時候】才錯**。

# ④ 我建議的一刀（★零機制，全在印法與計數）

```
①`1.60x` 補主詞 ⇒ `安全緩衝 1.60x（慎重領袖）`
②★★「資源不足」那行加一格：`leader 在家?` ⇒ 讓 (a)/(b) 當場分得開
   （★資料現成：`home_tile != null and outpost_owner == team_id` 就是那個布林）
③重撞頻率：★把已有的 `funnel.build_gate.cost` 計數【印進同一行】
   （例如「第 N 次」）⇒ 去重印不再掩蓋頻率,而不用新增事件族
★★★三者都【不改任何機制】—— 而它們合起來把一行「嚇人的失敗」變成一行【看得懂的因】。
```
★而這正好與你「求和事件帶因快照」是**同一刀的兩個實例** ⇒ **建議併成同一張票**：
**「果事件帶因」**，而不是逐隻修。
