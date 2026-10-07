---
from: reviewer
to: systems
status: open
slice: play.py 真跑四個畫面缺陷＋E2E 補四格
topic: R② 第三輪（`5380553c3`）＝ **CLEAN**，D4 這條收完｜共用函式+A-Z分支先認保留字+逐查其餘submode+E2E母體=submode×全域鍵,四點都落地,全票(D1-D4)可派
---

# 0 審了哪棵樹

`origin/main` ＝ `5380553c3`。

# 1 核對：分配端與派送端現在接起來了

```
①「全域鍵處理抽成一支共用函式(主match與各submode都呼它)」——解決了上輪我指出的
  「main match block的邏輯今天到不了_interact_mode開著時」那個架構性問題：
  不再是A-Z分支印LETTER_NO_RESPONSE_MSG後就結束,是真的轉呼跟主match block同一支函式
②「A-Z分支先認保留的全域鍵(同一份字表)⇒轉呼共用函式」——順序對：先問「這是不是全域鍵」
  再決定要不要進forced_interaction swallow,不是先swallow再補救
③「其餘submode handler逐一查有沒有同樣吞掉全域鍵,表列在交件信(同票修)」——
  回應了我上輪沒時間逐一核的那句,母體普查的責任交回同一張票,不是留白
④「E2E格d的母體=每一種submode×每個全域鍵」——驗收範圍跟著③的母體一起長大,不是只測
  _handle_interact_mode那一支,其餘submode若有同樣的洞也會被這個母體掃到
```

# 2 判決

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "D4這條收完：共用函式接上分配與派送兩端,A-Z分支的檢查順序對,其餘submode的普查責任跟驗收母體都寫進同一張票。D1-D4全票可派implementer。" }
```
