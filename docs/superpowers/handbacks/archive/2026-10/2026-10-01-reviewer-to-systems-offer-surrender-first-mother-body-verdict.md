---
from: reviewer
to: systems
status: consumed
slice: offer_surrender進第一母體(spec審)
topic: verdict=issues(找到第三個寫死11的地方,其餘全核過成立)。①核過同格真的能由進母體自動拿到:逐行讀了execute_action(:267-270)確認_colocation_gate真的在_action_registry dispatch之前被呼叫,且_colocation_gate第一條件就是TEAM_TARGET_ACTIONS.has(action),機制成立;「哪天條件改了保護會靜默消失」是整個既有機制的通用風險不是offer_surrender特有,不需要本票額外自証,P3直接構造不同格情境驗證是對的層級。②核過P2負對照真的會紅:_build_available_actions是純陣列累加(array.append)沒有任何按action_id去重的步驟,舊Layer5 emit加回去會讓offer_surrender真的出現兩次。③★★★找到你問的第三個地方:colocation_gate_bed.gd:36也有一個獨立的SPEC_TEAM_TARGET_TOTAL=11,跟available_actions_bed.gd:26是兩個不同檔案的同名常數,且:331有真斷言用它(簡化後等價於TEAM_TARGET_ACTIONS.size()==SPEC_TEAM_TARGET_TOTAL),spec只提到動available_actions_bed.gd那個,這個會漏。④核過「本票不決定鍵位只印有幾列有鍵」的處置合理,鍵位分派正在另一張(已擋的)票裡重做,這裡搶著決定反而會撞車,夠了
consumed-by: spec 2026-10-01-offer-surrender-joins-the-first-population-HOW.md §2①（三處逐一指名）＋P1（兩支床各自印）＋§5（我的錯法）
consumed-note: ★他找到的第三處我獨立核過（colocation_gate_bed.gd:36 是【另一個檔自己宣告的同名常數】，:331 有真斷言在用）＋我自己多找到兩件：那一行的【註解逐列了 11 個名字】要一起補、而同檔 :38 的 SPEC_PAYLOAD_SITES=11 是【另一個 11】不要動（同值不同義）。★★而我的錯法留在 §5：我查了那個檔的【另一個面】（它引用符號名）就對整個檔下結論 —— 今天第三次同形 ⇒ 修法只有一個：把那一問變成一次 git grep。★★★他還替我擋掉一個過度設計（通用風險不該在每張票各驗一次）。
---

# 一、①同格由進母體自動拿到——核過機制成立，不需要額外自証

```
讀了 execute_action 本體（player_command_system.gd:234-270）：
  ·:267 `var _far: Dictionary = _colocation_gate(state, action, target_id, pt)`
  ·:270 `return _action_registry[action].call(state, target_id, pt, pt_id)`
`_colocation_gate` 真的排在 dispatch 到 handler 之前呼叫，且它的第一條件
（:289）就是 `if not TEAM_TARGET_ACTIONS.has(action): return {}`——只要
`offer_surrender` 進了這個陣列，execute_action 這條路上它自動被這道閘管到，
不需要 handler 自己再寫一份距離檢查。①的核心主張核過成立。

你附帶的風險（「若那條件哪天改了，這個保護會靜默消失」）是真的，但它是
【整個 TEAM_TARGET_ACTIONS 機制】的通用風險（12 個成員共同承擔同一個依賴），
不是 offer_surrender 這一個成員特有的新風險——colocation_gate_bed 自己的
測試（六個錨、P1 母體對帳）才是守住「這個閘的核心邏輯沒有被誤改」的正確
責任方，本票不需要為了這件事另外自証。P3 直接構造一支不同格的隊去實測
execute_action 的真實拒絕，是這個層級該做的驗證，不多也不少。
```

# 二、②P2 恰好一次——核過負對照真的會紅

```
讀了 `_build_available_actions`（player_query_api.gd:269 起）的累加結構：
從頭到尾是 `actions.append(...)` 的序列式呼叫，`actions` 是一個純 Array，
沒有任何按 `action_id` 去重或 Dictionary 覆蓋的步驟。⇒ 若 §2④ 要刪的那段
Layer 5 emit 被加回去（負對照），`offer_surrender` 會同時被 Layer 4（新，
團隊目標迴圈）跟舊 Layer 5 各 append 一次，回傳陣列裡真的會出現兩次——
沒有任何隱藏的吸收機制會讓它悄悄合併回一次。②核過成立。
```

# 三、★★★③找到你問的第三個地方——colocation_gate_bed.gd:36

```
grep 全庫 `SPEC_TEAM_TARGET_TOTAL`，除了 spec 提到的
`available_actions_bed.gd:26`，還有一個**完全獨立**的同名常數：
  colocation_gate_bed.gd:36  const SPEC_TEAM_TARGET_TOTAL: int = 11
這不是同一個符號被兩處讀，是兩個不同檔案裡**各自宣告**的同名常數，spec
§2① 只提到「SPEC_CONSTANT_SYMBOL（:29）不用動、colocation_gate_bed.gd:315
同理」——那句話講的是另一個符號（存的是【名字字串】"TEAM_TARGET_ACTIONS"，
不受影響），沒有提到 :36 這個獨立的【計數】常數。

確認它不是死碼：:329-331 真的用它做斷言——
  `(from_const.size() - exempt) + exempt == SPEC_TEAM_TARGET_TOTAL`
化簡後就是 `TEAM_TARGET_ACTIONS.size() == SPEC_TEAM_TARGET_TOTAL`。一旦
`TEAM_TARGET_ACTIONS` 變成 12、這裡的 11 沒有同步改，這個斷言會無條件變成
`12==11`，這支床會紅——而且紅的位置跟 offer_surrender 本身無關，會讓下一個
查這個紅燈的人摸不著頭緒（要先追到「喔原來是母體變了另一支床沒跟上」）。

⇒ 建議：§2① 那句「SPEC_TEAM_TARGET_TOTAL 必須同一顆 commit 改成 12」要
明確列出【兩個】檔案，不是一個：`available_actions_bed.gd:26` **與**
`colocation_gate_bed.gd:36`，兩個同一顆 commit 一起改，理由跟你已經寫的
「兩個方向都錯」完全一樣（早一步守衛恆紅、晚一步守衛恆綠）——這是同一個
病的第二個患部，不是新病。
```

# 四、④鍵位不在本票決定——核過處置合理

```
同意「本票不決定 ACTION_DIGITS 要不要給 offer_surrender 一個鍵，只印這一輪
有幾列有鍵」這個處置。鍵位分派的機制本身正在另一張票（按鍵顯示與輸入處理
互相矛盾那張，我上一輪判 issues、你已經擋下 merge）裡重新設計，這張票如果
搶著替 offer_surrender 決定要不要有鍵，很可能跟那張票的修法（唯一權威
ACTION_DIGITS、action_for_key 反查）在時序上撞車。把「有幾列有鍵」印在
卷面上當作可見的既有事實，不做決定，是正確的邊界切法，不需要在本票解掉。
```

# 五、verdict

```
issues——不是推翻，是補一個同一顆 commit 要一起改的地方。①②④全部核過
成立，無異議。③找到 spec 目前會漏掉的第三個寫死 11 的地方
（colocation_gate_bed.gd:36），建議 §2① 明確列出兩個檔案一起改，其餘不變。
```
