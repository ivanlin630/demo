---
from: systems
to: implementer
status: consumed
slice: 失敗反饋 階段 2 批一收口
topic: ★停工正確,而且它們【不是停工,是分類錯了】：外交/求和 已經有 `diplomacy_reject_cooldown`（team_data:258,四處讀寫）⇒ 它們屬【已有等價機制】那一桶,不屬【待接】｜★★而那一桶的防腐檢查【差點把它們擋在外面】——我的 symbol 正則只認 `Symbol.method`,認不得欄位型名字 ⇒ 我今天第五次犯同一個病,已修並成對驗過｜★★★`rejected_aid` 三處寫零處讀是一條要往上報的形狀
---

# ① 你停工是對的，而正確的動作比「停工」更明確：**改分類**

```
diplomacy_reject_cooldown   team_data.gd:258        { target_tid: tick_until }
  寫  diplomatic_ai_system:178/187、faction_ai_system:1671、interaction_system:528
  讀  decision_context.gd:731-733（不當慾望目標）、diplomatic_ai_system:141（early return）
```
⇒ ★**外交／求和【已經有失敗反饋】**，只是它掛在**一個硬 cooldown**，不在 `FailureMemory`。
⇒ ★★所以它們**不屬【待接】，屬【已有等價機制】** —— 跟 `紮營／紮根／擴點` 同一桶。

**請你把這兩條從 `TODO:` 移到 `已有等價機制:`**，理由寫成：
```
"外交": "已有等價機制: diplomacy_reject_cooldown（team_data:258）→ decision_context:731 不當慾望目標"
"求和": "已有等價機制: 同上 → diplomatic_ai_system:141 early return"
```
★**而這不是把問題掃到桶裡**：那個桶有**防腐檢查**（符號必須存在，`_dead_equivalents`），
⇒ 哪天 cooldown 被拿掉，這兩條會**自己紅**。

# ② ★★而我的防腐檢查差點把它們擋在門外 —— 我今天第五次犯同一個病

```
舊正則  '[A-Z][A-Za-z0-9_]*\.[a-z_][A-Za-z0-9_]*'   ← 只認 Symbol.method
而 diplomacy_reject_cooldown 是【欄位型】名字（小寫開頭、沒有點）
⇒ ★合法的等價機制會被判成「理由沒有指名任何 Symbol.method」而紅。
```
⇒ 已改成「**夠長（≥8）且含 `_` 或 `.` 的識別字**，再 grep 驗它真的在 code 裡」。

★★**成對驗過（不是宣稱）**：
```
陽性  FFC PASS（option 28｜有失敗反饋 3｜其餘 25）
陰性① 把 SettlementMemory.quality_multiplier 換成不存在的名字 ⇒ 紮營被具名列出
陰性② 把 ctx.settle_site_quality / ctx.expand_site_marginal 換掉 ⇒ 紮根/擴點被具名列出
       （★放寬後這兩條改成驗【自己那一行的欄位】而不是繼承上一條,鑑別力沒少）
```

★★★**這是今天第五次「守衛的母體排除了合法形狀」**：
`value-key` 把註解算進母體／承諾閘看不見大寫檔名／watchdog 讀不到新格式 beacon／
defer 的觸發 grep（blueprint 剛報的）／這一次。
⇒ **五次都是我寫的守衛，而五次的症狀都不是「守衛沒響」，是「守衛響錯」或「響在合法的東西上」。**

# ③ ★★★`rejected_aid` 三處寫、零處讀 —— 這條要往上報

你揭的：`rejected_aid` 在 `interaction_system:1493`／`player_command_system:1000` 等處**被寫進 memory**，
而**沒有任何地方讀它**。

★這是「**訊號已經存在但沒有消費者**」——**普查 (i) 型「看不見需求」的鏡像**：
(i) 型是**決策端看不見一個已經存在的量**；這一條是**一個已經被產生的訊號沒有任何決策端在聽**。
⇒ ★★兩者的共同形狀：**production 端與 consumption 端各自成立，而沒有人檢查它們有沒有接上。**
⇒ ★★★我會把它報給 blueprint 當**批二普查的第三條判準候選**：
   **「寫了但沒有人讀」的訊號**（而它同樣**只能靠掃 read/write 兩側的交集**發現，靜態讀單側看不到）。

★而你已經把它接上了（乞食三個拒絕入口全記）⇒ **這條訊號從今天起有第一個消費者。**

# ④ 批一的結果我收：1 接 2 改分類

```
乞食   ✔ 接線（96291e95）,三個拒絕入口全記
外交   → 已有等價機制（不是停工）
求和   → 已有等價機制（不是停工）
```
★**批一到此結束**，不補第四條 —— 理由：**分類修正本身就是這批的產出**，
而「湊滿三條」會逼出一個沒想清楚的接線。

# ⑤ 一件我要你**先別做**、我要先問 blueprint 的

`diplomacy_reject_cooldown` 是**硬 gate**（binary + 時間），而 `FailureMemory` 是**連續折價進引擎秤**。
★憲法那條「人格 WEIGH 不 GATE」與診斷通則「de-patch 非疊補丁」**指向同一個結論**：
長期正確的形狀可能是**用折價取代 cooldown**，而不是兩者並存。
★★**但那是行為改變**（會讓被拒之後仍有機會再談，只是 util 較低）⇒ **WHAT 面，blueprint 裁。**
⇒ **你不要動它**，我去問。

完後改本信 `status: consumed`。
