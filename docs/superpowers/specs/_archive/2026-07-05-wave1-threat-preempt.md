# Spec：wave1 序3.5 — threat preempt（接 approach→感知→反應因果脊椎）

> 藍圖 threat-preempt-greenlight 裁定。反龜縮 bar：忙碌目標對壓境攻擊者盲=seam 斷（measure 坐實）。**接既有 offensive→defensive，非新機制。** 系統 owner。

## 1. 問題（已診斷坐實）
`_evaluate_threat` idle-gate（fai:375 `if current_task != IDLE: return`）+ unified idle-skip → **忙碌目標永不評威脅**。live measure：IDLE 目標遇逼近敵→反應；BUSY(生產)同威脅→無反應（續製造）。序2/3 後隊多在忙 → 攻擊目標 defensive≈0 = offensive 22.5% 不對稱主因。

## 2. 目標
強威脅 **preempt 非緊急進行中 task** → 忙碌目標感知壓境攻擊者 → defensive 反應（逃/備戰/求和/守）。門檻鎖「真能傷你」非「見武裝」。

## 3. WHAT bar（藍圖，納驗收）
- 犁田遇劫匪殺到→放犁；犁田遇路過弱/中立/帶刀商隊→**續犁**（不抖動）。
- preempt 門檻吃**相對戰力壓制+逼近+敵意**（序1 `threat_react` = `ThreatAssessment.score` 已含 approach+hostility+(power_ratio−1)·0.5，×dist_factor）→ 高門檻天然要求「能真傷你」才觸發。
- 反面守：禁「見武裝就 preempt」（task 抖動+單調恐慌，比龜縮糟）。
- 不 preempt 已緊急（戰鬥/逃/守/survival）。
- **★感知鐵律（藍圖 encounter-north-star，硬約束）**：preempt 門檻只讀 `threat_react`（=belief 表象 pop/armed_est + `known_reputations` 敵意 + observe_velocity 逼近）——**禁偷讀逼近者 `tags`（商隊/軍隊）或意圖打折**（「喔商隊放鬆」=把可信度弄回 bug）。反向守（弱/中立/帶刀商隊不 preempt）**必須由 threat_react 低分自然滿足**（弱=power_ratio<1、中立=hostility≈0、路過=approach≤0），**非讀 tag 判**。融合驗反向 case 的「帶刀商隊」設定用 rep+武器+非逼近表象，不設 tag 打折。

## 4. 設計（改 _evaluate_threat gate，序1 scaffolding 擴充）

現 gate（fai:375）：`if team.current_task != TASK_IDLE: return`。改為區分 idle / busy-preemptible / busy-urgent：

```gdscript
# REVOLT + DEFEND/PREPARE/FLEE/HOLD release 檢查（不變，在前）...
var _busy_preemptible: bool = team.current_task in PREEMPTIBLE_TASKS
# 忙碌且不可 preempt（戰鬥/緊急/social）→ 不評（原行為）
if team.current_task != TeamData.TASK_IDLE and not _busy_preemptible: return
var ctx: DecisionContext = DecisionContext.gather(state, team)
if team.current_task == TeamData.TASK_IDLE:
    if uses_unified(team): return              # idle unified 由 _decide_unified 主 rank（不變）
    if ctx.threat_react < ctx.threat_threshold: return   # 一般門檻
else:                                          # busy_preemptible
    if ctx.threat_react < _preempt_threshold(ctx): return   # ★高門檻「能傷你」
# dispatch via rank_threat（preempt 對 unified/非 unified 一致走 threat repertoire）
for opt in DecisionEngine.rank_threat(ctx): ...   # 既有序1 dispatch 迴圈
```

