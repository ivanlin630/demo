---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN] SLICE B分配政策HOW——4元件seam親驗皆合理，HONOR_WEIGHT util公式不重蹈economy-headroom那輪「payoff結構性到不了cap」的無效lever(此次乘數真能推過1.5)，WEIGH非GATE/感知鐵律/約束1(同convoy脊椎)/tap覆蓋皆核到位，剝削A/B fork不影響seam本體CLEAN"
---

# R②判決：SLICE B 分配政策 HOW — CLEAN

窄範圍新增(deficit偵測+distribute候選+DELIVER新終點分支+unrest耦合)，複用已深度驗證過的既有機制(convoy FETCH/RETURN、deliver_cargo bypass-reserve、GOAL_UTIL_CAP家族、unrest sink)，我直接自驗。

## ①-④ seam逐項核對

**deficit偵測**：`runway=(team_food+local_granary)/(pop×burn)`——複用`resource_system:126`既有算式的claim合理，跟我之前審查過的`food_flow.gd`runway概念同構，非發明新公式。

**★`_distribute_candidates` util公式——沒有重蹈上兩輪economy headroom那次「無效lever」的坑**：親算`HONOR_WEIGHT=base×(0.3+honor)/(0.3+greed)`，honor/greed∈[0,1]獨立值——比值範圍約0.23(貪婪極高義氣極低)到4.33(義氣極高貪婪極低)。**這跟goal_registry的payoff(結構性封頂1.5,乘上≤1的三個乘數後cap形同虛設)不同**——這個乘數真的能把util的pre-clamp值推到遠超1.5，代表義氣夠高的領主，distribute候選真的可能在GOAL_UTIL_CAP生效前就贏過同樣受這個cap管轄的deliver-candidate(deliver-candidate因為payoff結構性≤1.5，pre-clamp頂多打平distribute的下限區)——**這次的util公式設計是有效的，不是又一次斷言**。§3 dev-verify要求的「persona分岔→decision翻轉」正是驗證這一點，紀律到位。

**DELIVER終點擴充**：`_resolve_market_at_outpost`加`kind=="distribute"`分支，直注food入resident pool、跳過market_order/支付/reserve整套邏輯——親讀過的`interaction_system.gd:807-829`(`_market_visitor_sell`)是完全另一條路徑，這個新分支不會誤觸市場結算邏輯，是乾淨的新終點分岔非硬塞進舊函式。守恆：capital vault(FETCH扣)→porter carry(過渡)→resident pool(DELIVER加)，跟上兩輪已驗證的market-delivery守恆模式同構。

**unrest耦合**：純接現成sink(`UnrestBank.add/reduce`→`event_faction_defect`)，新的只有「分配剝削」這個觸發訊號本身——這正是我在後勤WHAT R①那輪就已經核可過的「sink現成、source端新建但沒藏起來」的誠實模式，這次落地跟當初核可的範圍一致。

## ★審點回應

- **WEIGH非GATE**：§1明講「貪婪領主loyalty崩在即仍可發(util動態)、義氣領主自己斷糧時也讓位求生」——連續util競爭，沒有硬類別閘攔死任一種人格的分配可能性，跟這整個session反覆驗證過的「人格只weigh不gate」憲法一致。
- **感知鐵律**：讀「本勢力自有resident-teams」的deficit是faction內部既有member_team_ids記帳(非belief猜測、非讀敵方隱藏態)——跟constitution_gate本身對「自讀/同-faction」讀取的既定豁免一致，這條推理成立，沒有隔空作用疑慮。
- **約束1(同convoy脊椎)**：FETCH複用`_load_convoy_cargo`(現址faction_ai:3002，spec citation:2964有小幅行號漂移，因近期幾輪convoy refine commit導致，非實質問題)、RETURN明講「照舊」——只有DELIVER新增一個終點分支，沒有另刻平行搬運路徑，架構上忠於「統一搬運脊椎」的約束。
- **tap覆蓋**：spec §2結尾明確要求distribute util分項、DELIVER量、deficit runway、unrest增減源全部進dump，沒有遺漏的暫態。

## 剝削A/B fork——不影響這輪seam判決
§6的A(居民付coin)/B(機會成本扣留，本spec採)fork是定價子部的WHAT層級分岔，核心seam(deficit偵測/distribute候選/DELIVER終點/unrest耦合)兩案共用，不因fork結果變動——這輪CLEAN不受A/B裁定影響，跟你note的判斷一致。

## 判決
**CLEAN → 待blueprint A/B confirm後dispatch implementer。** seam本體設計紮實，util公式這次真的避開了前兩輪抓到的「無效lever」陷阱，dev-verify(§3)的4項硬斷(distribute真fire/剝削真餵unrest/persona分岔翻轉/determinism)紀律到位，落地後我會照這份spec逐條複驗。
