---
from: blueprint
to: systems
status: consumed
topic: "[經濟真修向·coin循環願景A+B] 用戶定A+B:讓成員成經濟agent,coin雙向流動非單向死牢。A消費(成員person.coin買個人需求→流賣方團池,市場活+個人經濟生活,貪婪囤/匱乏花=戲)+B回收(團週期稅→成員coin部分回自團池,直補no_coin,稅率掛領袖人格)。平衡意圖=稅別收乾(留成員錢消費)。這是WHAT——怎麼接(消費路徑/稅機制/plumbing)是你HOW。accessor/resolver/死常數降級併框架債backlog(非主刀)"
---

# 經濟真修向：coin 循環願景（A+B）——只給 WHAT，HOW 你定

收你私囊鎖真根定音。用戶定願景方向,我給 WHAT,**怎麼接是你 HOW（我這 arc 越界猜 HOW 被 measure 推翻四次，這封只給願景，不畫 code）**。

## 真根（你證的，我對齊）
私囊鎖 no_coin 91%：salary `team.resources.coin→person.coin` 單向抽、person.coin 只死才吐 → team 池單調枯竭 → 買方口袋空 → 市場死。

## 願景（用戶定 A+B，2026-07-15）＝WHAT
**讓成員成經濟 agent，coin 雙向流動,非單向死牢。** 兩條互補回流路,都掛人格:

**A 消費**：成員拿 person.coin 買個人需求（餓了買糧、買貨）→ coin 流向賣方團池。
- WHAT 意圖：市場活（買方真有錢）+ **個人經濟生活**（貪婪成員囤 / 匱乏成員花＝湧現戲：富員活好、窮員餓死）。
- grounded：成員本有飢餓需求 → 餓了花錢買糧＝真需求真滿足（消費從買糧起最自然，之後擴買貨/奢侈）。

**B 回收**：團週期稅/上繳 → 成員 coin 部分回自己團池。
- WHAT 意圖：team.resources.coin 不單調枯竭（直補 no_coin）。稅重稅輕由**領袖人格秤**（貪婪壓榨→成員怨、義氣輕稅→成員富）＝本身是戲。

**★為何 A+B 非單一**：單 A → 成員在別隊市場消費,coin 流賣方團池不必然回自己團,且守財成員照囤 → 自己團池仍可能乾。單 B → 成員只過路無能動性,戲薄。**A+B 兩路互補：A 給市場活+個人戲,B 保自團池回血。= 真雙向循環（成員↔團:salary下/稅上;成員→市場:消費）。**

## 平衡意圖（WHAT 級，非 HOW 細節）
- **稅別收乾**：收乾則成員無錢消費、A 死。稅是部分,成員留夠過經濟生活。
- **兩處都掛人格別 flat**：A 成員花/囤傾向掛人格（貪婪/匱乏）、B 稅率掛領袖人格（貪婪/義氣）。
- 這些是意圖,**落成什麼函式/常數你定**。

## HOW 全交你（我不越界）
- coin 循環怎麼接（成員消費決策走引擎? 稅怎麼觸發/多少? 讀哪些欄位? plumbing）＝**你 HOW**。
- 我只要結果：**team.resources.coin 不再單調枯竭 + no_coin 大降 + deals 真發生 + 成員花錢行為隨人格分化**。
- **先量再 spec 仍守**：coin 循環修 spec 前,若有「成員消費決策該走引擎 vs 掛單層」之類 HOW 抉擇你自決;若牽動願景（如「成員該不該為奢侈/地位消費」擴充範圍）再回我。

## 降級項（非經濟主刀，你 HOW 判去留）
- accessor 統一（5 讀點 `order_system:110/118/252`+`trade_valuation:87`+`decision_context:138`）、雙 resolver 收斂、掛單層死常數人格化——**真結構債但 <3% binding** → 併框架債 backlog / coin 修後順手收,**別當經濟主刀大重構**。
- threat 韌性（B 貿易願景）：真 preempt 僅 ~6 起＝非急 → coin 修好再議。
- Team6 execlock thrash（死法一 24 筆）＝churn 家族 → 併 churn-latch 結構 backlog。

## 下一站
系統 patch-gate-first + spec coin 循環修（A 消費路徑 + B 稅回收,掛人格）→ reviewer R②（新經濟機制大框,審設計對齊）→ impl → measurer 中性 full-HD（team.resources.coin 不枯竭 + no_coin 降 + deals 真發生 + 成員花錢隨人格分化）→ 我批。
**經濟真 binding＝錢不流通,先通錢。願景 A+B 鎖定,HOW 你架。**
