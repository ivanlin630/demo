---
from: implementer
to: systems
status: open
slice: 7b 戰後處置過渡（spec 2026-10-16-aftermath-disposition-transition-7b-HOW）＋小修 diplomacy_grounded 床佈置
topic: 請 merge feat/aftermath-7b 56957fe3a（已併 main 0310fcadc）｜稽核先落那輪：釘 3b1263741 run-id 19277-20261016-035632 RC=1 唯一紅＝ki-status 存量（你已在 main 修）、新判準沒抓到任何懸空｜全量：釘 56957fe3a 136／136 全綠 RC=0（run-id 18751-20261016-100726）｜battle_aftermath 23／23；n1–n4 全紅在該紅的格｜world-fp 不換基準
---

# 結論

- 分支 `feat/aftermath-7b`，tip `56957fe3a`，base origin/main c4c964f0e，已併 0310fcadc（你領導的勢力；合併乾淨，無衝突）。
- **commit 序**（照 GO 信：稽核那刀單獨先落、先跑電池）：
  1. 3b1263741 稽核反向檢查：活人 team_id 指向不存在的隊 ⇒ 違規
  2. 99cad5a16 改法一～三＋五（kill_named、屠村全殺、強佔不殺、玩家句、舊床同 commit 改）
  3. a11bf0853 diplomacy_grounded 小修
  4. 3ae0f0468／e89ad1309 併 main
  5. 3f8c48e0f headless Task6d 斷言修正（見下）
  6. a324a2351 7b 普查床（diagnostic）
  7. 4ae42e379 diplomacy_grounded 補 @bed-kind
  8. 56957fe3a 併 main b698fe380
- 原始輸出：`docs/measurements/2026-10-16-aftermath-7b/`。

# 兩輪電池

| 輪 | 釘 | run-id | 結果 |
|---|---|---|---|
| 稽核先落 | 3b1263741 | `19277-20261016-035632` | RC=1，唯一紅 ki-status（base 帶的存量條目，你已在 main 5ce024d17 修）；**新判準在全電池裡沒抓到任何懸空活人**。`battery-audit-only-3b1263741.txt` |
| 全量第一輪 | e89ad1309 | `915-20261016-080233` | RC=1 紅 3 支，都處理了：①headless——失敗清單多一條「強佔人口應不變（10…），實際=11」＝我改的 Task6d 斷言寫錯（見文末），3f8c48e0f 修；②bed-kind——`diplomacy_grounded_test.gd` 被本票觸及而沒有 `@bed-kind`，4ae42e379 補 acceptance＋slice；③defer-phrase——你的 progress.md「排在你領導的勢力之後」，你已在 main b698fe380 修。`battery-e89ad1309-red.txt` |
| 全量最終 | 56957fe3a（＝tip） | `18751-20261016-100726` | **136／136 全綠 RC=0**；跑前跑後樹 sha 都是 56957fe3a、跑前 porcelain 0 行。`battery-final-56957fe3a-green.txt` |

- 床、負對照釘 e89ad1309（之後到 tip 的差：headless 斷言、bed-kind 宣告、普查床、docs 合併——都不碰 encounter_system／invariant_audit／player_command_system）。
- world-fp：三輪電池 world-fp 都綠，**不換基準**；B5 三個 res.* 在普查 6 個世界總和全 0（下表）⇒「fp 不變」＝NPC 路確實休眠，不是路沒走到以外的原因。

# 改了什麼

- **`EncounterSystem.kill_named(state, t, pid) -> String`**：`scripts/simulation/encounter_system.gd:1695`。
  - dp 存在 ⇒ 標死、`remove_member(t, pid, false)`、是隊長則清隊長，回名字。
  - dp 不存在 ⇒ 仍 remove_member，回空字串。
  - 不碰 am。
  - 兩個呼叫點：
    - 戰鬥結算 `:1260`：守衛三行留在呼叫端；`dead_named` 照舊條件「dp != null and am sides has」記回傳的名字。
    - 屠村 `:1715`。
- **屠村**：逐人改呼 kill_named；拿掉冗餘 `set_leader(-1)`；回傳改 `{killed_anon, killed_named, team_id}`。player_command_system 同 commit 改讀，改用 `mr["key"]` 直讀：新 key 若再改，會當場報錯，不會靜默變 0。
- **強佔**：拿掉 `kill_random` 兩成；print 改「據點易主，居民留下」。
- **稽核**：`invariant_audit.gd` 反向檢查 `t == null` ⇒ `懸空 P%d team_id=%d 隊已不存在（活人）`；註解改成現在的事實。
- **玩家句**：
  - 屠村「你下令屠村：Team{N} 的 {a} 人被殺（含 {名字…}），據點易主」，a＝匿名＋記名。
  - 強佔「據點易主，Team{N} 的 {p} 人留在原地」。
- **舊床同 commit 改**：
  - headless `_test_occupy_force` 標題與斷言。
  - battle_aftermath A10 句子格「逃散」→「被殺＋（有記名）含名字」，「開頭你下令屠村／含據點易主／不含戰」保留。
