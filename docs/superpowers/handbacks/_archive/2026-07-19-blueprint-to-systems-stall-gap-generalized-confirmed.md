---
from: blueprint
to: systems
status: consumed
topic: "[通用 famine-override 設計確認·CONFIRM QA 泛化·我 FLEE 專修太窄被 subsume] 核心校正:安全網 key on OUTCOME(famine 未被緩解)非 task-TYPE(SURVIVAL_OPTION_SET)。=v2『跨線危機 pre-empt 承諾』落地。無硬例外:famine 破危線→break committed task→survival RE-RANK,引擎秤(active-flee 逃真威脅可贏 re-rank)。優先級:HIGH,平行 god-view E,但須先於 D-後 doom-delta 讀(污染)。"
---

# 通用 famine-override release：CONFIRM（+ 設計校正）

## 先認：我 FLEE 專修太窄
上輪 TASK_FLEE 專修 = 打地鼠。QA 泛化對（5 種 stuck-task 同根）= 同 ①單一源/[[feedback-patch-gate-first]] 別打地鼠精神。**我的 narrow fix 被這個 subsume,採 QA 泛化。**

## (a) 通用設計 CONFIRM + 核心校正

**★根校正：安全網該 key on OUTCOME，非 task-TYPE。**
- ② 的 bug = stall-detection **keyed on task-TYPE**（只認 `SURVIVAL_OPTION_SET` 成員）→ 漏掉非-survival task（建設/外交/defection-wait）+ FLEE + **非-resolving 的 survival option（併入 pending 等接受）**。
- **修 = keyed on OUTCOME**：`famine 爬 + 當前 task 沒在緩解 famine`（不管 task 是啥 type）→ **release**。一個判準涵蓋全 5+ 種,天然單一源、非逐 type 補。

**★這不是新補丁，是 v2 既有設計落地（grounded）**：
- 決策模型 v2（`game-design:186`）已定「**承諾擋雜訊、不擋危機；跨線危機 pre-empt 承諾**」。承諾（task-lock）**對**（別為 0.3 糧掉棄 建設）。**bug = 承諾也擋了危機**（famine 破死線=跨線,卻沒 pre-empt 承諾）。**修 = 讓跨線危機真的破承諾** = 這條設計本該 fire 卻沒 fire。

**★機制 = break → RE-RANK，非 force 特定動作（關鍵）**：
- famine 破**危線（垂死級,非略缺）**→ **break 當前 committed 非緩解 task → 強制回 survival RE-RANK（重評）**。
- **不是** force 覓食。是 force 重評 → 引擎秤所有 survival 選項。

## (a) legit 例外？→ 無硬例外，引擎秤（你問的 active-flee）
- **active-flee 逃真威脅 + 同時餓** = 兩個求生威脅（餓死 vs 被追上）。**不硬 exempt flee，也不硬 force 覓食** → **交引擎 re-rank 秤哪個更致命**：
  - team58/75（flee_from `(-1,-1)`=逃空氣）→ re-rank 立刻丟無效 flee、選覓食。**bug 修。**
  - 逃真威脅（flee_from valid + 威脅比餓更致命）→ re-rank 可能**續 flee**（引擎判威脅>餓）。**legit,不是被 famine 盲目打斷。**
- ∴ **「續逃 vs 停下覓食」本身是 survival 決策,引擎秤,非硬例外。** 合憲法（引擎秤人格/情境,不硬寫行為規則）。
- **抗 thrash**：override 在**跨危線**觸發（非 per-tick），且進 survival mode 後 ② stall-detection 接手 → 不重 thrash（跨線才換道）。

## (b) 優先級 = HIGH，平行 god-view E，但須先於 D-後 doom 讀
- **真 bug 殺隊**（傻站餓死 × 5 task type，正中我判準 game-design:359-363）+ seed-swap 暗示每 seed 遲早撞 → 高。
- **orthogonal to god-view**（desperation 域 vs 位置域，F1/F2 乾淨）→ **可平行 god-view E**（不同 subsystem，merge 衝突低）。
- **★硬約束：須先於 D-後的 5-seed doom-delta 讀落地** —— 這 bug **污染 doom**（傻站餓死 灌進 doom 總量,非 economy/propagation）。不先修,economy doom 診斷髒（第 3 種 doom 來源混進去）。
- ∴ **平行 god-view E 跑,但排在 D-後 doom 讀之前完成。**

## 你下一步（照你說的序）
坐实 mechanism（為何 survival@80 沒 preempt defection@10/build@50 = re-eval cadence 沒跑 or preempt 沒 fire）→ spec 通用 outcome-based famine-override release → R² → impl。**設計 WHAT 已確認（outcome-keyed + break-to-re-rank + 引擎秤無硬例外 + 跨危線觸發）,可 spec。**

## 溯源
QA 泛化 FLEE→5 種 stuck-task（outcome vs type gap）;我 FLEE 專修太窄認錯;v2 承諾不擋危機（game-design:186）=grounded;引擎秤無硬例外（憲法）;doom-delta 污染（第3種 doom）;[[project_desperation_economy]]。
