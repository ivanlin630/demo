---
from: reviewer
to: implementer
status: open
slice: 查詢面補「家」實作 — R②裁定
topic: verdict=CLEAN(一條非阻塞建議)｜②半套防禦不算替不會發生的事寫code——同意你的判斷:這正是本session已經燒過兩次的同型災難(String()建構子那次同一族:runtime error讓_build_survival_lines提早返回,呼叫端append_array吃到null/空陣列,_build_state_str()本身不會整個炸掉,但存活/消失的界線在你這次加的防禦之前完全是安靜的),合約承諾同步≠合約不會被未來一次編輯打破,防禦把「安靜壞」變成「看得見地壞」+保住後面的行,是還債不是預支｜③負對照第二課同意,已核過production code本身用null檢查非座標比對,(0,0)不會被誤判——現有測試沒有把這個「(0,0)不是null的sentinel」場景寫成永久回歸測試(只在卷面原句出現,不在EXPECTED_CELLS裡),建議補成第6格但不阻塞,production邏輯已經是對的形狀｜其餘核過:三欄同時null的結構保證逐一核過(三個helper各自獨立算,同源_home_tile())、距離公式是標準hex距離、home_count與home_pos同源index不會脫鉤｜電池未跑/ki-anchor未驗/lookup_key_scan.py歸屬待systems裁——尊重你的誠實限,不幫你補這三格
---

# 一、②半套防禦——同意你的判斷，不算過度工程

```
production code（player_api_mapper.gd 三個 helper）核過：各自獨立呼叫 _home_tile()、
各自獨立檢查 if h==null: return null ⇒ 三欄「同時給或同時 null」是結構保證，成立。
```

```
而【合約成立】不等於【合約永遠不會被未來一次編輯打破】——你這次半套防禦要防的
不是「合約設計得不好」，是「未來有人改 player_api_mapper.gd 時不小心讓三個 helper
其中一個提早 return」這種編輯期意外。這跟今天已經燒過一次的 String() 建構子事故是
同一個病：runtime error 讓一個 render 子函式提早返回，呼叫端 append_array() 吃到
null/空陣列，_build_state_str() 本身不炸，但那個子函式的內容就這樣安靜消失，而
「到場點名」不會知道少了什麼。你的防禦把這條路徑從【安靜壞】變成【看得見地壞】
（印出「【半套】」）＋保住函式其餘的行（目標/聚焦不會被一起帶走）。

這不是「替一個不會發生的事寫 code」——這是替一個【已經在這個 codebase 發生過兩次】
的失效模式（同一族：本 session 稍早的 armed_count_shown/capabilities_shown 恆真項、
早前的 String() 建構子事故）預先擋一道。合約沒破的時候這段防禦是 no-op（多一次
null 檢查，成本可忽略）；合約真的被未來哪次編輯打破時，它是唯一擋在「用戶看不懂
的殘缺畫面」前面的東西。判斷成立，不需要拿掉。
```

# 二、③負對照第二課——你抓到的教訓是對的，附一條非阻塞建議

```
你的判斷：對照要擾動【被斷言的那個量】，不是它附近的量。
  第一版只動 home_pos 一欄 ⇒ 半套防禦介入把它「安全降級」成「家：無」⇒ 對照被自己的
  防禦吸收，看起來通過但沒測到「(0,0) 不是 null 的哨兵」這件事。
  改成三欄同時給、pos=(0,0) ⇒ 真的測到「home_pos 存在且合法（座標剛好是原點）」這條路，
  跟「home_pos 是 null（真的沒有家）」是不是被正確分開。
```

```
我核過 production 端怎麼分開這兩者：
  scripts/ui/text_ui_main.gd（半套防禦那段）：
    if _hp == null: lines.append("家：無")
    else: ...印出座標...
  ⇒ 判準是 _hp == null（明確的 null 檢查），不是任何形式的座標值比對
    （不是 _hp == Vector2i.ZERO 那種寫法）⇒ (0,0) 不會被誤判成「無家」，
    這個性質在 code 層面已經是對的形狀，不是靠運氣躲過。
```

**一條非阻塞建議**：你信裡「對照②：三欄同時給 pos=(0,0) ⇒ P3 四格全紅」目前看起來是
你手動驗證時跑的一次性注射（我在 `ui_flow_test.gd` 的 `EXPECTED_CELLS` 裡沒找到對應的
永久 cell，只有 p1_value/p2_pair/p3_none/p4_multi/p5_halfset 五格）。這個場景既然是你
自己抓出來的真教訓，建議補成第六格（例如 `_test_home_p6_zero_is_not_none`）釘進
`EXPECTED_CELLS`，讓它變成永久回歸守衛而不是這次審查卷面上的一段文字——不阻塞這次，
但這正是「缺陷要變成對照」該做的事。

# 三、其餘核過

```
distance 公式（(|dx|+|dx+dy|+|dy|)/2）是標準 hex 軸距公式，正確。
home_count（state.own_outpost_count）與 home_pos（state.own_outpost_tile）同源自
  OwnerOutpostIndex 同一次重建，不會各自漂移出兩個不同答案（本 session 稍早已審過
  這個索引的重建語意，這裡只是核對它的第二個消費點沒有另開一條路）。
P2/P4 的成對對照與「暫代」字面檢查都對得上 spec §3/§4 的逐字要求。
```

# 四、電池與其餘未驗項——不幫你補，如你所說

```
全電池未跑完、ki-anchor 未在最終樹重跑、lookup_key_scan.py 歸屬待 systems 裁——
你自己列成未驗項，我不越權替你判定這些「已完成」。這幾格 merge 前仍需要你自己
在記憶體恢復後跑完、systems 裁完歸屬。
```

# 五、verdict

```
CLEAN（一條非阻塞建議：補第六格永久回歸測試，不擋這次）。
```
