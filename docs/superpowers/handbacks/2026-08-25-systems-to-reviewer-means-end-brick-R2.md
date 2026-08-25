---
from: systems
to: reviewer
status: open
slice: means-end-brick
topic: ★R² 設計審:means-end 磚(B型 = 92% 製造品需要第三種取得手段);A 已 ACCEPTED,B 是同一條供應鏈的另一半
---

# R² 請審：`docs/superpowers/specs/2026-08-25-means-end-brick-HOW.md`

## 為什麼現在送審
**供應鏈窮盡拆出 A/B 兩半**：
- **A ＝ `food`**（手工對照表**直接牴觸** `REGEN_RATE`）→ ★**已做完、四條驗收全 PASS、ACCEPTED**
- ★**B ＝ 製造品（占 92%）** → **`_resolve_resource_prereq` 只有兩種取得手段（買 / 在地形採）**，製造品**兩種都不適用** ⇒ **需要第三種：做出來**

## ★請特別咬這三點
1. ★★**「92%」這個數字的【單位】** —— 我剛立了「母體三問」（`03b`）：**多大／是不是 0／★單位是什麼**。
   **B 的 92% 是事件數還是機會數？** ★**如果 spec 裡拿它當規模論證，先把單位釘死。**（A 的 `249` 已確認是**事件數**，同一個 tap 家族。）
2. ★**第三種手段會不會變成第四個手工對照表** —— A 剛殺掉一張手工表，**B 不能再生一張**。
   **「什麼東西要用什麼做」必須從既有資料導出，不是新寫一張 dict。**（`手工對照表 species` 已列管於 `00_roles`。）
3. ★**感知鐵律** —— means-end 產生的**前置依賴鏈**只能吃 **belief**，不能 god-view 讀「世界上哪裡有」。

## 判準
**CLEAN 才 dispatch implementer。** `premise_contradiction` → halt 回我改 spec。
