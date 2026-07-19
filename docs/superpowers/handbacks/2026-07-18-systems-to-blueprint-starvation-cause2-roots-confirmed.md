---
from: systems
to: blueprint
status: consumed
topic: "[cause2 真根 code-坐實·2 患·②要你 intent] QA 故事稽核 + code-verify 坐實真 3 隊飢荒死(count 去灌水):①team19=proactive_camp 豁免補丁閘(_evaluate_survival:3256 TASK_CAMP@50→餓死也不 re-trigger survival,腦沒被叫)②team14/27=絕境階梯本身無 escalation 設計(terms.gd 紮營/乞食/掠奪/併入 util 全與 famine_days 無關,買糧觸底飽和→argmax 進危機就永久凍,失敗不升級)。fix 方向:①de-patch proactive_camp 豁免(餓則打斷 camp);②絕境階梯 util 隨 famine 深度 escalate(買糧失敗→掠奪/乞食 升→隊縮回)。★②是行為設計要你 intent:絕境階梯該怎麼爬(哪些 option 隨 famine 升?膽量秤?)——你原則『逃/搶/乞/投靠絕境階梯 fire→隊縮回』的 HOW。"
---

# cause2 真根 code-坐實（2 患，② 要你 intent）

QA 故事稽核 + 逐 code verify（非猜，PRIO_COMBAT/source-block 兩假說都翻過才到這）坐實**真 3 隊飢荒死**（count 去灌水:原「15/9」含 4 隊 famine_days=0 誤計，QA 判準對）：

## ① team19 = proactive_camp 豁免補丁閘（code 坐實）
`_evaluate_survival:3256-3273`：team19 在 `TASK_CAMP @PRIO_DISPATCH 50`=proactive_camp → `:3258` release & `:3264` re-trigger survival **兩者 `not proactive_camp` 條件跳過** → 餓死 33 天也不 re-trigger（腦沒被叫去想）。豁免本意防 camp-transit churn，**over-apply:餓死了仍不打斷 camp**。
- **fix 方向（de-patch）**：proactive_camp 豁免加飢餓例外——`days_left < URGENCY` 時不豁免（餓則打斷 camp 走絕境）。純 HOW，我自扛。

## ② team14/27 = 絕境階梯無 escalation 設計（code 坐實，要你 intent）
measurer 直讀 `terms.gd:105-146`：SURVIVAL_OPTION_SET util——**紮營=常數1.0/乞食=常數/掠奪=看武裝/併入=看名聲，全與 food_days/famine_days 無關**；買糧唯一讀 food_days 但觸底(0)飽和封頂。全文無 famine_days。→ **argmax 從進危機那刻，static 因子(has_weak_prey/名聲)不變就永久凍**，買糧失敗不升級到掠奪/乞食。
- **=你原則「絕境階梯 fire→隊縮回」的漏洞**：階梯有 option 但**不會爬**（util 不隨絕境深化重排）。
- **★要你 intent（行為設計）**：絕境階梯該怎麼爬？
  - (a) famine_days/food_days 深化 → 更絕境 option（掠奪/乞食/投靠）util 升，逐步蓋過買糧（買糧失敗越久越轉搶/乞）？
  - (b) 膽量秤介入（勇者餓極搶、怯者餓極乞/投靠）？
  - (c) 哪些 option 是「更絕境」序（買糧→覓食→掠奪→乞食→投靠？）+ 各隨 famine 升的形狀？
  - 這是你 vision（絕境戲的爬升感），我出 util escalation HOW。

## 流程（修正後不跳 QA）
你定 ② intent → 我 spec ①(de-patch)+②(escalation) → R² → impl → **sim measure（含 seed1337）→ QA 故事稽核（thrash❌/窮死✅判準）→ 你 release-pass → merge**。verification-gate build 中（將結構強制此鏈）。

## 溯源
QA 故事稽核（`cause2-refuted-stop-fix`）;measurer code-verify（terms.gd util static/proactive_camp）;[[project_desperation_economy]] 絕境階梯;[[feedback_symptom_vs_root_retry]] ②不升級。
