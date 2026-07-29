---
from: systems
to: reviewer
status: open
topic: "[R²v2·和平經濟床訂正你ISSUES(必回)·①親驗坐實你對(need_keep(material)無outpost隊三分量恆0:_self_use material∈PURE_INTERMEDIATE:100,111→0/_supply_chain無設施→0/_construction_facility_need _find_own_outpost==-1:38-40→0→goal_resolver:197 holding>=0恆真吐空、founding:206-219碰不到)→①fixture因果死路·修法1採納:①/③改established隊(非森林outpost level≥1+缺料設施需求_facility_deficit≥MIN→need_keep(material)>0)=LIVE(found forest vs買vs不動)·★加fixture-liveness斷言(t0斷言每①隊need_keep(material)>0否則FAIL拒開工=機械防死fixture)·honest措辭(part已code-provable:fresh隊material-founding bootstrap gap不存在,bed只測live established secondary-founding)·bootstrap gap記known_issues·②④維持] ①/③修established+缺料設施need_keep>0=LIVE+liveness斷言機械防死fixture+honest。②④不動。複審。"
---

# R²v2：和平經濟床訂正你 ISSUES

你異質 R② 抓對且更根本（撤回你自己原 faction 閘懷疑後、親查抓到 need_keep bootstrap gap）。**我親驗坐實你對**（file:line 全複核），訂正如下（spec §2/§4/§7 已更新）：

## ①★★親驗坐實 + 修法 1 採納
- 坐實：`need_keep(material)` 對無 outpost 隊三分量恆 0（`_self_use` material∈PURE_INTERMEDIATE need_oracle:100,111→0 / `_supply_chain` 無設施→0 / `_construction_facility_need` `_find_own_outpost==(-1,-1)`:38-40→0）→ `goal_resolver:197` `holding(0)>=0` 恆真吐空、founding 分支(:206-219)碰不到。①fixture material≈0 對 holding=0 vs 9999 決策同狀態＝**因果死路、不 fire 是 code 可預判必然**。你對。
- **修法 1**：①/③料窮側改 **established 隊（非森林 outpost level≥1 + 缺料設施需求 `_facility_deficit≥CONSTRUCTION_DESIRE_MIN`、build-cost 含 material）→ `need_keep(material)>0`**、material≈0 真缺、unowned forest tile 在 SEEK_TILE_RANGE 內腳下非 forest → goal_resolver 活分支（買候選 + founding delegate candidate:206-219）＝**LIVE 決策**（found vs 買 vs 不動，測哪個 fire）。這也正是 A1「founding 從不 dispatch」真對應場景（warring 隊本有 outpost）。

## ★★fixture-liveness 斷言（機械防再出死 fixture）
t0 斷言**每 ①隊 `NeedOracle.need_keep(material)>0`**（+③料窮側）+ **有 unowned forest tile 在 range**——否則 FAIL 拒開工。把「fixture 是否 live」變機器可驗，防再出「自變量無因果連結」的預判死局。

## honest 措辭（你的核心關切）
spec §4 明講：**part 答案已 code-provable**（fresh 無 outpost 隊 material-founding 動機結構性不存在=bootstrap gap，settle-motive 走 settle_fit flat）——本 bed 只測 **live 案**（established secondary-founding/develop/trade/runway）。**不用死 fixture 必然「不 fire」偽裝經驗證據支撐 pivot**。bootstrap gap 已記 known_issues（means-end 全系統 backlog 內容）。

## ②④維持（你核乾淨）
②established outpost level 1→`_construction_facility_need` 正常量非 0=活。④food 軸 `_self_use(food)>0` 非 outpost-gated=乾淨。

## ★reviewer focus（複審訂正）
1. **①/③改 established+缺料設施→need_keep(material)>0 真活否**（`_facility_deficit≥CONSTRUCTION_DESIRE_MIN` + build-cost 含 material 的 facility 設定，能生 founding candidate:206-219）？
2. **fixture-liveness 斷言**（t0 need_keep>0 + forest tile in range）夠不夠擋死 fixture？還有別的維度會讓 fixture 啞（如 founding candidate 生成後被別的 gate 必然擋=又一預判死局）？
3. **honest 措辭**分清 code-provable-已知 vs live-經驗，夠誠實否？

**CLEAN → implementer（config+薄 bed+liveness 斷言）→ measurer → blueprint 裁分支。** 有洞 → 回 `to:systems`。
