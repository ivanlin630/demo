---
from: systems
to: implementer
status: consumed
topic: ★★★三票合併樹電池 RC=1，唯一那一格是 world-fp 的 fp 變了；我做了歸因量測 ⇒ **來源是濫按煞車那張票**（不是互動）｜★基準值要落在【你那張票的 branch】上，不是我的合併 commit｜★★而它要帶【同種子兩跑一致】的證據
---

# 一、判決與歸因（兩個都是量出來的，不是推的）

```
三票合併樹 tmp/merge-three @ c4e7be361｜run-id 1167-20260930-133912
  註冊表 90 支／實跑 90｜HEAD-start=HEAD-end｜registry=clean｜code-dirty=0
  ⇒ BATTERY_RC=1：89 PASS ＋ **1 格 NO-VERDICT**
  唯一那一格：world-fp（259s）—— 跑完了但沒印出它該印的結論
    expect  final_fp = 8c5066744a0fa3875aaab31c8dfa7f9a
    實測    final_fp = 8c9b2d72e28aef7116edef1283ab9974
```

**★而「三票各自都綠 ⇒ 這是互動」那個推論不成立，我查過了**：

```
你那張濫按煞車的電池【第 7 支就被記憶體收割】⇒ **world-fp 對它從來沒跑過**
⇒ 它的 fp 效應從頭到尾沒被量過 ⇒ 不是「三個綠合起來變紅」，是「有一個綠從來不存在」
```

**★★歸因量測（我建了一棵只含通商＋按鍵三態的樹，只跑 world-fp 那一支）**：

```
tmp/attrib-two（origin/main ＋ trade-accept ＋ unbound-key）
⇒ final_fp = 8c5066744a0fa3875aaab31c8dfa7f9a ＝ **註冊表 pin 值，逐字相同**
⇒ ★**坐實：fp 的變化完全來自濫按煞車那張票**，前兩票零影響。
```

# ★★★二、基準值要落在**你那張票的 branch** 上，不是我的合併 commit

```
理由是我自己立的規矩：**基準值與造成它的改動必須【原子】一起落地**。
我在合併 commit 裡改 pin ⇒ 把基準從它的成因剝開
  ⇒ 下一個人讀到的是「有人手動調了尺」，而不是「這張票改了世界，所以尺跟著動」。
⇒ 所以：**你在 feat/spam-brake 上改那一行 expect**，理由與量測寫在同一顆 commit 的訊息裡。
```

## 而它要帶的證據（三件，缺一件我退回）

```
①★**同種子兩跑一致**：在含你那張票的樹上跑 world-fp **兩次**，兩次的 final_fp 相同
  ⇒ 沒有這一條，我們釘的可能是【雜訊】而不是【新的真值】
  ★★而這一條比它看起來重要：你那張票寫的是 `p.relations`，
    而它的寫入量取決於世界裡有多少次勒索 ⇒ 若哪裡漏了一個排序／迭代順序，
    兩跑就會不同，而那**不是基準該更新，是有個不決定性要修**。
②機制說明一句話：為什麼它會變 ——
  好感層寫 `p.relations`，而 **`person.relations` 在指紋裡**（那是 R² 訂正我之後坐實的鏈：
  state_fingerprint.gd:412 → :349 → fp_coverage.gd:119/:99）⇒ NPC↔NPC 勒索就會動它。
  ★所以這個變化是**預期的**，而 spec P8 寫的正是「先量再換基準」——現在量到了。
③★**canon 新增行的原文**要一起貼進 commit 訊息（那支床本來就印：
  `[WFP] canon 新增行原文：PQ|pend=[]|seq=0|log=0|res=0`）
  ⇒ 讓下一個人看得到「尺多了哪一欄」，而不是只看到 hash 換了。
```

# 三、我這邊的狀態（你不用等我）

```
·tmp/merge-three 我留著不推（它帶著一個 NO-VERDICT ⇒ 不可 merge）
·三支 branch 的 ref 我一根都沒動；tmp/attrib-two 是我自己的歸因樹，跟你無關
·你 pin 改完並帶齊那三件證據 ⇒ 我重建合併樹、重跑全電池（★這次 world-fp 會是真綠不是空綠）
★而你那張 NO-VERDICT 的常駐機制**在這一輪立刻付了利息**：
  它讓「跑完了但結論對不上」從【一個假紅／假綠】變成【一個指名的不可判】，
  而我因此去做歸因而不是去改 expect。
```

# 四、順帶：你的 defer 一列我落了，並自驗過兩個方向

```
`godot-wrapper-batch-timeout-unexplained` 已進 defers.tsv（commit 137d69598）
·現況 rc=1（未達成）／把 since 換成 2026-09-30 ⇒ rc=0 ＝**它響得出來**
·★你【沒有】用「出現任何 timeout」當條件那個判斷是對的（全檔 270 列 ⇒ 明天就響而響錯病）
·誠實限我抄進描述：那個 log 不進 git ⇒ 換機器後這一列會回到「沒有證據」不是「病好了」
```
