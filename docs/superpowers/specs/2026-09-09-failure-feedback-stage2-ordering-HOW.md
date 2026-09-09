# HOW spec：失敗反饋 階段 2 —— 排序、分批，與第一批

owner: systems ｜ 2026-09-09 ｜ player_reachable: no ｜ 狀態：R² CLEAN（item3/4 已補）⇒ 可 dispatch

## §1 這張票在解什麼

階段 1 把「誰沒有失敗反饋」變成資料（28 = 已接 2／待接 14／已有等價機制 3／判準不成立 9），
並讓 `failure.unmapped.<option>` 可以數。**階段 2 是把「待接 14」接上去**，
而**接一個要回答三個逐 option 不同的設計問題** ⇒ 必須分批。

## §2 ★★★排序之前必須先做的一次 join（不做會接錯東西）

```
階段 1 的 unmapped 前 5：建設 483／迎戰 434／求和 428／紮營 349／survival 299
★而 `迎戰`／`survival` 屬【判準不成立】、`紮營` 屬【已有等價機制】
⇒ ★★`failure.unmapped` 數的是「【沒有走 OPTION_FAIL_KEY 這條路】」，
   不是「【沒有任何失敗反饋】」。
⇒ ★★★照這份名單由上而下接，第 2、4、5 名都會接到【不該接的東西】。
```

**⇒ 本票第一件事：產出一張 join 過的表，而不是直接用 unmapped 排序。**

```
option ｜ 桶（已接／待接／已有等價機制／判準不成立）｜ unmapped 次數 ｜ 已存在的失敗訊號(file:line)
★只有【待接】那一桶的列是候選。
★★而表要【整份印出來】（28 列），不是只印候選 —— 讓下一個人看得到「為什麼那幾個不在候選裡」。
```

## §3 分批判準（每批 3 條，理由：一批要能一次審完）

排序鍵**依序**：

```
①【待接】桶（硬過濾，非權重）
②該 option 的 unmapped 次數（＝它被決策的頻率 ⇒ 折價會影響多少次決策）
③★已存在的失敗訊號【夠不夠具體】：
   有明確 reject 事件（envoy.reject / join_rejected / rejected_aid）＞
   有 abandoned 偵測（construction_abandoned）＞
   只有靜默 `return false`（convoy 那七個）
   ★理由：訊號越具體,「什麼算失敗／target 是誰」越不需要發明
```

★**第一批我先定，其餘等第一批的實測**（不預先排完 14 條 —— **排完的清單會變成工單，而工單會被照抄**）。

## §4 第一批（3 條）

| option | unmapped | 已存在的失敗訊號 | 三個設計問題的**已知答案** |
|---|---|---|---|
| **外交**（結盟） | ─ | `envoy.reject`（`faction_ai_system:582`）、全庫 152 reject / 6 accept | 失敗＝envoy 被 reject；target＝**對象勢力**；TTL＝★待定 |
| **求和** | 428 | diplomatic reject 路徑 | 失敗＝求和被拒；target＝對象勢力；TTL＝**借 §5③ 的先例形狀** |
| **乞食** | ★見下 | `rejected_aid` 已寫進 memory（`interaction_system:1493`） | 失敗＝乞食被拒；target＝**被乞求的那一隊**（單一事件、單一對象，無歸屬歧義）；TTL＝借先例形狀 |

★★★**「建設」被移出第一批（R² 2026-09-09 查實，硬阻斷不是軟風險）**：

```
faction_ai_system.gd:6383  ⛔ current_dispatch_id / current_dispatch_target 是【磚 branch 的欄位】,本 branch 沒有
              :6386-6387  # TODO(rebase-after-brick): team.commit_stall_id = team.current_dispatch_id  ←整段註解
team_data.gd:272-273       commit_stall_id / commit_stall_target 欄位【存在】但【永遠沒被賦值】
⇒ ★這不是「查完可能還好」,是【跨 branch 依賴沒到位】⇒ 查完必定卡住。
⇒ ★★`自救建田` 也【不能】當替補：它的理由寫著「同『建設』,走同一條 construction_abandoned」
   （failure_memory.gd:54）⇒ 同一組依賴、同一個阻斷。
```

