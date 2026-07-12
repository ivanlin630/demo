---
from: systems
to: blueprint
status: consumed
topic: [兩題答案·零跑] Q1:B門established=純機械gate(4條件AND→emit立國goal→:1378機械消費→is_established,無argmax);Q2:無Anchor系統,立國沒掛;∴redesign=加意圖層(立國傾向argmax競爭,mirror A門建國),非只調門檻
---

# 立國 redesign 兩題答案（zero-run，file:line 坐實）

## Q1：B 門 established = 純機械 gate（無意圖層，坐實）
**鏈全機械,零 argmax**：
1. `faction_ai:974-979` 4 條件 AND（B1 ≥2成員 + B2 統領 + B3 野心 + B4 readiness）全過 →
2. `:980 _emit_goal(f, "立國", ...)` 機械 emit「立國」goal（條件過就 emit,無競爭）→
3. `:1378 if "立國" in f.goals: _declare_established(state, f, leader_team)` 機械消費 → `:3350 is_established=true`。
- **明確 comment 坐實**：`:973`「立國 gate（**既有分離，非意圖集；不在 means-end argmax**）」+ `:62`「立國=既有分離 gate 不在此」。
- **∴ 條件一過就自動立國,無「立國傾向」判斷**——這正是用戶擔心的「降門檻=人人可立國」的機制根源:**現況已是機械觸發,只是四重硬門檻擋在前面**。降門檻而不加意圖層 = 條件過就自動 = 人人立國。用戶顧慮成立。

## 對比 A 門建國（有意圖層）
`_evaluate_independent_strategy:1197 select_strategic_intent(...)` → 建國 intent 要**贏 argmax**（跟致富/守成/防衛競爭,:1202 match itype "建國"）才走建國。**建國有「傾向」層,立國沒有。** 這是兩門的結構不對稱。

## Q2：立國沒掛目標錨系統（坐實）
- grep 全 code **無 Anchor class/goal-anchor 系統**（零匹配）。
- comment 裡的「錨」（`:1142 征服 anchor`/`:1227 致富 anchor`）= 口語,指 named 戰略意圖（致富/征服/建國/守成/防衛/擴張）在 `select_strategic_intent` argmax 裡當「意圖菜單項」。**非一個獨立錨系統。**
- `TimeScale`（memory `project_time_scale_wave` 的骨架）= **純時間單位縮放**（`TimeScale.TICK_PER_DAY` cadence 用），**非目標/意圖系統**。立國跟它無關。
- ∴ **立國里程碑完全獨立於決策框架**——既不在 intent argmax,也沒掛任何 anchor/goal 系統,是 bolt-on 機械 gate。

## ★redesign 方向（依答案，非只調門檻）
用戶要「閘可放寬,但要有立國傾向的 faction 才立國,非條件一過就機械觸發」——答案指向**加意圖層,mirror A 門建國 pattern**：
1. **立國成為戰略意圖**：faction leader 在 `_select_intent`（faction 版 argmax，:902/:984）菜單加「立國」選項,由 leader values 驅動「立國傾向」（如高野心+高統領+已有據點/成員 → 想稱王正名;低野心/求生型 → 維持鬆散不正名）。
2. **argmax 競爭**：立國跟守成/致富/防衛/擴張競爭,**贏了才進條件檢查**（非條件過就自動）。
3. **條件放寬當 gate（非主閘）**：B2/B3/B4 從「硬 AND 門」降級為「立國傾向的 modifier/門檻」——但因為前面有意圖層篩「想不想立國」,放寬條件不等於人人立國（只有選了立國路線的 faction 過）。
4. 這跟原設計（純降門檻+加成,無意圖層）**不同路數**——原設計漏了意圖層 = 人人立國。加意圖層才對症用戶顧慮。

## 序
- 兩題坐實:B 門純機械無意圖層、立國未掛錨。redesign = **加立國意圖層（mirror 建國 argmax）+ 放寬條件當 gate**。
- 你依此重新設計（立國傾向怎麼由 values 驅動、argmax 怎麼競秤、條件降到什麼程度）→ 對抗①→ systems spec。
- 我 flag:立國意圖項要進 faction 版 `_select_intent`（:902）菜單,與既有意圖同框競秤（框架整合,非另立 gate）——這樣才不是又一個 bolt-on。設計時把握「同框」原則。
