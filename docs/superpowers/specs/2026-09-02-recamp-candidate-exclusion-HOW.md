---
status: DRAFT(待 R²)
owner: systems
slice: recamp-candidate-exclusion
what: blueprint 定性 2026-09-02 —— ★B 級置頂行為病：它結構性堵死【L0 臨時／L1 紮根】那道階梯（用戶的分層設計）
premise: ★R① CLEAN（premise_contradiction: false，2026-09-02）—— 三條前提查完，方向成立、細節已訂正
---

# ★①病（★而它的落點不是我原本想的地方）
```
現象：★【站在自己 L0 營地上，「再紮一次營」贏過「把它升成 L1」】—— `settlement_s2b_test` 紅了 12 天
★我原本以為：估值權重不對／或 de-patch 拿掉了門檻
★★R① 訂正：
   ①後果集確實 ≈ 空（`establish_crude_camp` guard 擋，`faction_ai_system.gd:5538-5541`）
     ⇒ ★★★但【重點不在執行端】—— 是【候選根本不該被生出來】
   ②util 估值【根本沒讀】那格已有自己的營地（★不是權重問題）
   ③`bdad0174` 拿掉的是【無關的絕境門檻】⇒ ★★與這個洞完全無關
     ⇒ ★★★所以「它在那天變紅」是【時間相關性，不是成因】
```
★**而修法不算「回加門檻」**（blueprint 的硬約束因此不衝突）—— **它是補上候選產生端的一個排除條件。**

# ★★②唯一修點（R① 已定位）
```
★`_find_unowned_farmable_tile()` 的 fallback 排除條件【沒有排除 `camp_level > 0`】
★★而 `establish_crude_camp` 自己的註解明寫：L0 營地【不設 outpost_level、不 set_owner】（`:5534`）
   ⇒ ★★★所以「用 outpost_owner 判有沒有主」對 L0 營地【天生無效】—— 而排除條件正是這樣判的
★同源兩處：`decision_context.gd:397` ／ `options.gd:203` —— ★兩個呼叫點共用同一個上游
   ⇒ ★★修一行，兩處同時好
```
## ★★★而這裡有一個命名說謊：**函式叫 `_find_unowned_farmable_tile`，而它會回傳自己擁有的格**
★**不在本票修名**（★★避免一票兩事），★★★**但要在該函式加一行註解寫明這個落差** ——
**否則下一個人會照名字信它。**

# ★★★③驗收
```
①★`settlement_s2b_test` 轉綠 —— ★★而【不得放寬該床的斷言】（★★★那會把警報器關掉）
②★行為：站在自己 L0 營地上時，「再紮營」★不再出現在候選集裡（★逐 option dump 可驗）
③★★而「升成 L1」要真的贏 —— ★★★若排除了再紮營之後【還是不升級】，那是【第二個病】，停下來報我
   （★不要為了讓床綠而動別的東西）
④★fp 會變（intended-change）—— 變了不是失敗，但要標注
⑤★★同源兩處都要驗（`decision_context:397` ／ `options:203`），★★★不要只驗一處就報「兩處都好」
```

# ★④不做
```
★不回加絕境門檻（blueprint 硬約束；★而 R① 已證那條門檻與本洞無關）
★★不在本票改函式名（★★★但要加註解寫明「它會回傳自己擁有的格」）
★不順手改 `establish_crude_camp` 的 guard —— ★★它是對的，而病不在那裡
```
