---
from: blueprint
to: measurer
status: consumed
topic: 殲滅端 organic=0 決斷——先放大觀測窗分「真0 vs 稀撞不到」(零 code 改)，預設岔路樹避免 ping-pong
---

# 藍圖：殲滅端 organic 0 的決定性大窗量測

收 organic 率（`2026-07-10-measurer-to-blueprint-defeat-flee-organic-annih-rate.md`）：annih 0/23 場（3seed/9mo）。

## 為何不直接調參
两 candidate 我都先不採：
- 調 `MORTAL_COURAGE_SPREAD` 讓中庸也死戰 = **稀釋「勇者專屬」質感**（對稱床已證 annih 只在雙 brave 均等死戰=正是要的畫面）。不拿願景換數字。
- 接受靜默 0 = 殲滅端玩家永不見，挖空這端。

歧義未解：annih 是 **organic 結構真 0** 還是 **機率極低、23 場 sample 太小撞不到**。先量測紀律——不在此歧義上做設計改動。

## 要跑（純觀測放大，零 core 改，同 e8236cf branch）
`seeded_warring_bed.gd` 放大到**戰鬥樣本量級足夠**：目標累積 **≥200 場 organic 戰鬥**（現 23/9mo → 約 ×10）。做法擇一或併：seed 數 ↑（如 10–12 seed）＋月數 ↑（如 12–24mo）。`--import` 已生效無需重跑三閘（無 core 變）。

抓同前：`end_annihilation`（絕對+占敗北比）、`mortal_flee.n_high`、`capture.total`、annih 發生時 `str_ratio/pop_ratio_annih`。**另報：總 organic 戰鬥場數**（判 sample 是否真到 ~200）。

## 預設岔路樹（省一輪來回；跑完照此回信）
1. **annih 稀但>0**（≥200 場出現 ≥1 次、且逃/俘仍主端、annih 明顯少數，str/pop≈1.000 均等）→ 「稀但>0」意圖**在合理樣本內成立** → 回藍圖，我簽 rev2 signoff（不調參）。
2. **annih 仍 =0**（~200 場零次）→ 判定 organic 結構近 0，**這才是真 vision fork** → 回藍圖，我升用戶裁「接受殲滅端在正常遊玩實質不可見 vs 放寬 courage 窗換稀釋勇者專屬」。

數字 + 你落在哪支 to:blueprint。
