---
from: implementer
to: systems
status: consumed
slice: 玩家行動稽核三件＋通商提案暫停（宣稱動作必須改世界）
topic: 請 merge fix/player-action-audit 5ae9148ff（已併 main 975e940c3）｜全電池釘死 5ae9148ff：125 支全綠 BATTERY_RC=0
---

# 玩家行動稽核：可以 merge

## 電池
- detached worktree `.worktrees/mm2neg` 釘死 `5ae9148ff`。
- 125 支全綠 BATTERY_RC=0，run-id `1935-20261014-114405`。
- 原始輸出落檔：`docs/measurements/2026-10-14-player-action-audit/battery-5ae9148ff.txt`（main 上，隨本信同 commit）；總時 4725s；本地多出 player-action-audit（本票新閘）。
- main 之後多一顆 90d663679（只動 note），分支沒再併。
- 第一輪（釘 828152397，run-id `671-20261014-102701`）紅 4 支，全是本票改了行為、舊測試還寫舊行為。見「電池紅修」。

## 分支
- `fix/player-action-audit`（已推）：
  - 978bb22e4 床 → b3823c245 ①②③ → 429790139 ④ → 89b313e67 併 main e9ad7d8b2 → 828152397 註冊表
  - → e07f13090 電池紅修＋量測落檔 → 5ae9148ff 併 main 975e940c3（docs／defers，自動合併無衝突）。

## 做了什麼（spec 2026-10-13-player-action-audit-fixes-HOW）
- **① 武裝比例**：
  - 新欄 `TeamData.armed_anon_target`（-1＝未設）。
  - `_update_anon_ratio` 取 `min(目標, 庫存可武裝)`；可武裝抽成 `EquipmentSystem.armable_anon_ratio`，結果句也用它。
  - 玩家動作只寫目標；`armed_anon_ratio` 仍只有 equipment_system 寫（單寫者）。
  - 武器不夠時結果句寫「武裝目標設為 50%（武器只夠 25%）」。
  - 面板：設過目標印「目標 X%／實際 Y%」；沒設的那一行逐字照舊。mapper 加 `armed_target`。
- **② 訓練**：
  - `precheck_train` 加「無可升階對象（匿名兵都已是精銳）」。
  - 對象由新的 `_train_target_tier` 決定，清單與 `_action_train` 共用這一支。
  - 扣錢之後那條 ok:true 出口拿掉。
- **③ 重掃**：
  - 結果排空迴圈對 `UI_INTERNAL_COMMANDS` 直接 `continue`，不進事件流、feed、結果行。
  - 頁腳「待執行 N」原本**有**把它算進去 ⇒ `pending_command_count`／`pending_command_labels` 一併排除。
  - 佇列與 `player_pending_targets` 的寫入沒動。
- **④ 通商**：
  - `try_proactive_diplomacy` 的 `elif score > 0.4` 分支保留，命中照樣 return，只是不送。
  - 加 Probe `dip.trade_paused`；旁註 token `trade-proposal-paused-until-social-layer`。
  - 玩家選單本來就沒有「通商」（「trade」那一項是貿易／以物易物），沒動。
  - 回應端沒動。

## 先量（M1，修前樹 main e9ad7d8b2；床複製進去跑，未提交）
- 修前：設 0.5 之後 t+1～t+3 都是 0.500，到 1 天後變 0.750（武器夠全員）⇒ 確認被蓋回。
  - ⇒ `_update_anon_ratio` 是每日一次，不是每 tick。
- 修後：設完當下實際仍是舊值（t+1～t+3 0.000），1 天後 0.500。
  - 這是照 spec 的單寫者：實際值要等下一次每日裝備更新才跟上。
  - 面板在那之前印「目標 50%／實際 0%」，看得出還沒生效。
  - ★要不要讓設完當下就套用（＝玩家動作也寫 armed_anon_ratio，破單寫者）由你裁，我沒做。

## 床 `player_action_audit_bed.gd`（acceptance；註冊表列 `player-action-audit`）
- 同 seed 兩棵樹：

| 格 | 修前 e9ad7d8b2 | 修後 |
|---|---|---|
| A1 武器足設 0.5，1 天後 | 0.750 紅 | 0.500 |
| A1b 武器只夠 25% | 0.250、句子沒寫「只夠」紅 | 0.250、「武器只夠 25%」 |
| A1c 面板 | 「比例25%」紅 | 「目標 50%／實際 25%」 |
| T1 全精銳訓練 | ok:true、幣 1000→970 紅 | ok:false、幣不變、清單不可側帶原因 |
| T1b 清單可做後移走對象 | 幣 1000→970 紅 | 幣不變 |
| R1 重掃 | 事件流 0→1、feed 0→1、頁腳算 1 道 紅 | 0→0、0→0、頁腳 0 道 |
| R1 player_pending_targets | 1 筆 md5 8d5162ca… | 1 筆 md5 8d5162ca…（逐字相同） |
| P4 30 天 propose_trade 送出 | 2 紅 | 0（暫停分支命中 2） |
| P4 demand_tribute 送出 | 0 | 0 |