★**第三條為什麼是「乞食」而不是照 unmapped 次數選** —— 我把限制寫出來，不假裝排過：
```
§3 排序鍵②（unmapped 次數）★我【無法套用】：階段 1 只回報了前 5 名,
   完整的 20 種計數【沒有落地成檔案】,而那份回報的來源卷面已被覆寫（見 03b 第四條）。
⇒ 改用排序鍵③（訊號具體度）——它有 file:line 可查,不需要重跑：
   明確 reject 事件 ＞ abandoned 偵測 ＞ 靜默 return false
   `乞食` 有 `rejected_aid`（單一事件、單一對象）
   `併入`／`吸納` 共用 `join_rejected`（faction_ai_system:6331 / interaction:1280）
   ⇒ ★選 `乞食`：★★兩個共用同一事件的 option 會多出一個「這筆失敗算誰的」的歸屬問題,
     而第一批不該同時處理【接線】與【歸屬歧義】。
⇒ ★★★而本票【必須把完整的 join 表印出來】(§2)：若真實計數與這個選擇矛盾,那必須看得見。
```

★★★**`建設` 那條有一個【現成的坑】**：`:6424` 的註解自己寫著
「**現在故意不記 —— 寧可少一筆，也不要用錯身分記到無辜選項頭上**」
⇒ ★**那個 TODO 的前提（身分快照）是否已經到位，必須先查**；
★★**沒到位就不要接它**，改把第一批換成別的 option ——
★★★**而「查了發現還沒到位」本身是這張票的合格產出**，不是失敗。

## §5 每一條接線都要回答的三題（★寫進 handback，逐條）

```
①什麼算【失敗】？ ——★必須是【做不成】,不是【效果不好】(階段 1 判準①)
②【target】是誰？ ——★這決定「重撞同一個目標」的粒度:
   接太粗(target="-")=試過一次就對【所有】同類選項折價;
   接太細(target=具體座標)=每次都是新目標,折價永遠不累積。
③TTL 多久？ ——★★這是設計選擇,而它必須【從那件事的物理導出】,不是挑一個數字。
   ★**既有先例（R² 指出，直接抄這個做法不算發明數字）**：
     `order_system.gd:226` 的 TTL 用 `ORDER_LIFETIME`（`:4`，＝5 天）——
     ★★**衍生方式是「借【這個動作自己的到期週期】」**（買單自然到期＝重試的自然週期），
     不是另外算一個物理量。⇒ 外交／求和／乞食都該先找「這件事自己的週期」。
   ★★★**而「答不出來」的後果 spec 必須講完（R² 抓到的自我抵消）**：
     `FailureMemory.record` 的 `ttl_ticks <= 0` 會【直接放棄不記】（`failure_memory.gd:86-89`）
     ⇒ 實作者面前只有兩條路：**發明一個數字（違規）** 或 **這個 option 不接**。
     ⇒ **規則：TTL 從物理導出不出來 ⇒ 這個 option 這批【不接】，換 §3 排序的下一個候選。**
     ★**停工是允許的結果**，而「寫了『答不出來』但 code 裡還是塞了一個數」不是。
```

## §6 驗收

```
①【join 表完整】28 列全在,候選只從【待接】桶取 ⇒ ★成對對照:把一個【判準不成立】的 option
   放進候選 ⇒ 檢查必須擋下來（否則這張表沒有守住任何東西）
②【每條都有三題答案】三題有一題答「答不出來」也算過,★但空白不算
③★★★【折價真的生效】對每條新接的 option：同一 target 連撞 N 次後,
   `mult_for_option` 回的值必須【下降】,而 `failure.suppressed.<option>` 有非零計數
   ★成對對照:把 record 那行拿掉 ⇒ 該格必須紅
④【不改別人】已接的 買糧/買料 的 mult 曲線不變（★fingerprint 只在新接的 option 有決策時才該變）
⑤★★【咬不咬人】raw/eff/gate 三數（接線票必備格,`01_architect` 設計 checklist）
   ★誠實限:短窗下 eff/gate 只能回答「沒翻轉」
```

★誠實限：本票**不改** `FailureMemory` 的折價公式（`FLOOR`／`INTENSITY`／`COUNT_CAP`），
它們是 blueprint 核可的真參數。**本票只餵它，不調它。**
