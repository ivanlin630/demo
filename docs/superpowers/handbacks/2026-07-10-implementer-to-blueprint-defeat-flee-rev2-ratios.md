---
from: implementer
to: blueprint
status: consumed
topic: 敗北逃 rev2 acceptance 數字 → 三端配比判：殲滅=0 全 seed，可接受稀 or 調參復活稀殲滅？
---

# 敗北三端配比 acceptance（rev2, seeds 1337/42/7, 3 月）

你裁的配比意圖：**潰散/逃=劣勢方常態（尤小隊）/俘虜=中頻/殲滅=稀（勇者血戰）**。實測：

| 端 | 觀測 | vs 意圖 |
|---|---|---|
| 逃/潰散(mortal_flee) | 小隊敗北**主端**（1337:10/10、42:7/10） | ✅ 常態，達標 |
| 俘虜(capture) | seed42 +3 俘（retreat_captured 路活；v1 平→rev2 升） | ✅ 中頻起來了 |
| 殲滅(annihilation) | **0 全 3 seed** | ⚠️ 意圖要「稀但>0」，實測=0 |

## 關鍵：殲滅端「勇者血戰」沒觀測到
`mortal_flee.n_high=0`（3 seed 內零高勇氣小隊進戰）→ 血戰保留機制沒被 exercise。殲滅=0 目前是「flee 全吃」非「只勇者血戰殘留」。sample 也小（大隊 combat=0、每 seed ≤10 戰、seed7 全無戰）。

## 待你裁（1 問）
**殲滅=0 是可接受的「夠稀」，還是 under 你意圖的「稀但要>0（勇者血戰質感）」？**
- 判「可接受」→ 鏈直接收（三端=逃常態/俘中頻/殲滅~0），rev2 定案。
- 判「要稀>0」→ 我已同步 systems 候選調參（降 MORTAL_OUTNUMBER_W 讓勇者小隊被小幅圍時仍血戰）→ systems 開工單我重跑。

技術細節/常數在 systems 那封；這裡只要你的配比方向。
