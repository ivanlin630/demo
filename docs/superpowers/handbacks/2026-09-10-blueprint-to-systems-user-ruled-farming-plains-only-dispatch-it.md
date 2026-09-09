---
from: blueprint
to: systems
status: open
slice: 地理 fork 終審落地
topic: ★用戶裁(2026-09-10):「1做 3先認後面再調」——①農田限平原票開工(required_terrain:"plains" 照抄 stable 一行,走常鏈 spec→R²→dispatch)②「一塊地養10人」追認為設計(暫),調整鉤掛有大有小 arc;意圖帳「地理與承載力」row 已入｜★★spec 要點四格在內文,含存量農田處置=你 HOW 裁
---

# ①農田限平原票(WHAT 定案,HOW 你寫)

```
改動=FACILITY_DEF["farming"] 加 required_terrain:"plains"(outpost_system:619-620 檢查現成)。
spec 四格:
1. 成對驗收:山地/森林 civilian outpost 建 farming 必拒(紅格)+平原照建(綠格)——
   兩格都要輸出,恆真防呆。
2. 存量處置=你裁:新規則只擋新建(存量山地農田自然留存=歷史遺產)還是掃描 assert?
   我傾向只擋新建(不重寫歷史),但 HOW 歸你。
3. 漣漪預告:此改動後山地/森林聚落(pop>10)結構性缺糧——這是【要的效果】不是回歸;
   驗收判準要能分辨「礦鎮開始買糧/派 convoy」(戲,綠)與「礦鎮無聲餓死」(失敗反饋
   缺口的形狀,紅)——後者出現=接到失敗反饋 arc 不是 revert 本票。
4. 預期湧現 watch(非驗收,記讀數):山地聚落 food buy-order/convoy 需求出現=
   「值得跨越的距離」第一次真的存在——下一張市場/後勤卷應該看得到它。
```

# ②「一塊地養 10 人」追認(記帳即可)

用戶原話「先認後面再調」——ledger 已標(追認暫,調整鉤=有大有小 arc)。
兩常數(plains 8.0/日耗 0.8)不動,但從今天起它們是【被寫下來的設計】,
改任一個=改承載力上限=要回用戶,不再是隨手 tuning。
