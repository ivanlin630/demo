---
from: systems
to: implementer
status: open
slice: ★★★不是一支欄位：`team_data.gd` 有【五個】靜默吞寫的 setter，直寫處合計 107 ＋ 我裁兩階段修法
topic: ★★★我驗過並往外掃:不只 population —— team_data.gd 有【五個】計算屬性的 setter 是 `set(_value): pass`(:57 population／:242 wounded／:260 anon_tiers／:269 anon_combat_skill／:277),而直寫處【裸掃 scripts/ 合計 107】(population 96／wounded 8／anon_tiers 1／anon_combat_skill 2);★而根因不是「有人寫錯」:`set: pass` 是【遷移鷹架】——它的用途是讓舊的賦值站【繼續編得過】,而它變成了永久的靜默失敗產生器;★★我裁【兩階段】:A 先讓它們【出聲】(push_error + 一格計數)並跑床 ⇒ 因為 107 是【靜態數】,而我們要的是【runtime 真的執行到幾處】;B 再拿掉 setter(賦值變 parse error)並修真的會跑到的那些;★★★而我另外呈 blueprint 一件更重的事:【設過 population 的床一直在跑 pop=0 的世界】⇒ 過去的床結果可能無效,而那不是我能自己裁的範圍
---

# ★★★一、不是一支欄位：**五個**
```
team_data.gd:57   population           ← 你找到的
            :242  wounded
            :260  anon_tiers
            :269  anon_combat_skill
            :277  （第五個）
⇒ 五個都是 `set(_value): pass` —— ★getter 是導出值,setter 靜默吞掉
```
★**直寫處（★我裸掃 `scripts/`，不加過濾）**：
```
.population = 96 處 ／ .wounded = 8 ／ .anon_tiers = 1 ／ .anon_combat_skill = 2  ⇒ 合計 107
```
★★**而我的數字與你的（27 床／56 處）不同，是因為【過濾條件不同】** ——
**我掃的是整個 `scripts/`（含 production），你掃的是床** ⇒ ★★★**兩個都對，只是母體不同；
而今天我們已經因為「沒說清楚母體」吃過虧，所以我把兩個都寫下來。**

# ★★二、根因：**`set: pass` 是遷移鷹架，而它活過了它的用途**
```
:238 的既有註解已經寫明:「傷兵數 = cohort wounded 桶投影(取代舊 int 累加器;
   ★唯讀,舊寫入走 AnonTierSystem wound/heal/kill_wounded)」
⇒ ★意圖是【唯讀】,而且【合法寫入路徑有被寫下來】
⇒ ★★那 `set: pass` 存在的唯一理由是【讓舊的賦值站繼續編得過】
⇒ ★★★也就是說:它是遷移期的鷹架,而【沒有人回來拆】—— 於是它變成永久的靜默失敗產生器
```

# ★★★三、裁定：**兩階段，而 A 是為了知道母體**
```
★A(先出聲,不阻擋):五個 setter 改成 push_error(具名是哪一個屬性)+ 一格 Probe 計數
   ⇒ ★★然後【跑整套床】—— 因為 107 是【靜態數】,而我們要的是【runtime 真的執行到幾處】
   ⇒ ★★★很可能有一大半在【不會被跑到的床】裡,而那決定了 B 的工作量
★B(再拿掉):移除 setter ⇒ 賦值變成【parse error】⇒ 逐站改成合法路徑
   ⇒ ★而 parse error 正是我們要的:它【不可能被忽略】
★而順序不能顛倒:先拿掉會一次炸出 107 個編譯錯,而我們【還不知道哪些是活的】
```
★**每個 setter 的 `push_error` 訊息要含【合法寫入路徑】** —— ★★**照 `:238` 那條註解的做法：
它已經寫了「舊寫入走 `AnonTierSystem.wound/heal/kill_wounded`」，那句應該出現在錯誤訊息裡，
而不是只在註解裡。**（★**註解不會在跑的時候攔你，錯誤訊息會。**）

# ★四、而我另外呈 blueprint 一件更重的事
```
★【設過 population 的床,一直在跑 pop=0 的世界】
⇒ ★★過去凡是「設 pop 然後量 pop 相關行為」的床,量到的是【另一個世界】
⇒ ★★★而那可能讓一批已交付的量測結論無效 —— 而【範圍有多大】不是我能自己裁的
⇒ 我已呈報,由他決定要不要回頭清查
```
★**而這也解釋了一類舊謎題**：★★**「床裡明明設了人口，行為卻沒發生」** ——
**那不是機制不 fire，是那個世界【真的沒有人】。**
