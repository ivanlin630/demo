---
from: systems
to: blueprint
status: open
topic: [B4真根+全4門一次摸清·零跑+算] B4=食物軟gated recovery(0.3 floor非硬鎖,初始1.0,combat drain)已被食物修部分緩;★meta:立國門三重gate(統領+野心+readiness)把政治里程碑綁戰鬥/繁榮stat=過度gated,建議整體放寬非逐層
---

# B4 readiness 真根 + established 全 4 門一次摸清

## B4 readiness = 軟食物 gated recovery（非硬雞生蛋）
- **初始 readiness = 1.0**（team_data.gd:136）→ **隊開局就過 B4**（0.7），除非被 combat drain。
- **drain**：`npc_combat:284-287 ROUND_READINESS_DRAIN=0.08/round`（morale cascade ×2）——打仗掉得快。
- **recovery**（`interaction_system:105-118`，非戰鬥時）：`READINESS_RECOVERY_BASE(0.04) × (1+excess) × morale_factor × resource_factor`。
  - **resource_factor = 0.3 + 0.7×(food_used/food_needed)** → **食物 gated 但有 0.3 floor**（餓也能慢慢回,非 B2 那種硬鎖）。**食物修（forage floor）→ resource_factor 升 → readiness 回得快 = 一修多解部分惠及 B4**。
  - excess=(統領-0.8)/0.2 → 只統領>0.8 加成（多數 0）。morale_factor=1-unrest/30（動亂拖慢）。
- ∴ **B4 非硬雞生蛋**（recovery 有 floor 會動,初始 1.0）——比 B2/B3 溫和。真卡點=**warring 世界 combat drain > recovery 的 timing**（打太頻→立國 eval 當下 readiness<0.7）+ 動亂拖慢。食物修已部分緩。

## ★全 4 門一次摸清（established 調查鏈總結）
| 門 | 條件 | 型別 | 根 | 修向 |
|---|---|---|---|---|
| B1 | ≥2 成員 | 結構 | faction 要先形成（A 門 pop 上游） | 上游急性崩修（已 merged forage） |
| B2 | 統領≥~0.35 | **雞生蛋(累積)** | 統領唯一成長 P4_expand 被繁榮閘鎖 | command-tenure(日常成長)已裂開 4.2% |
| B3 | 野心≥0.6 | **靜態倒序** | 立國門(0.6)>建國門(0.55),野心不成長 | align 門檻(ESTABLISH 0.7→0.65) |
| B4 | readiness≥0.7 | **軟食物 gated** | combat drain>recovery timing,食物拖慢 recovery | 食物修部分緩;或降門檻/解耦 |

## ★★meta 觀察（給你/用戶,建議整體看非逐層）
**立國（政治里程碑）被三重 gate 綁在 戰鬥/繁榮 stat 上**：
- B2 統領（帶兵技能）+ B3 野心（人格）+ B4 readiness（戰備）**同時要高** → **只有「高統率+高野心+剛打完仗有餘力恢復」的繁榮好戰 faction 過得了**。
- 掙扎/和平/剛立足的 faction 結構性立不了國 → established 天生稀少。
- **這解釋為何 established 一路恆0**：不是單一門,是三重篩疊加,每個都要繁榮/好戰/雄心才過。逐層修（B2 de-patch→B3 align→B4 tune）能鬆,但**根本問題=立國門對「政治穩定」的定義過度綁戰鬥繁榮**。

**兩條路（vision 判,用戶裁）**：
1. **逐層 tune**（延續現做法）：B2 command-tenure merge + B3 align(0.65) + B4 降門/靠食物修。三個小改疊加,established 應鬆動。**保守、可驗證、但立國仍偏繁榮 faction**。
2. **★整體重思立國門**（vision）：立國該代表什麼？若「多數 faction 該穩定成國」是願景 → 現三重戰鬥/繁榮 gate 太嚴。可簡化為「≥2 成員 + 存活夠久（tenure）」為主,弱化統領/野心/readiness 硬門（它們當「立國速度/聲望」修飾而非硬 gate）。**大改但對症「世界從沒真正立國」根**。

## 序建議
- **B2/B3/B4 三門真根全摸清**（B2 雞生蛋/B3 倒序/B4 軟 gated）——不會再有「接力卡驚喜」,剩下是這三門 + A 門 pop。
- **待用戶裁**：路 1（逐層 tune,保守）vs 路 2（整體重思立國門,對症但大改）。**我建議帶用戶看這張全表 + meta**,一次定方向,免再逐層。
- 定方向後 → brainstorm→對抗→spec（單輪或組合）。measurer 12mo 續跑先擱置等方向定（免又測到下一層才知）。
