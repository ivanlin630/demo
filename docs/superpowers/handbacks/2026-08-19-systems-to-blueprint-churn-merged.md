---
from: systems
to: blueprint
status: open
topic: "[報:churn-fix MERGED 7877310a(critical path 解鎖)+缺口誠實+wrapper infra bug+序推進·★根修三件全走既有結構(JOIN timeout進既有單源塊TRADE↔STATION/撲空abort讀自己belief感知鐵律/join_rejected cooldown防換皮=我加的必要件)、proximity不加·★gate:控制床決定性PROVEN(measurer獨立重跑ALL PASS:abort+timeout真fire、task釋放、memory寫入、social_target清=同對隊換皮結構性不可能重演非只觀察降低)+headless 0-new+constitution 77;merged main我親驗綠(constitution 77+JOIN lifecycle ALL PASS)·★attribution坐實=pre-existing(plain main無農業b已顯churn signature、fix只碰faction_ai)=你『pre-existing被高壓逼現形』判斷成立·★缺口誠實(非blocker、我裁merge理由):②churn消比例③team不暴增④perf回正未在農業b同量級高壓(49→242/793ms/40-70×)復現(organic plain main天然churn量低n太小)→由下游labor-v2 combined+農業b re-measure兩輪覆蓋(那才是高壓場景)、已記known_issues;merge理由=控制床構造斷根>organic聚合(03b協議查因果>聚合)+不merge卡整條critical path+你sequencing本就是churn先merge·★★順帶infra bug(measurer揪、我立known_issues):tools/godot.ps1 GODOT_TIMEOUT Kill()後立刻ReadAllBytes→handle未釋放→整段stdout憑空消失、複現2次含solo run=所有長跑量測有隨機失憶風險(本輪churn organic大窗就這樣被吃掉)、修向WaitForExit+retry或detach承接、非阻塞排critical path後·★序推進:已dispatch implementer把churn-fixed main疊進labor-v2 branch(純base更新不改邏輯)→完→我route measurer combined同床re-measure真honest starve水位(你帳目紀律要的真代價)→merge+記真accepted cost→農業b re-measure(含floor)→§4·無需你動作、FYI+缺口透明"
---

# churn-fix MERGED（critical path 解鎖）+ 缺口誠實 + infra bug + 序推進

## ★根修（三件全走既有結構、非新機制）
①JOIN timeout 進**既有單源塊**（TRADE↔STATION 之間、鏡射 TRADE 殘距額度）②**撲空 abort 讀自己 belief**（`belief_pos(self,social_target)==(-1,-1)`=感知鐵律、非 god-view 查 host 真位）③`join_rejected` cooldown **防 release 後重選同 host 的 churn 換皮**（我加的必要件、implementer 提案未列）；proximity 不加。

## ★gate
控制床**決定性 PROVEN**（measurer 獨立重跑 ALL PASS：abort/timeout 真 fire、task 釋放、memory 寫入、`social_target` 清=**同對隊換皮結構性不可能重演**、非只觀察降低）+ headless 0-new + constitution 77。**merged main 我親驗綠**（constitution 77 + JOIN lifecycle ALL PASS）。
**★attribution 坐實=pre-existing**（plain main 無農業b 已顯 churn signature、fix 只碰 faction_ai）=你「pre-existing 被高壓逼現形」判斷成立。

## ★缺口誠實（非 blocker、我裁 merge 的理由）
②churn 消比例 ③team 不暴增 ④perf 回正 **未在農業b 同量級高壓（49→242 / 793ms / 40-70×）復現**（organic plain main 天然 churn 量低、n 太小）→ **由下游 labor-v2 combined + 農業b re-measure 兩輪覆蓋**（那才是高壓場景）、已記 known_issues。
**merge 理由**：控制床構造斷根 > organic 聚合（03b 協議：查因果 > organic 聚合）+ 不 merge 卡整條 critical path + 你 sequencing 本就是 churn 先 merge。

## ★★順帶 infra bug（measurer 揪、我立 known_issues）
`tools/godot.ps1`：`GODOT_TIMEOUT` `Kill()` 後**立刻** `ReadAllBytes` → handle 未釋放 → **整段 stdout 憑空消失**、**複現 2 次含 solo run**=所有長跑量測有**隨機失憶風險**（本輪 churn organic 大窗就這樣被吃掉）。修向 `WaitForExit`+retry 或 detach 承接。非阻塞、排 critical path 後。

## ★序推進
已 dispatch implementer 把 churn-fixed main **疊進 labor-v2 branch**（純 base 更新不改邏輯）→ 完 → 我 route measurer **combined 同床 re-measure 真 honest starve 水位**（你帳目紀律要的真代價）→ merge+記真 accepted cost → 農業b re-measure（含 floor）→ §4。
無需你動作、FYI + 缺口透明。
