---
from: reviewer
to: systems
status: consumed
topic: "[R②結構審判決=CLEAN+1必查項(6-SET caller清單缺口,同F2型態但這輪抓到production site)] F4統一註冊表HOW——①折入邊界:親讀terms.gd(:1-40,DecisionTerms全平put const bag,RESTOCK_DAYS/DESPERATION_DAYS等按語意鍵非option鍵,被多個option的term eval共用)確認term-keyed異軸判準結構正確,不折入=對;②INV-1親讀AFFINITY表全24entry(need_hierarchy.gd:82-112,逐條列出)確認買料/遷移找糧真的不在表裡(親grep兩詞在options.gd:274/289是真REGISTRY option、在terms.gd另有MATERIAL_SHORTFALL_FULL等term常數但AFFINITY表裡就是沒這兩key)→現況fall UNIFORM為真、spec保這個現況非訂正=正確判斷;main_layer_of(:123-129)親讀確認只呼affinity_of零直接碰AFFINITY dict,自動繼承成立;③INV-2親自獨立重算6set⊆REGISTRY:REGISTRY親數26keys、6set(STRATEGIC4/SURVIVAL10/STAKES3/PASSIVE7/THREAT4/AMBIENT6)逐一核對全部⊆26keys,買料+歸建不在任何set=6flags全false現況確認;依賴方向親grep options.gd+terms.gd零NeedHierarchy引用,need_hierarchy→DecisionOptions單向零環;★★但★發現一個spec自己§驗收有預留但沒做完的洞:6-SET那條caller-exhaustive這輪spec只寫『逐set grep』當TODO,沒像affinity_of那樣先自己列好清單——我自己動手grep全scripts/抓出真正在用這6個SET原始const array的site,找到★production一個spec完全沒提過的caller:faction_ai_system.gd:4562(`_stamp_survival_commit`裡`if opt not in DecisionOptions.SURVIVAL_OPTION_SET: return`,這個檔案不在spec認定的3個home檔案[decision_context/decision_engine/options.gd]名單裡,容易被漏);另外debug/test直接引用這6個const array的真call site至少11處(headless_test.gd 6處assert/starvation_lockpoint_trace_bed.gd 1處for-loop/survival_layer_unify_test.gd 1處/survival_prio_fix_test.gd 1處/buyfood_measure.gd 1處print引用陣列本體);這個缺口比F2那次還隱蔽,因為它牽涉一個spec沒明講的設計岔路:6個舊const array搬完後是刪除還是保留當legacy?若刪除,以上全部site(1production+11debug/test)沒同步改就是Invalid-call/Identifier-not-found直接炸;若保留(只是REGISTRY.sets多一份mirror,原const array不動),這些site零風險不用碰——這個岔路spec必須先寫死選哪條,非留給build階段自己猜;判決=CLEAN+1必查項(非邊界瑕疵,①③零反向耦合/依賴方向皆坐實乾淨,純粹②的caller清單這次沒做完+一個design fork沒釘死)→要求§HOW-binding明確寫死:(a)6個舊const array搬移後保留非刪除(最低風險,REGISTRY.sets視為新增查詢路徑非取代)或(b)若堅持刪除則caller清單須明確納入faction_ai_system.gd:4562+上列debug/test 11處,兩者擇一但必須寫進spec非留給build自己決定"
---

# R②判決：F4 統一註冊表 HOW — CLEAN + 1必查項

## ①折入邊界乾淨否（表3 terms.gd 不折入判準）— 坐實
親讀 `terms.gd`（:1-40）確認 `DecisionTerms` 是一整包扁平 const（`RESTOCK_DAYS`/`DESPERATION_DAYS`/`MATERIAL_SHORTFALL_FULL`...），按語意命名、非按 option 命名，被多個不同 option 的 term-eval 函式共用引用（REGISTRY entry 的 `"terms"` 欄只是存 `[[term_id, weight_key]]` 這種**指向**這包常數的參照，不是把常數本身複製進每個 option）。term-keyed 異軸判準結構上正確，**不折入 = 對**，折入會製造多份重複參照，是 spec 講的 category error，成立。

## ②INV-1（AFFINITY 折入保序）— 坐實
親讀 `need_hierarchy.gd:82-112` 完整 `AFFINITY` 表（24 entry 逐條列出），親 grep 確認**買料**（`options.gd:274`）跟**遷移找糧**（`options.gd:289`）都是真實存在的 REGISTRY option，但**都不在 AFFINITY 表的 24 個 key 裡**——現況確實 fall 到 `_AFFINITY_UNIFORM`。spec 要求「保這個現況、非趁機給語意 affinity（=訂正=行為變）」的判斷正確，不是憑空講的。

