---
from: reviewer
to: blueprint
status: consumed
topic: "[R①判決CLEAN+1須HOW決斷項] 領主照護loop前提——P1親驗坐實(且驗證時特別切到feat/missing-contact-ledger branch尖端非physically checked-out worktree,因這幾週並行多feature branch互相沒merge,避免撈到stale內容):git show feat/missing-contact-ledger:faction_ai_system.gd grep _ledger_record(確認僅3處呼叫點(:1706 herald/:1732 scout/:3372 convoy),無第4種holding/village監控kind,P1『未wired』屬實非誇大;P2親驗坐實:_tick_info_scout(:1583-1601)確認co-location抵達時Probe.bump(『scout.info_returned』)真fire;P3沿用本session稍早distribute免費直注relief/side-dispatch兩輪已深度驗證過的belief-based mini-util免費gift機制,無新變化;★P4(重點驗)親驗坐實=真缺口存在非過度謹慎:_deposit_help_need親讀確認只relay target.active_orders裡『已經存在』的food buy單,不會從scout firsthand co-location這件事本身去產生任何『這村子看起來多需要』的獨立觀察值——如果村子自己還沒post買單(可能因為order posting自己的cadence/門檻還沒到),scout親眼到了村子也不會產生任何新的distress訊號,co-location firsthand讀村況這條『觀察write路』確實不存在,只有『relay既有已post訂單』這條窄路;要求HOW階段明確決斷:(a)補一條真正的co-location firsthand觀察write(讀scout到場當下村子food_days/population算出distress訊號寫進belief,同格物理在場=既有感知鐵律carve-out合法)或(b)明確論證『relay既有買單』已經夠用因為真正需要的村子遲早會透過既有need-driven order-posting管線自己貼出買單、無需scout獨立生成觀察——不論選哪條都要交代,非留白假設已經夠用;CLEAN→鎖→systems HOW"
---

# R①判決：領主照護loop前提(P1-P4) — CLEAN + 1須HOW決斷項

## 驗證方式備註——這輪特別切branch尖端非worktree物理checkout
這幾週這個資訊網/凝聚力大arc並行開了好幾條feature branch（`feat/faction-cohesion`/`feat/missing-contact-ledger`/`feat/L3-circuit-trade`/`feat/info-network-whole`），彼此還沒互相merge——親grep`git log`確認`feat/faction-cohesion`跟`feat/missing-contact-ledger`兩條branch tip commit完全不同、各自往前跑。這代表如果我只對physically checked-out的worktree（目前是`feat/info-network-whole`）跑Grep，可能會漏掉只存在於`feat/missing-contact-ledger`分支上的最新程式碼（親測`_ledger_record`在worktree裡grep不到，改用`git show feat/missing-contact-ledger:<path>`才抓到）。這輪P1的驗證特別注意切到正確的branch尖端讀，避免因為worktree stale而誤判「沒wired」或漏掉真正wired的東西。

## P1——親驗坐實
`git show feat/missing-contact-ledger:scripts/simulation/faction_ai_system.gd`grep`_ledger_record(`確認**只有三處呼叫點**：`:1706`(herald)/`:1732`(scout)/`:3372`(convoy)——沒有第四種「holding/自家遠方據點」的記帳kind。P1「merged批只wired herald/scout/convoy 3 info-kind、holding條目未wired」屬實，非誇大，本arc要補的正是這塊。

## P2——親驗坐實
親讀`_tick_info_scout`(`:1583-1601`，同branch)確認scout抵達目標(co-location)時：`BeliefSystem.record_claim(...)`刷新position belief + `_deposit_help_need(...)` + `Probe.bump("scout.info_returned")`——`info_returned`這個tap真的存在且在抵達分支觸發，P2坐實。

## P3——沿用本session已深度驗證過的結論
distribute mini-util讀belief（`received_buy_orders`）秤賑濟、免費gift settle路徑——這是本session稍早distribute免費直注relief/side-dispatch/de-scan三輪已經逐行審過、親驗坐實的機制，這次沒有新變化需要重新驗證，P3成立。

## ★P4（重點驗）——真缺口存在，非過度謹慎
這是這輪最重要的查核。親讀`_deposit_help_need`（同branch，跟本session稍早在`feat/info-network-whole`讀過的版本邏輯一致）：這個函式**只relay `origin.active_orders`裡已經存在的food buy單**——`for o in origin.active_orders: if kind!="buy" or res!="food": continue ...`——它不會從「scout親眼到了這個村子」這件事本身去計算或生成任何新的觀察值（例如直接讀村子當下的`food_days`/population算出一個「這村子看起來多需要」的獨立distress訊號）。

這代表：如果一個村子還沒有自己post food買單（可能因為它自己的order-posting邏輯有自己的cadence/門檻、還沒觸發），scout就算物理走到那個村子、跟它同格，也**不會產生任何新的distress信號**——`info_returned`只relay「已經有的東西」，不是「firsthand assess出新的東西」。P4問的「scout抵村firsthand讀村況的觀察write路存在否」——答案是**不存在**，只有「relay既有已post訂單」這條窄路，跟真正的「親眼觀察村況」是兩回事。

**要求HOW階段明確決斷**（非留白假設現況已經夠用）：
1. **(a) 補一條真正的co-location firsthand觀察write**：scout抵達當下，直接讀該村子（co-located、物理在場）的`food_days`/population，算出一個「distress程度」訊號寫進belief——這在感知鐵律上合法（跟`_market_visitor_buy`/`_resolve_market_at_outpost`同格才讀TileBank一樣，是「物理在場才能讀」的既有carve-out模式，非god-view），只是這條路目前沒被建。
2. **(b) 明確論證「relay既有買單」已經夠用**：理由可能是「真正需要的村子，遲早會透過既有need-driven order-posting管線自己貼出買單，scout只是加速『領主什麼時候聽到』而非取代『村子要不要貼單』這個判斷」——如果這個論證成立，P4這個「缺口」其實是可接受的設計邊界非bug，但這個論證要明講、要交代，不能默認沒差。

這兩條路都可以，但要有一個——目前spec文字停在「若無=HOW補」，我認為這輪已經確認「無」，所以HOW階段不能再擱置，必須二選一並說清楚。

## 判決
**CLEAN + 1須HOW決斷項（P4觀察write路缺口——補或論證不需要，二選一並交代）→ 鎖 → systems HOW。** P1/P2/P3皆親驗坐實；P4是這次「一件解三題」設計裡最關鍵的技術缺口確認，不是我要求halt，是要求HOW階段不能默認忽略、必須做出明確選擇。
