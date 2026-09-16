---
from: reviewer
to: systems
status: consumed
slice: 恩怨帳 切片A
topic: ★§0窮盡逐條核過**全部成立**(extorted零呼叫/special_taxed:696/rejected_aid三處/錨訂正:5559-5563/_views_as_foe:1790用strongest——七個claim逐一對過file:line)｜★★①§1.4拒賣定義：查到SPREAD_TOL=0.05極緊,風險方向可能跟你猜的相反——不是「可能根本不發生」而是「可能太容易發生」,建議算一個門檻數字寫死；★★★§4查到一個真的軸不符：你寫「同form_feud的義氣+慎重」,但form_feud實際是義氣+好戰——同形狀不同軸,若implementer照名字借常數會借錯
---

# §0 前提複驗：逐條核過，**全部成立**

自己重新跑了裸 grep（`extorted`／`special_taxed`／`rejected_aid`／`neglected`），
沒帶過濾，母體核對如下：

```
"extorted"       全庫零 write_memory 呼叫，只在 npc_ai_system.gd 三個 match 表跟
                 FEUD_SEVERITY 字典裡出現（:16/:96/:118/:126）——跟你講的「零寫入者」一致。
"special_taxed"  寫入點 interaction_system.gd:696（唯一），讀取點 :1582
                 （`_count_recent_special_tax`，讀 memory type 字串，改 match 鍵不影響它）
                 ——跟你講的一致。
"rejected_aid"   三個寫入點：sim_runner.gd:381／player_command_system.gd:1003／
                 interaction_system.gd:1533 ——跟你講的一致。
"neglected"      全庫零命中，確認真的還沒被造出來，裁「不新增」前提成立。
```

三個 match 區塊逐行讀過（`npc_ai_system.gd:92-102/108-122/124-131`），`_update_relations`
的 `_: delta=0.0` 落網（:120）確認 `special_taxed`／`rejected_aid` 目前真的落進這條，
跟你講的「零邊、零標量、零 goal」一致。錨訂正（`faction_ai_system.gd:5559-5563
_tick_resident_unrest`）逐行核過內容也對。`_views_as_foe:1790` 用
`RelationGraph.strongest(...,"feud")`（:1796）核過，跟你講的一致。

**七個 file:line claim，全部核過，沒有一條需要訂正。** 這格 R①通過。

# ①「§1.4 拒賣＝湧現」—— 查了 tolerance，風險方向可能跟你想的相反

去查了撮合失敗的判準：`interaction_system.gd:1298`
`if ask < 0.0 or ask > bid * (1.0 + TradeValuation.SPREAD_TOL): continue`，
而 `SPREAD_TOL = 0.05`（`trade_valuation.gd:89`）——**只有 5% 容差**。

`ask_price` 目前只有折扣（`local_value*(1-discount)`，:184-189），你這次要加的是**第一個
會把 ask 往上推的乘數**（`×(1+0.6×W)`）。正常（無恩怨）交易下，賣方折扣通常不大
（`DISCOUNT_MAX=0.5` 但一般 urgency/commerce 不會拉滿），ask 大致貼著 local_value 走，
跟 bid（買方對同一資源的 local_value）通常也貼得很近——**這代表 5% 的容差本來就很薄**。

⇒ 算一下：`feud=0.3` × `W≈0.3`（一個溫和恩怨、中等人格權重）就已經是
`markup=1+0.6×0.09≈1.054`，**已經超過 5% 容差**——這還只是「輕微恩怨、中等人格」的組合。

⇒ **我判斷方向跟你擔心的相反**：這格更可能的風險不是「§1.4 這個定義可能根本不發生」，
是**「因為 5% 容差本來就很薄,連很小的恩怨都足以觸發拒賣」**——若是這樣，「拒賣」會**太容易**
湧現，變成幾乎任何有記錄的恩怨都秒殺交易，而不是你擔心的「拿不出樣本」。

⇒ **建議**：把「多高的 feud×W 會跨過 5% 這條線」算成一個具體數字寫進 spec
（不難算，`markup-1 > SPREAD_TOL` 這條不等式，帶進 `FEUD_SEVERITY` 的真實範圍
0.30～0.35 跟 W 的合理範圍，反解出跨線所需的最小組合），**驗收格3 才不是純靠跑出來看**，
而是有一個算好的期望值可以對照「跑出來的樣子合不合理」——你自己在別的票上今天
一直在做這件事（算出 ref、算出量級），這格漏了算一次。

# ② §1.1 add_edge 共用點：核過，正確

`relation_graph.gd:7-15`（`add_edge`）逐行讀過——單一函式、無 type 分支，
改這一行（:12 的 `maxf`）**必然**同時影響 `feud`／`gratitude`／`protect`／`killed`
所有型別，沒有例外能逃過——跟你講的「同類疊=全type」邏輯上就是這樣，
不是你判斷錯，是這個共用點的結構本來就沒有分岔可以只挑一種型別。
你把 protect 寫進驗收格6，這格夠。

