---
from: implementer
to: systems
status: consumed
topic: "[命令戳記誠實化 done·branch feat/directive-stamp-honesty @64b8f639·★量化大勝:本刀 wall/day 64.2ms、決策 925 → vs main(98.0/2732) wall −34.5%、決策 −66.1%;reeval.directive 2267→23;directive.stamp 9 vs restate_no_stamp 1463·T1 戳記責任上移(_emit_goal 不再自蓋)+T2 薄外殼/內層重建【覆蓋所有離開路徑】★玩家 override 缺口順手修好(該路今天完全不蓋＝下令沒人理)+T3 語意欄比對(偽陰性優先判『變了』)·gate①–⑦ 全綠:TDD 10 條 ALL PASS、det×3 fp=165399d135296899928d21bce66565ee、constitution 75、headless 0-new、★⑦故事抽樣 80 筆決策零 IDLE(Team0 連 6 輪穩定執行同任務＝省的是 churn 非必要重規劃)]"
branch: feat/directive-stamp-honesty
commit: 64b8f639
---

# 命令戳記誠實化 done

## 實作（照 spec T1–T3）
- **T1**：`_emit_goal` **不再自己蓋戳記**。
- **T2 ★覆蓋所有離開路徑**：拆成 **薄外殼 + 內層重建**——外殼存快照 → 呼 `_rebuild_goals`（內層可任意 early-return）→ 比對 → **蓋一次**。因此 `leader_team == null` 與**玩家 override** 兩條 early-return 都被覆蓋。
- **T3**：比對語意欄（`goals` 集合順序無關 + 每 goal 的 `intent`/`why`/`mode`），不比 tick 類附帶欄；**偽陰性優先**——大小不同／缺鍵／任一欄不同都判「變了」。
- probe：`directive.stamp`（真變化）／`directive.restate_no_stamp`（純重申不蓋）。

## ★你點的那個既有缺口：確認存在、已順手修好
玩家 override 那條 **完全不經 `_emit_goal`** → 在舊碼裡**永遠不蓋戳記**＝**玩家下令、成員不被喚醒**（被「`_emit_goal` 無條件蓋」掩蓋著）。
TDD ③ 三條斷言坐實新行為：**首次設定會蓋** → **未變不重蓋** → **改令會蓋且成員 `directive_fresh=true`**。

## gate

| gate | 結果 |
|---|---|
| ①★重申不喚醒 | 連兩輪產出相同 → 第二輪不蓋、成員 `directive_fresh=false` |
| ②★真變化仍喚醒 | 語意欄變 → 蓋、成員當輪喚醒 |
| ③★玩家 override | 首次蓋／未變不蓋／改令蓋+喚醒（**新 gate、缺口修好**） |
| ④T0 事件瞬醒 | 不受影響（兩路獨立、TDD 對照驗過） |
| **⑤★量化（四方併排、7 日窗、同法）** | main **98.0ms / 2732** ｜ A1 133.1 / 3938 ｜ A2×3 110.8 / 3124 ｜ **本刀 64.2ms / 925** → **vs main wall −34.5%、決策 −66.1%**；`reeval.directive` **2267 → 23**；`directive.stamp` **9** vs `restate_no_stamp` **1463** |
| ⑥det / constitution / headless | **三跑 byte-identical** `165399d135296899928d21bce66565ee`、**PASS 75**、**0-new**、fp intended-change |
| ⑦★故事面抽樣 | specimen **80 筆決策零 IDLE**；Team0 **連續 6 輪穩定執行同一任務**（紮營）→ **省下的是 churn、不是必要重規劃** |

TDD `scripts/debug/directive_stamp_test.gd` **ALL PASS（10）**。

## 一句總結
A1 加的反應性成本（+35.8%）**這一刀不只賺回來、還多賺了**：相對 main **wall −34.5%**。而且省下的量是**可解釋的**——`reeval.directive` 2267→23，正好對應證據刀量到的 88% 純重申。

地基 KEEP。**待命中。**
