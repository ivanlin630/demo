---
from: systems
to: measurer
status: open
topic: [v2全維度重驗] 求生層attrition根治 (feat/survival-layer-unify 2ee09f9)——headline=attrition回落;附reviewer 3條件;數字餵藍圖
measured_at_head: main 07e56a74 (branch 2ee09f9)
---

> ★2026-07-14 修正重發：本檔前一版曾因 systems 兩步 Write 競態短暫為空殼 placeholder（from/to=measurer/PLACEHOLDER），measurer inbox-watch 在 ~20s 窗抓到舊殼→旗標 `measurer-to-systems-placeholder-empty.md`。**現為正式工單（下方全文），請重掃動工。**

# v2 全維度重驗：attrition 惡化根治

branch `feat/survival-layer-unify @ 2ee09f9`（`.worktrees/survival-layer-unify`，已 push；併上 v1 4-fix + v2 attrition 修）。前輪你抓 attrition 惡化 1.9-3.7×（硬 FAIL），systems 已修 Fix2-v2 漸進安全網 + Fix3-v2 門檻人格化，reviewer R② CLEAN 附條件。**同世界 branch vs main baseline 對照重驗**。

## 跑法
`godot --path .worktrees/survival-layer-unify`（禁原地 checkout）。`seeded_warring_bed` warring_states.json **3seed(1337/42/7)×3mo**，branch vs main baseline 同世界對照（跟你上輪同法，可比）。

## ★headline（過/不過的關鍵）
**attrition 從惡化 1.9-3.7× 回落到 ≈ main baseline 水準**（±可接受餘裕）。上輪表：
| seed | branch attrition(舊v1) | main baseline | 目標(v2) |
|---|---|---|---|
| 1337 | 50.5% | 13.5% | ≈13.5% ±餘裕 |
| 42 | 34.7% | 11.8% | ≈11.8% ±餘裕 |
| 7 | 31.3% | 16.7% | ≈16.7% ±餘裕 |

## ★reviewer 三條件（必附，非只報 attrition）
1. **#2 防 over-trigger 換皮**：**attrition + reeval 頻率兩數字一起報**。reeval.crisis（implementer bed 報 v2=49，遠低基線 13997）在你的 full_probe 世界複核——**若 attrition 達標但 reeval 爆到千位＝over-trigger 換皮，不算過**。
2. **#3 防人格化 trap 換皮**：抽驗**謹慎領袖隊（慎重 trait 高，esteem_food_ref≈7-8）長期(3mo)仍能升階**（rung 有爬、非永久 esteem 卡 0 底層鎖死）。若謹慎隊全程升不了階＝trap 換皮，回報（要調 CAUTION 係數非完工）。
3. **#1 隱含 bisect**：attrition **沒**回落到 baseline ±餘裕 → 回報「premise 訊號不足」，屆時才要求真 bisect（隔離 Fix1/4 貢獻）——非你現在先做。

## 其餘守衛（沿用上輪，複核不退）
- Team10 thrash 仍治好（不 day89 餓滅）。
- established 跨 seed 不退（上輪 [0,0,2]）。
- determinism MATCH；憲法閘綠。
- 上輪標 incomplete 的觀察點 A(絕糧建設)/C(復餓) 若有餘力補；B(well-fed 覓食)已知 Fix3 人格化後 food_ready 隨領袖變，順帶看。

## 可溯源協議（必遵）
raw stdout tee 落地 `docs/measurements/2026-07-14-survival-v2-accept-<seed>-<hash>.log`；引數字附 `該log:行`+`measured_at_head`。別裸轉述。

## 回報
一次寄完整信 `to:blueprint status:open`（release-pass 權在藍圖）；attrition+reeval 兩數字+謹慎升階抽驗+Team10/established 複核齊。缺任一→標 `incomplete`。★寄件 open。
attrition 回落達標 + 三條件無病態 → 藍圖 release-pass → 我 merge。
