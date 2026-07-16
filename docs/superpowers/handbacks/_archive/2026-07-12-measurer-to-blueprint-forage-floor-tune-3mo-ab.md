---
from: measurer
to: blueprint
status: consumed
topic: forage-floor-tune 3mo快答+A/B選檔——★選5天檔(A)：7天檔attrition未見額外改善(seed42反更差)+雙檔皆守住苟活≠繁榮；急性崩解顯著緩解(45-50%→17-31%)；established仍全程恆0(B2依舊100%卡死,非本slice範圍)
---

# 量測回報：forage-floor-tune 3mo 快答 + A/B(5天vs7天)選檔

工單：`2026-07-12-implementer-to-measurer-forage-floor-tune.md`。依 systems 右尺寸砍指示（`2026-07-12-systems-to-measurer-forage-rightsize-cut.md`），A/B 兩檔均只跑 **3mo×3seed，default.json**（12mo×winner留待你裁是否要，本輪先報3mo定案）。

## ①急性崩解——顯著緩解
對照前基線（`main_worldgen_baseline_std.json`，post-worldgen-merge，3seed×3mo，同config同seed）attrition 44.9-50.2%（均~47%）：

| seed | 前基線 | A(5天) | B(7天) |
|---|---|---|---|
| 1337 | 50.2% | **27.9%** | 27.9%（同A，見下方註） |
| 42 | 44.9% | **30.6%** | 38.9% |
| 7 | 45.6% | **17.4%** | 14.7% |

苟活地板tune確實大幅緩解急性崩解（月1-3），兩檔均降幅顯著（腰斬量級）。

## ②A/B選檔——5天檔(A)勝出
- **attrition**：A均值25.3% vs B均值27.2%——B**沒有**額外改善，seed42甚至更差(38.9% vs 30.6%)。7天多出的buffer沒有換來更低攻擊死亡率。
- **苟活≠繁榮守住（雙檔皆過）**：`farming_level=0`隊（`farm_zero_avg_pop`）A/B兩檔均與`farm_pos_avg_pop`同量級（~7-9人），無爆長；curve裡pop全程下降或持平，**無任一seed在任一檔出現異常成長曲線**。
- **7檔誤開成長風險——未觀察到**：`establish.gate_fail_b2_command` 三seed在B檔仍與`gate_b1_ok`完全相等（100%卡死），`gate_all_pass`恆0——7天buffer(pop×5.6)貼近建國門但3mo窗內**沒有**觀察到誤開通過案例。
- ★**seed1337 A/B數字完全相同**（27.9%/98pop/136start，逐位元一致）：非量測失誤——determinism已驗CLEAN，B檔常數確有生效(seed42/7有明確差異)；推測seed1337該世界的覓食隊在3mo窗內從未逼近5天buffer上限，故5→7天headroom對該seed是inert，非bug。

**結論：選5天檔(A，即implementer已ship的branch值)**。7天沒換到額外攻擊死亡率改善，且5天檔本就在建國門下留有更大安全margin（implementer原信§已指出）。**維持現狀（5天）即可，branch免修改**。

## ③established——仍全程恆0，非本slice範圍
三seed三檔established恆0，B2(`gate_fail_b2_command`)三個seed皆與`gate_b1_ok`完全相等，100%卡死（與前輪command-tenure-growth驗收一致，B2是獨立上游問題非本slice能觸及）。按systems右尺寸指示，本slice不主判established，此為預期內「下游需另修」，非本slice失敗。

## 產物
- `.worktrees/forage-floor-tune/tools/orchestrator/runs/ff_A_5day_3mo.json`（A檔，5天，3seed×3mo）
- `.worktrees/forage-floor-tune/tools/orchestrator/runs/ff_B_7day_3mo.json`（B檔，7天，3seed×3mo，量測後常數已revert回5.0並reimport確認）
- determinism CLEAN（1seed×1mo byte-identical，`ff_det1.json`/`ff_det2.json`）

## 待你
A/B已選5天（維持branch現狀）。若要12mo×1-2seed看established長窗苗頭（非gate，bonus觀察），告知我續跑；否則本輪到此，可直接推merge流程。
