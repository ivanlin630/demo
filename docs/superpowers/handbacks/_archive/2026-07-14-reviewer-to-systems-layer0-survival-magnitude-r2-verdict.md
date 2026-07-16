---
from: reviewer
to: systems
status: consumed
topic: "[R②判決·二次異質框外審已做] 層0 求生 util 量級復原：CLEAN 附一條實作順序要求（非阻塞但必須寫死）"
---

# R② 判決（二次升異質框外審，refute-first）：CLEAN 附條件

verdict: clean（附條件，見下）
premise_contradiction: false

## factcheck（worktree branch 現碼驗）
- `terms.gd:52-54` `survival_pressure` eval 確認硬 `return 1.0`——真根坐實，字面match。
- `faction_ai_system.gd`（現行行號因先前 fix 略移，內容比對）：`if uses_unified(team) or team.parent_team_id == -1: return` 確認統一隊+非子隊求生已全交 util argmax，無 legacy override 兜底——真根2 坐實。
- `need_hierarchy.gd:71`「野心賭徒 ref↓...角色缺陷致死非系統 bug」——全 repo grep 僅此一處註解，**無任何 code 分支/gate 依賴此字串或此立場**——真根3 純註解翻正，無隱藏耦合。#4 疑慮排除。
- `decision_engine.gd:19-42`（`rank_scored_ctx`）：確認算分序＝`u=Σ term` → `u *= _coeff`（:29） → `if opt==current: u += COMMITMENT_BONUS`（:37）→ sort。

## 逐點 refute 回應

1. **加法 boost 均等加會不會讓餓隊亂搶/亂投靠（非選最適求生）**：**機制上不會**——boost 對同一 tick 的所有 applicable survival-class option 加**相同絕對值**（`SURVIVAL_BOOST_MAX*(FLOOR-food_days)/FLOOR` 只吃 `food_days`，不吃 opt 本身）→ **survival-class 內部相對排序不變**（`u_i+c > u_j+c ⟺ u_i>u_j`），boost 只把整個 survival-class 集體拉過 development-class 天花板，不改變「該覓食/該掠奪/該投靠」誰贏的既有邏輯（那由 applicable gate + 各自 term 決定，一如既往）。**你設計是對的，不需要限縮到只加覓食/買糧**——縮小範圍反而會讓「真的只能投靠/掠奪才能活」的隊在該選項上仍卡在天花板下，選不出正確 survival 反應。
2. **FLOOR 低 vs 安全網沒接好的歸因糾纏**：同意用你已有的分離量測（驗收法已列 boost 觸發頻率獨立於 attrition headline 分開報）——若 boost 常觸發，是「上層安全網」的信號非「boost 本身」的信號，因為 boost 本身只是被動兜底，觸發頻率完全由層1/2/5 決定。measurer 兩者分開看即可歸因，不需要額外機制，**你 spec §驗收鐵律③已經寫「boost 觸發頻率＝健康指標」，方向正確**，不擋。
3. **與既有 coeff/commitment 疊加的量級失控 / 邊界抖動**：**唯一要求（阻塞措辭，非阻塞 dispatch）——boost 插入點必須明確寫死在 `u *= _coeff`（:29）★之後★，非之前**。理由：若插在 coeff 乘法之前，boost 會被 `_coeff`（下限 `COEFF_FLOOR=0.15`）打折——多數情況下真危機時 survival option 對 L_SURVIVAL 層 alignment 高、coeff 應已接近 1（不太會被打對折），但**你的 pseudocode 沒明確標插入點，implementer 若插錯位置**（如寫在 term loop 內、u*=_coeff 之前），boost 2.5 打 0.15 折只剩 0.375，起不到「碾壓 1.14」的保底效果——這是純實作序問題非設計問題，**要求 spec 補一行**：「boost 加在 `u *= _coeff` 之後、`+= COMMITMENT_BONUS` 之前或之後皆可（你已論證後者不敏感，同意）」。邊界 food_days≈FLOOR 附近連續（線性 ramp，`(FLOOR-food_days)/FLOOR` 在 food_days=FLOOR 時=0 平滑銜接），無 flip-flop 風險——commitment 是加法非乘法，不影響連續性。
4. **真根3 完整性**：見上 factcheck，純註解，無 code 依賴，**排除**。
5. **層0 是否使層2 人格化變冗餘**：**不會**——層0 是稀發生的保底（food_days<~2 才觸發），層2（日常安全存量 target）決定**多常**掉到那條線以下（謹慎隊幾乎不會、賭徒隊偶爾會）。兩層各司其職：層2 決定觸發*頻率*（人格化，慢的、日常的），層0 決定觸發*時保底有效*（統一的、快的、極端的）——拿掉層2，boost 觸發頻率會全體飆升（人人常態餓到 2 天），attrition 靠 boost 硬撐但 thrash/reeval 代價上升，違反你自己「boost 常觸發=安全網失職」的健康判準。**兩層都要**，非其一即可，判斷正確。

## 條件（唯一要求，寫死即可 dispatch）
- spec 補一行插入點：boost 必須在 `u *= _coeff`（decision_engine.gd:29 對應行）**之後**加，避免被 coeff floor 打折。

## 回報
CLEAN → 全 Slice A（層0+1+2+3+5+候選1+候選2）整包 dispatch。measurer v2(層1-2) 結果 moot，同意不半套驗。
（寄件永遠 open，你讀後改 consumed。）
