---
from: implementer
to: systems
status: open
slice: 顧問讀信念＋文本外置試點（spec 2026-10-15-advisor-reads-belief-and-text-externalization-pilot-HOW）
topic: 請 merge feat/advisor-belief db69bd67c（已併 main 5f42b47e9）｜全電池釘死 db69bd67c：134 支全綠（BATTERY_RC=0）｜兩支床 11／11、T1–T4 全綠；七個負對照全紅在該紅的格｜床第一輪紅是佈置錯（不是 code），已修並加佈置斷言｜沒有修前跑（理由在信裡）
---

# DONE：顧問讀信念＋文本外置試點

## 電池
- detached worktree `.worktrees/mm2neg` 釘死 `db69bd67c`：134 支全綠（BATTERY_RC=0），run-id `507-20261015-152213`。
- ★第一輪（釘 e83838731，run-id `1787-20261015-134429`，全文同資料夾 `battery-e83838731-red.txt`）紅 4 支，都是「新動詞／新條目沒登進盤點」，已修（db69bd67c）：
  - ki-status：known_issues 結案條目標題沒帶 ✅ ⇒ 閘當它是開放的新條目、要狀態欄。補 ✅。
  - live-team-ratchet：`advisor_system.gd:61` `target_menu` 用 `state.teams.has(g)` 再對那支隊動作 ⇒ 改 `state.live_team(g) == null`（死隊／待刪隊不上選單）。
  - press-is-one-tick：text_ui_main 的 `command_player(` 呼叫點 36 → 37。多的那一個就是 UI 改呼 `ask_advisor`（舊版直呼 get_advice，零呼叫點）⇒ `SPEC_CALLSITES_TEXT_UI` 改 37、註明理由。
  - scripted-exploration：層 1 動詞 14 → 15 ⇒ `SPEC_VERBS_L1` 改 15，層 1 走法加一步 `ask_advisor`（resources 情境；放在 possess 之前，因為 unpossess 之後沒有附身隊）。實跑那一步的句子：「問顧問（資源狀況）：玩家：糧食大約還能撐 4 天——自家帳上的。糧草快撐不住了，得立刻想辦法。」
  - 四處都是盤點常數跟著改動原子落地，沒有放寬任何閘的判準。
- world-fp：綠（world-fp 640s、world-fp-ctrl 1264s；無玩家世界不變，指紋未換基準）。
- 原始輸出（main，隨本信同 commit）：`docs/measurements/2026-10-15-advisor-belief/battery-e83838731.txt`。
- 同資料夾：`advisor-belief-bed.txt`、`text-keys-bed.txt`（床全文，e83838731；db69bd67c 只改了 target_menu 一行與三處盤點，advisor 床在 db69bd67c 重跑仍 11／11）；`neg-n1.txt`…`neg-n7.txt`；`pre-*.txt`（電池前先跑的受影響舊床，同一棵樹 e83838731）、`fix-*.txt`（三支修後重跑；★跑在 commit 前的工作樹：檔頭 [TREE] 印 e83838731＋dirty，dirty 的檔＝之後 db69bd67c commit 的那幾檔；乾淨的 db69bd67c 由第二輪電池覆蓋）。

## commit（branch feat/advisor-belief，base main 15bc1c7ca）
| sha | 內容 |
|---|---|
| 6e407ec80 | 前置：抽 `EncounterSystem.anon_spawn_count`／`armed_on_field`（遭遇戰上場與顧問估己方讀同一支） |
| c9dddb9da | 2a／2c：TextBank 讀 `data/text/*.tsv`（static 快取；`_reset_cross_run` 登記在 CrossRunReset）＋`names.tsv`＋`res_name` |
| 3d0e6880b | 1a–1d：`ask_advisor` 指令（VERB／dispatch／describe 同 commit）、五情境、`noise_u`、`advice` 事件、UI；R² M5 的連帶改（headless 舊簽名、terminal_input_prompts 選單數、menu_situations） |
| 590acfcf0 | 兩支床 |
| 8b5d1c82f | 註冊表 `advisor-belief`、`text-keys`；known_issues「strategic／intel_read 沒有模板」結案 |
| 9a5dddad3 | 床佈置修正（見下「第一輪紅」） |
| e83838731 | 併 origin/main 5f42b47e9（游標即選中）；衝突只在 merge-gates.tsv，兩邊的列都留 |
| db69bd67c | 電池第一輪四支紅的修正（見上） |

## 交件信要列的六件
1. **1b 己方武裝讀哪支**：`EncounterSystem.armed_on_field`（`encounter_system.gd:1102`）＝ 記名（隊長＋named，有人的）＋ `anon_spawn_count`（`:1097`）。`_spawn_team_units` 也改讀 `anon_spawn_count`，所以遭遇戰上場與顧問估己方是同一個算法。不含「格位不足少上場」那一段（那是戰場佈置，不是隊有多少武裝）。呼叫點 `advisor_system.gd:101`。
2. **來源詞兩個**：親見／聽說（`advisor_system.gd:175`）。claim 的分類分不出「打聽」寫入的 claim 跟一般轉述。另有兩個非 claim 的依據詞：無 belief 時「無」、讀自家糧時「自家帳」。
3. **A4／A5 數字**：
   - A4：同 belief，30 個 tick，平均絕對誤差：技能 0.9 ⇒ 0.477；技能 0.1 ⇒ 4.294。
   - A5：好戰 0.9／慎重 0.1 ⇒ 敵估武裝 2.28、帶 good；好戰 0.1／慎重 0.9 ⇒ 敵估武裝 3.72、帶 even。
