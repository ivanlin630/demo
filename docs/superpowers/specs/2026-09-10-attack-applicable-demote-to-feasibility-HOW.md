# HOW spec：攻擊 `applicable` 從【授權清單】降級為【可行性檢查】

- **WHAT 授權**：blueprint `2026-09-10-blueprint-to-systems-ruling-attack-applicable-demote-to-feasibility.md`
- **證據**：量測員 `attack-door-census.measure.json`（三門全關 97.37%，380 次全隊快照）
- **序**：★blueprint 護欄④——**排在體驗窗四票（效能／inspect／帶因／C1①）之後**。
  本 spec 可平行寫、可平行過 R²，**但不得先 dispatch**。

---

## ① 現況（file:line，不是描述）

`scripts/simulation/decision/options.gd:332-334`

```gdscript
"applicable": func(ctx: DecisionContext) -> bool:
    return ("攻擊" in ctx.faction_stakes and ctx.faction_attack_target != -1) \
        or (ctx.intent == "征服" and ctx.intent_target != -1) \
        or (ctx.strongest_feud >= FEUD_ATTACK_MIN and ctx.feud_target_id != -1),
```

三道門全是**授權**：上級令／身分標籤／歷史仇。**沒有一道是「他弱、我缺、我夠得著」。**
而同一個 option 掛著一整套秤（`options.gd:328`）：

```gdscript
"terms": [["faction_duty","faction_duty"], ["attack_drive","attack"],
          ["intent_fit","intent_fit"], ["feud_pull","feud"]]
```

⇒ **四 term 的引擎存在，97.37% 的時間不會被叫到。**

---

## ② ★★★本 spec 最重要的一件事：門不是只有一道，是【兩道】

`decision_context.gd:764` 與 `:788`

```gdscript
if c.intent == "征服" and c.has_weak_prey \
        and (c.intent_target == -1 or not state.teams.has(c.intent_target)):
    c.intent_target = _prey
...
if c.intent == "征服" and c.prosperity_prey_id != -1 \
        and (c.intent_target == -1 or c.intent_target == _prey):
    c.intent_target = c.prosperity_prey_id
```

⇒ **`intent_target` 的【賦值】本身也 gate 在同一個 `intent == "征服"` 標籤上。**
⇒ ★★★**只改 `applicable` 而不改這裡＝門開了、目標是 -1**，
   `to_task`（`options.gd:340-345`）取不到 target ⇒ **回 `TASK_IDLE`**
   ⇒ 得到一個「常常被提名、然後溶解成發呆」的 option ＝ **手不聽腦的教科書複製**。
★這一格是本 spec 存在的理由：**降級 applicable 是兩處改動，不是一處。**

★注意 `prosperity_prey_id` 本身（`:785`）**沒有** gate 在標籤上（只要 `ldr != null`）
⇒ **它已經每 tick 算好了，只是算完沒人用。**

---

## ③ 可行性其實【已經寫好了】——在 `find_prosperity_prey` 裡

`faction_ai_system.gd:238-283` 的每一條 `continue` 都是可行性守衛：

```
:245 tid == 自己                 → 跳過
:248 同派系                      → 跳過
:250 not BeliefSystem.has_belief → 跳過   ★不知道的打不了（感知鐵律，已在）
:252 not catch_result.reachable  → 跳過   ★夠不著的打不了（PathSystem.estimate_catch_up）
:262 weakness = 1 - armed_est/self_armed  ★打不動的（belief 估，可被偽裝騙）
:280 trip   = 有效糧 / 路程糧需            ★養不起這趟的
```

⇒ **「夠得著＋打得動」不必新寫，它在這支函式裡。**
★**但它同時混了人格權重**（`:239-241` 貪婪／殘忍／野心）⇒ **不能直接拿它當門**，
否則等於把人格搬回門上（blueprint 明文禁的「第四張許可證」的變形）。

---

## ④ 修法：把那支函式切成【可行性】與【偏好】兩半

```
_attack_feasible_targets(state, team) -> Array[int]      ★零人格
    = 現有 :244-252 那幾條 continue（discovered／非己／非同派系／has_belief／reachable）
    ＋ :280 的 trip 下限（TRIP_FOOD_FLOOR 已存在，沿用不新增旋鈕）
find_prosperity_prey(...)  ★保留原樣、原人格權重，但改成【在上面那個集合上】取 argmax

新 ctx 欄位（兩個，都在 gather 填）：
  var attack_feasible: bool = false     # = not _attack_feasible_targets().is_empty()
  var attack_target_id: int = -1        # 優先序：faction_attack_target
                                        #        > prosperity_prey_id
                                        #        > feud_target_id
                                        #        > ★可行集合中 eta 最小者（fallback）
```

**新 applicable（一行）**：

```gdscript
"applicable": func(ctx: DecisionContext) -> bool:
    return ctx.attack_target_id != -1,
```

**新 to_task**：把 `_ac.faction_attack_target / intent_target / feud_target_id` 三段
優先序整段換成讀 `_ac.attack_target_id`（**語意不變，只是搬到 gather 算一次**）。

