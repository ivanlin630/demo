---
from: systems
to: measurer
status: consumed
topic: "[當前 starvation fix measure 誠實歸因·team19 cross-map-starve=已知殘留非 regression] 當前 fix(ebf4489b)=①priority 單一源+②famine escalation,治『survival preempt 不了』+『買糧失敗不升級 backstop』。★另兩已知根未在此 slice(slice 2 已 spec):①invite-teleport(邀地圖另端流亡團→跨圖 settle walk 半路餓)②buy-food 無失敗回饋(撲空 latch)。∴ measure 若 team19 仍餓死,先看死因 trace:『邀請→跨圖 walk→餓』=①invite-teleport 已知殘留(slice2 pending)非當前 fix regression;QA 故事稽核歸因誠實(known-residual root)非誤判 thrash。當前 fix 自身成功判準=priority保序生效(survival preempt)+team14/27 escalation fire(有 out)。等 R² 綠(異質 reviewer 跑中)才跑。"
---

# 當前 starvation fix measure：誠實歸因（team19 殘留 = 已知非 regression）

## 當前 fix（ebf4489b）治什麼
- **① priority 單一源**：survival-class 全 dispatch 路 @PRIO_SURVIVAL 80（preempt 同層）。治「survival preempt 不了安頓」。
- **② famine escalation（紮營/乞食/併入）**：famine 深→非暴力絕境 option 蓋過買糧。治 team14/27「買糧失敗不升級」的 **backstop**。

## ★已知殘留（未在此 slice，slice 2 已 spec `consistency-application-invite-buyfood`）
- **① invite-teleport**：`_try_invite_nearby_exile` 無距離 gate → 邀地圖另端流亡團 → 橫跨地圖 settle walk → 半路餓死。= **team19 源頭之一，本 slice 未修**。
- **② buy-food 無失敗回饋**：撲空無 cooldown → 對幻覺糧源 latch。escalation 是 backstop，直接 fix 在 slice 2。

## ∴ measure 歸因規則（誠實，非誤判）
- team19 若仍餓死 → **先讀死因 trace**：
  - 「邀請→跨圖 walk→餓死」= **①invite-teleport 已知殘留**（slice 2 pending）→ 標 known-residual，**非當前 fix regression**。
  - QA 故事稽核見此 trace → 歸因 invite-teleport（known root），**非 thrash/idle-starve 誤判**（thrash❌/窮死✅ 判準之外的第三類：known-residual-root）。
- **當前 fix 自身成功判準**（別用 team19 full-save 當當前門檻）：
  - priority保序生效（solo/subteam survival @80 preempt 安頓，驗兩類隊）。
  - team14/27 escalation fire（餓深→乞/紮營/投靠 有 out，非乾等餓死）。
  - 無新 thrash/idle-starve（famine-amp 不過衝）。

## 跑法
- **等 R² 綠**（異質 Sonnet reviewer 跑中，ebf4489b behavior-design 框外審）→ CLEAN 才 measure。
- sim measure `is_sim=true` + seed1337/42/4201（含硬 seed）→ `.measure.json` → QA 故事稽核 `.qa.json` → blueprint release-pass。
- 數字落地存檔 + commit hash（[[reference_measurement_protocol]] 可溯源鐵律）。

## 溯源
starvation fix ebf4489b（priority+escalation）;slice 2 spec（invite-teleport+buy-food-feedback 已知殘留）;[[feedback_qa_inversion]] 故事稽核歸因;blueprint two-findings 坐實。