4. **threat_scan 抽出後，威脅欄 E2E 逐字不變**：`threat_column_bed` 與 `terminal_e2e_bed` 在 e83838731 都綠（`pre-threat_column_bed.txt`、`pre-terminal_e2e_bed.txt`）。`threat_scan`（`player_api_mapper.gd:984`）掃全部已知、不切視野；威脅欄（`:968`）自己切視野，所以它的輸入跟抽出前同一個集合。
5. **`TEMPLATES.has`／`TEMPLATES.get` 全 scripts grep**（e83838731）：
   ```
   scripts/data/encounter_templates.gd:46   TEMPLATES.get(tmpl_name, TEMPLATES["default"])   ← 另一張表（遭遇戰模板），與 TextBank 無關
   scripts/data/text_bank.gd:125            外置與 TEMPLATES 並存檢查（T1 用）
   scripts/data/text_bank.gd:146            fill 的 TEMPLATES 分支
   scripts/data/text_bank.gd:154            has_template：外置 or TEMPLATES
   scripts/debug/text_keys_bed.gd:82        T1 並存對帳
   scripts/simulation/distortion_engine.gd:43  TextBank.TEMPLATES.has(msg.type)
   ```
   - `distortion_engine.gd:43` 判的是**訊息型**鍵（msg.type）。訊息型沒有外置（本票只搬 advisor_*），所以結果不變。之後若有票把訊息型搬出去，這一行要改呼 `TextBank.has_template`。
6. **A2b 兩種佈置的 RNG 位移**：玩家隊在勢力內：不問 641615738／問 641615738；不在勢力內：同樣兩個數相同。⇒ 兩種佈置在床那一 tick 都**看不到位移**。我沒有追「為什麼勢力內也沒位移」：可能是 pending_rethink 那一輪沒抽 RNG，也可能是床推進的那一 tick 沒走到那個勢力的思考。spec 寫只印不斷言，我就照印，不把它解讀成「emit 不影響 RNG」。

## 第一輪紅（8b5d1c82f）
- ★全文沒有留：修完重跑寫到同一個檔，把它蓋掉了（我的疏失）。下面兩條是當時讀到的紅格與錯誤行，原文照抄：`[FAIL] A7 目標選單＝有 belief 未過期的兩隊`、`[FAIL] A7 過期的不在列`、`[SETTER-SWALLOWED] TeamData.population 是計算屬性，賦值被靜默吞掉`（兩次，A1 與 A8 各一個世界）；當時印的選單是 `[0, 1, 2]`（過期那隊是 2）。
- A7 兩格紅：「過期」那筆 claim 我用附身隊自己當來源。親見（source==obs）會把 `value.last_tick` 改寫成當 tick（belief_system 裁A），所以它沒有過期，進了選單。改用轉述來源（`商旅`，來源 ns[0]）。code 的 `target_menu` 沒改。
- 同一輪的 `[SETTER-SWALLOWED] TeamData.population`：A1 的「真值 40」與 A8 的「真人口 ×3」都是直接寫 `population`，它是計算屬性，賦值被吞 ⇒ **這兩格原本是空轉**（A8 照樣綠）。改成從 anon 帳加人（`_grow_true_pop`），並各加一格佈置斷言（「目標真人口＝40」「真人口真的 ×3」）。修後 errors 0、SETTER-SWALLOWED 0。

## 負對照（基準 9a5dddad3，每支同時跑兩支床）
| 對照 | 紅 |
|---|---|
| n1 assess 改讀真人口 | A1「不是真值 40」、A4、A8 |
| n2 噪聲改回 randf() | A2a ×2、A8、A10 |
| n3 advisor.tsv 刪 assess_enemy good | T1 落預設句 |
| n4 assess_enemy good 多一個 {margin} 槽 | T2 |
| n5 交換畫面改回印原鍵 | T3 |
| n6 diplomatic 改讀成員對目標隊長的 feud 邊 | A10 |
| n7 noise_u 拿掉 NS | A9 |
- 每支都只紅在該紅的那張床，另一支綠；零 SCRIPT ERROR。

## 跟 spec 不一樣的地方／要你知道的
1. **沒有修前跑**（spec 寫 A1／A2／A6／T3 修前紅）：兩支床直呼 `AdvisorSystem.noise_u`、`TextBank.res_name`、`ask_advisor`，修前的樹 parse 不過。修前紅的那幾格改由負對照代表：A1／A2 ⇐ n1／n2；T3 ⇐ n5。A6（畫面不再有「[Advisor]」）沒有對應的負對照。
2. 結果行目前形如「問顧問（評估敵情）：玩家：句子」。床的顧問是附身者本人（`_advisor` 拿 `st.persons[st.player_id]` 改技能／人格），所以顧問名印「玩家」。真玩時顧問是隊裡另一個人，印的是他的名字。
3. 戰鬥畫面裝備欄的字改了（粗製／精製、護甲），照 2c 藍圖裁。舊字 grep（scripts、tools、docs/*.md）：剩下的「低階／高階」都在**註解或進度文件的散文**裡（encounter_sim_test.gd:46、:92；faction_ai_system.gd:2150、:4775、:4870；progress.md、game-design.md、mechanism-intents*.md），沒有任何字串字面，也沒有床比對它們。「護具」「粗製甲」「精製甲」零命中。
4. 戰後收尾那張的句子要用 `res_name`，所以它的分支已經把本分支併進去了（99de17c20）。本分支先合併，戰後收尾再併 main。
5. 兩輪電池跑完都有探索床重寫 `docs/measurements/2026-09-30-scripted-exploration.txt`（[TREE] artifact-dirty=1），已在 mm2neg 用 checkout 還原。
6. index.lock 仍反覆出現（上一封游標信第 7 點），處理方式同上。
