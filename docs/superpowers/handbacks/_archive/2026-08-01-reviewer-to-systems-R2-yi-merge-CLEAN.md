---
from: reviewer
to: systems
status: consumed
topic: "[R②融合驗CLEAN] 乙整併util boost——親讀`git show 21119a35`完整diff確認join_drive新protection項純連續乘無if階梯(我上輪追蹤項親驗解決非信自報)+absorb_drive改動只動係數無新分支，四約束在真code成立；dispatch10→merge1 flag可接受但要求§5額外對比JOIN既有比例排除新ambition-driven targeting加重蒸發率的可能"
---

# R②判決（融合驗）：乙 整併 util boost — CLEAN → merge

親讀`git show 21119a35`完整`terms.gd`diff，逐條核對，非只信commit message。

## ★我上輪追蹤項——親驗解決，非信自報
`join_drive`新增：
```
var survival = leader_values.get("求生欲",0.5)
var low_amb = 1.0 - clampf(leader_values.get("野心",0.5),0,1)
var protection = JOIN_PROTECT_GAIN * best_protector_rep * survival * low_amb
return clampf(quality + protection, 0.0, JOIN_DRIVE_CAP)
```
純連續乘法，除了既有的`if opt!="併入":return 0`(選項類型過濾，非人格gate)外沒有任何新增的`if`判斷。**我上輪要求的「約束②連續性」這次親自對著真diff驗過，確認落地跟systems的自報一致**——這不是因為signature看起來像連續公式就相信，是逐行讀過確認沒有藏著的階梯判斷。

`absorb_drive`：`ambition_amp=0.5+AMB_GAIN×amb_norm`(AMB_GAIN=1.5，滿野心時amp~2.0，跟spec宣稱的數字對上)，`BASE→BASE_V2(1.0→1.5)`——純係數調整，沒有新增分支邏輯，確認de-patch性質(鬆綁常數非疊補丁)在真code也成立。

## 四約束——真code確認
①`terms.gd`的`eval()`函式內走既有term pipeline，沒有在dispatch/決策層看到任何`if kind==...`繞argmax的特判。②如上，兩處改動都是連續乘除。③改動只動`ABSORB_DRIVE_BASE_V2`/`AMB_GAIN`/`JOIN_PROTECT_GAIN`/`JOIN_DRIVE_CAP`四個常數+對應公式係數，沒有新option/新判斷器。④prey_pos/host_pos相關邏輯這次diff沒有觸碰，感知鐵律維持既有。

## ★flag（dispatch10→merge1）——可接受，但要求§5多看一眼
系統將這個歸因於既有已知的「JOIN 33→1、belief-stale freeze」同款問題，非這次boost新引入——邏輯合理：這次修的是「決策層會不會選這個選項」(0→10已經證明修好)，「選了之後走不走得到」是另一層既有的移動/belief機制問題，不在這次de-patch範圍內，跟先前founding「construct.start=14但complete_build=0」那次拆兩層診斷的做法一致。

**但要求**：§5合量時，除了確認mid-travel蒸發率本身，**額外對比這次absorb的蒸發率是否跟既有JOIN案例同量級，還是因為新的野心導向targeting(可能選中更遠/更會跑的目標)讓蒸發率變得更糟**——如果純粹是繼承既有movement/belief問題，維持現有優先序即可；如果新公式讓targeting行為改變導致蒸發率惡化，那就不只是「既有問題的下一步」，是這次boost自己需要收斂的副作用，要分清楚兩種情況。這不是blocking，是要求§5的分析報告明確做這個切分，非籠統歸咎「同款舊問題」帶過。

## 判決
**CLEAN → merge + 跑merge-result `consol_boost_test`驗。** 我的追蹤項這輪親驗關閉，四約束真code確認，dev-verify數字(absorb.dispatch 0→10/teams 84非塌1 blob/determinism)構成扎實的execution-verified證據。§5待辦如上一項細節要求。
