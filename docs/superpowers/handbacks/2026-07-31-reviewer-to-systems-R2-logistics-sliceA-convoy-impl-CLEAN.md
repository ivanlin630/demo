---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN+1追蹤項] 後勤SLICE A convoy實作——三驗收線+lifecycle interop+守恆+不凍皆親驗坐實；convoy.return和平床telemetry=0未定論，要求measurer拉dispatch-tick時間戳或延長run天數確認是視窗太短非功能gap，非rubber-stamp「已證」"
---

# R②判決：後勤 SLICE A convoy 實作（GATE-B撮合物理送貨第一刀）— CLEAN + 1 追蹤項

## ①-⑤ 親驗diff（`git show 4754214e`），逐項核對

**lifecycle interop（我上輪ISSUES②③④的驗收）**：親讀diff確認`TASK_CONVOY`分支(`faction_ai_system.gd:1741-1744`附近)插在`TASK_SETTLE`分支**之前**、離generic fallback(:1753原行號)更遠——結構上保證`_tick_convoy`會先攔截，convoy子隊不可能落到generic fallback或被TASK_SETTLE的`_convert_to_resident`誤轉，這正是上輪要求的「專屬分支比照TASK_BUILD/SETTLE」，落地精準。

**RETURN機制**：`phase=="RETURN"`且`move_target==(-1,-1)`(到家)→`merge_queue.append`→loop2b的`try_merge_back`處理歸建釋放pop，非`_convert_to_resident`/非整隊消失——比照spec設計、非另闢蹊徑。`convoy.return`的bump點刻意選在loop2b真merge處、認`convoy_phase`標記(非在`_tick_convoy`內部bump)——comment講清楚理由(防porter中途被release→IDLE走IDLE併回路時漏記或重複記)，這是有意識的防漏設計非隨手擺放。

**DELIVER**：`_resolve_market_at_outpost`呼叫confirmed，`Probe.add_amount("convoy.cargo_delivered", before-after差值)`量測真實搬運差量(非固定假數字)。

**cargo守恆**：`_load_convoy_cargo`用exact-load(delta補足/退多餘)，dispatch時FETCH真實從母隊inventory+vault扣、DELIVER真實deposit——親讀邏輯無憑空增減。

## ★1追蹤項——convoy.return和平床telemetry=0不算已解決，要求measurer補證

implementer的「功能已證(merge/無zombie/pop守恆、warring convoy=59)」是**間接**證據（別的場景/別的驗證方式），不是這輪和平床這個特定run裡RETURN真的被觀測到執行過。親算時間序：DELIVER完成的**同一tick**就設`move_target=home_pos`轉RETURN(diff確認)，代表RETURN是OUTBOUND的對稱回程——若4次convoy dispatch集中在6個月視窗後段(候選生成本身需要surplus累積+belief傳播，不會一開場就有)，去程就吃掉大半剩餘時間，回程很可能真的還沒走完run就結束了。**這是合理解釋，但目前只是解釋，不是驗證過的事實**——跟本session反覆立下的「別讓別處證明頂替這裡的觀測」規矩(specimen精化4/5、B1礦山bootstrap、founding floor team14 timing同款要求)一致，這次也不能因為warring數字好看就跳過。

**要求**：measurer獨立驗收時，二選一（不是都做）：(a) 從`convoy.dispatch`/`convoy.deliver`的sample資料拉出這4筆的實際tick，跟6個月總tick數比對，看dispatch是否確實集中在後段、回程時間是否真的不夠(視窗太短，非功能gap，可安心結案)；(b) 直接延長和平床run天數(如8-9個月)重跑一次，確認`convoy.return>0`真的出現。兩者選一即可，不用兩個都做，但不能什麼都不做就採信「已證」的說法。

## 其餘（感知鐵律/不凍/determinism）——核對到位
`received_buy_orders`belief讀取(非god-view)、attrition 1.80%≠0+teams 90 churn(不凍延續前幾輪判準)、determinism byte-identical——皆跟既有驗收線一致，不重複展開。

## 判決
**CLEAN → merge。** 三驗收線+lifecycle interop+守恆皆親驗坐實，這是GATE-B撮合第一次真的活起來、值得merge。1項追蹤（convoy.return和平床0）非blocking但要求measurer在獨立驗收時明確補證，別讓這條疑點靜默滑過變成下一個「以為已證其實沒測過」的案例。
