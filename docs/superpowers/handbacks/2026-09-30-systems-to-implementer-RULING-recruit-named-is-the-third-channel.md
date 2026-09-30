---
from: systems
to: implementer
status: consumed
consumed-by: docs/superpowers/handbacks/2026-09-30-implementer-to-systems-third-channel-gated-87-87.md（第三個管道補完、P6 五條逐欄、口徑帶分母、電池 87／87、負對照 6／6）
consumed-note: ★我的錯法記在回信 §②：標註了借來的結論卻仍然讓它充當覆蓋 —— 而處置是把那個範圍放進床的母體，不是決心多核一次。
topic: ★★★R² 抓到第三個管道：`recruit_named` 跨隊搬人＋搬 coin 而零同格檢查 —— 我裁【納入本票同一顆 commit】，不登 defer｜＋口徑統一（8 與 10 各自的分母）｜★而那個「不在爆炸半徑內」是我說錯的
---

# 一、R² 擋件，而擋得對：**我那個負斷言是錯的**

我在 spec §5 寫「`execute_action_with_target`（吃 Dictionary 那條）不在爆炸半徑內」——**錯的**。我開檔重核了：

```
execute_action_with_target → "recruit_named" → _recruit_named_internal(state, pt, from_team_id, person_id)
  var tgt4: TeamData = state.teams.get(from_team_id)      ← from_team_id 來自 target dict（任意值）
  ResourceBank.set_amt(pt, "coin", …)                     ← 玩家付錢
  ResourceBank.add(tgt4, "coin", RECRUIT_COST_NAMED, …)   ← 對方收錢
  state.remove_member(tgt4, person_id, false)             ← 人離原隊
  state.add_member(pt, person_id)                        ← 人入玩家隊
★零同格檢查 ⇒ 走程式介面可以【隔空向任意隊買走一個記名成員】
⇒ 它轉移【人＋coin】，比隔空索貢更重。
```

## ★★我的錯法（今天第二次同族，而這次更結構）

```
我用【哪一個入口】界定爆炸半徑，而不變量的母體是【哪些動作跟別隊發生作用】
⇒ ★**入口不是母體。** 「它吃 Dictionary」是真的，但那件事**與這個問題無關** ——
  型別不同不代表它不跟別隊發生作用。
★★今天第一次同族是「好感不在指紋裡」（我只查了手寫那一套收錄機制）
  ⇒ 兩次都是**我拿一個維度去代替母體**（一次是收錄機制、一次是入口）。
⇒ ★★★規矩：下「某條路不在爆炸半徑內」之前，先把**母體的定義**寫出來，
  而那個定義必須是【被守的性質】（跟別隊發生作用），不是【我審查的路徑】。
```

# ★★★二、裁：**納入本票，同一顆 commit。不登 defer。**

R² 給了兩條路（納入／或至少在 defer 裡指名）⇒ 我裁**納入**。
理由：同一個洞、同一條不變量、同一張票 ⇒ 登 defer 等於**把一個已經有名字的活洞寫進表裡然後留著**，
而**表裡的名字不會堵住它**。

```
做法：覆用 `_colocation_gate` 的邏輯，掛在 `recruit_named` 那條路的【單一咽喉】
     （`_recruit_named_internal` 入口 或 `execute_action_with_target` 的那一支，位置你選，但只准一處）
★驗收加一格 P6【跨隊招募也需同格】：
  直呼 API、不同格的隊 ⇒ ok=false **且【人與 coin 兩邊都沒動】（逐欄印）**
  ｜負對照：拿掉那一行 ⇒ 人真的被買走、coin 真的轉移 ⇒ 必紅
★★而它必須印【兩邊都沒動】而不是只印 ok=false：
  這條路有**四個寫入**（付錢／收錢／離隊／入隊）⇒ **半途擋下來比沒擋更糟**
  （人離了原隊而沒入玩家隊 ＝ 憑空消失）。
```

# ★三、口徑統一（R² 發現床裡的「8」與他算的「10」對不上）

**兩個數都對，只是分母不同 ⇒ 兩個都要寫上分母**：

```
·需同格的動詞 ＝ **10**（`get_available_actions` 的 11 減掉 early-return 的 `ignore`）
·原本零檢查的 ＝ **8**（10 減掉已有檢查的 `invite_settle` 與 `beg`）
⇒ 床裡那句改成「8／10 原本零檢查」，不要光寫 8。
★★而加入 `recruit_named` 之後分母也要動：它**不在** `get_available_actions` 的集合裡
  （走另一個入口）⇒ **閘的母體定義要從「動詞清單」改成「跟別隊發生作用的動作」**，
  並在卷面上把**兩個入口各自的數分開印**。
```

# 四、R² 其餘四件（已收，不需改設計，但有兩件是我說錯的）

```
①錨點確實錨在 `TEAM_TARGET_ACTIONS.has(action)` 第一行；`hunt` 不在清單裡
  ⇒ 連 `teams.get` 都不會執行到 ⇒ ★**我擔心的那個誤擋不成立**
    （我的形狀對、而結果被你的錨點擋下來了 —— 這一句要記在卷面上，別讓它看起來像我白擔心）
②`computed-prop` 實際涵蓋 TeamData **全部 5 個**計算屬性（不只 `population`）
  ⇒ ★**又一個我沒查就說的負斷言**（我寫「它只盯一個屬性」）。PersonData 沒有同類計算屬性，
    這支床也沒用反射式 set ⇒ 沒有第二個靠運氣過的格。
③`CONTROL_FLOOR_FEP` 確實取到 10（取大的）✓
④P3 單向盲區 ＝ 合理範圍邊界（正反兩方向的失效模式本質不同：壞掉的按鈕是硬 HOW 不變量，
  漏列選項牽涉 WHAT）✓
```

# 五、下一步

```
①把 recruit_named 那一格補上（同一顆 commit）＋ 口徑改成帶分母
②重跑電池（★母體變了：註冊表若不變則 87／87，而 P6 是床內新增一格）
③交回我 ⇒ 我送 R² 複核（他寫「補完即 CLEAN」）⇒ 綠才 merge
★而 P25／通商／煞車照原序排在後面，不要併進這一顆。
```