- **註冊表**：battle-aftermath 那一列只改 expect 的到場數 19→23（加了四格，數字不改閘就紅）；col3 補一句；沒有新增列。
- **小修**：`diplomacy_grounded_test.gd` `_mk_ctx_diplo` 加 `has_tribute_to_give = true`，加一格「false ⇒ 求和不入候選」；全床輸出 `diplomacy-grounded.txt`：`=== DONE === ALL PASS`。

# 驗收（battle_aftermath_bed 23／23 errors 0，`bed-full.txt`）

- **B1** 實跑逐字：`你下令屠村：Team915 的 9 人被殺（含 首領915、甲記名、乙記名），據點易主`。
  - 地板：隊長＋活記名 3 人、匿名 6。
  - 每人 is_dead、活人懸空 0。
  - **屠村前後 `len(state.persons)` 47 → 47**（留屍：死者留在 persons，team_id 指向已刪的隊、is_dead＝true）。
  - `_resident_setup` 只生隊長 ⇒ B1 另加兩名記名（床內 `_add_named`）。
- **B2**：`據點易主，Team915 的 7 人留在原地`，人口 7 → 7、隊仍在、據點屬玩家。
- **B3**（A 系列原本沒有斷言 is_dead／dead_named ⇒ 照 spec 補這格）：敵隊長戰死 ⇒ is_dead、team_id 留 910、隊長欄 -1、dead_named ["首領910"]。
- **B4** 陽性對照：造懸空 ⇒ `["懸空 P987654 team_id=876543 隊已不存在（活人）"]`；刪掉 ⇒ 0。
- **A10** 既有「活人懸空＝0」格保留，照綠（現在靠殺達成）。

## 負對照（釘 e89ad1309，BED_ONLY 子集，跑完還原、porcelain 空）

| 刀 | 紅（原文） |
|---|---|
| n1 屠村改回 remove_member（散） | `B1 屠村後每個記名 is_dead（false）、活人懸空 0（0）` |
| n2 強佔放回兩成 | `B2 強佔：居民隊仍在、人口不變、據點屬玩家、句子含「留在原地」` |
| n3 稽核改回 continue | `B4 稽核：懸空活人 ⇒ 違規含「懸空」（0 筆）；刪掉 ⇒ 0（0）` |
| n4 結算不呼 kill_named、只 remove_member | `B3 戰死記名：is_dead、出名冊、team_id 留、隊長欄清空、dead_named 含名字` |

- ★n1 只紅 is_dead 那格，句子格沒紅：我那一刀只把迴圈退回散，句子組法還是新的（把散的人名放進「含 …」）。所以這一刀證的是「殺」那一半；「句子人數＝匿名＋記名」那一半，n1 這一刀分辨不出。

# B4／B5：四條 erase 路與 NPC 休眠（`erase-census.txt`，兩層 × 3 seed × 30 天、每天稽核一次）

| 層／seed | 有懸空的天 | 滅團 extinct.team.* | 批次 erase.batches（teams_erased） | 子隊併回「[Merge]…完全合併」 | 獸隊「[BeastHunt]」 | res.seen／npc_massacre／npc_force |
|---|---|---|---|---|---|---|
| 無玩家 1337 | 0 | 0 | 18（18） | 12 | 0 | 0／0／0 |
| 無玩家 2026 | 0 | 0 | 23（23） | 14 | 0 | 0／0／0 |
| 無玩家 777 | 0 | 4 | 54（54） | 38 | 0 | 0／0／0 |
| 有玩家 1337 | 0 | 2 | 28（28） | 23 | 0 | 0／0／0 |
| 有玩家 2026 | 0 | 0 | 52（52） | 46 | 0 | 0／0／0 |
| 有玩家 777 | 0 | 1 | 28（28） | 22 | 0 | 0／0／0 |

- 30 天 × 6 世界每天收尾稽核一次：**懸空活人 0**。
- 四條 erase 路：
  - 滅團 7 次、批次 203 次、子隊併回 155 次，三條都走到了，而且全程 0 懸空。
  - **獸隊 0 次**：普查世界裡沒有人獵到野獸（headless 合成場景有 2 次 `[BeastHunt]`，但那不是電池世界）。
- ⇒ 照 spec：獸隊那條**不算審過**，known_issues「刪隊時隊上記名的人不會被處理，稽核也看不到」**不結案**，改寫成只剩獸隊那條。known_issues 是你的檔，請你改寫；我沒動。
- 誠實限：
  - 「懸空 0」證的是這 6 個世界裡沒發生，不是不會發生。
  - 稽核是每天一次，不是每 tick：一天之內先懸空、後被別的路清掉的情形看不到。
  - 電池其他世界走這些路時，也由 headless／scripted_exploration 裡既有的 InvariantAudit 看著，兩輪都沒紅。

# headless Task6d 那條斷言
舊斷言「強佔 pop 應 10→8」：佈置當下人口其實是 11，11 − (11 − int(11×0.8)) ＝ 8 碰巧等於 8。改成「記呼叫前人口、斷言不變」（3f8c48e0f）。

# 消費
GO-aftermath-disposition-transition-7b、SMALL-diplomacy-grounded-fixture、MERGED-player-led-faction。

下一張：真玩小修（之後掛單押貨）。
