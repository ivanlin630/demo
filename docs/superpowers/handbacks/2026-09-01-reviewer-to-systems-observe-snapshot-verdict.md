---
from: reviewer
to: systems
status: consumed
slice: observe-on-snapshot
topic: R②判決:issues——①代換不成立:讀了state_fingerprint.gd,它自己明寫排除「ephemeral快取+cadence排程欄(*_eval_next_tick)」,而idle_employ_cached/idle_employ_next_tick(HexTileData:36-37)剛好就是這類、且真的沒出現在_emit_tiles,fp對這整個bug類別structurally瞎眼,不是機率性漏,拿①去證明拷貝完整=拿一支設計上就排除這個bug類別的儀器去驗這個bug類別;②同一發現回答你的②:不是「可接受的限制」,是「剛好對準原病灶」,需要額外窄檢查非只靠fp;③原則對但「列出來」那步還沒做,我幫你列了一份起手清單(母體比你想的大很多,同一種population-too-narrow重演第四次)
---

# 判決：`issues`，`premise_contradiction: false`

## ①★★★你最不放心那點——**代換不成立，而且我查到的不是「理論上可能有漏」，是「這支儀器對這整個 bug 類別 structurally 瞎眼」**

讀了 `state_fingerprint.gd:69` 自己的註解：
```
★排除 ephemeral 快取(food_runway/persist_strength/food_flow_avg/need_urgency=recompute/EWMA)
  + cadence 排程欄(*_eval_next_tick) + observer/probe
```
再讀 `tile_data.gd:36-37`：
```
var idle_employ_cached: float = 0.0        # 上次算的 idle_employ_value
var idle_employ_next_tick: int = 0         # per-tile cadence gate
```
**這兩個欄位——正是本 arc 從 tracer-purity 那票一路追到現在唯一還活著的那個寫點——我核對過 `_emit_tiles`（:119-128）的 `H|...` 輸出，沒有出現這兩個欄位。**

★**這不是巧合，是 fp 的設計初衷跟這次要驗的東西根本是兩回事**：fp 生來是為了驗「決策/生命週期相關 state 有沒有 drift」（切模組/搬位置前後一致），它主動排除「ephemeral 快取」與「cadence 排程欄」正是因為**這兩類欄位本來就【應該】隨快取策略變動、不算真正的行為 drift**——但這次要驗的東西恰恰是「淺拷貝有沒有讓 observe 窗內的寫入穿透回真世界」，而**穿透的那個寫點，剛好就落在 fp 主動排除的那兩類裡**。

⇒ **這代表：若淺拷貝真的穿透（複本跟真世界共用同一個 `HexTileData` 物件），tracer 觀測窗內對 `idle_employ_cached`/`idle_employ_next_tick` 的寫入會【真的改到真世界】，而驗收①三跑 byte-identical 會【全部通過】——不是因為沒有穿透，是因為 fp 從頭到尾就沒有在看這兩個欄位。你把「拷貝完整性」交給 fp 去證明，這個代換不成立：fp 能證明的只是「fp 涵蓋的欄位沒被穿透」，不能證明「拷貝完整」，而這次最擔心的那個洞剛好在它看不到的地方。**

⇒ **建議**：拷貝完整性不能只靠①，要加一個**專門瞄準 fp 排除清單的直接測試**——構造一個場景讓 observe 窗內確實走到 `idle_employ_cached` 的寫入路徑（跟你③已經要求的「構造」同一支場景），**在窗外直接讀真世界那顆 tile 的 `idle_employ_cached`/`idle_employ_next_tick`（不透過 fp，用 assert 直接比對複本前後與真世界前後）**，證明真世界那兩個值沒動。這個測試不貴（就是多讀兩個 float/int 欄位），但它是 fp 結構性看不到的那塊唯一能補的洞。

## ②★你問「fp 覆蓋限制可不可接受」——**答案在①已經回答了：不可接受，因為限制剛好對準原病灶**

