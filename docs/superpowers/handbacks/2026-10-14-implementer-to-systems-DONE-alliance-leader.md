---
from: implementer
to: systems
status: open
slice: 第五輪回饋 #7：同盟不搬勢力領袖（＋#8 據點易主進事件流、拿掉 D C1）
topic: 請 merge fix/alliance-leader 0d7a69902（已含 main 62ed240ff）｜全電池釘死 0d7a69902：123／123 BATTERY_RC=0（3840s）
---

# 同盟不搬領袖：可以 merge

## 電池
- detached worktree `.worktrees/mm2neg` 釘死 `0d7a69902`。
- 123／123 ✓，BATTERY_RC=0，總時 3840s，run-id `1959-20261014-062719`，摘要 `docs/measurements/.battery/1959-20261014-062719.txt`（那棵樹）。
- 第一輪（釘 d9ca04561，run-id `1293-20261014-051218`）紅 3 支，全部是同盟分支自己的，改 code／測資修，沒動判準。見「電池紅修」。
- 電池產物 `docs/measurements/2026-09-30-scripted-exploration.txt` 只有 sha 行變 ⇒ 已還原、不帶。

## 分支
- `fix/alliance-leader` → `0d7a69902`（已推遠端）。
- d9ca04561 ＝ 併 main 62ed240ff。衝突兩處：
  - `merge-gates.tsv`：兩邊新增的列都留（alliance-leader ＋ 三支 UI 閘）。
  - `world_events.gd`：describe 留易主／居民兩句＋main 的情報句；兩邊的函式都留。

## 做了什麼（spec 2026-10-13-alliance-never-moves-faction-leader-HOW）
- **#8-0 據點易主進事件流**（8fc776e6a）：
  - `OutpostOwnerBank.set_owner` 簽章加 state（27 個呼叫端），成為真單寫者（world_state 死亡釋放也改走它）。
  - 只在玩家相關時 emit `outpost_owner_changed`（wake=false，NPC↔NPC 不發）；登記事件種類、人話、推進停點。
- **量測準備**（47eb53dd0）：join 帶 reason（10 種來源、Probe `faction.join.<reason>`）；`_form_alliance` 角色 3×3 與「領袖被搬走」計數（純觀測）。
- **本體**（54364921d）：
  - `plan_alliance` 純函式：領袖綁勢力；登記居民綁地主（過渡 token `resident-bound-to-landlord-faction-is-transitional`）。
  - `_form_alliance` 回實際動作；**拿掉 D C1（結盟不轉讓據點）**。
  - `handle_diplomacy_message` 先試算；NPC 選項層排除「無動作結盟」。
  - 玩家端：方向統一（:1865）、拿掉 :876 重複呼叫、結果句與提案行預告寫實際後果。
  - `set_team_faction` 的 `_on_faction_changed`：領袖離開 ⇒ 繼位或解散；居民換旗 ⇒ 通知地主。
  - InvariantAudit **L7**：勢力不得無頭（leader_team_id 指向存在且屬本勢力的隊）。
- 床 `alliance_leader_bed.gd`（L1–L9／R1／R1b／R1c／R1d／R2）0 錯；註冊表列 `alliance-leader`。

## 先量（修前，樹 47eb53dd0）
- 落檔：`docs/measurements/2026-10-13-alliance-growth-census.txt`（fix/alliance-leader 上）。
- seed 1337／2／3 各 30 天：**領袖被搬走 0 次**、結盟送據點（set_owner reason=alliance）**0 次**，主要管道＝false（三 seed 都沒到門檻）。
- 陽性對照（佈置 A 領袖對 B 成員）：修前那一支確實 fire（moved_leader 1、原勢力懸空=true）⇒ 0 次不是母體太小。
- ⇒ D C1 與搬領袖在 NPC 自然局裡都沒 fire，拿掉它們不動 NPC 世界的那三個 seed。

## 負對照（逐格放回舊行為，床必紅）
- A1 拿掉領袖守衛 → 紅 4（L2／L2c／L5…）
- A2 :1865 方向回舊 → 紅 1（L1）
- A3 拿掉居民綁定 → 紅 1（R1）
- A4 放回 D C1 → 紅 1（R1d）
- A5 領袖離開不繼位 → 紅 1（L8）
- A6 選項層不排除 → 紅 1（L9）
- A7 易主不發事件 → 紅 1（R2，八種 reason）

## 電池紅修（第一輪 d9ca04561 的 3 支紅；0d7a69902）
1. **bed-arm**：`alliance_growth_census`、`alliance_leader_bed` 先 setup 才 arm。
   - 改走 `MeasureBedHelper.arm_and_setup(cfg, false)`（留玩家）。未涵蓋 2 → 0，沒進白名單。
   - census 改後在現行（修後）樹上跑 1 天 sanity：陽性對照 moved_leader 0（那一支已拿掉，預期如此）。修前那份落檔沒重量——setup 期間不會呼叫 `_form_alliance`，arm 提早不影響那三個數。
2. **bed-kind**：`owner_outpost_index_test.gd`（#8-0 改簽章時觸及）沒有宣告。
   - 它有判決彙總行 ⇒ 宣告 diagnostic 會紅；補 `@bed-kind: acceptance` ＋ `slice:`（原 spec 2026-08-20-owner-outpost-index-HOW）。
3. **headless**（HARD-FAILS 仍 3，但清單變了：兩條新紅）：
   - `_test_alliance_outpost_transfer`（Trade Task8）斷言舊 D C1「owner 應變攻方」。spec #8-1 明令拿掉 ⇒ 斷言改成 owner 留原主 99，標題改「不轉（#8-1）」。
   - `_test_invariant_faction_bidir` 的最小勢力沒設 leader_team_id（-1）⇒ 觸發新 L7。測資補 `f.leader_team_id = 0`；L7 本身沒動。
   - 改後失敗清單與 baseline 逐條相同。
   - ★Task8 是**改舊斷言的方向**（spec 指定的行為變更），請你過目。

## 已消費的 GO
- `2026-10-13-systems-to-implementer-GO-alliance-never-moves-faction-leader.md`

## 下一輪
- 勒索零所得 `fix/extortion-zero-take` 5351aa326（已併 main 62ed240ff），單獨跑一輪電池，綠了另寫信。
- ★勒索分支也在 `merge-gates.tsv` 加了一列（extortion-zero-take）⇒ 兩支先後 merge 時註冊表會有一處兩邊各加一列的衝突，兩列都留即可。
