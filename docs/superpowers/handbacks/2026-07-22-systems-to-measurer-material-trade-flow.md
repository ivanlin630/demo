---
from: systems
to: measurer
status: consumed
topic: "[工單·material/tools 貿易流 measure·Gate B trade-primary 決定性·帶§④b樣本+specimen(新規則長跑→QA)] blueprint裁②純貿易為主:軍事隊帶coin買material/tools(非faction內部teleport)。★需你measure定『material/tools貿易流通不通』(main,economy keys bed):①mil隊(military archetype/持weaponsmith buy-order)取得material/tools成效——post_buy material/tools計數 vs 實際buy成交(deal on material/tools)②bail組成(mil買material/tools失敗因:no_stock市場無貨/buy_no_coin無錢/沒到市場/no_want)③供給側:civ隊有無賣material(post_sell material計數+市場material stock=public_storage material量)——material全域3587在誰手④★specimen(SpecimenDumpHelper,seed1337+42):一mil隊要建weaponsmith缺material全程——有無去買material/買到沒/為何沒(coin?到不了?市場無貨?)。判讀:市場有material stock+mil有coin但沒買到→撮合/routing;市場無material stock→civ不賣(reserve?)/供給鏈;mil無coin→coin流通。★★這是長跑→必附specimen送QA(新hook規則),別只aggregate。回blueprint+QA+cc systems(★verdict務必cc systems,blueprint認可補洞)。定trade blocker才spec Gate B trade fix。"
---

# 工單：material/tools 貿易流 measure（Gate B trade-primary 決定性）

blueprint 裁 ② 純貿易為主：軍事隊**帶 coin 買** material/tools（非 faction 內部 teleport）。fix 前需你 measure 定「material/tools 貿易流通不通」（main，economy keys bed）：

## 請你 measure
1. **mil 隊取得 material/tools 成效**：`post_buy material/tools` vs 實際 buy 成交（deal on material/tools）。
2. **bail 組成**（mil 買 material/tools 失敗因）：`no_stock`（市場無貨）/ `buy_no_coin`（無錢）/ 沒到市場 / `no_want`。
3. **供給側**：civ 隊有無**賣 material**（`post_sell material` + 市場 material stock=`public_storage` material 量）——material 全域 3587 在誰手、有無上市。
4. **★specimen**（`SpecimenDumpHelper`，seed1337+42）：一 mil 隊要建 weaponsmith **缺 material 全程**——有無去買 material / 買到沒 / 為何沒（coin? 到不了? 市場無貨?）。

## 判讀
- 市場**有** material stock + mil **有** coin 但沒買到 → 撮合/routing。
- 市場**無** material stock → civ 不賣（reserve?）/ 供給鏈。
- mil **無** coin → coin 流通。

## ★★長跑→必附 specimen 送 QA（新 hook 規則）
別只 aggregate（QA 讀不動）。回 blueprint + **QA** + **cc systems**（★verdict 務必 cc systems，blueprint 認可補 out-of-loop 洞）。定 trade blocker 才 spec Gate B trade fix。
