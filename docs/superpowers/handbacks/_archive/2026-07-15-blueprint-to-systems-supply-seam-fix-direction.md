---
from: blueprint
to: systems
status: consumed
topic: [願景+確認] 供給真根=storage accessor seam(manufacture→public_storage,非糧賣單讀team.resources=0);修=非糧賣accessor對齊public_storage(同food WS-2c已修);先修seam啟動經濟→觀察revived市場→再建發展模型;統一accessor別再漏
---

# 供給 seam 修：確認 + 願景方向

你 patch-gate-first 挖到真根:**非糧賣單讀 `team.resources`（=0）,但 manufacture 產出進 `public_storage` → 產了的貨賣單看不到 → 永不掛賣單 → 市場無貨**。同 WS-2c food accessor seam 家族,food 已修、非糧漏修。**這是 seam bug 非缺子系統——生產和賣行為都在,只是讀不同 storage。** 好消息。

## 願景方向（你問的「回你定願景」）

**這修的願景很小——就是把 seam 接對,不是大設計。** 但它是**整個經濟/發展 arc 的 enabler**:

1. **先修 seam（現在）**：非糧賣 accessor 對齊 `public_storage`（鏡射 food 已修的 WS-2c）→ 產的貨進得了市場 → 供給有貨 → 市場能撮合。**de-patch/seam 對齊,非新機制。**
2. **★統一 accessor（別再漏）**：food 修了非糧漏＝**同 seam 修一半**。這次**把 storage accessor 統一**（所有資源賣單走同一個「讀可賣庫存」accessor,不管 food/非糧），別留下第三種資源又漏。**用統一框架式**——一個 accessor 家族,不是逐資源各寫。
3. **修後觀察 revived 經濟**：seam 修好→市場活→coin 流→私囊鎖不鎖還成不成問題?供給夠不夠?**先看經濟活過來長什麼樣,再定發展模型細節**（先有結果紀律——別紙上猜 revived 經濟）。
4. **然後建發展模型**（統一維度 registry,經濟/軍事/建設）——**在活的經濟上建**,非死的。

## ∴ 經濟/發展 arc 的形狀（定了）
```
第一刀:供給 seam 修(非糧賣 accessor 對齊 + 統一 accessor 家族) ← 現在,你 spec
  → 觀察 revived 經濟(市場活?coin流?私囊鎖還是問題?)
  → 發展模型統一框架化(經濟維在活經濟上建)
```

## 我的教訓收尾
coin 這串我假設錯 5 次（枯竭→鎖公庫→月3凍結→市場壞→怕沒生產）。**真根是一個 accessor seam,你 patch-gate-first 挖對。分工再次證明:我 WHAT+粗猜常錯,你挖 code 根準。用戶持續戳把假設扒到底。**

## 下一站
系統 spec 供給 seam 修（非糧賣 accessor 對齊 public_storage + 統一 accessor 家族防再漏）→ R²（seam 修,標準審）→ impl → 中性 full-HD 重跑（order_fulfilled 從 ~0 回升?市場活?coin 流動?）→ QA/measurer 驗 → 我批。
→ 修後觀察 revived 經濟 → 我+用戶定發展模型細節。
