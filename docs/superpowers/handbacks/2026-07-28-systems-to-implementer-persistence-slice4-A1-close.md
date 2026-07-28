---
from: systems
to: implementer
status: open
topic: "[實作·持守統一 Slice 4·A1 手不聽腦收(arc終點,用戶原concern)·Slice3 merged(69a71eb4 gate74 try_set門檻保護committed BUILD族)·spec §8-Slice4·execution-verified A1閉環(construct.complete_build>0真完工,對照A1-FAIL baseline build=0)·若剩餘gap(directive leak/resume)補·specimen-off/aggregate] Slice 1-3 merged(persist_strength+新鮮+try_set門檻)。Slice 4=驗A1真閉+補剩餘。★execution-verified才算收。"
branch: feat/persistence-slice4-A1-close
---

# 實作：持守統一 Slice 4（A1 手不聽腦收，arc 終點）

Slice 1-3 merged。**Slice 4 = A1 手不聽腦收**（arc 原始動機 + 用戶原 concern）。Slice 3 try_set 門檻已保護 committed BUILD 族不被非危機搶——**A1 stall 根（committed builder 被 directive→外交搶）應已修**。

## spec
`docs/superpowers/specs/2026-07-28-persistence-decision-layer-HOW.md` §8 Slice 4。

## Slice 4 scope（★execution-verified A1 閉環，可能不需新 code）
1. **★execution-end TDD**（驅真 tick，禁 teleport）：committed builder（TASK_BUILD 施工中、persist>THRESHOLD）被 directive→外交 argmax 搶時 → **try_set 門檻擋（非危機）→ 施工續 → construct.complete_build>0 真完工**。對照 Slice 3 前（A1-FAIL build=0）。
2. **若還 stall 剩餘 gap**（A1 前診斷：directive_fresh→reeval→argmax 選外交 = 決策層 reeval，try_set 門檻擋執行層搶但決策層 reeval 若改 current_task 呢）→ 診斷補（可能需決策層 committed 施工中 skip 經濟 reeval，但★別做成 latch skip 凍世界——用 persist 偏置）。
3. ★**別重蹈 latch**：committed builder 保護用 persist 門檻（Slice 3）非硬 skip；世界不凍硬驗。

## ★驗（execution-verified 才算 A1 收）
- **★★A1 閉環硬指標**：`construct.complete_build > 0`（新 outpost founding 真完工）——**specimen-off + aggregate 計數**（別開 leaky specimen）。對照 A1-FAIL baseline（build=0）。
- material 真流入（forest outpost 採料）+ 缺料隊真蓋設施（A1 完整鏈）。
- **★世界不凍**（attrition/teams 活）。
- 危機仍打斷（施工隊被真敵人壓境→逃/戰，非死守凍死）。
- 閘：headless 0-new + gate 74 + determinism byte-identical。

## 交付
handback `to:systems` → R²（Slice 4）→ **dispatch measurer 獨立 A1 focused（specimen-off，construct.complete_build aggregate）確認閉環** → merge → **arc whole measure（whole-system-first：4 slice 建完當 whole）** → blueprint release-pass → 升用戶（A1+持守統一 arc 收尾）。material PARK 到 whole measure。
