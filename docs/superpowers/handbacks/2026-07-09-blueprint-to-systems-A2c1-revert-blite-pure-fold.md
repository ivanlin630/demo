---
from: blueprint
to: systems
status: consumed
topic: A2c-1 定案——REVERT (b-lite)(回收征服前提已死);A2c-1=純 FA5 fold;phantom 另立 micro-slice;好戲驗跑中
---

# A2c-1：REVERT (b-lite)，保純 FA5 fold

## 我改判：revert（撤回先前的 keep 批）
我原批 (b-lite) keep 有**兩理由**：①真 bug ②回收征服助好戲關。**②被數據推翻**（520→520 逐點同，我+你的 over-suppress 判讀錯）。剩①「真 bug」——但**真 bug ≠ 該搭 A2c-1 便車**。

∴ **revert (b-lite)**，理由：
1. **slice 純淨/單一責任**：A2c-1 = 純 FA5 fold。phantom `current_option` 是 `_decide_unified` **generic 路徑改（影響全 option）**，與 FA5 正交 = scope-creep。
2. **審計乾淨**：keep A2c-1 純，則 **520 可證 100% 是 FA5-fold artifact 移除，無他 confound**。混進 generic 改 = 糊了「520 是誠實 FA5 baseline」的 audit trail 與 game-design 記檔。
3. 我自己的線（byte-0 裁時立的）：語意/正交改進塞明確 owner 的獨立 slice，別讓 fold slice 夾帶。一致。

**這是 receiving-review 紀律**：我的批基於一個已被證偽的預測 → 更新，不護。

## phantom current_option → 另立
- 真 bug（承諾寫在 try_set 前，dispatch 失敗也記，違 1487 註解原意）→ **記 known_issue**。
- 修走**獨立 micro-slice**（自己 spec+驗證），非搭 A2c-1。你收尾時登記帳。

## 好戲驗（我這邊）
- 你確認 fixed/phantom conquest 同 520 → 我背景跑的 folded 大事記（worktree @含 b-lite）**代表 520 世界**，revert 後 conquest 同，**驗值不受影響**、不用重跑。
- 3 月大事記跑中（timeout 1800），跑完我判 520 世界好戲否 → 過則放行鎖 spec；壓扁亂世感則升級用戶「要哪種世界」。**這是鎖 spec 前最後一關（我 owner）。**

## 收尾定序
1. 你：revert (b-lite) 一個 commit → A2c-1 = 純 FA5 fold @ 新 tip。（全閘已綠，revert 後補跑 constitution/framework/HOB 確認仍綠即可。）
2. 我：好戲驗回攏。
3. 兩綠 → 你收尾 spec（記 **740→520=bypass artifact 移除**、**征服密度=引擎內可調旋鈕留 A2d/平衡 pass**）→ merge-gate 進 main。
4. game-design 記檔我 owner，好戲過+spec 鎖後落筆。

等你 revert + 我好戲驗。
