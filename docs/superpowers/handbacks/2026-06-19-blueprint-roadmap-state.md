---
from: blueprint
to: systems
status: open
topic: 藍圖規劃 session 收束 — roadmap 狀態 + measure-first 決定（記錄供續接）
---

# 藍圖規劃 session 收束記錄

本 session 為純規劃（無 game code）。產出與下一步決定，供任一 session 續接。

## 本 session 產出（全 committed）

- **擬真審計**：世界「有運動沒因果」→「因果脊椎」框架。
- **3 脊椎 spec**（已交系統寫 plan）：
  - ①G2 目標錨 `specs/2026-06-19-g2-goal-anchor-design`
  - ②G1 供應鏈 `specs/2026-06-19-g1-supply-chain-design`
  - ③G3 情報→決策(魂) `specs/2026-06-19-g3-info-decision-design`
- **game-design.md** §戰鬥解算與敗北模型。
- **裁定**：E-1(殲滅A+C/砍D)、E-2(歸參戰意志子spec)、E-3(獨立快修)、ore_gold 守恆(對齊 coin_eq)。
- **G2c rung→task feel** 表（handback 待 G2c 消費）。
- **handback channel** 建立 + 雙向 dogfood。

## 下一步決定 = measure-first（重要）

**3 脊椎 spec 已跑在實作前面很多。決定：不再往前堆 spec，直到 G2/G1/G3 落地 + 量測。** 世界長出來後再從下表挑下一個，避免 build-first-decide-later 的 stale-spec 債。

## 遞延項優先表（量測後挑，勿現在預 spec）

| 項目 | 依賴 | 重要性 | 備註 |
|---|---|---|---|
| 戰俘 | 無 | 中高 | 最佳 next（不卡、具體、衝突傘現成）。WHAT 待藍圖（屠/俘/招降/放 + loyalty）|
| ④Trait縫 | 無（要 content 消費者）| 天花板最高 | 收編 身份/宗教/法律/階層/性別。**seam+首content 一起**，別空建 |
| 衝突完整 | 無（combat 已 work）| 中(polish) | 人海×意志/絕境死守/E-2/等量耗時/遭遇戰UI。綁衝突傘 |
| 信用幣 | **卡 G3** | 中(enrich) | money=信任。G3 後「貨幣信用」spec |
| 情報戰C | **卡 G3 A+B** | 高(玩家魂玩法) | 造謠/偽軍情/收買信使。乙，已定後做 |

## 待回呈藍圖（系統實作到時）

- G2c rung→task feel（已給 handback）、G2 升降/冒進/脫軌 數值感。
- G1 商隊/訂單 feel、鑄率平衡。
- G3 plan 疑義、技能vs計謀 數值感。
- 戰俘 WHAT（開戰俘 spec 時）。
- 衝突完整的 參戰意志/人均戰力/品質重扣 數值（子 spec 開時 dogfood）。
