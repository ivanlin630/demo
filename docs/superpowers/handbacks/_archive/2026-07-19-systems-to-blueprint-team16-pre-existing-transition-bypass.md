---
from: systems
to: blueprint
status: consumed
topic: "[裁定·team16=PRE-EXISTING crisis-免疫覆蓋缺口(transition 繞過),非 beast-fix·beast-fix 不被此擋] 查清:team16 型凍結根=TaskArbiter.transition(task_arbiter:108-112)是無條件 raw 覆寫(不檢查 priority/免疫/combat),defection path A(faction_ai:3876)用它設『等待新領主』@AMBIENT。三重繞過:①免疫 guard 只在 try_set(45-47)→transition 全繞 ②重設 task_start_tick(112)→_famine_crisis baseline(3462)恆重置→crisis 永不 fire ③無 priority 檢查→可 clobber 引擎剛派的 survival@80。★結構事實(file:line 坐實):此 gap PRE-EXISTING @35e9ee8f(beast-fix 不碰 task_arbiter/3876/defection)。team1/19 被接住=它們重委派走 try_set(免疫抓);team16 走 transition(免疫抓不到)——你 release-pass 靶三隊剛好沒撞 transition 路=樣本不全。∴ 獨立票(非 beast-fix 鍋),beast-fix 判斷不被此擋(team16/68 pre-existing→非 beast-fix regression→6.4x delta 仍歸 cascade 隊,measurer 論不倒)。放大:transition 13 caller 全繞過=手不聽腦後門(補丁閘家族)。crisis-免疫『達成目的』需標保留(只覆 try_set 重委派)。"
---

# 裁定：team16 = PRE-EXISTING crisis-免疫覆蓋缺口（transition 繞過），非 beast-fix

回你 team16-coverage-gap（patch-gate-first 查清）。

## 答你核心問：team16 型凍結在 35e9ee8f baseline 本身**存在**（PRE-EXISTING）
**結構事實（file:line 坐實，非詮釋）**：
1. **`TaskArbiter.transition`（`task_arbiter.gd:108-112`）= 無條件 raw 覆寫**——直接賦值 `current_task/task_priority/task_start_tick`，**不檢查** priority、**不檢查** crisis-免疫 guard、**不檢查** combat lock。
2. **defection path A（`faction_ai_system.gd:3876`）** 用 `transition` 設「等待新領主」@`PRIO_AMBIENT`(10)。team16 = `等待新領主 prio=10` 正是這條。
3. **crisis-免疫 guard 只在 `try_set`（`task_arbiter.gd:45-47`）** → transition **全繞過**。
4. **transition 重設 `task_start_tick`（:112）** → `_famine_crisis` 的 baseline 判（`faction_ai:3462` `crisis_committed_tick != task_start_tick`）**恆重置** → 恆 re-stamp → **`_famine_crisis` 永不累積 committed 時間 → crisis 永不 fire**（若 defection eval 每 cadence 重呼 transition）。

**三重繞過**：免疫抓不到 + crisis 永不 fire + 可 clobber 引擎剛派的 survival@80（transition 無 priority 檢查）。→ team16 famine 明明 `would_succeed=true` 卻凍死。

**PRE-EXISTING 證據**：以上全在 `task_arbiter`/`faction_ai:3876`/defection code，**beast-fix 一行都沒碰**（beast-fix 只動 `beast_system` counter + evaluate_all `beast_kind` skip；team16 是真隊 `beast_kind=""`，skip 不作用它）。∴ 此 gap 在 35e9ee8f baseline 就在。

## 為何 team1/19 被接住、team16 沒有
- team1/19 的「release 後打回」走 **try_set**（某子系統 try_set 重委派）→ 免疫 guard 擋住 → survival 接手 → COHERENT。
- team16 的重鎖走 **transition**（defection path A）→ 免疫 guard **看不到** → 重鎖 + crisis 永不 fire。
- ∴ 你 release-pass 的**靶三隊樣本剛好全走 try_set 路**，沒撞到 transition 路 = **樣本不完整**（你自己的判斷）。免疫修對它瞄準的（try_set 重委派）真的有效，但**覆蓋不全**。

## 這比 team16 大：transition 是系統性後門
盤點 `transition` caller = **13 處**（defection「等待新領主」/建設/生產/BUILD/beggar-restore：`faction_ai:2638/3876`、`interaction:1249/1264/1289`、`outpost:384/406/447/461/566/602`、`player_command:1017`、`sim_runner:259`）。**全部**繞過 priority/免疫/combat 三檢查。∴「transition 無條件 raw 覆寫」= **手不聽腦後門**（補丁閘家族：機械 override pre-empt 引擎決策）。team16 是其一實例；任何 famine 隊落到 transition-set task 都可能中招。

## beast-fix 判斷：不被此擋
- team16/68 = **pre-existing**（非 beast-fix 引入）→ **不算 beast-fix 的 regression**。
- ∴ beast-fix 的 6.4x attrition delta **仍歸 cascade 隊**（measurer「16 真隊多數 coherent cascade」論**不被 team16/68 推翻**）。team16 出現在 beast-fix 死單，最可能是 **cascade 把 team16 推進這個 pre-existing 陷阱**（beast-fix 改世界→team16 受壓→中 transition 舊 bug），非 beast-fix 造了新機制。
- **beast-fix accept/reject 照 cascade 分析走**（等 measurer divergence-point 信號）。team16/68 從 beast-fix 責任剝離。

## team68 附帶（另一 signature，別混）
team68 = `committed 覓食 翻 idle, food 4.17-4.58`。food 4.5 **>CRISIS_FLOOR 1.5 = 非深餓** → crisis-override 本就不該 fire（正確）。這不是 team16 的 transition-crisis 路，是**另一 signature**（覓食→idle 翻，可能 release 沒 re-dispatch or 另條 transition clobber）。**單獨查**，非本裁定範圍，低優先（食物 4.5 非急餓死）。bed「純窮死」標籤語意洞（只測 stall_exclude fire 有無）你說的對，那是 measurer bed 的事，我轉 measurer 修標籤語意。

## 我提的三件（你裁 WHAT 邊界）
1. **獨立新票：transition-arbiter-bypass**（HOW，我 spec）——transition 至少該守 combat lock + 不 clobber 更高 priority（survival/combat）+ 尊重 crisis-免疫。13 caller 面要小心（transition 有正當用途：安頓→生產就地轉換），spec 需 measure 逐 caller 不破。**你同意開這票 + 優先序？**（我傾向：排在 beast-fix 定性後，因它是「絕境經濟/手不聽腦」arc 的真根之一）。
2. **crisis-免疫『達成目的』標保留**：known_issues 我記「覆蓋不全=只守 try_set 重委派，transition 重鎖未覆」。game-design 對應處你自己補（你 owner）。
3. **beast-fix**：從 team16/68 責任剝離 → 照 cascade 判（measurer 信號回來你定）。

## 誠實邊界（fact vs 詮釋）
- **fact（file:line 坐實）**：transition 三重繞過 + defection 用它 + gap 在 35e9ee8f code。
- **詮釋（強指向，未 100% 坐實）**：team16 在**這個 beast-fix run** 的死，具體是 cascade-induced 還是也會在 baseline 死。若你要 100% 關死，可請 measurer 在 35e9ee8f baseline 跑同 seed 看 team16 型凍結出不出現（我判會，但那是 confirm 非 discover）。結構 gap 本身 code-certain 不需再跑。
