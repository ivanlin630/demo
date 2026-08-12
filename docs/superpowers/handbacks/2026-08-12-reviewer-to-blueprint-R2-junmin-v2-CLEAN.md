---
from: reviewer
to: blueprint
status: consumed
topic: "[re-R②判決=CLEAN] 军民混编/民兵動員spec v2——6項finding逐一核對非只信『已訂正』字面:①framing誠實化親讀§0確認直接承認『非5折1』字面矛盾、明講armed_anon/captive_guard/TASK_TRAIN保留不折,跟真正折的(guard_ratio+團型TAG)分開講,不再模糊②★拆兩slice親讀§0/§3/§4確認Slice A(guard照妖鏡+belief-threat)明講『不碰決策路由』真自我限縮scope,Slice B(團型梯度+pool分數化)前置一道硬性gate『開工前先小spike定decouple法』——這是對finding②承重牆最誠實的處理方式(不是假裝WHAT層級能解決uses_unified綁TAG這種需要探查~15處gate才能定案的技術問題,而是把它變成Slice B動工的硬性前置條件)③guns-vs-butter cache staleness §3明講須加進ensure_fresh重算觸發條件④manufacturing:86分子膨脹bug §3明講須同修分子分母⑤guard_ratio夜襲免疫消費者§2明講一併接,不再漏列⑥belief-threat只服務uses_unified隊的缺口§2明講Slice A要讓純軍團守衛決策也走belief;六項皆非表面回應、是真的改變了spec的技術承諾內容(尤其②從『團型梯度』輕描淡寫升格成『須先小spike定decouple法』的硬gate,對應我親驗過的uses_unified:2394真結構風險);Slice A範圍確認自我限縮乾淨(不碰pool_of/TAG_PRODUCE結構/uses_unified),可以先切不用等Slice B的spike結果;判決=CLEAN→鎖→Slice A先切(Slice B待spike後另行R②)"
---

# re-R②判決：军民混编/民兵動員 spec v2 — CLEAN

## 逐條核對 6 findings，非只信「已訂正」字面

**①framing 誠實化**：親讀 §0 確認直接承認「不是 5 折 1」這個字面矛盾，明講 `armed_anon_ratio`/`captive_guard_ratio`/`TASK_TRAIN` 保留不折，跟真正被折的（`guard_ratio` de-patch + 新建動員分數 + 團型 TAG→梯度）分開講清楚——不是換個說法帶過，是真的把 scope 講精確了。

**②★拆兩 slice——finding② 承重牆處理得最好**：親讀 §0/§3/§4 確認 Slice A（guard 照妖鏡+belief-threat）明講「**不碰決策路由**」，真的自我限縮範圍；Slice B（團型梯度+pool 分數化）前置了一道硬性 gate——「**開工前先小 spike 定 decouple 法**」。這是對「`uses_unified` 綁 TAG_PRODUCE 二元、~15 處硬 binary gate」這個真結構風險最誠實的處理方式：不是假裝在 WHAT 層級就能解決一個需要實際探查 15 處 gate 才能定案的技術問題，而是老實承認「這個問題現在還沒答案」、把它變成 Slice B 動工前必須先做的硬性前置條件（spike），非空話帶過。

**③guns-vs-butter cache staleness**：§3 明講「須加進 `ensure_fresh` 重算觸發條件」——直接對應我上輪親讀 `LaborSystem.rebalance`/`ensure_fresh` 找到的 cadence-staleness 問題，措辭具體（比照既有食物危機那條觸發），非模糊帶過。

**④manufacturing:86 分子膨脹 bug**：§3 明講「分子仍讀原始 population → labor_share>1.0 產出膨脹 bug、須同修」——這是我上輪親自重讀 code 抓到的具體 bug，v2 逐字承認且指名要修的兩個確切位置。

**⑤guard_ratio 夜襲免疫消費者**：§2 明講「一併接」——不再是 grounding 表漏列的狀態。

**⑥belief-threat 覆蓋缺口**：§2 明講 Slice A 要讓純軍團（非 `uses_unified`）的守衛決策也走 belief-threat——正面處理了「belief-threat 現只服務 uses_unified 隊」這個 finding，不是留給 Slice B 才管。

**六項都不是表面回應**——尤其②，從原本 v1 輕描淡寫的「團型梯度」升格成「須先小 spike 定 decouple 法」這個硬 gate，直接對應我親驗過的 `uses_unified:2394` 真結構風險，是真的改變了 spec 的技術承諾內容，不是換句話術。

## Slice A 範圍自我限縮確認乾淨

親讀確認 Slice A 不碰 `pool_of`/`TAG_PRODUCE` 結構/`uses_unified`——只動 `guard_ratio` 公式（離散→連續人格）+ 動員/守衛 trigger 讀源（god-view→belief），這兩塊在上一輪就已經親驗坐實（`_has_hostile_within` 真 god-view、`ThreatAssessment.score` 真 belief-based 既存機制）。Slice A 可以獨立先切，不需要等 Slice B 的 spike 結果先出來。

## 判決
**CLEAN → 鎖 → Slice A 先切。** Slice B 待前置 spike（決定半軍半民隊 `uses_unified` 路由語意怎麼 decouple）完成後另行送 R②，不在這輪判決範圍內——這個分階段安排本身就是這輪 v2 對框外審 finding 的正確回應，不需要我這輪替 Slice B 預先審一個還沒做完 spike 的設計。
