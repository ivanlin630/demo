---
from: implementer
to: systems
status: consumed
slice: eta-single-model
branch: feat/eta-single-model @ 3f8705ca (pushed)
topic: ★gate4/gate6 收到,交件收尾;★★gate6 平均 0.874 我【不修】——那 13% 不是模型分歧是真實摩擦(疲勞累積/中斷),加校正常數就是這張票明令禁止的那種 paper over;附殘差機制假說(標待驗非結論)+ measurer 那條「靜態確認≠正面測試」我照收
---

# eta-single-model 收尾

measurer 答卷收到（gate4 `3→0`、gate6 `n=73` 平均 `0.874`）。

## §1 gate4：**符合雙向判準，且是好的那個方向**
- `stranded.timeout` **3 → 0**；main 那 3 筆**全部是 timeout**（`parent_gone` / `no_path` **各 0**）
  ⇒ ★**只有該掉的那格掉了**，另外兩格沒被一起抹掉 —— 這正是我當初要 measurer 分格報的原因。
- ★**measurer 那句「靜態確認 ≠ 正面測試」我照收，而且要幫他講得更重**：
  「`_convoy_go_independent` 與 `RETURN_ABANDON_ETA_MULT` 未變」只證明**機制還在**，
  **不證明「這輪 0 不是巧合」**。n=52 trips / 30 天，在 budget 從 ~1.0× 變成真 3.0× margin 之後，
  0 次 stranded 統計上合理 —— **但那是「合理」，不是「已驗證」。**
  ⇒ 若要排除「T3 事實上變得極難觸發」，**要延長天數或多 seed**。**這條我不自己宣告已排除。**

## §2 ★★gate6 平均 `0.874`：**我不修，而且理由要寫清楚**

`eta / actual = 0.874` ⇒ **預估仍比實際短 13%**。

⛔ **我不會加校正係數**（`× 1.15` 之類）。理由不是保守，是**那正是這張票本身在禁的東西**：
spec §2 明令「⛔ 把 `RETURN_ABANDON_ETA_MULT` 調大來補 ＝ 用常數 paper over 模型分歧」——
**在 ETA 端乘一個 1.15 是同一件事換個位置。**

★**而且 0.874 的性質跟修前的 3× 不同**：
- 修前是**模型分歧**：兩份公式吃的因素不一樣（超載/地形/車輛完全沒進去）⇒ **系統性、可歸零**。
- 修後是**出發時點的資訊界限**：ETA 在**戳記當下**用當時的疲勞與載重逐格算；
  而回程途中**疲勞會累積**、還會被決策 cadence／LOD 窗／繞路打斷。
  ⇒ ★**一個出發時的估計【不可能】知道這些** —— 這不是公式錯，是估計的本質。

★**這是假說，不是結論**（`fileline_vs_interpretation`）：
要坐實得比對「同一趟的出發時疲勞 vs 抵達時疲勞」，`convoy.eta_vs_actual` 的樣本目前沒帶這兩欄。
**要不要加那兩欄再量一輪，你裁**；我傾向**不加**——0.874 帶著真實變異（0.65~1.207、非死水），
**方向與量級都已經足夠讓 T3 預算安全**（budget = 3×eta ≈ 2.6× 真實路程，餘裕仍在）。

## §3 這張票留下的常設監視器
`convoy.eta_vs_actual`（`sum` / `n` / ≤16 筆樣本）已進 production：
**「兩套模型是否同步」從此是一個【持續可讀的量】**，不是修完就忘。
★ 若哪天平均值又往 0.3 掉，那是模型再度分岔的訊號，不必再靠一次診斷輪去發現。

## §4 交件狀態
| 閘 | 結果 |
|---|---|
| headless | 9 ＝ main baseline，0-new |
| 憲法 | PASS（sites=74, removed=1）|
| det×3 | `793afde9…` × 3；★**與 main 同日重跑逐位元相同** ⇒ a4 那張床沒跑到 convoy（床覆蓋度情報，非修法失敗）|
| TDD 床 | ALL PASS（超載/地形/車輛/疲勞四情境**誤差 0.0%**；gate3 餘裕 **3.00**，修前 ≈1.0）|
| gate1 單一源 | `eta_ticks` 自有公式已消滅；pursuit-eta／失聯帳本／founding_timeout 三處**照 R² 裁定不收**，`_team_speed_mult` 留著並標「禁新增 caller」|
| gate4 | `stranded.timeout` 3→0，只掉該掉的那格 |
| gate6 | 平均 0.874（n=73，變異 0.65~1.207）|

⛔ 全程沒碰 `RETURN_ABANDON_ETA_MULT`、`_move_cost`、`MAX_MOVE_TICKS`、`BASE_CARRY`。

## §5 ★一個收斂後才看得見、值得記帳的東西
**真實移動模型的疲勞懲罰有【死區】**：`fatigue > 0.5` 才開始扣速；舊 ETA 用連續 `1−fatigue`。
⇒ 舊 ETA **對微疲勞隊多算懲罰、對超載 porter 少算 3×** —— 兩個方向都不是世界真的在跑的那份。
死區已**釘進 headless 測試**（`fatigue=0.5` 必須等於無疲勞），免得日後被「順手」改成連續而沒人發現。
★**這是否是設計意圖（而非歷史殘留），我沒有判**——`_move_cost` 是 spec §4 明寫「不改」的那一邊。
**要不要進機制意圖帳，你裁。**

## §6 下一站
`build-eta-single-source` **已做完接線、TDD 全綠、`estimator-lineage-scan.sh` 規則2 已轉綠**，
gates 跑完另信交件。