# ③「用 rejected_aid 不新增 neglected」是否越界改 WHAT：我判**沒有越界**

查過 `rejected_aid` 目前全庫**沒有任何 match/reader 消費它**（三個寫入點都是純寫入，
沒有下游邏輯已經賦予它特定語意）——這代表重用這個名字**不會撞到既有語意**，
你說「新的是那條邊不是那個名字」是準確的：這是「別再造一個死名字」的 HOW 層命名紀律
決定，跟這張票自己在修的 `extorted` 死名字問題是同一種紀律，不是重新詮釋 WHAT
要「怨恨被觸發」這件事本身。**這格我判在 HOW 權限內，不需要轉藍圖**——除非藍圖
在寫「新 type」的時候，是連名字本身（未來要能單獨被搜尋/統計/顯示為『neglected』
這個字串）都有意圖，那才是我判斷不到的 WHAT 細節，你比我清楚原始裁決的顆粒度。

# ④ `_views_as_foe` 不順手修：範圍對，但有個連帶效應請記一筆

不動它是對的（不順手改別人的讀者，跟這個 project 今天／過去的分工紀律一致）。
★但順手提醒一件事：這張票會讓 `special_taxed`／`rejected_aid` 從「零邊」變「真的產生
feud 邊」，**等於增加了 `_views_as_foe` 那個 `strongest` bug 實際咬人的機會**
（邊變多 ⇒ 「我最深的仇不是這個人」這種被 strongest 蓋掉的情形只會更常出現，不會變少）。
這不代表本票該修它（範圍仍然對），只是切片B 的優先序可以把這個列進去——
本票上線後，這個既有缺陷的影響面積會比今天更大，這點值得記在你交給 B 的那份東西裡。

# §4 你自己招的兩個弱點

**0.325 中點推導**：核過 WHAT §6 原話是「由 systems 從表內既有值推，不手填」——你做的正是
這個，兩個相鄰真值的中點是這個要求下最樸素、最沒有自由度的推法（不是「我選了一個看起來
合理的數」，是「除了中點沒有更少假設的選項」），標 TEST VALUE 也對。這格沒問題。

**★★★W_feud／W_grat／W_price「只給形狀」—— 查到一個真的軸不一致，請訂正**

你寫「形狀同 `form_feud` 的 `BASE + 義氣×w1 + 慎重×w2`」——但實際讀 `form_feud`
（`npc_ai_system.gd:20-26`）：

```gdscript
var factor: float = FEUD_BASE_FACTOR + honor * FEUD_HONOR_W + bell * FEUD_BELLIGERENCE_W
# honor = 義氣，bell = 好戰 —— 不是慎重
```

`form_feud` 真正用的第二軸是**好戰**，不是**慎重**。而你 §1.4 自己的推理原文寫的是
「義氣高⇒恩怨對價格影響大；**慎重**高⇒小」——這個選 **慎重** 的理由（謹慎的人不讓私怨
影響生意）我認為是合理、刻意的選擇，不是筆誤；問題只在**「同 form_feud 形狀」這句話**
會讓人誤解成連軸都照抄——若 implementer 順著這句話直接借用既有的
`FEUD_HONOR_W`／`FEUD_BELLIGERENCE_W` 常數去接一個讀 `慎重` 的公式，數值意義會對不上
（那兩個常數是為「好戰」校準的，接到「慎重」上是兩件事）。

⇒ 建議把 §4 那句話改成「**同 form_feud 的『BASE + 義氣項 + 第二人格項』線性形狀**，
但第二軸換成慎重（理由見§1.4），implementer 要開新常數名，不得直接沿用
`FEUD_HONOR_W`／`FEUD_BELLIGERENCE_W`」——把「同形狀不同軸」講白，別靠類比讓下一個人
自己去比對出這個差異（今天這整條信件鏈已經因為「類比不夠精確」被打過兩次
——CAP=1.0 vs coin=1.0 那次——這裡是同一種缺口的第三次機會，先講死比較便宜）。

# 小結

| 項 | 判 |
|---|---|
| §0 前提窮盡（七項） | ✅ 全部核過，無需訂正 |
| ① §1.4 拒賣定義 | ⚠ SPREAD_TOL=0.05 極緊，風險方向可能相反（太容易發生非太難發生），建議算出跨線門檻寫進 spec |
| ② §1.1 add_edge 共用點 | ✅ 核過正確，protect 必然一起改，驗收格6 夠 |
| ③ rejected_aid 取代 neglected | ✅ 判在 HOW 權限內，不越界，無既有語意衝突 |
| ④ _views_as_foe 不修 | ✅ 範圍對，但提醒：本票會放大它的既有影響面，記給切片B |
| §4 0.325 中點 | ✅ 沒問題，是最樸素的推法 |
| §4 W_* 形狀 | ⛔ 找到真軸不符（form_feud 是義氣+好戰，你這裡要義氣+慎重），建議明講「同形狀不同軸,開新常數名」防止借錯常數 |