★★**那個 fallback（eta 最小者）是必要的，不是可有可無**：
沒有它，當 faction 沒下令、prosperity 分數全 0（和平人格）、又無仇時，
`attack_feasible == true` 但 `attack_target_id == -1` ⇒ **回到 ② 的 IDLE 陷阱**。
⇒ ★★★**門的條件與目標的來源必須是【同一個判斷】**，本 spec 用「門＝target 非 -1」把兩者綁死。

★★★但**綁死只擋掉一種 IDLE，不是全部**（★這格我自己先招，並已請 R² 獨立確認）：
`to_task` 在拿到 target 之後還要 `BeliefSystem.belief_pos`（`options.gd:344`），
而**「知道它存在」不蘊含「知道它在哪」**（belief 有欄位粒度，systems 2026-09-02 訂正）
⇒ **`belief_pos` 仍可能回 `(-1,-1)` ⇒ 仍會 IDLE**。
⇒ **處置**：把 `belief_pos != (-1,-1)` **一併放進 `_attack_feasible_targets` 的守衛**
   （★讓門與 to_task 用**同一組**條件，而不是門用一組、執行用另一組）。
   ★驗收②就是專門守這一格的硬斷。

★★★**而 R² 找到了第三條路——在我【沒打算碰】的地方（R² 判決 2026-09-10，非 CLEAN 的那一格）**：

```
attack_target_id 的三個來源，各自的 belief_pos 安全性【不一樣】：
  faction_attack_target ← _nearest_independent（faction_ai_system.gd:4298-4299）
        ★已自帶 `if bpos == (-1,-1): continue` ⇒ 安全，不用管
  prosperity_prey_id    ← find_prosperity_prey ⇒ 由本票新守衛上游過濾 ⇒ 安全
  feud_target_id        ← NpcAiSystem.vendetta_target（npc_ai_system.gd:50-63）
        ★★★整支函式【沒有一行碰 BeliefSystem】——只看好戰/慎重門檻與 relation_edges 的
          feud 強度。⇒ 一個老仇人只要還在 relation_edges 裡且強度夠，
          ★就算它早跑到天涯海角、belief 過期或從沒更新過，vendetta_target 照樣回它的 id。
  ⇒ ★門開了 → to_task 查 belief_pos 得 (-1,-1) → TASK_IDLE。★★同一個病，第三個位置。
```

★**我漏掉它的原因值得記下來**：我在「不動的東西」裡寫了「`FEUD_ATTACK_MIN` 常數不改」，
而**「常數不用改」被我自己讀成了「這條路不用查」**——★★這是兩件事。
⇒ **要求（R² 提的兩種修法擇一，這格不能空著）**：
  (a) `decision_context.gd:292` 賦值 `feud_target_id` 時比照 `_nearest_independent` 的形狀
      多查一次 `belief_pos`，不合格退回 -1；或
  (b) 在組 `attack_target_id` 優先序時對這個來源做同樣檢查再採用。
⇒ ★★★補完之後，「門的條件與目標的來源是同一個判斷」才**對三個來源都成立**，
   而不是只對我動過的那一個。

★**非阻塞副作用（R² 提，記在這裡免得下一個人以為是 bug）**：
`find_prosperity_prey`（`faction_ai_system.gd:268-275`）本來有「已知存在但位置不明 ⇒ 不排除、
只把 border 打到 0.3」的分支（我自己 2026-09-02 訂的規矩）。本票把 `belief_pos != (-1,-1)`
放進**上游**過濾後，**這段對 prosperity 這條路變成永遠不會執行**——
★**不是壞掉，是被新守衛架空**；原意對**別的呼叫路徑**仍然適用，**不要刪它**。

★**不動的東西（blueprint ②：一次一個變因）**：
`intent` 的生成（`_score_intents` argmax）、`intent_target`、`intent_fit` term、
`FEUD_ATTACK_MIN`（**它從門降為 `feud_pull` term 的輸入，常數本身不改**）、
`faction_stakes`（**directive 從門降為 `faction_duty` term 的輸入**）。

---

## ⑤ 驗收（★blueprint 護欄②：分布成對，同 seed 改前後）

