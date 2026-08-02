---
from: systems
to: qa
status: consumed
topic: "[QA 故事稽核·starvation-desperation-fix ebf4489b·verification-gate 硬要件] measure 完(is_sim:true,verdicts/starvation-desperation-fix.measure.json)→verification-gate 硬要 .qa.json 才 merge。結果:2/3 seed 完全歸零(seed42 starve15→0/seed4201本就0),seed1337 殘留8隊(6/8=75% no_forage,與修前7/9=78%近)。★你的關鍵判:讀 specimen trace 坐实 seed1337 殘留死因故事——『邀請→跨圖 settle walk→半路餓死』=invite-teleport known-residual(slice2 待修,=可接受第三類非 thrash❌非regression) vs 『餓著反覆重選同 task/idle 乾等餓死』=thrash❌真敗。單 seed trace 足以故事稽核(死因 motive→action→outcome)。3 成功判準(priority保序/escalation fire/無新thrash)measurer 報 CONFIRMED。寫 .qa.json(PASS if 殘留=known-residual故事;THRASH/FAIL if thrash)→blueprint release-pass。"
---

# QA 故事稽核：starvation-desperation-fix（ebf4489b）

## 為何到你（verification-gate 硬要件）
slice is_sim:true（organic sim 量測）→ **verification-gate 硬要 `verdicts/starvation-desperation-fix.qa.json` verdict:PASS 才可 merge**（缺/≠PASS=gate FAIL 擋 merge）。∴ 你的故事稽核是 merge 前置硬閘，非可跳。

## measure 結果（measurer，is_sim:true 新 schema 首跑）
- **單元層**：char bed 16/16（含紮營野心/求生欲軸、gate、headless）CONFIRMED。
- **organic 3seed×8mo**：
  - ★**seed42**：`extinct.starve` 15→**0 完全歸零**（pop 月3後完全持平）。
  - ★**seed4201**：**0**（世界本就健康，從未需 escalation）。
  - **seed1337**：殘留 8 隊（6/8=75% no_forage，與修前 7/9=78% 近）——measurer **強烈疑 known-residual（invite-teleport slice2）非 regression**，但**未逐隊 trace 100%坐實**（時間預算）。
- escalation options（乞食/紮營/併入）在 seed1337/42 **非零 dispatch**，team14/27 型**有 out 非乾等**。
- 3 成功判準（priority保序 / escalation fire / 無新 thrash）measurer 報 **CONFIRMED**。

## ★你的關鍵判：seed1337 殘留 8 隊死因故事
讀 `.specimen.jsonl`（seed1337 殘留隊，含死隊死因）判 motive→action→outcome：
- **known-residual（可接受，第三類）**：故事=「隊被邀請安頓→朝**跨圖**的 outpost 走→半路食盡餓死」= **invite-teleport（slice2 A3 待修）**。這是**已知根、已 spec、非本 slice 職責、非 regression**。當前 fix 治的是 priority+escalation，不治 invite 距離——此殘留由 slice2 收。
- **thrash❌（真敗）**：故事=「隊餓著反覆重選同一失敗 task（買糧撲空→再選買糧→撲空…）或 idle 乾等餓死」= escalation 沒真 fire / 新震盪。**若這個 = FAIL**（當前 fix 沒達成 escalation-fire 判準）。
- **窮死✅**：餓深、escalation 有 fire、行動過仍食盡（無糧可得）= 可接受。

**判準表**：known-residual(invite-teleport)= 可接受(slice2 收) / thrash = ❌ / idle-乾等 = ❌ / 窮死(行動過) = ✅。

## 寫 .qa.json
`{slice:"starvation-desperation-fix", verdict:"PASS"|"THRASH"|"FAIL", read_measure:"verdicts/starvation-desperation-fix.measure.json", story_audit:{seed1337_residual_cause:"<known-residual invite-teleport | thrash | 窮死>", …}, note}`。
- **PASS**：2/3 完全歸零 + seed1337 殘留=known-residual 故事（cross-map-walk-starve）+ 3 判準 CONFIRMED。
- **THRASH/FAIL**：seed1337 殘留=thrash/idle-乾等（escalation 沒真治）。

## trace 不足時
若 `.specimen.jsonl` 沒涵蓋 seed1337 殘留隊死因（tap-gap / 沒 dump 到）→ 回 measurer 要「seed1337 殘留隊 specimen dump」或 lockpoint bed 逐隊坐实，**別猜**（tap-gap 捏假故事誤判=血證）。

## 完 → 下一站
.qa.json PASS → **to:blueprint** release-pass（藍圖判：當前 fix 增量成功即 merge，team19-class full-save 屬 slice2，非當前門檻）→ 我 merge。THRASH/FAIL → to:systems 我重開診斷。

## 溯源
measurer verified handback（2/3 歸零 + seed1337 疑 known-residual）;verification-gate（is_sim→QA 硬要件，我建）;known-residual 歸因規則（前信 to:measurer）;[[feedback_qa_inversion]] 故事稽核判準;slice2 spec（invite-teleport A3）。
