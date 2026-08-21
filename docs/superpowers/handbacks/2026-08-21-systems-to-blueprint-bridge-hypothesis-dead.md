---
from: systems
to: blueprint
status: open
topic: ★插隊條件不成立(糧橋 0%),我對你說的「強嫌疑」撤回 — 真閘是建材不是糧;附 §7 驗收已寫死
---

# 糧橋插隊：**條件不成立，不插隊**

**measurer C6-#4 實測**（`dispatch-fail-90d.txt` @ `52f08fdf`，peaceful 90d seed 1337）：

```
dispatch_fail.資源不足   = 28 (100.0%)
dispatch_fail.糧橋不足   =  0 (  0.0%)
bridge.no_go_food       =  0
```

**28 次派遣失敗 100% 是建材不足；food-bridge 檢查這輪一次都沒機會執行**（建材 gate 更早短路）。

## ★我要撤回一句話
我上封對你說：「**與 `size_matter` 記的『settle 從未 dispatch』對得上 ＝ 強嫌疑**」。
**撤回。真正擋建造隊派遣的是建材，不是糧。**
——這正是我當時堅持「未實測不當事實用」、你也照准「條件准」的理由。**條件沒到，就不插隊。**

## 但這顆的狀態不是「誠實」，是「未爆」
`_eta_build` 高估 24× **仍然是錯的**，只是上游 gate 100% 先短路，**讓它沒機會咬人**。
⇒ 留在 §E 修正清單（走工期單一真相源批次），**不升 critical path**。

## 順手撈到一條 lead（已記 `known_issues.md`，**未動工**）
**`size_matter` 那條「三接入動詞各斷」的建造端，真閘在建材 `_can_afford` 1.5× 這一層。**
下一步該問的是：**那 28 次缺的是哪種建材、是不是 genuine-depletion**
（依既有紀律：池空 ≠ bug，先分 genuine vs 盲派）。**排序你定**，我不自己插。

## §7 世界層驗收已寫死（照你給的 acceptance）
| # | 驗收 | 形狀 | 現況 |
|---|---|---|---|
| 1 | `outpost.l0_to_l1 > 0` | ★**二值**，無旋鈕可假造 | **0** |
| 2 | `camp.abandoned < camp.built` | 結構：營地淨增長為正 | 25/28 ＝ 89% |
| 3 | `collect.no_outpost_no_camp_zero_food` **低於同床 main** | 相對非絕對 | 1244 vs 1133 ＝ 反向 |

★**門檻刻意不是我拍的百分比** —— 拍一個「棄置率 < 30%」正是本輪剛立的〈禁手抄物理〉要滅的形狀。
