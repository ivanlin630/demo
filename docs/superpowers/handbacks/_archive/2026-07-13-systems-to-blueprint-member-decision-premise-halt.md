---
from: systems
to: blueprint
status: consumed
topic: [★premise矛盾岔路·halt] R①抓錯:成員早已走_decide_unified(rank_scored),縫#3序6已結清;②-1「最大洞」不存在=我gatekeeper審漏loop1;需重定②scope
---

# premise 矛盾岔路：成員決策洞不存在（我審漏）

藍圖許可岔路(premise 矛盾)→halt 回報。R① 抓到我 premise 錯,自驗坐實。

## 錯在哪（誠實認）
- 我 gatekeeper 全圖說「faction 成員(faction_id!=-1)只跑戰略層,無個人日常決策=最大洞(縫#3)」。
- **坐實矛盾**：`_assign_member_tasks:1390-1410`(loop1,`_assign_tasks:639`→)**對每個非-subteam 成員呼 `_decide_unified(state,mt)`**(=merchant/producer 同一顆 rank_scored 統一引擎)。`:1402-1404` 註明「撤除舊 goal→task cascade→徵收/攻擊/掠奪/生產/貿易/生存 引擎 rank_scored 競秤(縫#3 結清)」。
- **成員早已走統一決策**(序6/A2c-1 某輪結清)。我 gatekeeper 審**只看 loop2**(成員段確不呼 `_evaluate_solo`)→**漏 loop1 `_assign_member_tasks`→`_decide_unified`**→誤判成洞。
- ∴ **②-1「成員無決策=最大洞」不存在**。整份 spec 的 slice 序(②-1 優先)倒。

## 決策路真圖（重新盤點修正）
- **_decide_unified(rank_scored 完整引擎)**：unified 隊(merchant/produce tag) + **faction 成員(非-subteam)**——皆走此,頻繁重評無 IDLE-gate。
- **_evaluate_solo**：獨立(faction_id==-1)非-unified 隊——cadence-gated(本 session cadence rework 修的)。
- **_evaluate_subteam**：子隊(lifecycle 特殊)。
- → **多數隊(unified+成員)早已統一走 rank_scored**。②「分流」真圖=**2-3 個 rank_scored 入口函式**(_decide_unified/_evaluate_solo/subteam),非「成員無腦」行為洞。

## 對 ②/⑦ scope 的意涵
- **②不再有行為洞**(成員已決策)。剩=**入口函式收斂**(_decide_unified/_evaluate_solo→單一核心)=**結構性**,非行為缺口。**架構紀律真問題**:各入口 rank_scored **之外**有無殘留「特判行動」邏輯?——我上輪 gatekeeper 審**不完整**(漏一整條路),不足以判。**需重新精確盤點三 loop 全部決策點**才知 ② 有無真收斂工作、在哪。
- **⑦釋放統一 premise 未受影響**(reviewer 確認)——四套 release 收斂仍值得做,且**不預設 ②優先**(②優先理由=最大洞,已倒)。

## 判斷請求（藍圖裁）
我 premise 認知有誤,不宜帶錯前提硬推。三選一:
- **A（推薦）**：先重新精確盤點三 loop 決策路全圖(哪條走 rank_scored/哪條有 rank 外殘留特判)→坐實 ② 有無真收斂工作 + 架構紀律真缺口在哪 → 再定 ②/⑦ scope 與序。**但這是「新查證」**——用戶剛喊停查證,故先問你要不要現在盤點,還是：
- **B**：跳過 ②(成員洞不存在、入口收斂是結構性可能低價值),**直接做 ⑦釋放統一**(真散落 4 套,premise 未倒),ready-to-build。
- **C**：②⑦ 都先擱,回到用戶要的「代表隊 trace 看行為 fidelity」(measurer 已在跑)為先,依 trace 顯示的真行為問題再定下一步。

我傾向 **B 或 C**:②的行為動機(成員洞)已證不存在,強推入口收斂=為統一而統一(且我審不全,風險);⑦ 是真散落值得做;C 讓用戶先看行為再定。**不建議 A**(又一輪新查證,撞用戶剛喊停)。你裁。

零跑至此(自驗 _assign_member_tasks:1410 坐實成員走 _decide_unified)。halt 待你裁 ②/⑦ scope。
