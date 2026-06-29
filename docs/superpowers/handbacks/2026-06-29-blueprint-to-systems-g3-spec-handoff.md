---
from: blueprint
to: systems
status: open
topic: G3 統一信息域/情報戰 spec 移交 — HOW+分階 plan(E→D→P);2 硬要求守統一可擴充;納 provenance 不變量
---

# G3 統一信息域 spec 移交

藍圖 brainstorm 完成（用戶逐情境走查校正）。spec：`docs/superpowers/specs/2026-06-29-g3-info-warfare-unified-design.md`。請接 HOW + 分階 plan。

## 一句話
當初 G3 scope OUT 的「情報戰 C」+ 統一信息域 enforce + 玩家被動呈現，**設計一體、build 分階**。= 玩家錨 C 心臟 + 欺敵地基。

## build 序（spec §4 脊椎）
```
Phase E（enforce/地基）：god-view 漏補(best_estimate) + provenance 審計閘 + 背叛 belief 驅動化
Phase D（欺敵 primitive）：植假 + 接 commander 孤兒 affordance(離間/假和/緩兵) + 既有識破/口碑反制
Phase P（玩家被動）：belief 唯讀霧呈現(best_estimate+uncertainty+claims+疑點,無全知)
擴充（後續）：channel verbs / 玩家主動·武器化 / 信用幣
```
先 plan Phase E（小、半成）。

## ★ 核心模型（brainstorm 校出的兩個關鍵，spec §2/§3）
1. **感知可信度 ≠ 真實可靠度**：收訊者**不知真 hop**（那是 god-view）。只看「直接來源 + claimed provenance（可謊報）+ 自己技能」。真 hop/失真模擬側隱藏 → 可「自信地錯」。`source_type` 改 claimed-falsifiable，感知可信度去真-hop。
2. **多手多騙子**：每手失真=該中間商 driver（非 RNG）；收訊者只判直接來源；多獨立源矛盾→查證；親見切鏈；究責沿鏈。

## ★★ 兩條硬要求（spec §5b，破則退回非統一，務必守）
1. **植假 primitive 通用**：`plant(target, 任意subject, 假值, claimed_provenance, scheme)`，假和/離間/緩兵=實例非 3 hardcoded 函式。
2. **relay 失真走統一 driver 模型**（意圖驅動 action，非 bolt-on 亂數 roll）。

用戶特別確認：此為**專案核心機制**，統一+可擴充是硬標準。可擴充邊界=multi-claim+可信度範式內（完整認知模擬故意 OUT）。

## 不變量
納 **「凡 belief 必有 provenance」** 進 invariants.md（信息域那條，三不變量骨架之一）。Phase E 審計閘 = 比照決策域「無因令=0」。

## 待系統
1. 納 provenance 不變量。
2. plan Phase E（先）→ E done 後 D → P。各 measure-first、TEST VALUE 戰國 seed 校。
3. 背叛折入 Phase E（消信息域零星非統一）。
4. HOW 守 §5b 兩硬要求。

平行 framework-cleanup / StressBank / 戰國 seed 照舊（greenlight 那封）。戰國 seed 早點起 = G3 驗證床。
