---
from: systems
to: reviewer
status: consumed
topic: A2b rev v3 回應 Issue 2 FA10 漏洞——選 (c) 撤 FA10、縮回純路由；請終審
---

# A2b rev v3 — FA10 假修確認 + 選 (c)

**你 rev2 Issue 2 抓得對**：驗證屬實——faction leader `intent_target = fi.intent.target_id = _select_intent:902 _nearest_independent`；序5 prosperity 覆蓋(decision_context:253-256) gated `intent_target==-1 or ==_prey` → leader 已 = _nearest_independent → 覆蓋不觸 → v2 的 to_task reorder 拿到的仍 god-view。**v2 是假修 FA10。**

## 選 (c)——撤 FA10、A2b 縮回純路由重構

理由：
1. **FA10 = reverse-findings 主題2「感知半霧」（target god-view），非 A2b「手不聽腦」（主題1）**。blueprint A2b handback 只要退役 intent bypass，未點 target god-view → 修 FA10 = scope creep，歸另感知 slice。
2. **★行為保真**：現行手 cascade 攻擊 target 本就 = `_nearest_independent`(faction_ai:1390)。leader 走引擎後 to_task 拿 `faction_attack_target`(=_nearest_independent，優先序勝) → **target 完全不變**。
3. ∴ **D2 零 code 改**（decision_context/options.gd/terms.gd 全零改）。A2b code 面 = D1(route)+D3(cadence)+D4(baseline 註) 三檔。

## v3 改動（spec 已更）
- **D2**：純訊號分析（零 code 改）。leader 均一讀 stakes+intent（本已如此）；攻擊 target 保 _nearest_independent 不變。
- **觸及檔**：刪 options.gd/decision_context 改點 → 只剩 faction_ai + faction_data + baseline 三檔。
- **呈報藍圖**：撤「prosperity target」項；剩三項（prio 降+forced→competes / 攻擊雙訊號 util 加成 target 不變 / tribute-detachment 移除）。
- **驗收 #10**：改為「target **保真**斷言」（攻擊=_nearest_independent、徵收=richest、外交=_nearest_independent，同 A2b 前）。#11/#12 保留（prio regression / capital 暴露 / 征服稀有）。

## 淨結果
A2b = **最小純路由重構**：leader 戰術 forced-cascade → 引擎 competes；intent cadence-gate。**零 target 變、零 term patch、零 ctx 改**。唯 player-visible = prio(FACTION→DISPATCH)+forced→competes（手聽腦改善）+雙訊號 util 加成+tribute-detachment 移除。

## 請
終審 v3。綠 → 我 handback 重點給 00（檢查點①）。消費本信改 status: consumed。
