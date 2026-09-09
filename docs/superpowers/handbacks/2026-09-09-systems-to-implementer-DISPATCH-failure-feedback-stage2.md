---
from: systems
to: implementer
status: open
slice: 失敗反饋 階段 2（第一批 3 條）
topic: ★DISPATCH（R² CLEAN）｜★★第一批＝外交／求和／乞食——【建設被移出】,R² 查實它是跨 branch 硬阻斷(current_dispatch_* 是磚 branch 的欄位),而『自救建田』走同一條依賴也不能當替補｜★★★TTL 答不出來的後果 spec 已寫死:【這個 option 這批不接,換下一個候選】——停工是允許的結果,「寫了答不出來但 code 裡塞了一個數」不是
---

# 開票：`docs/superpowers/specs/2026-09-09-failure-feedback-stage2-ordering-HOW.md`

階段 1 已 DONE（`d554ed39`）。R² 判過一輪，兩處補完，**不用再送 R²**。

# ① ★第一件事：join 表，不要直接用 unmapped 排序

```
階段 1 的 unmapped 前 5：建設 483／迎戰 434／求和 428／紮營 349／survival 299
★而 迎戰/survival＝判準不成立、紮營＝已有等價機制
⇒ ★★`failure.unmapped` 數的是「沒走 OPTION_FAIL_KEY 這條路」,不是「沒有任何失敗反饋」
⇒ ★★★照這份名單由上而下接,第 2/4/5 名都會接到【不該接的東西】。
```
R² 確認這不是我多慮：`mult_for_option` 對**所有**不在 `OPTION_FAIL_KEY` 的 option
**一視同仁** bump ⇒ **這個計數器的設計就決定了它不能單獨排序用**。

⇒ **產出一張 join 過的表（28 列全印，不是只印候選）**：
`option ｜ 桶 ｜ unmapped 次數 ｜ 已存在的失敗訊號(file:line)`
★整份印出來的理由：**讓下一個人看得到「為什麼那幾個不在候選裡」**。

# ② 第一批三條

| option | 已存在的失敗訊號 | target | 備註 |
|---|---|---|---|
| **外交**（結盟） | `envoy.reject`（`faction_ai_system:582`）、全庫 152 reject / 6 accept | 對象勢力 | |
| **求和** | diplomatic reject 路徑 | 對象勢力 | |
| **乞食** | `rejected_aid`（`interaction_system:1493`） | **被乞求的那一隊** | 單一事件、單一對象，無歸屬歧義 |

## ★★「建設」被移出第一批 —— R² 查實是硬阻斷

```
faction_ai_system.gd:6383   ⛔ current_dispatch_id / current_dispatch_target 是【磚 branch 的欄位】,本 branch 沒有
              :6386-6387    # TODO(rebase-after-brick): team.commit_stall_id = ...   ←整段註解
team_data.gd:272-273        commit_stall_id / commit_stall_target 欄位【存在】但【永遠沒被賦值】
```
⇒ ★**不是「查完可能還好」，是跨 branch 依賴沒到位 ⇒ 查完必定卡住。**
⇒ ★★**`自救建田` 也不能當替補**：`failure_memory.gd:54` 的理由寫著
「同『建設』，走同一條 `construction_abandoned`」⇒ **同一組依賴、同一個阻斷**。

## ★★★第三條為什麼是「乞食」——我把限制寫出來，沒有假裝排過

```
§3 排序鍵②(unmapped 次數) 我【無法套用】：階段 1 只回報前 5 名,
   完整 20 種計數【沒有落地成檔案】,而那份回報的來源卷面已被覆寫。
⇒ 改用排序鍵③(訊號具體度,有 file:line 可查、不需重跑)：
   明確 reject 事件 ＞ abandoned 偵測 ＞ 靜默 return false
   `併入`/`吸納` 共用 `join_rejected` ⇒ ★會多出「這筆失敗算誰的」的歸屬問題,
     而第一批不該同時處理【接線】與【歸屬歧義】⇒ 選 `乞食`。
⇒ ★★★而你印出來的 join 表若顯示真實計數與這個選擇矛盾,【那必須看得見】——
   矛盾的話回報我,不要自己改順序。
```

# ③ 每條必答三題（§5，逐條寫進 handback）

```
①什麼算【失敗】？ ★必須是【做不成】不是【效果不好】
②【target】是誰？ ★接太粗(target="-")=試過一次就對所有同類選項折價;
                  接太細(具體座標)=每次都是新目標,折價永遠不累積
③TTL 多久？
```

## ★★★TTL：既有先例可以直接抄，而「答不出來」的後果已寫死

```
先例（R² 指出）：order_system.gd:226 的 TTL 用 ORDER_LIFETIME（:4，＝5 天）
  ★衍生方式＝借【這個動作自己的到期週期】(買單自然到期＝重試的自然週期)
  ⇒ ★★抄這個做法【不算發明數字】。外交/求和/乞食都先找「這件事自己的週期」。
★★★答不出來的後果（R² 抓到我原本的自我抵消）：
  FailureMemory.record 對 ttl_ticks <= 0 【直接放棄不記】(failure_memory.gd:86-89)
  ⇒ 只有兩條路:發明數字(違規) 或 這個 option 不接
  ⇒ 【規則】TTL 導不出來 ⇒ 這個 option 這批【不接】,換 §3 排序的下一個候選。
  ★停工是允許的結果;「寫了答不出來但 code 裡還是塞了一個數」不是。
```

# ④ 驗收（§6 五格）

```
①join 表 28 列全在,候選只從【待接】桶取
  ★成對對照:把一個【判準不成立】的 option 放進候選 ⇒ 檢查必須擋下來
②每條都有三題答案（答「答不出來」也算過,★空白不算）
③★★★折價真的生效:同一 target 連撞 N 次後 mult_for_option 回的值【下降】,
  且 failure.suppressed.<option> 有非零計數（★R² 確認這個 key 存在:failure_memory.gd:132）
  ★成對對照:把 record 那行拿掉 ⇒ 該格必須紅
④已接的 買糧/買料 mult 曲線不變
⑤★★咬不咬人:raw/eff/gate 三數（接線票必備格）
  ★誠實限:短窗下 eff/gate 只能回答「沒翻轉」,不能回答「不咬人」
```

★誠實限：本票**不改** `FailureMemory` 的折價公式（`FLOOR`／`INTENSITY`／`COUNT_CAP`）——
它們是 blueprint 核可的真參數。**本票只餵它，不調它。**

完後改本信 `status: consumed`。
