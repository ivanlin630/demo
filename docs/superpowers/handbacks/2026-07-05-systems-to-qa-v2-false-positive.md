---
from: systems
to: qa
status: open
topic: V2「征服1529→0脊椎斷」=假陽性(我bed探針配對錯);measure定論=征服行為真fire(攻擊2/捕俘3/同化2/交戰10);請重判V2出矛盾類;殘=commander directive路0貢獻=🟡未知(探針follow-up);blueprint修序去V2
---

# V2 measure：假陽性（探針配對錯，非脊椎斷）

用戶指示「先量」。measure 完，**V2 撤下 🔴矛盾**——根因是我 sufficiency_bed 的探針配對錯，非世界斷鏈。誠實揭：bug 在我機器裡。

## 根因（率表列採錯 counter）

- 率表「意圖→行為 征服」列：want=`intent.sel_征服`（全征服選擇）、feasible=`conq.intent`、happened=`conq.winner_prosperity`。
- **`conq.intent`(faction_ai:1519) 只在 `_decide_unified` 且 `_solo_type=="征服"` bump**——而 `_decide_unified` 只跑 `uses_unified` 隊（**TAG_MERCHANT/TAG_PRODUCE**）。武力征服隊幾乎不帶那 tag → conq.intent≈0 **by construction**。碼註解 1569-1570 早明寫「winner_prosperity≈0 由 construction」——這對探針本為舊「征服名實」measure 設計，被率表誤採當轉化分母。
- 即：want=1529（commander 選征服）vs feasible=0（unified 隊）= **量不同族群**。假陽性。

## 數據坐實：征服行為真 fire（同世界同跑，seed1337 6月）

```
intent.sel_征服          = 1529   (100% commander;conq.declared=0=無獨立征服宣告貢獻)
conq.intent (率表舊feas)  = 0      ← 假陽性根
── 真征服行為 counter ──
conq.prosperity_reached  = 2      攻擊真派出
conq.combat_entered      = 10     真交戰
conq.combat_decisive     = 1
conq.retreat_captured    = 3      俘虜真發生
捕俘 capture/戰 = 0.3、同化 = 0.667   (率表自己也顯示>0)
```

征服→攻擊→俘虜→同化 鏈**明明在跑**。**V2 非脊椎斷。**

## 已修機器（我 lane，L3 純觀測，merged 73d167f）

- +`conq.member_atk_eligible`/`member_atk_dispatch`（faction_ai:1486，commander 征服 directive→成員 faction_goal 攻擊路徑，舊零 counter）。
- 率表征服列 feasible→`member_atk_eligible+declared`、happened→`member_atk_dispatch+prosperity_reached`（`_cnt` 加 `+` 求和）。
- 零 sim 行為變：seeded warring 47/8/1/380 不變、headless DONE、framework 前綠。

## 修正後的率表列 + 浮現的窄真問題

修正列 = **1529/0/2**（want/feas/hap）。happened=2>0 → **證非斷鏈**（撤矛盾）。
**但 feasible=0**（`member_atk_eligible=0`）：commander 征服 directive→成員攻擊(faction_goal 路 1486)**0 貢獻**，真征服 2 次全走**獨立 prosperity 路**。

→ 這是 **🟡未知**（非 🔴矛盾）：commander-directive 征服轉化路是**死碼** vs **只 2 established faction 太少沒觸發**，需一個 probe follow-up 分辨（查 established faction 數 + 其成員有無 攻擊 tag-weight）。**非阻塞、非塌房**（征服有路=獨立 prosperity）。

## 請 QA

1. **V2 出 🔴矛盾類**（行為 fire=非斷鏈，判準「合理可解釋」）。
2. 新增 🟡未知一條：commander-directive 征服路 0 貢獻（探針 follow-up 待排）。
3. 重發修正判決表給 blueprint（**修序去 V2**，真矛盾剩 V1 貿易/V3 accept/V4 envoy）。

## 給 blueprint（QA 轉，或逕讀）

修序名單縮：**V1 貿易（卡你 LOD/carrier 兩裁權）仍首**、V3 提案 accept=0、V4 envoy(LOD 同根)。V2 除名。V2 的窄殘（commander 征服路）=探針 follow-up，我可順手排。

## 方法論註（measure-first 又贏一次）

QA 代碼推理標 V2「最大 gap 脊椎斷」——measure 翻。同型教訓：藍圖 reachability/net0 前提兩度被 measure 翻（[[feedback_session_roles]] 兩層制）。**率表 harness 自身的探針配對也要驗**（機器會錯，這次錯在我 bed）——列了充足性率表不代表每列 counter 配對對，新率表列該附「同世界真行為 counter 交叉驗」。已記，建議入 QA checklist：判「斷鏈」前先問「feasible counter 是否量同族群」。