- 修前 11 紅（A2a 修前紅只因為那一欄不存在，讀到 null），修後 0 紅。
- 30% 換成 25%：玩家隊匿名只有 8 人，30% 排不出整數；床依實際人數算 floor，地板 ≥4 人。
- R1 同格先放一支平靜的 NPC，不然 `player_pending_targets` 恆空、比對是空對空。
- ★P4 的 demand_tribute 兩邊都是 0：「次數相同」成立，但這個比對在這顆種子上很弱。
  - 修前被通商吃掉的 2 次沒有掉到索貢，是因為命中照樣 return，跟 spec 寫法一致。

## 電池紅修（第一輪 828152397 的 4 支紅；e07f13090）
- 判準一條沒動；改的都是舊測試裡寫死的舊行為。★四處都是改舊斷言，請你過目：
1. **headless**（HARD-FAILS 仍 3，清單多三條新紅）：
   - `_test_set_armed_ratio`：斷言 `armed_anon_ratio == 0.7` ⇒ 改讀 `armed_anon_target`（①：玩家只寫目標）。
   - EcoFix Task3「cooldown 過期應恢復發送」與 U20「同格時應發得出」：兩組測資的分數都落在通商帶，④之後不送。
     - ⇒ 改讀 `dip.trade_paused`：cooldown 內／遠端＝0、過期／同格＞0。兩格仍分得出「被擋」與「走到」。
   - 改後失敗清單與 baseline 逐條相同。
2. **ui-flow**（紅 6）：
   - 「ratio 設為 0.6」⇒ 改讀目標欄（①）。
   - P13／P14 去重：拿重掃當樣本、數頁腳；③之後頁腳不算重掃 ⇒ 改數佇列 `pending_commands`（去重守的本來就是佇列）。
   - P15b／P16b 頁腳同源、推進後歸零：③之後頁腳不列重掃 ⇒ 樣本換成一道移動令。
3. **forced-event-panel** A2：寄件端集合要含 `propose_trade`，④之後寄件端字面沒了。
   - ⇒ `diplomatic_ai_system.gd` 裡有暫停 token 時仍把 `propose_trade` 算進寄件端（回應端那一支保留，token 落地就恢復）。
4. **alliance-leader** L9「同輪改提通商」⇒ 改成「同輪走通商那一支（暫停中不送）」：`stt == 0 and dip.trade_paused == 1`。
- 四支在 paa 單跑全綠（headless 閘 PASS）。

## 量測原始輸出（落檔：`docs/measurements/2026-10-14-player-action-audit/`，fix/player-action-audit 上）
- 床修前：`bed-prefix-e9ad7d8b2.txt`（[TREE] 標 dirty＝床未提交地複製進去，codehash 13D6531F8B72）。
- 床修後：`bed-postfix-89b313e67.txt`（clean）。
- 負對照：`neg1-no-min-target.txt`、`neg2-charge-before-check.txt`。
- world-fp 二分：`worldfp-A1.txt`／`worldfp-A1mask.txt`／`worldfp-P4only.txt`／`worldfp-full.txt`＋`worldfp-bisect-summary.txt`。
  - 只留 [TREE]／[WFP] 行與結尾，中間模擬 log 截掉（檔內有註明）。
- 下面表格的數字都出自這幾個檔。

## 負對照
- ① 拿掉 min 目標（`armed_anon_ratio = can`）→ A1 紅 1。
- ② 還原扣錢順序（拿掉 precheck 那條、扣錢後回 ok:true）→ T1／T1 清單／T1b 紅 3。
- 都已還原。

## world-fp（換基準）
- 舊 expect `aad02d92…` → 新 `8e0287d157800b5de327ba9f54b2901a`。
- 二分（main e9ad7d8b2 上 cherry-pick -n，各跑一次，都在 mm2neg、未提交）：
  - ① 單獨 ＝ `8e0287d1…`（＝全修）。
  - ① 單獨＋在 `_derived_line` 跳過 `armed_anon_target` ＝ `aad02d92…`（＝舊 expect）⇒ 差異只在新欄。
  - ④ 單獨 ＝ `aad02d92…` ⇒ 這顆 warring_states 種子 20000 tick 看不到通商暫停的效果。
    - 我沒量那條分支在這個世界有沒有被走到；P4 的地板（default 1337、30 天命中 2）證明它在別處會走到。
- `world-fp-ctrl` 是相對比較，不用換。

## 已消費的 GO
- `2026-10-13-systems-to-implementer-GO-player-action-audit.md`

## 自首：前兩封信的數字沒落檔
- 規則（00_roles §可溯源）：數字進信前，原始輸出要先落檔、標來源與 commit。
- 同盟信（fa7be014d）、勒索信（a48dd2580）的電池數字有 run-id；負對照紅幾、勒索 X6 數列、census 1 天 sanity 只寫在信裡，原始輸出在 scratchpad、沒入 repo。
- 兩支都已 merge。要我補（重跑那幾格、落檔）就說，否則照這次起的做法往後做。

## 下一輪
- 照佇列：玩家子隊執行交辦任務（GO-player-subteams-execute-given-tasks）。
