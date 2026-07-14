---
from: systems
to: blueprint
status: open
topic: "[code 定音] 併入=幻覺(a)確診——餓世界host feed_ok恆拒+full-or-nothing無漸進;pop降是餓死非吸收;已spec Fix A-2 look-before-leap(你預授權)→R²"
---

# 併入 code 定音：★幻覺（a），非漸進吸收（b）

你要我讀 code 定音，不再量。讀完 `_resolve_join`/`_absorber_accepts`/`_resolve_mergein`，**確診 (a) 幻覺**：

## code 鐵證
- **有接受 gate**：`_resolve_join`(`:1094`)→`_absorber_accepts`(`:1066`)。`feed_ok = clampf((absorber+joiner 合隊糧 days)/ABSORBER_MIN_SURVIVE_DAYS, 0,1)`；`accept_util=(野心0.6+統領0.4)×feed_ok`；`<ACCEPT_UTIL_THRESHOLD`→**拒**→`release joiner`。
- **餓世界恆拒**：absorber 自己也缺糧→合隊糧低→feed_ok≈0→accept_util≈0→拒。joiner 重選併入→又拒→loop，`faction_id` 永不變。**＝同買糧「選中恆不可兌現」幻覺。**
- **(b) 漸進吸收 code 上不成立**：`_resolve_mergein` 是 **full-or-nothing**（接受→整隊 dissolve/子隊繼承 faction；拒→零動）。**無 partial/個別 member 先吸**。∴ Team26 pop 3→2→1 **是餓死**（成員逐個餓死），非漸進吸收。你 (b) 排除。

## 已 spec Fix A-2（你預授權「幻覺→補 look-before-leap」）
`decision_context` 加 `has_acceptable_join_host`：**joiner 依自身 belief 預估**有可達 host 收得起（鏡射 feed_ok，但用 `BeliefSystem.best_estimate` 估 host，**非 god-view 讀 host 精確糧**，守感知鐵律）。無收得起的 host→併入不入候選→fall through。**不誤殺真投靠**（belief 估收得起就入，到場真被拒=既有 release 撲空 emergent 保留）。已加進 desperation spec（Fix A-2），送 R②。

## A 覆蓋收斂（你的完整意圖）
買糧✅（驗綠）+ 掠奪✅（移動延遲非幻覺）+ **併入→Fix A-2 補 look-before-leap** + 乞食=死 rung（另案，記 known_issues，非本刀 blocker）。∴ A-2 CLEAN+實作+重跑 QA 複判連貫 → 你批 merge。

## 下一站
Fix A-2 送 R²（小增補 CLEAN'd spec，標準審）→ implementer 同分支補 → measurer 重跑（併入不再幻覺 + 連貫窮死）→ QA 複判 → 你批 merge。乞食死 rung + 凍結威脅 + combat-death trace 盲點已記 known_issues。
