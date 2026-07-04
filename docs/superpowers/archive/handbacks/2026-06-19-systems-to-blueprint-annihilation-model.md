---
from: systems
to: blueprint
status: consumed
topic: E-1 結構免疫 → 「打到死」殲滅模型 WHAT 待決（系統呈報，越界呈報你裁）
ruling: 藍圖已裁，見 2026-06-19-blueprint-to-systems-e1-annihilation-ruling.md + game-design.md §戰鬥解算與敗北模型
---

# 呈報：E-1 收斂模型是願景決策，請藍圖裁

> channel dogfood 反向邊（systems→blueprint）。channel 定義已落 `00_roles.md`「跨角色交接 channel」節，待 user 批。

## 背景（系統已挖定，technical 部分結案）

E-1「弱隊殺不光/對攻擊免疫」深挖完，**兩病灶分屬不同 owner**（全文見 `known_issues.md` E-1 段「分叉解剖 2026-06-19 #3」）：

| 病灶 | owner | 狀態 |
|---|---|---|
| 繼承分叉（encounter 死 leader 不叫 `on_leader_death`，三入口不一致） | **系統 HOW**（單一真值源 seam） | 我處理，將起 spec/plan→worktree。行為不變、不擴願景。 |
| 結構免疫（未上場 anon mass 永不進 kill 池 → pop 殺不掉） | **藍圖 WHAT** | **本呈報，待你裁** |

關鍵已證：兩病灶**全在 player-encounter 路徑**，NPC-vs-NPC 走 npc_combat 結構無病（自帶 wound 全 pool + anon 晉升）。所以 E-1 是玩家介入才發病的問題。

## 要你決定的 WHAT

**遊戲要不要「大軍能被磨滅殲滅」？** 純機制層我能實作任一選擇，但「弱隊該不該被打到滅團 / 大隊該不該被磨光」是平衡意圖 / 玩法願景，非系統可自決。

候選方向（系統列可行性，你選願景）：
1. **模型 A — 敗方 pop 損耗**：encounter 結算按上場陣亡比例連坐未上場 anon。先例可複用：`force_occupy`(encounter:1424) 已有 20% pop 損耗公式。→ 一直打 → anon 漸減 → 0 → 無人晉升 → 團崩潰滅團 = 真「打到死」。
2. **subjugate-or-flee 強制**：不殲滅，敗方強制臣服 / 潰散（接戰俘 spec #2）。
3. **武裝率下限否決**：armed_anon_ratio 有下限，避免 0 武裝隊免疫接戰。
4. **接受 cap 為設計上限**：大軍只 cap 數量接戰、其餘不損耗（維持現狀，承認「不可殲滅」是 feature）。

可組合（如 A 底 + B 層 + C 武裝下限）。

## 耦合 / 時序

- 繼承統一（系統）我會**先做**（孤立、行為不變、可獨立 land）。
- 但**完整 E-1 收斂 spec 要等你定殲滅模型**才能合成（繼承統一 + pop 損耗兩件一起才收斂，單修繼承會回「named 工廠」死循環——見 known_issues E-1「關鍵推論」）。
- 你裁定後：寫進 `game-design.md`（你 owner）→ 回標本 handback consumed → 系統合成 E-1 spec。

## 邊界
WHAT 你決定權，HOW 我決定權，喬不攏 user 裁。我不碰 `game-design.md`。
