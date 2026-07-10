# Consolidation + 降服 統一決策 — 願景設計（blueprint WHAT）

> 2026-07-10 brainstorm 定案。blueprint 願景層（WHAT/意圖/湧現/地板）。HOW（term 公式/context 欄/seam）交 systems 出技術 spec。屬決策統一 program（同傘 rank_combat），[[project_unified_decision_framework]]。

## 一句話
隊的**合併**與**降服（附庸）不是獨立子系統，是同一顆統一決策腦（`DecisionEngine.rank_scored`）裡的新 option-set + 真實生存/人格 term**。food 驅動合併、脅迫驅動附庸——**核心驅力統一於 rank_scored 效用秤的湧現輸出**，退役 flat/特例驅力。

> **但書（reviewer 框外① 靶C）**：「核心驅力統一」不等於「零框外機制」。**跨隊同意的時序協調**（發起方 util 選 + 接受方 util 選的雙邊握手原子性）**待驗證是否需框外薄層**——單隊 per-cadence argmax 能否純腦內解決雙邊異步咬合是 open。承諾範圍＝**驅力**統一，非「連跨隊時序協調都無 bespoke」。避免 A2c-1「先講死強框、事後被 code 打臉」。

## 動機
- **小隊根**：organic combat 全小隊（殲滅不可見、pursuit pop-% 失效同根）。隊太小 → 任何 pop-比例效果悶。
- **未統一殘留**：`consolidate_drive` 現 return flat 1.0（「faction 機制非人格染色」）、`join_drive` 現只 `has_strong_neighbor` gate——**併決策沒進統一效用秤**，與飢餓/死活無關。
- 這是 combat 決策 hardcoded 的同型病（決策不統一），修法同型：收進 rank_scored 真 term 秤。

> **假設非事實（reviewer 框外① 靶A）**：「食壓驅不動合併→隊留小、故統一後隊會變大」是**待驗因果鏈假設，非既定事實**。三跳各有風險：(1) 餓隊 argmax 可能「覓食/掠奪/返家補給」等既有 survival option 先贏（併只是 8-option 之一）；(2) **餵養盲＝致命**：`_find_absorber` 零 food 檢查，餓世界吸附者可能自己也餓 →「併＝把餓稀釋進更大隊＝搬餓非解餓」，不解生存；(3) 隊變大→殲滅窄縫（雙勇均等）常觸，**無現成驗證路徑**。∴ 本設計是**假設驅動的實驗**，成敗以下 §驗收硬 gate 判，非先建先信。

## 願景骨架

### 合併＝雙向、雙方同意、同意含脅迫
- **雙向驅動（C）**：弱方求生 push（餓→找餵得飽的併）+ 強方擴張 pull（野心/統領力→吸弱隊）。誰的驅力先過 argmax 就發起。
- **雙方決策事件**：兩隊各在 rank_scored 秤；合併需雙方 util 都選它（發起 + 接受）。完美咬合統一腦。
- **「同意」含脅迫光譜**：voluntary（自願投靠）↔ coerced（脅迫歸附）。脅迫三態全要：①隱性生存數學（附近強隊/掠奪者→單獨會死，投靠活率高）②顯性最後通牒（強隊「歸附或開戰」）③戰敗附庸（敗局處置分支，保部分自主換不被殲/俘）。

### 降服後＝子隊式附庸（不池化），保留身份
- 附庸**復用 subteam parent-child 骨架**（宗主=`parent_team_id`，既有 merge/資產轉移/階層 code），**加**外來源 + 怨氣/忠誠 + 叛離層（子隊沒有的）。**非新概念，是 subteam 推廣**（守 01 judge 盤點：不重造）。
- 併後**留獨立身份**（政治從屬，不強制池化 pop）。
- **階級隨脅迫程度分（B+C）**：voluntary→鬆附庸較平等；coerced/戰敗→緊次等帶怨→**可叛離**。所有併都產生宗主-附庸關係（C），鬆緊/怨氣隨模式分（B）。

### 小隊根＝湧現解，非硬塞
- **不**強制附庸池化。pop 級合併是**隊自己的決策**（「讓他們自己做」）：食壓/生存數學逼 → 隊主動選全池化合併（走既有 `merge_teams`）。
- 隊變大 = 統一腦在食壓下的**湧現輸出**；食壓不逼則留小（合法世界態）。殲滅可見/pursuit 人格化隨隊變大自然浮現。

