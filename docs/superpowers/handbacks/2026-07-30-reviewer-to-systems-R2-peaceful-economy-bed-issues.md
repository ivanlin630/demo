---
from: reviewer
to: systems
status: consumed
topic: "[R②異質 ISSUES] 和平經濟床①founding情境confound——material≈0對無outpost隊是因果惰性設定(need_keep(material)恆=0)，不fire是code可預判的必然非待測經驗問題；②④設計乾淨、③料窮邊risk同款，需訂正才開工"
---

# R②判決（異質，直接refute）：和平經濟觀測床 HOW — ISSUES（①必修，③一併查）

召異質 + 我自己逐行複驗。**先訂正我自己上一輪的懷疑方向**：我原本疑心「①情境全隊 `faction_id:-1`，會不會連 `_evaluate_infrastructure`（真正的『蓋新outpost』分支，faction_ai:3175-3183）都碰不到，因為那函式只在 `for fid in state.factions` 迴圈跑（3130/693-694），independent隊永遠進不去」——這個懷疑本身**方向錯**：親查 `_evaluate_solo`(1920)/`_decide_unified`(1927) 對 `faction_id==-1` 隊照跑、`DecisionEngine.rank_scored`(decision_engine:48-53)呼 `frontier_candidates`無faction閘、`goal_resolver._resolve_resource_prereq`(:192-219)本身就有「缺料+無該地形outpost→派子隊建civilian outpost」這條路（:212-219 comment 明寫「★A1founding」），means-end 通路對 independent 隊是通的，我原本的懷疑不成立，撤回。

## ★但親自複驗抓到更深、更嚴重的一條——①情境本身是 causally 死路
`goal_resolver.gd:197`：`if effective_holding(...,res) >= NeedOracle.need_keep(...,res,...): return {}`——這行**在**買/採兩個分支之前，先判「前置已滿」就直接空手回。

親查 `need_oracle.gd`：`need_keep(material) = _self_use + _supply_chain + _construction_facility_need`：
- `_self_use`(:105-114)：`material ∈ PURE_INTERMEDIATE`(:100)→**恆 0**（純中間品需求全走供應鏈，:111-112）。
- `_supply_chain`(:119+)：材料需求靠隊「有的設施」的配方反推缺口——沒有任何設施的隊，`out_maxcoef`空 →**恆 0**。
- `_construction_facility_need`(:33-39)：`own_pos = _find_own_outpost(...)`，**沒有自家 outpost 就在:39 early-return 0**。

**三項對「無 outpost 的隊」全部恆等於 0**——`need_keep(material)=0`。①情境設定 `material≈0`：`holding(0) >= need_keep(0)` → `0>=0` 為真 →`_resolve_resource_prereq`**在197行就吐空**，連買（200行）跟採@地形/founding（206-219行，正是本情境要測的那段）都碰不到。

**這代表**：①情境把「隊的material持有量」設成0，但對沒有outpost的隊而言，這個引擎壓根**不認為material是需要的東西**（need_keep結構上恆為0），跟持有量多少完全無關——holding=0跟holding=9999對決策狀態是**一模一樣**。①情境的自變量(material≈0)對它想測的行為沒有因果連結，**不fire是讀code就能預判的必然結果，不是等資料回答的經驗問題**。這比「confound」更嚴重——這輪 Step0 的整個立意是「別用訊號理論式pivot，用資料裁分支」，但①這樣設計，資料還沒跑就已經知道答案，跟「先量confound」的初衷矛盾（用一個必然不fire的情境去論證「動機機器壞」，論證力等於零，還可能被拿去支撐一個本不該發生的pivot）。

## 要求（①必修，二選一）
1. **改情境設定**：①隊改成**已有一個非森林的outpost**（material=0 但該outpost有設施缺料需求，讓 `_construction_facility_need`能量出非0的need_keep），forest tile擺在別處——這樣「該去forest outpost拿料 vs 去市場買」才是活的決策分支，不fire才有診斷力。
2. **改措辭誠實化**：不改情境，但spec明講①在測的其實是「material需求 bootstrap gap（無outpost→need_keep(material)恆0→無論持有多少都不會想要）」這個**已經讀code就能坐實的既知缺口**，非開放經驗問題——不能再寫「兩者皆不fire=動機壞」這種暗示需要跑數據才知道答案的措辭。

系統選哪條都行，但**現狀①的文字不能照原樣開工**。

## ②④設計乾淨（對照組，佐證①是特例非普遍問題）
②情境隊已有 `outpost level 1`→`_find_own_outpost`成功→`_construction_facility_need`能正常量出非0 need_keep→設施升級是活分支，測得出東西。④靠 food 軸（`_self_use(food)`本身非0，非outpost-gated）→runway機制驗證乾淨。

## ★③交易情境——料窮邊有同款risk，需查
③「食富料窮 ⇄ 料富食窮」配對——**食物軸**沒事(`_self_use(food)>0`不需outpost，買糧候選在:200-203正常生成)。但**料窮那一側如果也沒有outpost**，會踩①同一顆雷：`need_keep(material)=0`→不會生成「該去買material」的候選，③想測的「對缺口有反應」在material這條軸上可能是啞的。要求：確認③的料窮隊是否已有outpost(理由同①修法1)，沒有的話一併補上。

## 判決
**ISSUES → `to:systems`。** ①必修（二選一）、③料窮側一併查。②④維持原設計不用改。這輪異質抓到的問題比我自己原先懷疑的更根本，值得在 implementer 動工前解決——不然量出來的「①不fire」數字會被誤讀成「有意義的空資料」，實際上是必然結果，反而污染了 Step0 想避免的「訊號理論式pivot」風險（用一個假經驗問題包裝一個真code-provable已知缺口）。
