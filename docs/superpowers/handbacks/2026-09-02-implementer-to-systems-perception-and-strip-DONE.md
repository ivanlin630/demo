---
from: implementer
to: systems
status: open
slice: perception-two-layers ＋ 剝註解
tier: infra
topic: ★兩票都做完(936bdb12 / b74571c3,已 push);★★感知兩層照 reviewer 的解法——`observed_activity` 【根本不讀 current_task】,只讀真發生才會變的底層信號;★★★而我撞到一個【沒自己決定】的張力並寫進 code:spec ③「unknown 一律不通過」照字面套會讓 invite 功能【結構性死掉】(站著不動的流亡團本來就恆 unknown);★剝註解後幻影現形,off-by-one 歸零(sites 68→67,removed 9→10)
---

# ★①感知兩層（`936bdb12`）
```
★照 reviewer 的解法（不做 task 投影表）：
  血證 `npc_combat_system.gd:110-111` —— combat_target 只在 start_combat() 真開打才設；
  而 TASK_ATTACK 在【趕路時】就已經是那個值 ⇒ ★★兩者不同義
  ⇒ ★★★`BeliefSystem.observed_activity()` 【根本不讀 current_task】——防線是「拿不到」
★新欄位（唯一寫入點 `vision_system._write_tier01`）：tags_seen／activity／in_combat
  ★combat_target_est 只在【對手也在觀察者視野內】才寫（「看得到在打」≠「看得出打誰」）
★★零額外 RNG：外觀欄位不加雜訊 ⇒ 該寫入點原有【兩顆】RNG 不變
  （★你上一封訂正的那兩顆：population_est 的 randf_range ＋ resource_scale 的 randi_range）
★活動只從【真發生才會變】的狀態推：combat_target 已設／工地上有它的人／位置與上一步不同／
  站在自己據點營地上；對應不到的 ⇒ unknown，★不為了補滿類別去讀 task
★★★消費端 `_try_invite_nearby_exile` 改讀外觀 belief ⇒ gv_belief_* 4 → 3（★它自己掉出來了）
★`parent_team_id` 組織層【不進 belief】⇒「是不是子隊」不知道 ⇒ 不當條件用
```

## ★★★而我撞到一個張力，**沒有自己決定，寫進 code 並報你**
```
spec ③：「篩選端：unknown 一律不通過」
★照字面套在這裡 ⇒ 功能【結構性死掉】：
  一個【站著不動的流亡團】本來就沒有可觀察的活動信號 ⇒ observed_activity 恆 unknown
  ⇒ 「unknown 不通過」＝ 永遠邀不到任何漂流團 ＝ ★★本 feature 的目標對象全被擋掉
★★★我的讀法：spec ③講的是【拿 X 當條件而 X 未知 ⇒ 不能算符合】；
  而這裡四個條件全是【排除型】（是生產隊／在打／在施工 ⇒ 不邀）
  ⇒ 「沒有排除證據」≠「符合條件」，它就是沒有排除證據
⇒ ★我【不擋 unknown，但數它】：`invite.pass_activity_unknown`
  ★★若你/blueprint 判這仍屬 default-pass：把那個 bump 換成 continue 即可（★一行，位置已標）
⇒ ★★★我另外加了一個【正面排除證據】：activity == SETTLED ⇒ 不邀（看得出它有家）
```

# ★★②剝註解（`b74571c3`）
```
★sites 68 → 67、removed 9 → 10
★★新現形那一筆 ＝ `faction_ai_system.gd::_evaluate_infrastructure::gv_mapscan`
   ＝ 上一輪 off-by-one 的【本體】（幻影來自 :4936 一行註解）
★你掃到的另外兩處（`owner_outpost_index.gd:3`／`world_state.gd:189`）
   ★★【不在 GV_FILE_RE 的涵蓋檔內】(faction_ai/diplomatic/npc_ai/strategic/threat/decision/)
   ⇒ ★★★它們從來沒進過 current ⇒ 不會有 removed —— 你的「三處」對，而只有一處會現形
★不剝行尾註解：`# gate-ok` 正是靠行尾註解運作，連行尾一起剝＝把豁免機制關掉
```

## ★★★而對照本身踩過一次（值得你知道）
```
★我用 `c_unescape()` 把樣式從原始碼還原 ⇒ ★★它把 regex 的 `\b`（字邊界）當成 C 的【退格字元】
⇒ 樣式變成「`.tiles` 後面要有一個退格」⇒ ★真 code 也不命中 ⇒ ★★★對照【假紅】
⇒ 改成只做反斜線還原，並把這件事寫進 code（★下一個人會再拿 c_unescape 做同一件事）
★而對照的樣式是【從閘的原始碼讀出來】不抄一份 —— 抄一份會漂，漂了就是在驗一個不存在的閘
★★兩向都驗（你要求的）：真 code 仍被命中 ／ 註解不被命中 ／ 真 code 沒被 skip
   ⇒ ★★★沒有第三條的話，「剝過頭」是靜默的
```

# ★③順手交辦那一行（`combat_target` 旁路）
```
`world_state.gd` erase 清理迴圈的 `o.combat_target = -1` ⇒ 改走 `clear_combat_target()`
白名單那行已移除 ⇒ ★`[SINGLE-WRITER] PASS`（受管 2 欄、白名單外 0）
★★而你訂正「erase_teams 有清理契約、只是不完整」我收下 ——
  ★★★它清 combat_target／social_target／order_target_id，我今天補了 orders，relations 仍缺
```

# ④驗
```
★headless_test：HARD-FAILS 3 ＋ assertion 11 ＝ baseline
★★constitution_gate：PASS (sites=67, removed=10)｜gv_belief_* 4 → 3
★single-writer：PASS
★★★三個 invite fixture 補了外觀欄位 —— ★意圖是【人格決策】不是感知 ⇒ 補 fixture 非翻斷言
```

# ⑤誠實限
```
①★外觀欄位【沒有雜訊】⇒ reviewer 問過「會不會讓外觀層太可靠、與 god-view 實質等價」——
   ★★我沒有量它：目前只有「距離＋過期」在限制可見性，★★★而那是感知強度的問題，需要一輪量測才判得了
②★`observed_activity` 的四個信號是我挑的（combat_target／工地／位移／自家據點）
   ★★挑得對不對＝「這些真的是外觀嗎」——我逐個寫了理由，但那是我的判斷，不是量出來的
③★★★fp 會變（新欄位進 snap）而我【沒有跑長窗量差】—— assertion 沒動只代表測試情境沒走到
```
