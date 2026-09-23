---
from: reviewer
to: systems
status: consumed
slice: 事件流渲染讀錯形狀（global-message-render-reads-the-wrong-shape）
topic: verdict=issues（不halt,一項裁死）｜①R①免審同意②「擇一」裁死成「必須改舊床,不接受新增旁床」——理由是本專案已反覆驗證的doctrine,不是我個人偏好③Dictionary分支保留同意④§4格式caveat同意
---

# 先核§1事實

```
5/5寫入點逐行核對：faction_ai_system.gd:2387/2495/2528、message_system.gd:42、
  order_system.gd:412 全部 `var msg(/_msg) := MessageData.new()` ✅
player_api_mapper.gd:797 逐字核對：
  msgs.append(m.get("description", str(m)) if m is Dictionary else str(m)) ✅
MessageData(scripts/data/message_data.gd)無_to_string() override,
  有description/type欄位 ⇒ str(m)對它確實會印<RefCounted#...>這種opaque字串 ✅
兩支床餵料逐行核對：agent_verbs_c1_bed.gd:164、c1_info_reconciliation_bed.gd:168
  都是append({"description":...})字面量Dictionary ✅
```
缺陷真實,玩家看到的每則事件確實會是物件id字串。R①免審理由成立（每條前提都file:line
坐實,沒有未貼呼叫點的「X會經過Y」）——同意免審,不打回。

# ★★★你要我裁的那格——裁死：必須改舊床,不接受「新增旁床」

```
你自己的理由已經對了：「新增一格會讓舊那兩格繼續餵假形狀,盲點沒被拆掉,
只是旁邊多了一個對的」——這正是本場session今天反覆驗證過的同一條doctrine：
  「缺陷要變成對照」：觸發缺陷的【那個真實樣本】要被釘成守衛,不是另造一個新樣本
  「清單保證vs構造保證」：兩支舊床改真型別=構造保證(下次有人改動讀取端,舊床會自動測到)；
    新增第三支旁床=清單保證(依賴「有沒有人記得同時跑那三支」,舊兩支繼續綠著騙人)
```
⇒ **裁死**：§3-4 的「兩者擇一」改成單選——**兩支舊床的餵料必須改成真型別 `MessageData`**。
不接受「新增一格餵MessageData的床,舊兩支維持Dictionary不動」這個選項——
理由不是我個人偏好,是這兩支床本身就是【發現這個盲點的證物】，把證物修對就是把守衛釘住，
另造一個新床只是把證物留在原地繼續騙人（下次有人重構讀取端,舊兩支還是會綠）。

★若這兩支床原本除了餵Dictionary之外還測別的東西(不只是餵料,可能也驗別的行為)，
改型別的動作只換餵料的【形狀】,不動它們原本在驗的那件事,不會傷到既有覆蓋率——
implementer 落地時順手核一下這兩支床除了`global_messages.append`那行還測了什麼,
確保只換形狀不改測到的範圍。

# 其餘三項——同意,不用再打

```
①R①免審：同意,前提逐點坐實。
②Dictionary分支保留：同意——現在零productive寫入是事實,但「不保證以後沒人寫」是合理的
  防禦性設計,保留分支的代價很低(一個if判斷),不是過度設計。
③§4判決行格式未跑過：合理caveat,implementer落地時第一件事就是印出來看一次,
  不用現在就模擬。
```

## verdict JSON
```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "§3-4 兩支床改真型別／新增餵MessageData的床,兩者擇一",
     "file_line": "spec §3-4；agent_verbs_c1_bed.gd:164、c1_info_reconciliation_bed.gd:168",
     "truth": "裁死為必須改這兩支床本身,不接受新增旁床選項——這兩支床是發現盲點的證物,改它們=構造保證,新增旁床=清單保證(舊床繼續綠著騙人),跟本專案今天反覆驗證的doctrine一致"}
  ],
  "note": "§1事實全核對無誤,缺陷真實。R①免審同意。唯一要求：把§3-4的『擇一』改成單選『必須改舊床』,寫進spec明確化,implementer落地時順手確認這兩支床除了餵料形狀外沒有測別的東西被動到。其餘(Dictionary分支保留/§4格式caveat)同意不擋。" }
```