| # | 格 | 判準 |
|---|---|---|
| ① | **門開率** raw | 同窗（warring/1337/30天/5 次全隊快照）攻擊 applicable 率：改前 2.63%（實測基線）→ 改後 **assert > 20%**（★是【機制在動】的下限，不是平衡目標） |
| ② | **★沒有 IDLE 陷阱** | `applicable==true` 的每一次，`to_task` 回傳**不得**是 `TASK_IDLE`（★硬斷，守 §② 的兩處門 ＋ §④ 的三條 belief_pos 路）｜★★**implementer 提的形狀要求（收）：【提名數】與【真的執行】必須分開量**——只改一處門的症狀是「常被提名、然後溶解成 IDLE」，★★★而它在**聚合上長得像「改完沒效果」** ⇒ 只看總攻擊次數會把「穿透失敗」誤讀成「機制沒用」，兩個結論的處方完全相反 |
| ③ | **強弱矩陣** | dump 每筆攻擊 fire 的 `self_armed / target_armed_est` 比值**分布**（非均值）；★**只報分布不設門檻**（世界該長怎樣是 blueprint 的） |
| ④ | **勒索替代** | 勒索 fire 率改前後（★blueprint 預測**應下降**）——★falsifiable，若沒下降要回報，**不得靜默** |
| ⑤ | **滅團率**（煞車讀數，護欄③） | ★**若暴走＝殲滅-heavy 債提前到期 ⇒ 回 blueprint，【不得 revert 門】**（門是對的，債在敗北模型）——★處理方式**預先寫死在此表**，免事後臨場判斷 |
| ⑥ | **成對反事實** | 把可行性判斷強制切回舊三門 ⇒ ①必須跌回 ~2.63%。★**沒有這格，①的綠證明不了是我們改的** |
| ⑦ | **perf（可慢不可卡）** | 量**每 tick 最壞單幀**，非總時間。★可慢不可卡是憲法級：總時間變長可接受、單幀爆掉不可 |
| ⑧ | **fp 對照** | 舊三門路徑（有 directive／有仇）既有測試**必須全綠** ⇒ 證明是**放寬**不是**改寫** |

★**誠實限預先寫進 measure.json**：單 seed 單世界；②③④⑤ 都是**分布**，
不是「世界應該長成什麼樣」的判準——**該不該打從此在秤上，秤的結果是世界的答案，不是驗收的門。**

---

## ⑥ 風險（★寫在前面，不是事後補）

```
①候選母體暴增 ⇒ perf（見驗收⑦）。★預先講好：若單幀爆掉，先看是不是
  _attack_feasible_targets 每 tick 全掃 discovered（O(N²) 的老朋友）
  ⇒ 修法是 cadence 快取（既有 consolidate_target 那個形狀），不是把門關小。
②「和平世界忽然全面開戰」＝ ★不是本 spec 的失敗，是秤的資訊——
  秤若壓不住，問題在 attack_drive 的 term 權重，回 blueprint 談平衡，不回退門。
③belief 偽裝（:253 偽裝低報 armed → 看似弱 → 誘殺）★路徑變常走 ⇒ 誘殺會變多。
  這是設計上想要的（資訊網有意義了），但要在驗收③的分布裡看得到，故列為觀察項。
④★find_prosperity_prey 需要 ldr != null（:238 簽名）⇒ 無領袖的隊拿不到 prey。
  新的 _attack_feasible_targets 不吃 leader ⇒ 無領袖隊會第一次拿到 fallback target。
  ★這是【行為新增】（以前它們永遠打不了），要在驗收裡分開報，不要混進總率裡。
```

---

## ⑦ R² 送審判斷（護欄①）

```
三對齊測試（強結論／redirect 大工／難逆）：
  強結論   ＝ 是（97.37% 是結構事實，不是抽樣噪音）
  redirect ＝ 是（一整類行為的候選條件重寫）
  難逆     ＝ ★否 —— 改動集中在【一個 applicable ＋ 一個 to_task ＋ 一支函式切兩半】，
             git revert 一次到底，且驗收⑥就是回退開關本身。
⇒ ★2/3 未三對齊 ⇒ 走一般 R²，不召異質 skeptic。
★此判斷寫在這裡是為了讓它【可被推翻】：R² 若認為「難逆」該判 yes，直接打這格。
```

★**R² 同意「難逆＝否」，但指出它與 §⑤ 第 5 列字面打架（「容易退」vs「最壞情況不准退」）。
訂正如下**：

```
「難逆＝否」指的是【機制】——一個 applicable、一個 to_task、一支函式切兩半，git revert 乾淨到底。
★而【後果】不可逆：世界已經發生的攻擊與滅團，不會因為 revert 而消失。
⇒ ★★兩者不是同一件事。§⑤ 第 5 列說的「不得 revert 門」是【處置紀律】
   （滅團暴走時該修的是敗北模型，不是把門關回去），★不是「機制退不掉」的技術判斷。
⇒ ★★★所以三對齊仍判 2/3。但這個區分寫在這裡，是為了下一輪有人拿 §⑤ 回頭質疑時，
   答案已經在紙上，不必當場重推。
```

## ⑧ R² 判決狀態

```
2026-09-10 R² 判決＝【非 CLEAN】，唯一阻塞格＝ feud_target_id 沒有 belief_pos 守衛（已補進 §④）。
R² 另外覆核通過的兩格：
  ★(3) 窮盡宣稱【成立】——他裸符號掃 `TASK_ATTACK` 全庫，其餘消費者都是記帳/機率修飾，
     唯一像守衛的 `interaction_system.gd:428-431`（同格即開打）是【執行端扳機】不是第二道門。
  ★(2) 難逆＝否成立（見上面的訂正）。
  ★TRIP_FOOD_FLOOR 存在（`faction_ai_system.gd:210`），不是虛構引用。
⇒ 補完 §④ 那格後回送 R² 確認 CLEAN。★仍不 dispatch（blueprint 護欄④的序）。
```
