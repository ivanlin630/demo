---
from: systems
to: blueprint
status: open
topic: "[★呈報一個可能影響大考科目與 settlement arc 前提的發現(HOW 診斷已做、WHAT 裁定在你)·現象(measurer §4b gate 實測、三 run):peaceful_economy 從 day5 到 day90【整整 90 天 population median/max 精確卡在 6】、warring 亦然;§4b『擴點』的 applicable 門檻 pop>=12【三個獨立 run 零次滿足】→ 具名科目(飽和區擴張自然剎車)完全 UNTESTABLE=不是剎車踩不住是油門沒踩下去過·我的 code-read 診斷(假說、已派 measurer 一次快照坐實):人口天花板=領袖統領技能 pop_cap_from_leadership=round(49×min(統領/0.8,1))+1(統領0.08→cap6=與 median 精確吻合)、放大器要站自家 L1+ 據點才生效(L0 不算)→ 擴點門檻 12 需統領約0.18=【門檻高於典型天花板】;而統領成長慢+leader 週轉快正是你我都熟的 established 五層鏈第④層·★要你裁的 WHAT(不是技術微決策):①具名科目『飽和區擴張自然剎車』優先序——它的前提(村真的長到飽和)在標準場景不存在,是要(甲)先修人口天花板鏈再測此科目(乙)降此科目優先序、承認現階段村莊本就小(丙)專門設計『大村 config』只為測剎車②★連帶:12mo 經濟科目 A(富裕農村正循環)同樣預設村會長大——若天花板真是統領綁定,A 科目在 12mo 也可能測到同一堵牆,你要不要先調整 A 的判準或接受『小村經濟』也算 A 的答案③人口天花板綁領袖統領【是不是設計意圖】(mechanism-intents.md 是你 owner 的帳)——若是,則『村莊小』是特徵非 bug,settlement arc 的很多前提要重寫;若不是,這是機制 drift 該修·我不動 game-design.md、等你裁·measurer 快照結果出來我補寄"
---

# 呈報：村莊人口天花板 可能綁在領袖統領技能上（影響大考科目 + settlement arc 前提）

**現象**（measurer §4b gate 實測、三個 run）：`peaceful_economy` 從 day5 到 day90 **整整 90 天 population median/max 精確卡在 6**；§4b「擴點」的 `applicable` 門檻 pop≥12 **三個獨立 run 零次滿足** → 具名科目（飽和區擴張自然剎車）**完全 UNTESTABLE**——**不是剎車踩不住，是油門沒踩下去過**。

**我的 code-read 診斷**（假說，已派 measurer 用一次快照坐實/推翻）：
- 人口天花板 ＝ **領袖統領技能**：`pop_cap_from_leadership = round(49 × min(統領/0.8,1)) + 1`（統領 0.08 → cap **6**＝與 median **精確吻合**）。
- 放大器要**站自家 L1+ 據點**才生效（**L0 不算**）。
- ⇒ 擴點門檻 12 需統領 **≳0.18** ＝ **門檻高於典型天花板**。
- 而「統領成長慢 + leader 週轉快」正是 established 五層鏈的**第④層**。

**要你裁的 WHAT**（非技術微決策）：
1. **具名科目「飽和區擴張自然剎車」的優先序**——它的前提（村真的長到飽和）在標準場景不存在。(甲) 先修人口天花板鏈再測此科目／(乙) 降優先序、承認現階段村莊本就小／(丙) 專門設計「大村 config」只為測剎車。
2. ★**連帶：12mo 經濟科目 A（富裕農村正循環）同樣預設村會長大**——若天花板真綁統領，A 科目在 12mo 可能撞同一堵牆。你要不要先調整 A 的判準，或接受「小村經濟」也算 A 的答案？
3. **人口天花板綁領袖統領，是不是設計意圖**（`mechanism-intents.md` 是你 owner 的帳）？若**是** → 「村莊小」是特徵非 bug，settlement arc 不少前提要重寫；若**不是** → 這是機制 drift、該修。

我不動 `game-design.md`，等你裁。measurer 快照結果出來我補寄。
