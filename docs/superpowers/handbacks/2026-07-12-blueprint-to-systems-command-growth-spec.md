---
from: blueprint
to: systems
status: consumed
topic: [spec請求] 統領技能日常領導成長路徑——R②CLEAN，附精確化(評分懲罰非literal硬gate)
---

# 統領技能日常領導成長 —— 請出正式 spec（R②已CLEAN）

## 用戶裁定（WHAT，已點頭）
統領技能不該只能靠P4_expand(繁榮擴張reaction)練——**開日常領導成長路徑**：帶隊本身(leading a team/faction，不限food/stress狀態)隨時間/cadence微幅累積統領技能，作為新增的底層保底成長，**不取代**P4_expand既有路徑（繁榮隊仍可循此路徑額外/更快成長）。

## 真根（reviewer R②精確化版，非letter原始措辭）
- `skill_system.gd:13 REACTION_SKILL_MAP["P4_expand"]={統領,魅力}` — P4_expand是統領技能**唯一**growth來源。
- `reaction_system.gd:154-161 _score_expand`：`food>100 and stress<0.3 and 統領tag` **只影響base分**（0.55 vs 0.05），非硬gate——是**評分懲罰**：base壓到0.05後幾乎必輸給其他reaction的argmax，非literal impossible。
- `skill_system.gd:23-33 on_reaction`：growth只在reaction被argmax選中時fire——絕境隊P4_expand低base→幾乎不被選中→統領凍結，因果鏈成立（empirically恆0已確認，practically死鎖）。

## 設計約束（交你定HOW）
1. **帶隊判定**：`person.person_id==team.leader_id` 既有trivial比對，全codebase已用此pattern，無需新推導。
2. **成長速率**：明顯低於P4_expand（P4_expand≈+0.001~0.003/次，代表主動擴張決策練習）。日常路徑代表被動經驗累積，速率抓更小或同量級但低頻，讓絕境隊「終將爬過門檻」但非「立刻就過」——保留掙扎求生仍需撐過一段時間的遊戲張力，只拔除structurally practically永不可能那部分。
3. **cadence放哪**：由你評估現有tick結構決定（新增邏輯位置/觸發頻率）。
4. 未發現其他隱藏平衡假設綁定「統領只能靠P4_expand」——`REACTION_SKILL_MAP`只此一項map統領，無競爭。
5. **determinism**：這是行為改動非L3純觀測，預期改變數值結果，非regression bug——向measurer說明baseline位移（比照world-gen variety先例處理）。

## 序
出正式spec → measurer平行corroborate（leader統領技能12mo內實際爬升軌跡，pre/post對照）→ build → measurer驗established B2 gate_fail_b2_command是否從100%卡死變為有通過案例、established是否終於>0。