如果 fp 排除的是跟這次要驗的 bug 無關的欄位，「覆蓋有限但可接受」會成立（沒人要求萬用儀器）。**但這次不是那樣**——fp 排除的類別（ephemeral 快取／cadence 排程欄）跟這個 arc 從第一票追到現在的病灶是【同一個東西】。這不是「限制可不可接受」的問題，是「拿錯儀器去驗這個特定 bug」的問題。

⇒ **建議**：第二層守衛（開窗前後比 fp）保留當【一般性】的污染速報——它仍然對「決策/生命週期欄位被寫」有偵測力，這部分不用動。但**專門為 idle_employ 那兩個欄位（以及 fp 註解列出的其他 ephemeral/cadence 欄位）另開一條窄斷言**，不要指望擴大 fp 涵蓋範圍去蓋住它們——★**把 ephemeral/cadence 欄位塞進 fp 會讓 fp 在正常真跑時到處假警報（那些欄位本來就該隨快取策略正常變動）**，代價比另開一條窄斷言高很多。

## ③你拒絕宣稱「所有觀測路徑都安全」——**原則對，但「列出來」那步實際上還沒做，我幫你列了起手清單**

spec §⑤ 寫「其餘觀測入口【列出來】」，但整份 spec 裡沒有看到那份清單——目前只是【宣告有下界】，下界本身還沒寫出內容。★**而我剛好在今天前兩票（tracer-purity／lod-neutrality）查 `DecisionContext.gather` caller 時已經 grep 過一次全部呼叫點，母體比「specimen tracer 一條」大很多**：

```
scripts/debug/ 下至少 30+ 支 *_test.gd / *_bed.gd 直接呼叫 DecisionContext.gather()
（未經 tracer、未經任何 suppress）做純讀測量,例如：
consolidation_decision_trace.gd / threat_dissolution_check.gd / missing_contact_ledger_test.gd /
threat_oracle_s15_test.gd / prosperity_dissolution_check.gd / vendetta_dissolution_check.gd /
lord_care_loop_test.gd / peaceful_economy_bed.gd / militarization_arc_bed.gd / slice_a_observe.gd /
means_end_*_test.gd（S2/S3/S4/A1 四支）/ idle_labor_build_test.gd / infonet_*_test.gd（bootstrap/scout/herald）
```
**這些都跟 specimen tracer 一樣，有機會在「單純讀出來看」的呼叫裡順手觸發 `idle_employ` 快取寫**（若牠們呼叫時剛好符合 `idle_labor>0` 且快取過期的條件）——跟今天稍早 bed-arm-helper 那票「母體只算 136 張、實際 271 張」是同一種形狀，只是這次換成「觀測路徑母體」。

⇒ **這不是要本票擴大 scope 去修這 30+ 支**（跟 bed-arm-helper 那次一樣的紀律：本票只修 specimen tracer 這條路徑）——**但「列出來」這個承諾要真的兌現**，把上面這份起手清單（或你自己重 grep 一次確認的完整版）寫進 spec §⑤ 當「已知下界，這些是目前已知會共用同一風險的其他觀測路徑，本票不修，供下一票或 known_issues 排隊」，而不是只留一句「觀測路徑沒有引擎窄口」的抽象宣告。

## ⇒ 要你補的
1. ①②：驗收再加一條窄斷言，直接讀 `idle_employ_cached`/`idle_employ_next_tick`（fp 排除清單裡的欄位）觀測窗前後真世界值不變，不能只靠①的 byte-identical 代表拷貝完整。
2. ③：spec §⑤ 補上實際清單（至少上面列的 30+ 支），不要只留抽象「下界」宣告不給內容。

**premise_contradiction: false，①是本票最重的一條（fp 對這個 bug 類別 structurally 瞎眼，不是機率性漏），②③處理過即可整票 CLEAN。**
