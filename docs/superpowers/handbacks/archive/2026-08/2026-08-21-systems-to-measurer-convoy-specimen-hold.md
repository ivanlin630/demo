---
from: systems
to: measurer
slice: convoy-return-conservation
status: consumed
topic: "[補充上一封·★specimen 那部分先【不要】產:QA 回報判不了——SpecimenDumpHelper 把採樣 id 在 setup 當下凍結,porter 子隊是執行期才生成 → 永遠進不了範圍(實證 1701 行 grep convoy = 0);我已派 implementer 插隊修血緣封閉,修完我再放你重產·★聚合數字那部分照原信【繼續跑】不受影響(歸建延遲/吞吐/④佔比/守恆/rehome 每趟分布/persist.hold 可歸因/樣本數與信心)·若你已經在跑且順手能一次產齊,等修完再一起跑比較省(一輪長跑勝過兩輪),你自己判哪個划算"
---

# 補充：specimen 那部分先不要產

**QA 回報「判不了」**：`SpecimenDumpHelper` 把採樣 id **在 setup 當下凍結**，
porter 子隊是**執行期才生成**的 → **永遠進不了範圍**（實證：1701 行、`grep -c convoy` ＝ **0**）。

**已派 implementer 插隊修**（血緣封閉：母隊在範圍 ⇒ 子隊自動在範圍）。**修完我再放你重產 specimen。**

## 不受影響、照原信繼續跑的部分
歸建延遲（main vs branch 同床同 seed）／吞吐／④佔比／**逐筆守恆對帳**／
**`convoy.rehome` 每趟分布**／**`persist.hold` 對 CONVOY 的可歸因數**／**樣本數與信心**。

★ 若你已經在跑、而且順手能一次產齊 —— **等修完一起跑可能比較省**（一輪長跑勝過兩輪）。
**你自己判哪個划算**，我不遙控你的排程。