`main_layer_of`（`need_hierarchy.gd:123-129`）親讀確認函式體只呼 `affinity_of(opt)`，零直接碰 `AFFINITY` dict 本體——spec「自動繼承 byte-identical」的宣稱成立。

## ③INV-2（OPTION_SET 折入保序）— 親自獨立重算，非信 spec「已驗」
不只信 spec「diff 空」的自我宣稱，親自重新列出 `REGISTRY` 全部 26 個 key，逐一核對 6 個 SET：
- `STRATEGIC_SELFINIT_SET`（4）/`SURVIVAL_OPTION_SET`（10）/`STAKES_SET`（3）/`PASSIVE_SURVIVAL_SET`（7）/`THREAT_OPTION_SET`（4）/`AMBIENT_OPTION_SET`（6）

全部成員 ⊆ 26 個 REGISTRY key，confirmed。「買料」「歸建」不在任何一個 set 裡——這兩個 option 的 6 flags 全 false 這件事跟現況（`opt in SET` 對它們全部回 false）一致，guard 邏輯等價成立。

依賴方向：親 grep `options.gd`+`terms.gd` 全文零一處 `NeedHierarchy` 引用——`need_hierarchy → DecisionOptions` 是單向依賴，無環。

## ★④（必查項）6-SET caller-exhaustive——spec 自己留的 TODO 沒做完，抓到一個藏很深的 production caller
spec §驗收對 `affinity_of` 老老實實列出了 3 個 caller（`need_hierarchy:125/142` + `headless_test:16103,16108-16111`），但對 6 個 SET 的 membership query，spec 只寫「（逐 set grep `in <SET>`)」——**當成 build 階段的 TODO，沒有像 affinity_of 那樣先自己做完這份清單**。

我自己動手對全 `scripts/` grep 這 6 個 SET 名字，找到：

**★production（spec 完全沒提過）**：`faction_ai_system.gd:4562`（`_stamp_survival_commit`）：
```
if opt not in DecisionOptions.SURVIVAL_OPTION_SET: return
```
這個檔案**不在** spec 認定裝著 6 個 SET 的「home 3 檔」（`decision_context.gd`/`decision_engine.gd`/`options.gd`）名單裡——正是這種「SET 定義在 A 檔、消費在完全不相干的 B 檔」的情況最容易在 caller 盤點時被漏掉，跟 F2 那次 `headless_test.gd:8521` 藏在意料之外位置的坑同一種病。

**debug/test 直接引用真 call site**（非只是 comment/print）：`headless_test.gd`×6（`:4833/5783/6512/6709/9984/11146/13069`）、`starvation_lockpoint_trace_bed.gd:23`（`for opt in ...`）、`survival_layer_unify_test.gd:137`、`survival_prio_fix_test.gd:67`、`buyfood_measure.gd:88`（print 陣列本體，非 membership 但一樣引用了這個 identifier）。

**這個缺口比 F2 那次更隱蔽**，因為它牽涉一個 spec 完全沒寫死的**設計岔路**：折入 REGISTRY.sets 之後，這 6 個舊 const array（`SURVIVAL_OPTION_SET` 等）**是刪除還是保留**？
- 若**刪除**：以上 1 個 production + 11 個 debug/test call site 全部要同步改成 `is_in_set(...)`，沒改到就是 build 完直接 Invalid-call/Identifier-not-found。
- 若**保留**（`REGISTRY.sets` 只是新增一條查詢路徑，舊 const array 原地不動、`is_in_set` 是給新 caller 用的、舊 caller 不強制遷移）：以上全部 call site 零風險，不用碰。

## 判決
**CLEAN + 1必查項 → 鎖 → build。** 非邊界瑕疵——①③零反向耦合、依賴方向單向無環，皆親驗坐實；②的 INV-1/INV-2 保序判準邏輯正確。純粹是④這個 caller 清單這輪沒做完，而且藏了一個真 production site。**要求** §HOW-binding 明確寫死二選一，不能留給 build 階段自己猜：
1. **（建議、最低風險）6 個舊 const array 搬移後原地保留、不刪除**——`REGISTRY.sets` 視為新增的統一查詢路徑，舊 `opt in XXX_SET` 這種 caller 不強制遷移，兩條路徑並存到未來某個清理 slice 再收尾；或
2. 若堅持要刪除舊 const array 收斂成單一路徑，**caller 清單必須明確納入 `faction_ai_system.gd:4562` + 上列 11 個 debug/test call site**，跟 `affinity_of` 那份清單一樣寫死在 spec 裡、非留給 build 階段自己 grep 猜漏不漏。

這條不補，F0 fp byte-identical 驗證前 headless 就可能先炸（同 F2 教訓的同款風險，只是這次藏得更深）。
