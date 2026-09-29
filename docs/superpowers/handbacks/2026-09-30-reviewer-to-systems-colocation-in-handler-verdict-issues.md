---
from: reviewer
to: systems
status: consumed
slice: 同格檢查搬進handler(merge審) — R②裁定
topic: verdict=issues(不擋方向,一個真缺口要處理)｜①錨點核過確實錨在TEAM_TARGET_ACTIONS.has(action)【第一行】,hunt不會誤觸(它根本不在清單裡,連teams.get都不會執行到);單一來源核過真有異源比對測試(P2讀真實原始碼文字逐token抽取,不是自比);★★★但③負斷言是錯的——execute_action_with_target裡的recruit_named(:1428-1431→_recruit_named_internal:1488)真的跨隊轉移人+coin(from_team_id讀target dict任意值),完全沒有同格檢查,是跟這張票要堵的洞同型的第三管道,建議納入本票或至少補進defer清單明確點名｜②computed-prop那格母體地板夠(用_check非print,能在前提不成立時真的紅);另一問我查到一個更正:computed-prop閘實際涵蓋TeamData全部5個計算屬性(population/wounded/anon_tiers/anon_combat_skill/anon_wage)不是只有population,你原本的擔心已經被既有工具涵蓋,PersonData沒有類似計算屬性,這支床也沒用反射式set,沒找到第二個靠運氣過的格｜③CONTROL_FLOOR_FEP核過確實是10不是6｜④P3單向盲區判斷同意是合理範圍邊界不是推卸,正反兩方向的失效模式本質不同(壞按鈕是硬HOW不變量,漏列選項牽涉WHAT層判斷)｜⑤7的分母是10(11減1個early-return例外ignore)不是11,而且找到一個小落差待你確認:程式裡有處註解寫「8個原本零檢查的動詞」跟我算出的10對不上,可能是另一種計數口徑(零檢查vs全部團體動詞),建議統一措辭;47屬於另一軸(P3的選單規模,非同一分母),你的「兩層不同軸」判斷正確
---

# ★★★一、①③ execute_action_with_target 的負斷言——錯了，找到真缺口

```
execute_action_with_target(:1422-1438) 的 match 有四支：
  recruit_named／set_member_salary／equip_member／unequip_member
逐一核過語意（不是只看名字）：
  set_member_salary／equip_member／unequip_member 三支都檢查
    pt.named_members.has(mid) —— 真的只操作【自隊成員】，自隊動作，成立你的判斷。
  ★★★但 recruit_named（:1428-1431）呼叫 _recruit_named_internal(:1488-1511)：
    var tgt4: TeamData = state.teams.get(from_team_id)   ← from_team_id 來自 target dict 任意值
    ResourceBank.add(tgt4, "coin", RECRUIT_COST_NAMED, ...)   ← 真的動了對方的 coin
    state.remove_member(tgt4, person_id, false)                ← 真的把人從對方隊移走
  ⇒ 這支函式【逐字】就是「recruit_named」，跟已經在 TEAM_TARGET_ACTIONS 裡的
    「recruit」「recruit_anon」同一類（跨隊搬人），但它走 execute_action_with_target
    這條完全不同的 dispatch 路徑，而這條路徑【沒有任何同格檢查】——
    不是「爆炸半徑外沒有風險」，是【爆炸半徑外還有一個跟本票要堵的洞一模一樣的洞】。
```

⇒ **這正是 spec §1 自己講的那句話的第二個實例**：「不變量有兩處執法，第三條管道沒有」
——而 `recruit_named` 就是 execute_action_with_target 這條管道裡，那個沒有執法的動詞。

**建議**：這格不是可以留給下一輪的小事——它是本票要修的【同一個病】的另一個實例，
建議①納入本票同一顆 commit 補上同格檢查（`_colocation_gate` 的邏輯可以直接複用，
只是掛點換成 `execute_action_with_target` 的 "recruit_named" 分支），或②若你判斷
要另開票，至少要在 defer 裡明確點名 `recruit_named`（不是泛稱「這條路徑」），
且不能寫成「已核過不在爆炸半徑內」，因為它就在半徑內。

# 二、② computed-prop 修法——母體地板夠，且我幫你查到一個更正（好消息）

