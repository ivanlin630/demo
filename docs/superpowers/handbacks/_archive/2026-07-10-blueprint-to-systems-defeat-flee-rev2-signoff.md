---
from: blueprint
to: systems
status: consumed
topic: [SIGNOFF] 敗北逃 rev2 定案——三端達意圖(逃常態/俘中頻/殲滅接受不可見)，可 merge feat/defeat-flee
---

# 藍圖 signoff：敗北逃 rev2 定案

用戶已裁（2026-07-10）。三端配比定案，`feat/defeat-flee`（@e8236cf 或更新）可 merge。

## 三端最終判定
| 端 | organic 實測(大窗 219 場) | 判定 |
|---|---|---|
| 逃/潰散(mortal_flee) | 83.1% | ✅ 常態，達意圖 |
| 俘虜(capture) | 30 場（14% 敗北收場中大宗） | ✅ 中頻，達意圖 |
| 殲滅(annihilation) | 0.0%（219 場零次） | ✅ **用戶裁「接受不可見」** |

## 殲滅端裁決（用戶定案）
- de-patch 傷亡累積器（a6b90e2）**保留**——機制正確（對稱床 brave×brave 45%、str/pop=1.000 均等死戰質感精準），只是 organic 交集雙重窄縫相乘 → 實質不可見。
- **不放寬 courage 窗**（放寬會稀釋「殲滅＝勇者專屬殘局」質感，用戶不要）。
- 殲滅端定位＝理論賭注地板（正因全滅可能，逃才有重量），非常見收場。設計事實已寫進 `game-design.md`（敗北模型段）。
- **不追加 code 改**——rev2 現狀即定案。

## 給 systems（HOW 收尾）
1. merge `feat/defeat-flee` → main（融合驗/憲法閘/sanity 綠才 merge，你的閘）。
2. 你 owner 的 doc 反映 rev2 落地：`progress.md`（敗北逃 rev2 done）、`known_issues.md`（若先前有記殲滅-heavy/annih 相關項，closeout）、`invariants.md`（若 mortal-zone 傷亡累積器涉及不變量）。exercise 床 debug 檔（`defeat_flee_annih_exercise_bed.gd`）去留你定。
3. rev2 教訓提煉入 auto-memory（你單寫者）：捨入結構閘掐死小 pop 流血=補丁閘型病、de-patch 累積器修法、殲滅端窄縫疊窄縫 organic 不可見的設計接受。

merge 完 handback to:blueprint 收尾確認即可，無需再回量測。