### 4a. PREEMPTIBLE_TASKS（非緊急可打斷）
```gdscript
const PREEMPTIBLE_TASKS := [
    TeamData.TASK_MANUFACTURE, TeamData.TASK_BUILD, TeamData.TASK_TRADE,
    TeamData.TASK_GOVERN, TeamData.TASK_TRAIN, TeamData.TASK_FORAGE,
    TeamData.TASK_MOVE, TeamData.TASK_CAMP,
]   # 不含：ATTACK/LOOT(戰鬥)、FLEE/DEFEND/PREPARE/HOLD(已 threat)、REVOLT、JOIN/BEG(social 進行中)、survival
```

### 4b. `_preempt_threshold(ctx)`（高門檻，鎖「能傷你」）
```gdscript
func _preempt_threshold(ctx) -> float:
    # 一般門檻上疊 preempt 加成：只有壓制級威脅(power_ratio>1 貢獻大 + 逼近 + 敵意)才打斷工作。
    return ctx.threat_threshold + PREEMPT_MARGIN   # PREEMPT_MARGIN = TEST VALUE(建議 0.5)
```
- 一般 threat_threshold ≈ 0.3+慎重·0.3（0.3–0.6）。+PREEMPT_MARGIN(0.5) → preempt 需 threat_react ≈ 0.8–1.1。
- `threat_react` 組成：路過弱商隊（power_ratio<1 → 負貢獻、neutral hostility≈0、非逼近 approach≤0）→ 低分 → 不 preempt ✓；壓境敵軍（power_ratio>1、approach=1、hostility=1）→ 高分 → preempt ✓。**門檻天然實現「能傷你」語意**（藍圖 WHAT bar 由 threat_react 訊號組成滿足，非另加 tag/label 判斷）。

### 4c. TaskArbiter 優先序
preempt dispatch 走 `PRIO_THREAT`（序1 既有）。**確認 `PRIO_THREAT > PRIO_DISPATCH/PRIO_AMBIENT`**（preemptible task 多 PRIO_DISPATCH/AMBIENT 派）→ try_set 成功打斷。若優先序不足 → 調（實作驗）。

### 4d. unified 忙碌隊
idle unified 仍 skip（主 rank 管）；busy-preemptible unified 走 preempt path（rank_threat dispatch）——因 _decide_unified 忙碌時不重跑，preempt 是唯一即時感知路。preempt 後 PRIO_THREAT task 由既有 release 檢查（威脅消失回 idle→主 rank 復管）。

## 5. 融合驗（`threat_preempt_check.gd`，藍圖雙關）
- **該出現**：忙碌目標（current_task=生產/建設/貿易）+ 壓境能殺攻擊者（power_ratio>1、逼近、敵意）→ assert 放下 task、派 defensive（逃/備戰/求和/守）。（本 diagnostic 腳本 `scratchpad/threat_seam_diag.gd` 即驗胚，正式化。）
- **★反向守（防抖動，藍圖核心）**：忙碌目標 + 路過**弱**攻擊者（power_ratio<1）→ assert **續 task 不 preempt**；+ **中立**帶刀商隊（hostility≈0、非逼近）→ **續 task**；+ 逼近但**弱** → **續 task**。三反向皆綠=「見武裝就恐慌」防線成立。
- **回歸**：seeded（現 48/8/1/380，preempt 會升 defensive 反應→漂移允許 QA wave 判）+ framework PASS=7 + threat/solo/rung 融合驗不破 + 憲法閘。**live-seam threat（序3 加）仍綠**。
- **★對齊反龜縮**：seeded defensive threat dispatch 應從 ≈0 回升（忙碌目標現會反應壓境攻擊）——記錄前後（連 offensive 22.5% 的下游該顯化）。

## 6. 憲法閘
改在 `_evaluate_threat`（既有指紋），try_set 仍此 func → 指紋不變。閘應無變，實作確認。

## 7. 待藍圖 / 後序
- **無新 WHAT 待裁**（preempt 門檻 WHAT bar 已定，threat_react 訊號滿足）。PREEMPT_MARGIN=TEST VALUE 待 wave QA 校（抖動 vs 反應靈敏度）。
- spec → plan（融合驗雙關 TDD-first，反向守優先）→ 子 session。序3.5 綠 → 續序4 vendetta（已平行可起）。
