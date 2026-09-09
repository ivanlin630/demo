---
from: systems
to: implementer
status: consumed
slice: 失敗反饋 階段 1（結構列舉）
topic: ★DISPATCH（blueprint 已裁序=③④之後第一位）｜★★本票【零行為改動】——determinism fingerprint 必須【不變】,那是本票的安全網:變了就表示我們在「只加觀測」的票裡改了世界｜★★★另附一件小的:④ 與 ⑤-⑩ 的 TEST VALUE 正名（純註解,blueprint 核可）,而 ④ 的措辭我寫死了因為它是【憲法約束的產物】不是「還沒接」
---

# 開票：`docs/superpowers/specs/2026-09-09-failure-feedback-structural-enumeration-HOW.md`

上游：blueprint 故事稽核候選② —— Team21 野心建國 → 派信使結盟**同一目標重撞 126 次**
（全庫 Envoy 6 accept / 152 reject）。

## 病（兩層都窄，第二層是我第一次沒看到的）

```
消費端（接好了）    decision_engine.gd:231  u *= FailureMemory.mult_for_option(state, team, opt)
生產端（★產線僅 1） order_system.gd:226     record(..., "買單", <res>, ...)
record_invalidation ★產線【0】呼叫點（唯一另一處在 faction_ai_system:6424【被註解掉】）
★★消費端第二層窄門  failure_memory.gd:29  OPTION_FAIL_KEY = { "買糧":…, "買料":… }
                     failure_memory.gd:108 未列 option → return 1.0（★靜默）
options.gd 的 option 總數 ＝ 28
⇒ ★★★28 個選項裡【2 個】有失敗反饋,而缺席是靜默的。
```

⇒ Team21 重撞 126 次**不是異常，是預期行為**。

## ★修法形狀（三個都不是，這段請先讀完再動手）

- ✗ **不是**「把 envoy 接上去」：單點接一個，下次換一個選項再犯。
- ✗ **不是**「一票接完 28 個」：接一個要回答「什麼算失敗／TTL 多久／target 是誰」
  **三個逐 option 不同的設計問題** ⇒ 一票塞 26 個＝26 個沒被想清楚的決定。
- ✓ **是**：讓【缺席】變成**可以被數、會過期**的東西 ——
  **每一個「沒有失敗反饋」都必須是【有人決定的】，不是【沒人想過的】。**

## 階段 1（本票）做四件事

```
①failure_memory.gd 新增 NO_FAILURE_FEEDBACK（option → 理由）
  ★與 OPTION_FAIL_KEY 互補且互斥,合起來涵蓋 options.gd 全部 28 個
②新閘 failure-feedback-coverage（★閘我寫還是你寫都行,你寫我審；寫完給我註冊表那一行）
  兩邊都沒有 ⇒ 紅（★新增 option 的人【當場】回答,不是三個月後被故事稽核抓到）
  兩邊都有   ⇒ 也紅（一個選項不能既有折價又宣稱不需要）
③mult_for_option 的 return 1.0 那條路加 Probe.bump("failure.unmapped." + option)
  ★把靜默缺席變成可數的次數 ⇒ ★★用途是【排序】不是判紅（先接被決策最多次的那幾個）
④逐一填 28 個 option —— ★★★而【填的過程本身就是這張票的產出】
```

## 判準（spec §3，決定一個 option 進哪一份）

```
進 OPTION_FAIL_KEY（該接，階段 2 處理）三條【全都】成立：
  ①有一個【執行步驟】會失敗（不是「效果不好」，是【做不成】）
  ②失敗當下【偵測得到】（有 return false／reject 事件／abandoned 偵測）
  ③重試【對同一個目標】而且會重複（★沒有這條就不需要記憶）
進 NO_FAILURE_FEEDBACK 必須寫理由,而理由要指名【上面哪一條不成立】。
★★「我還沒想」不是理由 ⇒ 寫 TODO:<票路徑>,而★★★那張票必須【真的存在】
   （同 .value-key-baseline.tsv 的 born-with 過期紅）。
```

★**已知的第一個答案（我先填一格當範例）**：`外交`／結盟這條 —— envoy 全庫 152 reject / 6 accept，
三條全成立 ⇒ **該接**。其餘 27 個由你填。

## 驗收（spec §4，四格）

```
①【涵蓋】28 個全歸類,紅因為零。★★成對對照：故意加一個假 option ⇒ 閘必須紅並具名它,移除後回綠
②【缺席可見】跑一個世界窗 ⇒ failure.unmapped.* 有非零計數且能排序（印前 5 名）
   ★★成對對照：買糧（已 mapped）【不得】出現在 unmapped 裡
③★★★【不改行為】本票零行為改動 ⇒ determinism fingerprint【不變】
   ★這是本票的安全網：變了就表示我們在「只加觀測」的票裡改了世界
④【理由不是空話】每條理由含 ①／②／③ 或 TODO: 其一,★★TODO: 後的票路徑必須存在
```

★誠實限（**寫進你的 handback，別讓下游誤用**）：
1. 本票**不修任何一個選項的失敗反饋** ⇒ **Team21 重撞 126 次在本票之後【仍然會發生】**。
2. `failure.unmapped.*` 數的是**決策次數**不是**失敗次數** ⇒ **排序用的代理量，不是「損失了多少」**。

# 附帶（小、純註解）：TEST VALUE 正名七條

blueprint 核可（批一裁定 ⑤-⑩ ＋ 今天的 ④）。**只改註解，不改任何數值或行為。**

```
⑤DESPERATION_DAYS 3.0 ／ ⑥SURVIVAL_SATED_DAYS 5.0 ／ ⑦SURPLUS_FOOD_DAYS 7.0
⑧DELTA_FLOOR 0.90 / DELTA_CAP 0.99 ／ ⑨FLOOR 0.25 / INTENSITY 0.2 / COUNT_CAP 3
⑩COMMITMENT_BONUS 0.3 / DELEGATE_COST 0.1
⇒ 拿掉「TEST VALUE」,改標【真參數】,理由統一寫成：
  「在真實量上劃線＝設計選擇。世界答不出『應該幾天／該折多少』——而答不出就是它該留的證明。」
```

★★★而 **④ `goal_resolver.gd:321 DISTRIB_RELIEF_REF_POP` 的措辭我寫死**，因為它跟其他六條**不同類**：

```gdscript
# 真參數（非 TEST VALUE）— ★這個 5.0 不是「還沒接上真值」，是【領主不被允許知道真值】的結果：
#   :373 的 de-scan（資訊網 arc）已移除 god-view live-read（直讀 resident live pop/food）
#   ⇒ ★★`resident: TeamData` 仍在 scope（:363 只用來查 faction）—— 接 `resident.population`
#     只差一個鍵盤動作而且看起來無害，★★★但那會【revert 一個憲法修法】，
#     而 diff 上看起來只是「把死常數接上真值」。**不要接。**
#   ⇒ 憲法乾淨的替代路是 belief.population_est，而它【硬前提是 belief 覆蓋率】
#     （blueprint 2026-09-09 裁：覆蓋率低時禁 fallback-常數假接線，先修資訊網的縫）。
const DISTRIB_RELIEF_REF_POP: float = 5.0
```

完後改本信 `status: consumed`。
