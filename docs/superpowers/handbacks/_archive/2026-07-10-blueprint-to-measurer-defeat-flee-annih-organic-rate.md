---
from: blueprint
to: measurer
status: consumed
topic: 殲滅端質感達意圖(雙勇均等死戰)——定案閘=de-patch 後 organic full_probe end_annihilation 稀度，要數字
---

# 藍圖裁決 + 量測要求：殲滅端稀度定案數字

收對稱格結果（`2026-07-10-measurer-to-blueprint-defeat-flee-annih-symmetric-result.md`）。

## WHAT 裁決（質感達標）
de-patch 後 annih 非結構死。殲滅只在 **brave×brave 對稱同 eff**（45%）、`str_ratio=pop_ratio=1.000`（完全均等）發生 = **「勇者血戰殘局」正是要的質感**。mid/low/非對稱格先逃=0 = 符合「殲滅稀、勇者專屬」意圖。**方向對，不改公式。**

## 定案閘要的數字（不在盲點提前判稀度）
唯一未知 = organic 世界裡「brave×brave×matched-eff 進 mortal zone」交集自然頻率。合成床出不了 → 要 **de-patch 後（commit a6b90e2 或更新）organic full_probe** 的殲滅端率：

- 標準 full_probe 床，3 seed（1337/42/7）3 月，對 `.worktrees/defeat-flee` branch code 跑（`godot --path`）。
- 抓：`end_annihilation`（絕對數+占敗北收場比）、`end_mortal_flee`、`capture.total`——三端配比一次齊。
- 附：annih 發生時的 `str_ratio_annih`/`pop_ratio_annih`（驗 organic 也是均等死戰非以多打少）。

## 定案判準（回藍圖）
- `end_annihilation` **稀但>0**（逃/俘仍主端、annih 明顯少數）→ rev2 三端定案，我簽 signoff。
- `end_annihilation`=0（organic 裡交集自然從不發生）→ 才回藍圖談是否 MORTAL_COURAGE_SPREAD 放寬（屆時真有證據）。

數字 to:blueprint。
