---
from: measurer
to: blueprint
status: consumed
topic: "[量測完·門檻③達成] god-view逃脫故事Tier1床演示成功@08e376d5——★_refresh_attack_pursuit(前輪範圍疑點)Fix F後確認鎖last-seen(0,0)非live(8,0)=真撲空;belief_pos本體/movement_system排除路徑皆如預期;床determinism byte-identical+憲法綠;床已建為可復用infra(scripts/debug/pursuit_hiding_bed.gd,現存worktree未commit)"
---

# god-view pursuit 逃脫故事：Tier1 控制場景床演示成功

`measured_at_head: 08e376d5`（Fix F：`_refresh_attack_pursuit` 三態 vision-gate）。

## 一次量完（鐵律6）

## ★核心結果：逃脫撲空真生效，門檻③達成
`scripts/debug/pursuit_hiding_bed.gd`（Tier1 控制場景床，blueprint 授權建，過程含一次工具自身 bug 修正見下）手構場景：
- prey 真身在 B=(8,0)。
- pursuer 對 prey 的 belief 停在 A=(0,0)（近期、未過 3 天 staleness，模擬「曾見過但已偷偷移動」）。
- pursuer 已 engage（`current_task=TASK_LOOT`, `combat_target=1`）。

三項測試結果（`docs/measurements/2026-07-15-pursuit-hiding-bed-after-fixed-08e376d5.log`）：
1. **`BeliefSystem.belief_pos()` 本體**：回傳 A=(0,0)，非 B——本體函式正確鎖 last-seen。
2. **`movement_system.process()`**：`combat_target` 隊被 :77-79 `continue` 排除在外，move_target 維持原值——確認這條路徑本就不該管 combat pursuit（分工正確，非漏洞）。
3. **★`_refresh_attack_pursuit`（Fix F 標的，前輪我從 code-read 標記的「範圍疑點」）**：呼叫後 `pursuer.move_target = (0, 0)` = **A（last-seen），非 B（live）**——**Fix F 前這裡讀 `prey.tile_pos` 活值（god-view，撲空率恆 0）；Fix F 後正確鎖 belief last-seen，prey 真身在別處=撲空成立**。前輪標記的疑點已解。

**判讀**：三個介面（dispatch-time 選 target / movement_system 追蹤 / combat 專用追擊 refresh）全部一致鎖 belief last-seen，god-view 逃脫故事的機制端到端正確。

## 過程記一筆：床自身有 bug，已修正（純工具，非遊戲邏輯）
初版床遺漏 `_initialize()` 進入點（SceneTree script 沒它 `_run()` 永不執行，Godot 空轉到 wrapper 360s 逾時殺——量到的是床的 bug，非遊戲邏輯回歸，鐵律3「TIMEOUT≠迴歸」適用）+ 呼錯 `movement_system` 方法名（`move_teams`→正確為 `process`）。兩處皆 L3 surgical（新增3行進入點/改1行方法名），已修正、determinism 雙跑復核 byte-identical。

## 不回歸
- **determinism**：床本身兩跑 byte-identical（純函式呼叫，本就該 100% 確定）。
- **憲法閘**：PASS sites=29 removed=0。
- sanity/HOB 沿用 implementer 自報（headless 3+3、TDD 16 綠）——本輪未重跑，時間關係；若要 measurer 獨立複驗可另排。

## 床已建為可復用 infra（供未來稀有行為驗證，比照 buyfood_measure.gd 慣例）
`scripts/debug/pursuit_hiding_bed.gd` 現存 main+worktree，**未 commit**（我這邊不判斷是否該進 repo，留你/systems 裁：床本身零遊戲邏輯改動，若判定有復用價值可指示 implementer 正式收進 branch）。

## 待 blueprint 裁
1. 門檻③（Tier1 控制場景撲空率>0）**達成**——god-view 四項門檻是否齊全可批 merge？
2. 床是否正式收進 repo 當標準 infra（`03b_measurer.md` Tier1 床庫清單）？

---
measured_at_head: 08e376d5
