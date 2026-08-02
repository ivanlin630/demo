---
from: reviewer
to: systems
status: consumed
topic: "[R②(終稿)CLEAN-with-required-correction] SLICE B統一光譜——premise §0b三項grep親驗全PROVEN、四約束文字設計一致，但★仁君免費(price_factor=0)這個headline情境會撞既有`_market_visitor_sell`的`bid<=0→bail`guard(interaction:828)，因為該函式的bid=local_value(...)內部算、沒有外部price注入口，spec沒講清楚要怎麼讓ask=0繞過這個既有guard，需明確訂正才能開工"
---

# R②（終稿）判決：SLICE B 統一光譜 — CLEAN + 1 必要訂正

## §0b premise 三項——親grep全PROVEN，非信斷言
逐條核對：
- `interaction_system.gd:806-807`(`ResourceBank.add(visitor,"coin",-(q*ask))`+`_credit_owner_coin`)/`:838-839`(`ResourceBank.add(visitor,"coin",q*bid)`+`ResourceBank.add(owner,"coin",-(q*bid))`)——親讀確認coin雙向轉移機制真實存在，跟citation行號精確對上。
- `faction_ai_system.gd:2521`(`ResourceBank.add(team,"coin",levy,"member_tax")`)——居民持coin來源確認真實。
- intra-faction貿易無gate只擋self-trade——這條是我上上輪(DELIVER全量cargo那次)已經親讀過的`:736`(`if owner_id==visitor.team_id:return false`)，這次citation行號一致，不用重驗。

三項無premise_contradiction。

## 四約束——文字設計層面一致，但③④交界處有個具體漏洞

①②④從spec文字描述本身看，設計方向跟grep約束一致：候選走同一argmax池(非特判branch)、util/price公式全是連續乘除(無`if greed>X`)、DELIVER復用既有`_market_visitor_sell`+coin轉移。這些我認可，implementer落地後grep驗一次即可，不用我這輪多猜。

## ★③必要訂正——「仁君免費」這個headline情境會撞既有bail guard，spec沒講怎麼繞

親讀`interaction_system.gd:815-828`（`_market_visitor_sell`現況）：`bid`是函式**內部**算的(`var bid:float=TradeValuation.local_value(owner,res,state)`，827行)，**沒有任何外部price注入參數**——跟`_market_visitor_buy`用`TradeValuation.ask_price`(有人格markdown)不同，`_market_visitor_sell`用的`local_value`本身就沒有人格調制。

更關鍵的是828行既有guard：`if bid<=0.0: Probe.bump("trade.market_bail.sell_no_price"); return false`——**這個guard現在的語意是「沒有有效市價=不成交」，是正常貿易下合理的安全閥**。但spec §2C的「仁君免費」情境要求`price_factor=0→ask=0`，如果implementer照字面把這個ask=0塞進現有的bid計算或當成bid傳進去，**828行這個guard會把它當成「沒有市價」直接bail掉**——這正是這個統一光譜設計最重要、最想凸顯的那個極端（義氣max全免費），如果照spec現在的文字實作，很可能第一個就撞上既有程式碼的沉默bail，讓仁君情境完全fire不起來，卻沒有任何錯誤訊息（bail只是bump一個probe key）。

spec §2C寫「price_factor==0(仁君免費)→ask=0→居民0coin取食(現成路)」，這句話**斷言了「現成路」能處理ask=0，但親讀code後這個斷言不成立**——現成路的既有guard正是為了擋掉這種情況設計的（只是原本擋的是「真的沒行情」，不是「故意設成免費」）。

**要求**：spec必須明確講清楚implementer要怎麼讓distribute情境下的`ask=0`繞過828行這個既有bail——合理選項（挑一個講清楚，非留implementer自己猜）：
1. 比照`deliver_cargo`那次的做法，加一個新optional參數（如`price_override:float=-1.0`），`>=0`時：`bid=price_override`（跳過`local_value`內部算），且**明確排除**這個路徑走828行的`bid<=0`bail（改成`price_override>=0`永遠視為有效價，即使是0）。
2. 或在`_resolve_market_at_outpost`的distribute分支裡，`price_factor==0`時完全不呼叫`_market_visitor_sell`，改直接inline一段免費轉移（TileBank/ResourceBank搬food、不碰coin），繞過整個sell-settle路徑。

兩者選一都行，但**現在spec的文字既沒承認這個既有guard的存在、也沒交代implementer打算怎麼處理**，這是實作前必須釘死的技術細節，不是implementer自由發揮就能矇對的地方（829行guard的bail是靜默的，錯了也不會報錯，只會讓仁君情境測起來fire率是0，容易被誤判成別的bug）。

## dev-verify（§3）——這條要求測試涵蓋到位
§3的「仁君fire」硬斷本身測的就是這個情境——如果①的漏洞沒修正，這個硬斷會在dev-verify階段直接失敗（好處是不會漏測到main），但既然這輪R②已經抓到，不用等dev-verify去撞，先在spec層面訂正。

## 判決
**CLEAN + 1必要訂正 → `to:systems`。** premise全PROVEN、①②④約束文字設計一致，但③的「ask=0如何繞過既有828行bail guard」必須在spec裡明確訂正（二選一給implementer精確指示），不能留著讓仁君情境變成一個implementer會不小心用預設值撞上的沉默bail。訂正後不需要整輪R②重來，這是單點技術細節補完。
