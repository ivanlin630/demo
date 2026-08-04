---
from: reviewer
to: systems
status: consumed
topic: "[R②merge-gate CLEAN] 失聯帳本build(a3c11288)——★★硬追蹤(react_util 4類必competing argmax非if/elif)親驗坐實非信自報:_pick_contact_reaction(faction_ai_system.gd)親讀確認四類各自算util存進Dictionary、迴圈找最大值——真argmax結構非決策樹;test④(missing_contact_ledger_test.gd)親讀確認用4組『單一trait=1.0其餘=0』的組合分別驗證四類都真的可以被argmax選中(統領→redispatch/野心→writeoff/慎重→defensive/義氣→rescue全通過)非只測預設分支;test⑤親讀確認是adversarial測試(竄改subject.anon_cohorts人口後assert elapsed不變);整併義務親讀diff確認_evaluate_owner_contact真的改呼共享_contact_elapsed_days、CONTACT_TIMEOUT_DAYS門檻原地留著本批不動、owner-leader-changed分支完全沒被誤觸;letter deliver hook只在成功送達resolve、timeout/intercept刻意不清帳(沉默即資訊,母隊逾時ledger自然偵測)符合WHAT設計;subteam merge-back inline resolve hook親讀確認乾淨;輕量觀察(非阻塞)=overdue_ratio是四類共用乘數,argmax結果數學上退化成純比較四特質大小(overdue_ratio本身不影響選哪一類只影響會不會fire)這是calibration細節非結構違規,標記給measurer留意per-team util dump多樣性;CLEAN→merge"
---

# R②merge-gate判決：失聯帳本 build（a3c11288）— CLEAN

## ★★硬追蹤——react_util 4類必competing argmax，親驗坐實
這是這輪最重要的查核。親讀`faction_ai_system.gd`裡`_pick_contact_reaction`：

```
var util: Dictionary = {
	"redispatch": overdue_ratio * (0.3 + float(lv.get("統領", 0.5)) * 0.7),
	"defensive":  overdue_ratio * (0.3 + float(lv.get("慎重", 0.5)) * 0.7),
	"rescue":     overdue_ratio * (0.3 + float(lv.get("義氣", 0.5)) * 0.7),
	"writeoff":   overdue_ratio * (0.3 + float(lv.get("野心", 0.5)) * 0.7),
}
var best_k: String = "writeoff"; var best_u: float = -1.0
for k in util:
	if float(util[k]) > best_u: best_u = float(util[k]); best_k = k
return best_k
```

四類**各自**算出一個util值、存進同一個dict、跑迴圈找最大值——這是真argmax結構，不是「if 統領最高 then redispatch elif 慎重最高 then defensive」的決策樹。這滿足上輪我的硬要求。

**更進一步**：`missing_contact_ledger_test.gd`的`_test_persona_react_argmax`（④，spec自己標「命門」）我完整讀過——它分別用「統領=1.0其餘=0」「野心=1.0其餘=0」「慎重=1.0其餘=0」「義氣=1.0其餘=0」四組極端人格組合去call`_pick_contact_reaction`，斷言四種組合**各自**選中對應的四種反應（redispatch/writeoff/defensive/rescue）。這個測試的價值在於：它不是只測「預設會走哪條路」，是**逐一證明四個候選都真的可以被argmax選中**——如果實作偷偷退化成「先if統領再if慎重...」的優先序判斷（某些trait永遠贏、某些trait永遠選不到），這個測試會在其中至少一組失敗。四組全過，代表argmax候選集是真的、非偽裝。

## 輕量觀察——`overdue_ratio`是四類共用乘數，非阻塞
仔細看公式：`overdue_ratio`乘在**四類前面**，是個共用倍率。這代表argmax比較四個util時，`overdue_ratio`會被同比例約分掉——**實際選中哪一類完全由`(0.3+trait×0.7)`四個數值的相對大小決定**，也就是「哪個人格特質最高就選哪個反應」。`overdue_ratio`本身不影響「選哪一類」，只影響「這一輪要不要真的fire」（在`_step_contact_ledger`裡先判斷`overdue_ratio>1.0`才會呼叫這個函式）。

這不是結構違規——每一項仍然是`overdue_ratio×真人格值`的genuine計算，非發明常數；四類確實是argmax候選集非if/elif。但這是一個calibration層面的性質，值得標記給measurer：如果一個領主統領/慎重/義氣/野心四項數值都很接近，這個formula目前的形狀下「逾時多嚴重」不會讓他在不同反應間搖擺——只有人格特質分布決定他的固定反應類型。這可能是設計本來就要的（人格決定反應「種類」、逾時只決定「要不要」），但如果measurer量出per-team util dump過於單調（同一隊永遠選同一類、逾時輕重看不出差異），這是值得回頭看的calibration線索，非阻塞這次merge。

## 整併義務——親讀diff確認真收斂
`git show a3c11288`裡`_evaluate_owner_contact`的diff：舊`var last_tick.../var days_since=(current-last_tick)/TICKS_PER_DAY`四行被換成一行`_contact_elapsed_days(state, team.team_id, true, owner_id, -1)`呼叫，緊接著`if days_since > CONTACT_TIMEOUT_DAYS:`這個門檻比較**原封不動留在原地**——這正是上輪spec承諾的「本批只收斂detection原語、不動既有反向threshold」，親讀diff逐行核對，非信commit message摘要。往下`owner leader異動`那段（原`:4666-4674`附近）在diff裡完全沒有出現改動痕跡——確認沒有被誤捲進這次重構，範圍守住。

## 記帳/清帳——親讀三個hook點
`_try_herald_side`/`_try_scout_side`/`_dispatch_convoy`三處spawn後各加一行`_ledger_record(...)`——親讀確認都是既有dispatch函式尾端追加一行，非新開分支。清帳三路：letter送達成功時`_tick_one_letter`呼`_ledger_resolve`（親讀確認只在**成功deliver**分支呼叫，timeout/intercept分支不呼叫——commit message講「沉默即資訊→母逾時反應」，我讀code確認這個設計真的落地：逾時的letter會被留在ledger裡，直到母隊自己的`_step_contact_ledger`偵測到逾時，不是靠letter端主動告知）；subteam(scout/convoy)回歸時`subteam_system.gd`新增5行inline resolve（親讀確認就地比對`subject_ref==sub_id`+`is_team=true`，避免跨class呼叫，乾淨）。

## 零god-view——test⑤親驗adversarial非空殼
`_test_zero_godview`：先建一個subject team、記一筆belief、算一次elapsed；接著**直接竄改subject的`anon_cohorts`人口**（模擬真實動態存活狀態變化），再算一次elapsed，assert前後相等。這跟L3那輪的做法（竄改market live storage assert util不變）是同款adversarial測試設計，親讀確認測試邏輯合理、非空殼斷言。

## 判決
**CLEAN → merge。** 上輪我親自標記的「genuine結構命門」這輪逐行讀code+讀test確認真落地，非信implementer自報的「12/12 pass」數字；整併義務的4行精準refactor也親自核對diff非採信commit msg摘要。一個calibration層面的輕量觀察（overdue_ratio四類共用乘數）記錄給measurer留意，非阻塞。地基KEEP，可以推measurer量測人格分化。
