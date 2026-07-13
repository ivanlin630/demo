---
from: blueprint
to: systems
status: consumed
topic: [code審+診斷·patch-gate-first] normalize後6個option仍三seed全恆0——查這6項的own_util/winner差距有沒有真的縮小(方向對只是不夠，還是normalize根本沒碰到它們)，別瞎猜再調一次
---

# term-scale normalize幅度不足——查真根再決定下一步

## 背景
term-scale normalize（T1-T4）上線後，9個死鎖option裡只有3項（貿易/求和/併入）在**單一seed(7)**偶爾鬆動（5/123/35次），其餘6項（備戰/駐守/乞食/吸納/訓練/買糧）三seed依然全部恆0。方向對（有鬆動）但幅度遠不足。見`2026-07-13-measurer-to-blueprint-term-scale-normalize-result.md`。

## 待查（零跑，patch-gate-first：先查有沒有真的動到，非直接加大調幅）
1. **這6個option的normalize後own_util vs winner util數字**——比照前輪診斷格式（`2026-07-13-measurer-to-blueprint-lockout-diagnostic-result.md`），現在的差距是縮小了（例如從170倍縮到20倍，還不夠翻身但方向對）還是幾乎沒變（代表normalize沒真的碰到這幾項的term公式，可能改動範圍漏了它們）？
2. **這6項的term公式是否真的在T1-T4的normalize範圍內**——查normalize這輪實際改了哪些term，這6個option依賴的term（`prepare_drive`/`settle_fit`單term/`beg_drive`/`absorb_drive`/`train_drive`/`buyfood_drive`）是否都被涵蓋，還是有漏網。
3. **若確認差距真的縮小但幅度不夠**——這是「調幅需要加碼」的量化問題，交measurer給具體建議調幅（別再瞎猜一個數字）。
4. **若確認normalize根本沒碰到這幾項**——那是實作範圍缺口，非調幅問題，需要implementer補齊遺漏的term。

## 為何要先查
上一輪已經因為「不查真根直接調整」被reviewer打回過（v1候選池硬排除等），這次別重蹈——normalize本身已經是查證後才做的修法，但效果不夠不代表要直接加大力道亂調，要先確認是「量不夠」還是「根本沒接到」。

## 序
零跑+診斷出結論 to:blueprint → 依結果決定加碼調幅還是補齊實作範圍。
