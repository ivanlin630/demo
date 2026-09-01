---
from: implementer
to: systems
status: consumed
slice: S7-reconcile-type2
tier: probe
topic: ★型②做完(648719a5,只盤不修);★★主表 6 不一致——★★★而真正的 13 顆【全在我主表看不見的那一半】:主表只收字面值常數,而 TICKS_PER_DAY 是導出式 ⇒ 最有名的那顆錯數字我看不見它;★另立第二張表才抓到,含 invariants.md:101 憲法檔裡的 480(真值 2880);★★而我是【做完主表、對照你給的起點】才發現盲區的——若不是你在票裡先給了那顆,我會交出一份乾淨的錯報告
---

# ★①母體反過來綁（你定的設計重點）
```
側A：scripts/**（★排除 debug——床不是 production 常數）的 `const NAME: type = 數值字面值` ⇒ 603 顆
側B：docs/*.md + docs/process/*.md
     ★★specs / handbacks / verdicts / _archive 【不收】——它們是【有日期的紀錄】，
       記的是當時的事實；拿今天的 code 判它們「錯」是誤判
匹配法（★你要求標明）：【常數名 + `=`或`:` + 數字】、★★大小寫敏感
```

# ★★②主表：交集 69 行、不一致 6
```
TICKS_PER_HOUR          10  vs 60    tick_parameters.md:4 ／ estimator-ledger.md:44
FORAGE_FLOOR_DAYS       1.5 vs 5.0   known_issues.md:1015
FOOD_PER_PERSON_PER_DAY 2.4 vs 0.8   known_issues.md:1243（★該行自稱「勘誤」而它自己過時了）／:1419
CAPTIVE_INIT_MORALE     0.25 vs 0.35 progress.md:493
```
## ★判準演進（★本輪的方法論產出，記在 artifact 裡）
```
①子字串 + 大小寫不敏感 ⇒ 11 / 76 —— ★其中 5 條假陽性
   `TRUST_FLOOR=0.5`／`CRED_TIME_FLOOR=0.2` 被子字串 `FLOOR` 命中（★★第三次踩同族）
   `noise floor=0` 被【英文單字】命中（★★★短常數名與英文字撞，這是新的一種）
②＋token 邊界 ⇒ 7 / 70
③＋大小寫敏感 ⇒ 6 / 69，零假陽性
★★★而三版都跑得動、都印得出數字 —— 只有逐條看才知道前兩版是錯的。
```

# ★★★③而主表有一個【我自己的盲區】，而重災區全在那裡

```
主表只收【字面值】常數
而 TICKS_PER_DAY = TICKS_PER_HOUR * 24 是【導出式】
⇒ ★最有名的那顆錯數字（你在票裡點名的那顆），我的主表【看不見它】
```
⇒ 另立第二張表（doc 對【導出式】常數斷言值，23 條）：★**過時 13 ／ 需人判 3 ／ OK 6**
```
★★★invariants.md:101  JOIN_REJECT_COOLDOWN_TICKS=480 → 真值 2880   ← ★而那是【憲法檔】
world.md:36-39         TICKS_PER_DAY/MONTH/SEASON/YEAR 四顆全過時（240/7200/21600/86400）
tick_parameters.md     :4 TICKS_PER_DAY=240／:5 TICKS_PER_TURN=24／:30 MOVE_TICKS_PER_HEX=10
                       :142 SEASON_LENGTH=21600／:143 SALARY_INTERVAL=1680 —— ★整份都是
message.md:45          TIME_DECAY_PER_TICK=0.005 → 真值 0.000083
estimator-ledger.md:34 BASE_MOVE_TICKS=48 → 真值 240
★需人判 3：FAR_ZONE_INTERVAL=10／ORDER_LIFETIME=5／GOAL_EVAL_CADENCE=3
   —— doc 疑指【小時/天】而非 tick，那是單位不是錯值
★OK 6：BASE_ACTION_TICKS=10（★換根後仍是 10）／VISION_RADIUS=3 ×2／MOVE_TICKS_PER_HEX=240 等
```
★**真值來自【實跑 dump】不是推導**（臨時床印常數，跑完即刪）——
★★因為這一票的主題就是「文件寫的數字不可信」，那我自己算的數字也不該直接信。

## ★★★而我要講清楚我是怎麼發現這個盲區的
```
我是【做完主表之後】，拿你在票裡給的 tick_parameters.md 那顆去對照，發現它不在我的 6 條裡
⇒ ★才回頭查為什麼 ⇒ 才發現主表結構性地看不見導出式
⇒ ★★若不是你在票裡先給了那顆當起點，我會交出一份「6 個不一致」的【乾淨報告】
   而真正的 13 顆全在我看不見的那一半
⇒ ★★★所以「票裡先給一顆已知的」不只是省時間，它是【判準的校準物】
   —— 沒有它，我無法知道我的母體漏了什麼。
```

# ★④修法建議（★只盤不修，判定給你；你已先裁「不要更新成 1440」）
```
A【指 code 為準】拿掉死數字、留用途/高層模型（doc-strategy 已裁的 glance-aid 形狀）
   tick_parameters.md 整份（★它就是一張純數字表 ⇒ 整份都是這一類）
   world.md:36-39 ／ message.md:45 ／ estimator-ledger.md:34/44/122
B【真的要改】invariants.md:101
   ★★因為憲法檔的句子在講【規則】不是【參考值】，★★★規則寫錯數字會被人拿去判 code 對不對
   ⇒ 建議改成指常數名、不寫值
C【不動】progress.md ／ known_issues.md 的【歷史條目】——改它們等於改歷史
   ★★但 known_issues 的【現行待修條目】不同（如 :1015 FORAGE_FLOOR_DAYS）：
     那是活的清單，值錯了會誤導修的人 ⇒ 建議改
   ★★★而「同一個檔裡有歷史條目也有活條目」正是這一類判不動的原因，需要逐條看
```

# ⑤誠實限（三條，artifact 裡全文）
```
①匹配法抓不到「不提常數名只寫數字」的表（例：「一天 240 tick」）
   ⇒ 那要【搜數值】，而 240 是常見數字 ⇒ 大量假陽性 ⇒ 本輪未做，明標未做
②導出式 233 顆我只比了 doc 有斷言的 23 條；其餘 210 顆 doc 沒提 ⇒ 不在母體，★不是「查過沒事」
③★★★主表盲區是做完才發現的（見 §③）
```

# ⑥落地
```
docs/measurements/2026-09-01-s7-type2-doc-vs-code.txt（commit 648719a5，已 push）
★production diff = 0 行
```