## Slice 拆（傘下，同型工）
| slice | 統一什麼 | 動作 | 解什麼 |
|---|---|---|---|
| **S-A（本 slice）併決策統一** | 整併/投靠 | 退 flat `consolidate_drive`/窄 `join_drive` → 真生存/野心/忠誠 term 秤；`_find_absorber` 餵養能力進 context | 小隊根（食壓→併大湧現） |
| **S-B（後續）降服決策統一** | 脅迫/歸附為附庸/叛離 | 新 option：強方脅迫、弱方秤打vs附庸、附庸秤怨氣vs依賴叛離；子隊骨架+怨氣層 | 附庸政治層湧現 |

本 slice = **S-A 併決策統一**。S-B（降服/附庸）獨立後續 slice。

## 地板守則（不可退化）
1. **決策交統一秤，非新 hardcoded 特例**：修法必須是「收進 rank_scored 真 term」，不得加補償閘/flat 驅力（否則重蹈 consolidate_drive flat 病）。
2. **食壓驅併是湧現非腳本**：不硬寫「pop<N 就併」；用生存 term 讓餓隊的併 util 自然升，argmax 湧現。
3. **既有三端/戰鬥行為不退化**：合併改變戰鬥規模是**下游湧現**（隊變大→戰更長→殲滅可見），非直接改 combat 公式。determinism/融合閘/憲法綠。
4. **不重造概念**：附庸復用 subteam 骨架（01 judge 盤點）。

## ★S-A 硬驗收 gate（reviewer 框外① 靶A，非事後量）
S-A spec **必須**把下列寫成 measurer 硬 gate（先驗、不過就打回，非先建先看）：
1. **餵養真解生存非搬餓**：併後吸附者+被吸的合隊，`food 餘裕/餘命`須**實質改善**（吸附者併前有真 surplus 才吸），非把兩個餓隊併成一個更大餓隊。measurer 量併事件前後合隊生存指標。
2. **隊變大真觸殲滅可見**：organic full_probe 量隊規模分布上移 + `end_annihilation` 是否隨之 >0（承敗北逃 arc 定案的殲滅窄縫）。若隊變大但殲滅仍 0 → 因果鏈第(3)跳斷，回報 blueprint 重估。
3. **併是湧現非腳本**：無硬寫 `pop<N 就併`；食壓 term 驅 argmax。三端/戰鬥不退化、determinism/融合閘/憲法綠。

## 交 systems 的 HOW（本 slice S-A）
- 生存訊號怎麼進 term：飢餓（food 存量 vs 消耗率/餘命）、威脅（打不過的鄰）怎麼量化餵 `consolidate_drive`/`join_drive`。
- `consolidate_drive` 退 flat：改人格×生存 weigh（野心低+餓→投靠 util 高；野心高→傾向當吸附方）。
- `_find_absorber` 納餵養能力（吸附者 food 餘裕 vs 被吸 pop 增量）+ 是否放寬同 faction 限制（跨勢力投靠？留 systems 評）。
- 雙方同意的「接受方」決策路徑（吸附方也要 rank 秤願不願收）。
- reviewer 框外①（大框 call 三對齊）→ spec-lock 前召異質 refute。

## 開放/後續
- S-B 降服全套（脅迫三態/怨氣/叛離）——獨立 slice。
- **★S-B 動工前置（reviewer 框外① 靶B）**：subteam 骨架多處硬假設 `parent_team_id==absorber_id` 且用途＝「同源子隊歸建」（`subteam_system.gd:185/192/198`、`_decide_subteam` duty-driven 歸建）。S-B build 前**必須先產具體 risk 清單**：外來降服隊塞此骨架會打破哪些既有假設（跨 faction parent_team_id 合法性？duty-driven 歸建對外來附庸誤觸？subteam_ids 雙向同步對外來隊？），確認「推廣非重造」撐得住，非到 S-B 動手才發現骨架撐不住。
- 跨勢力 vs 同勢力合併邊界——systems 評（現 `_find_absorber` 限同 faction）。
