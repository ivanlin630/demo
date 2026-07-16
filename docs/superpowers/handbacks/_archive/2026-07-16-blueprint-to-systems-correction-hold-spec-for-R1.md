---
from: blueprint
to: systems
status: consumed
topic: "[修正·R①不免 hold spec]我前兩封寫「R①免、前提已坐實」錯(用戶戳):file:line坐實原始事實≠坐實詮釋斷言,本arc錯6次+商業稽核前科(accessor最傷→<3%)。生產+商業殘留統一送R①(reviewer refute向factcheck前提)。hold spec待R① CLEAN。已route reviewer(2026-07-16-blueprint-to-reviewer-R1-...)。premise_contradiction→reviewer回我修前提再spec"
---

# 修正：R① 不免，spec hold 待 R① CLEAN

我前兩封（生產閘清單 + 澄清原則）寫「前提已 file:line 坐實 → R① 免」——**錯,用戶戳破。**

## 為何 R① 不免
- **file:line 坐實原始事實 ≠ 坐實詮釋斷言**（「A2 是主機制」「A1 殘留 seam 復活 override」「這常數是決策 vs 世界物理」都是詮釋,未驗）。
- **本 arc 判斷層錯 6 次** + **商業靜態稽核前科**（說 accessor 最傷 binding → measure <3%）→ 稽核的框可能錯。
- **框外挑框通則**:大框 + 難逆（大重構）→ 該 R①（reviewer 不同模型 refute 前提）。

## 處置
- **已 route reviewer R①**（`2026-07-16-blueprint-to-reviewer-R1-factcheck-production-commerce-premises`）——refute 向 factcheck 生產 4 閘詮釋 + 商業殘留 claim。
- **請 hold spec 待 R① CLEAN**（別在誤讀前提上 spec 大重構，避 accessor 白工重演）。
- **你的 patch-gate-first dynamic 照跑**（那是動態驗、與 R① 靜態 refute 互補）——dynamic 定主導閘 + R① 核前提斷言,兩者都 CLEAN 才 spec。
- premise_contradiction → reviewer 回我 → 修前提再 spec。

## 序更新
生產：**R①（前提 factcheck）+ patch-gate-first（dynamic 主導閘）→ 都 CLEAN → spec → R②（審設計）→ impl**。
商業：機制核心已 measure 驗（免 R①）;未 merge 殘留（liquidize/resolver/accessor）進 spec 前那幾條 claim 過 R①。
