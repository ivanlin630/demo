# HOW spec：執行失敗反饋 —— 從【逐隻接】改成【結構列舉，缺席要可見】

owner: systems ｜ 2026-09-09 ｜ player_reachable: no ｜ 序：批一③④之後第一位（blueprint 裁）

上游：blueprint 故事稽核候選② —— Team21 野心建國 → 派信使結盟**同一目標重撞 126 次**
（全庫 Envoy 6 accept / 152 reject）。他點名這是**執行失敗反饋鐵律**的合規查點。

## §1 病：機制是好的，而它【只被餵一種失敗】、也【只折價兩個選項】

```
消費端（接好了）   decision_engine.gd:231   u *= FailureMemory.mult_for_option(state, team, opt)
生產端（★產線僅一） order_system.gd:226      FailureMemory.record(..., "買單", <res>, ...)
record_invalidation ★產線【零】呼叫點（只有註解與 world_events 的說明字串）
唯一另一處產線     faction_ai_system.gd:6424 ★【被註解掉】(TODO(rebase-after-brick)，寫明「現在故意不記」)
★★而消費端【也有第二層窄門】：
failure_memory.gd:29  const OPTION_FAIL_KEY = { "買糧": ["買單","food"], "買料": ["買單","material"] }
failure_memory.gd:108 var m = OPTION_FAIL_KEY.get(option); if m == null: return 1.0
options.gd 的 option 總數 ＝ 28（survival 乞食 佔村 併入 吸納 囤貨 外交 建設 徵收 掠奪 擴點
   攻擊 歸建 求和 生產 紮根 紮營 自救建田 覓食 訓練 買料 買糧 貿易 迎戰 返家補給 遷移找糧 領取 駐守）
⇒ ★★★28 個選項裡【2 個】有失敗反饋。而缺席是【靜默】的：`return 1.0`。
```

⇒ Team21 重撞 126 次**不是異常，是預期行為**：世界裡沒有任何東西告訴它「你試過而且失敗了」。

★**這不是「結盟漏掉了」，是「26 個選項都沒接」** —— 所以修法**不能**是「把 envoy 接上去」：
單點接一個，下次換一個選項再犯（★這是「結構列舉挑引擎決定的軸」那條）。

## §2 ★★★修法形狀：讓【缺席】變成一個可以被數、會過期的東西

**不要求這一票把 28 個都接上**（那會是一張做不完的票，而做不完的票會被放著）。
要求的是：**每一個「沒有失敗反饋」都必須是【有人決定的】，不是【沒人想過的】。**

### 階段 1（本票）：把缺席變成資料

```
①`failure_memory.gd` 新增 `NO_FAILURE_FEEDBACK: Dictionary`（option → 理由字串）
   ★它與 `OPTION_FAIL_KEY` 是【互補且互斥】的兩份，合起來必須涵蓋 options.gd 的全部 28 個。
②新增 merge-gate `failure-feedback-coverage`：
   options.gd 的每一個 option ⇒ 必須出現在 `OPTION_FAIL_KEY` 或 `NO_FAILURE_FEEDBACK` 其一
   ⇒ ★兩邊都沒有 ⇒ 紅（★★新增 option 的人【當場】就要回答這題，而不是三個月後被故事稽核抓到）
   ⇒ ★★★同時 ⇒ 紅（一個選項不能既有折價又宣稱不需要）
③`mult_for_option` 的 `return 1.0` 那條路加 Probe：
   `Probe.bump("failure.unmapped." + option)`
   ⇒ ★把【靜默缺席】變成【可以數的次數】：一個選項被決策了幾次而它沒有失敗反饋。
   ⇒ ★★這格的用途不是判紅，是**排序**：先接被決策最多次的那幾個。
```

### 階段 2（後續票，靠階段 1 的數排序）

逐批把**真的該接**的選項接上生產端。★**不在本票內做**，理由：
接一個 option 的失敗反饋要回答「什麼算失敗／TTL 多久／target 是誰」三個設計問題，
而那三個問題**逐 option 不同** ⇒ 一張票塞 26 個 = 26 個沒被想清楚的決定。

## §3 ★階段 1 的判準：怎麼決定一個 option 該進哪一份

```
進 OPTION_FAIL_KEY（＝該接，階段 2 處理）的條件，三個【全都】成立：
  ①它有一個【執行步驟】會失敗（不是「效果不好」，是【做不成】）
  ②失敗當下【偵測得到】（有 return false／有 reject 事件／有 abandoned 偵測）
  ③重試【對同一個目標】而且會重複（★沒有這條就不需要記憶——一次性的失敗不會重撞）
進 NO_FAILURE_FEEDBACK（＝不需要）必須寫【理由】，而理由要是上面三條裡的【哪一條不成立】。
★★「我還沒想」不是理由 ⇒ 那種要寫成 `TODO:<票路徑>` 並且【票要真的存在】
   （★同 `.value-key-baseline.tsv` 的 born-with 過期紅：ticket 檔不存在 ⇒ 閘紅）。
```

★★★**已知的第一個答案（我先填一格當範例，不是全填）**：
`結盟`／`外交` 這條 —— envoy reject 全庫 152 次而 accept 6 次，三條全成立 ⇒ **該接**。
其餘 26 個**由這張票的執行者逐一填**，而**填的過程本身就是這張票的產出**。

## §4 驗收

```
①【涵蓋】閘對現況跑 ⇒ 28 個 option 全部歸類完畢，紅因為零。
   ★★成對對照：故意在 options.gd 加一個假 option ⇒ 閘必須紅並具名它；移除後回綠。
②【缺席可見】跑一個世界窗 ⇒ `failure.unmapped.*` 有非零計數，
   ★而且能排序（印出前 5 名 option 與次數）。
   ★★成對對照：`買糧`（已 mapped）【不得】出現在 unmapped 計數裡。
③【不改行為】本票階段 1 ★零行為改動 —— `mult_for_option` 的回傳值一個都不變
   ⇒ determinism fingerprint【不變】。★★這格是本票的安全網：
   若 fingerprint 變了,表示我們在「只加觀測」的票裡改了世界。
④【理由不是空話】`NO_FAILURE_FEEDBACK` 的每一條理由必須指名 §3 三條裡的哪一條不成立
   ⇒ 閘檢查理由字串含 `①`／`②`／`③` 或 `TODO:` 其一（★★`TODO:` 後面的票路徑必須存在）。
```

★誠實限：
1. 本票**不修任何一個選項的失敗反饋**，它只讓「誰沒接」變成可數、可排序、會過期的資料。
   ⇒ **Team21 重撞 126 次在本票之後【仍然會發生】** —— 別讓下游把本票當成那個問題的修復。
2. `failure.unmapped.*` 數的是**決策次數**不是**失敗次數**（我們還沒有後者的通道）
   ⇒ 它是**排序用的代理量**，不是「損失了多少」。
