---
from: systems
to: reviewer
status: consumed
slice: storage-fits-own-next-step
tier: behavior
topic: R②請審:把 blueprint 的結構約束 pin 成 test(每級倉容 ≥ 該級升級全費含緩衝);★civilian 兩級都 FAIL(200<225、500<600)、★★military L1 剛好相等(300==300)而我【刻意不墊高】;★三問在末段,尤其「assert 要對三邊敏感」的陽性對照怎麼做才不是自我證明
---

# 送審：`docs/superpowers/specs/2026-08-26-storage-fits-own-next-step-HOW.md`

## ★背景
blueprint 裁：**「每級據點的儲量上限 ≥ 該級自身的升級全費（含緩衝）」＝結構約束**，
★**pin 關係不 pin 數字，禁把 200 拍成 230 完事。** 具體數字歸我。

```
civilian L1→L2  cap 200 vs need 225   ★FAIL
civilian L2→L3  cap 500 vs need 600   ★FAIL
military L1→L2  cap 300 vs need 300   ⚠️剛好相等
military L2→L3  cap 800 vs need 750   OK
```

## ★★三件要你審的
1. ★★★**「assert 要對三邊（cap／cost／margin）都敏感」這個驗收，怎麼做才不是自我證明？**
   ★**我寫的是「各動一次、三次都要紅」的陽性對照** —— **但那三次是 implementer 自己動、自己看紅。**
   ★★**你上一票教我的形狀（對照 A：拿掉註解仍 PASS ⇒ 證明是機制在扛）能不能套？**
   **我想要的是「證明 assert 讀的是【關係】而不是碰巧寫死了 225」，而我不確定我寫的對照夠不夠強。**
2. ★**動 cap 不動 cost，我的理由是「爆炸半徑」**（`OUTPOST_COST` 被 founding／facility／afford 多處讀，倉容只被「裝得下多少」讀）。
   ★★**請驗這個負斷言**：`OUTPOST_STORAGE_CAP`／`TileBank.cap` 的讀者是不是真的只有儲存路徑。
   ★★★**如果它還被別的決策讀（例如某個「夠不夠大」的判斷），我這條理由就垮，數字該動的是另一邊。**
3. ★**military L1 `cap 300 == 全費 300`（0 餘裕）我【刻意不墊高】** ——
   理由：blueprint 的關係式是 `≥`，**墊高是我自己加的平衡判斷，要另外過 WHAT**。
   ★★**你認為「照原樣留著＋記在 spec 裡」夠不夠，還是這種 0 餘裕本身就該當成不成立？**

## ★我已經先寫死的
- ★**誠實限**：本票只修「倉庫裝不下」，**不修「存不住」**（設施照樣會花掉）⇒ **驗收 `upgd.dispatched` 照原樣回報、不預測**。
  ★★**「為了更貴的目標而現在不花」blueprint 已裁定歸長程計劃脊椎的【湊足磚】，不在本票打補丁。**
- ★**回歸防線**：behavior 改、`fp` 兩床都會變 ⇒ **守恆帳，不是逐位元。**

★**CLEAN 才 dispatch。implementer 現在在跑「設施 vs 升級是不是同一把秤」那張量測票。**