```
P5 那格：_check("★母體地板B:索貢的前提真的成立(不成立的話ok=false不代表閘擋了它)",
  float(pt.population) > float(tgt.population)*1.5) —— 用的是 _check（會計入 _errors 讓
  整支床紅），不是只 print 數字，符合「能在前提不成立時真的紅」這個要求。夠。
```

```
★另一問「還有別的格靠運氣過嗎」——我查了 computed_prop_sites.py 本體：
  PROPS = r'(population|wounded|anon_tiers|anon_combat_skill|anon_wage)'
⇒ 這支閘【已經涵蓋 TeamData 全部 5 個計算屬性】，不是像信裡說的只盯 population 一個——
  你原本的擔心（"computed-prop 只抓 population 這一個屬性，其他計算屬性它管不到"）
  可以撤回，它本來就管全部已知的 5 個。
  PersonData 我查過沒有同構的 get:-only 計算屬性；colocation_gate_bed.gd 本身也沒有
  用 .set(...) 反射寫入（工具唯一承認的盲區）。
⇒ 沒有找到第二個「靠運氣過」的格。
```

# 三、③ rebase 常數——核過，取的真的是 10

```
grep 全庫 CONTROL_FLOOR_FEP ⇒ 只有 ui_flow_test.gd 一處：const CONTROL_FLOOR_FEP: int = 10
確認取到的是較大值，棘輪守衛沒有被悄悄調鬆。
```

# 四、④ P3 單向盲區——同意，是合理邊界不是推卸

```
正向（畫面列出的都必須過 handler）失效模式：玩家看到一個按不動的選項——這是硬
HOW 不變量，不需要任何 WHAT 輸入就能判斷對錯。
反向（handler 會放行的都必須被畫面列出）失效模式：玩家看不到一個他本來可以做的
選項——但這件事本身是不是缺陷，取決於「那個選項該不該被列」，而你舉的例子
（combat_target 過濾掉交戰中的隊）明顯是【刻意的設計排除】，不是遺漏。
⇒ 兩個方向的失效模式性質不同（一個是純 HOW 矛盾，一個牽涉 WHAT 判斷「這個排除
合不合理」），你把反向那格留給 WHAT 層、只在床裡寫清楚主詞跟下一步，是對範圍的
正確切分，不是把該做的事推掉。
```

# 五、⑤ 負對照母體——「7」核過但發現一個小落差，「47」核過是另一軸

```
P1 的迴圈：for act in TEAM_TARGET_ACTIONS（11 個），跳過 SPEC_EARLY_RETURN_EXEMPT
（只有 "ignore" 一個）⇒ 實際測試 10 個動詞，負對照的「7 個成立」是這 10 個裡的 7 個
（另外 3 個大概率是撞到 colocation 以外的其他前提，例如 extort 的 readiness 門檻），
不是「11 個裡的 7」。

★但我也發現一個措辭落差：P1 那格自己的註解寫「本格逐一指名那 8 個原本零檢查的
動詞」——8 跟我算出的 10（11-1）對不上。可能你這裡的「8」是另一種計數口徑（例如
「原本完全零檢查」vs「有其他檢查但沒同格檢查」是兩類，8 只算前者），但這個數字
沒有在 spec 或床的註解裡解釋清楚，建議統一或加一句說明這個 8 從哪來，免得下一個
讀者也卡在跟我一樣的疑惑上。

「47」屬於 P3（畫面側過濾拿掉），母體是整個測試世界裡【可能出現在選單上的
team×action 組合數】，跟 P1 的「對單一遠方目標測 10 個動詞」是完全不同的分母
——你判斷「兩層不同軸的量級」是對的，不需要對齊成同一個數字。
```

# 六、verdict

```
issues（不是 premise_contradiction，方向對；一個真缺口要處理）：
  ①execute_action_with_target 的 recruit_named 沒有同格檢查——這不是「不在爆炸半徑內」，
    是本票要堵的同一個洞的第三個實例，建議納入本票或至少在 defer 裡明確點名它
非阻塞：⑤那個「8」跟「10」的措辭落差，建議補一句說明來源。
其餘（①①②②③④⑤47那半）全部核過成立，無異議。
補完①即視為 CLEAN。
```
