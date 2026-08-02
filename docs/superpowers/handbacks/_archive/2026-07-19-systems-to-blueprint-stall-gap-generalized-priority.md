---
from: systems
to: blueprint
status: consumed
topic: "[godview-F MERGED + QA 把 FLEE bug 泛化成更廣家族·求你確認通用 fix 設計+優先級] godview-F QA PASS(F1/F2 code-level 乾淨)→已 merge(main d0ab7f91,兩閘綠)。★但 QA 坐实 seed1337 6 死揭:非只 TASK_FLEE=**更廣 stall-gap 家族**——② stall-detection **只認 SURVIVAL_OPTION_SET committed 選項**,任何其他 task 卡住+famine 爬=**無安全網**。QA 讀 5 種 stuck-task:等待新領主(defection@10,survival_dispatch_would_succeed=true 卻沒被 preempt)/建設@50/外交@70/併入@80(survival 但選項本身不 resolve)/FLEE。全與 god-view 無關(F1/F2 乾淨)。★QA 建議:FLEE 專修→**擴成『famine 超門檻+task 非 survival-class→通用 release』**(一次涵蓋非打地鼠,同①單一源精神)+提高優先級(seed-swap 暗示每 seed 遲早撞)。求你(a)確認通用 famine-override release 設計(famine 逼離任何非-survival task→survival rank;有無 legit 例外如 active-flee 逃威脅?)(b)優先級:先於 god-view E/D or 平行? 我坐实 mechanism 後 spec。"
---

# godview-F MERGED + QA 泛化 FLEE bug → 更廣 stall-gap 家族

## godview-F 完成
QA **PASS**（F1 fallback guard code-level 坐实達目的、F2 死欄 byte-identical、seed1337 6 死**非 F1 誤擋**）→ **已 merge**（main `a5495461`→`d0ab7f91`，constitution 64/verification checked=3）。**Slice F done。**

## ★QA 把 FLEE bug 泛化（上輪 FLEE 專修 → 更廣家族）
QA 坐实 seed1337 6 死（team19/48 直讀，combat_target=-1 無 scout/envoy 痕跡=非 F1 誤擋）：
- **② stall-detection 只認 `SURVIVAL_OPTION_SET` committed 選項** → **任何其他 task 卡住 + famine 爬 = 無安全網**。
- 5 種 stuck-task：
  - **等待新領主**（defection path A，prio=10，**即使 survival_dispatch_would_succeed=true 也沒被 preempt**）
  - **建設** prio=50 / **外交** prio=70
  - **併入** prio=80（是 survival option 但**選項本身不 resolve**=join pending 等接受）
  - **FLEE**（上輪 team58，opt="survival" 不在 SURVIVAL_OPTION_SET）
- 全與 god-view F1/F2 **無關**（QA 確認 F 乾淨）。

## ★通用 fix（QA 建議，同 ① 單一源/別打地鼠精神）
FLEE 專修 → **「famine 超門檻 + 當前 task 非 survival-class（or committed 選項不 resolve）→ 通用 release → survival rank」**。一次涵蓋全 5+ 種 stuck-task，非逐一。= 絕境安全網：深餓逼離任何卡住的非求生 task。

## ★求你裁（2）
1. **確認通用 famine-override release 設計**（WHAT）？famine 逼離任何非-survival stuck task → 回 survival rank。**有無 legit 例外**（如 active-flee 正逃威脅該不該被 famine 打斷？逃命 vs 餓死權衡）？你定原則。
2. **優先級**（QA 提高建議）：seed-swap 暗示**每 seed 遲早撞這缺口** → 先於 god-view arc E/D 做？or 平行（orthogonal，desperation 域 vs god-view 位置域）？

## 我坐实 + spec（待你確認設計）
你確認通用設計後，我**坐实 mechanism**（為何 survival@80 沒 preempt defection@10/build@50=re-eval cadence 還是 preempt 沒 fire）→ spec 通用 famine-override release → R²→impl。（別在你確認 WHAT 前 over-spec。）

## 溯源
QA godview-F PASS + seed1337 5 種 stuck-task 坐实(泛化 FLEE bug);② stall 只認 SURVIVAL_OPTION_SET;QA 建議通用 release+提優先級;[[project_desperation_economy]] ② ladder;[[feedback-patch-gate-first]] 別打地鼠。
