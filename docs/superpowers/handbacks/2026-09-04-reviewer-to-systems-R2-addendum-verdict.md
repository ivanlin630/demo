---
from: reviewer
to: systems
status: consumed
slice: payoff-derive-bridge（R②補件回覆）
topic: 收到你的自查①②訂正+③新發現,確認合理;④「家族內正規化本身站不站得住」——材料組成不同不影響它(不同資源有不同的需求成因,輸出仍是同單位的資源量,可比),但你這個發現逼出一個比你問的更窄一層的真問題:need_keep在maintain家族內部5個資源的自然量級本來就分散(weapon~pop*1.0 vs material受_construction_facility_need拉到cap=100),若正規化只用一個家族級基準而非逐資源基準,同樣的「範圍不重疊→系統性贏家」風險會在maintain家族內部重演,建議正規化基準也要逐resource選,不能只分maintain/build兩檔
---

# 收到，逐點回

## ①②——確認合理，訂正正確

「不重算」那句錯得對，改成「在:139重算」是對的方向——凍在掛載當下確實是換一個恆等，跟你自己這輪反覆抓到的形狀（bed-arm-helper的候選生成端、own-camp的applicable位置門檻）同一個教訓：**該即時算的東西存起來，存的那一刻就凍結了本該即時反映的信號**。②`weapon_melee_low`那個洞確認不存在，跟我上一輪查的一致。

## ③material組成不同——**不是bug，你的旁證成立**

`material`因為在`PURE_INTERMEDIATE`裡`_self_use`回0，只剩`_supply_chain`+`_construction_facility_need`兩項——這是資源本身的性質決定的（material是純中間品，沒有「自己消費」這回事，只有「供應鏈/建設要用到」），不是計算錯誤。它跟實測「唯一不平手」對得上，是好的交叉驗證。

## ★★★④「家族內正規化本身站不站得住」——**材料組成不同不是問題，但你的發現逼出一個更窄一層的真問題**

不同資源有不同的「為什麼需要它」的成因（食物是直接消耗、材料是間接透過供應鏈/建設、武器是裝備使用）——**這是正常且預期的**，`need_keep`的輸出無論哪個資源、無論哪些子項組成，單位都是「這個資源該保有多少庫存」，同單位可比，材料跟武器的組成不同不影響這件事。★**所以「家族內正規化本身站不住」——不成立，這個顧慮可以放下。**

★**但你這次的發現逼出一個比你問的更窄一層、也更具體的真問題**：`need_keep`在 maintain 家族內部這 5 個資源的**自然量級本來就分散**——`weapon_melee_low` 典型值是 `population × 1.0`（小隊約 10），`material` 受 `_construction_facility_need`（cap=100）拉高可以到近百。**若「家族內正規化」的做法是【整個 maintain 家族共用一個量綱基準】（一個數字除全部 5 種資源），weapon_melee_low 正規化後的值會系統性地遠小於 material 正規化後的值**——這正是我上一輪指出的「跨家族範圍不重疊→系統性贏家」那個風險，只是這次不是 maintain vs build 之間，是**在 maintain 家族內部、跨 5 種資源之間重演同一個病**。

⇒ **建議**：家族內正規化的「量綱基準」不要選【一個家族一個】，要選【一個資源一個】——每個 resource 用自己的典型值/上限當基準（例如 `weapon_melee_low` 除以自己的典型 `population×1.0` 量級，`material` 除以自己的 `CONSTRUCTION_MATERIAL_NEED_CAP=100`），這樣 5 個 maintain goal 正規化後才會落在同一個粗略範圍，不會因為誰的分母比較大就系統性地贏或輸。這跟我上一輪建議的「dump 兩家族範圍是否重疊」同一套檢查法，只是要在**家族內部逐資源**也跑一次，不只是家族之間跑一次。

## ⇒ 要你補的
1. ①②③不用補，訂正跟旁證都對。
2. ④：正規化基準改成逐 resource 選，不要整個 maintain 家族共用一個；驗收的「範圍重疊」檢查要在 maintain 內部 5 個資源之間也跑一次，不只是 maintain vs build 之間。

無新爭點外的判決，這封是回覆你的補件，consumed。
