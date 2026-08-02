---
from: systems
to: reviewer
status: consumed
topic: "[R²乙整併util boost HOW(dispatch前必過,blueprint COMMIT方向)·spec docs/superpowers/specs/2026-08-01-scale-dynamics-consolidation-util-boost-HOW.md·根定案per-option util DUMP(吸納ownutil均0.104 vs贏1.09~10×弱/併入0.332 vs 1.23,吸納finder找4794但util餓死dispatch0)=決策層util-starvation非finder/travel/resolver·餓死公式§0b坐實(terms.gd:224-230 absorb_drive=BASE1.0×slack×(0.5+0.5yield)×(0.5+0.5·amb_gap),amb_gap=ambition×0.3被閹+base[0,1]cap+三factor連乘)=死常數過度正規化·de-patch:A absorb野心真放大(amb_gap→ambition_amp=0.5+AMB_GAIN·ambition_gap)+base保守抬 B join加理性protection urgency(弱near強非只絕境)·★審統一非補丁grep硬檢:①走既有argmax term pipeline(terms.gd drive+weight)無特判branch繞argmax②連續weigh非if ambition>X硬gate只連續乘③野心真放大是term re-weight非新機制④感知鐵律prey_pos/host_pos走belief保持·保守起步值靠§5合量tune·dev-verify小併大真fire+人格分化連續+保守未塌"
---

# R² 乙 整併 util boost HOW（dispatch 前必過）

spec：`docs/superpowers/specs/2026-08-01-scale-dynamics-consolidation-util-boost-HOW.md`。blueprint 已 COMMIT 方向（boost 整併 util、保守起步）。

## 根定案（per-option util DUMP、非靜態斷言）
- 吸納 ownutil 均 **0.104** vs 贏家 1.09（~10× 弱）、併入 0.332 vs 1.23。吸納 finder 找 **4794** 弱鄰但 util 餓死 **dispatch 0**＝**決策層 util-starvation**（非 finder/travel/resolver）。
- **餓死公式坐實**（terms.gd:224-230）：`absorb_drive = BASE(1.0) × slack × (0.5+0.5·yield) × (0.5+0.5·amb_gap)`，`amb_gap=ambition×0.3`（被閹）+ base [0,1] cap + 三 factor 連乘＝**死常數過度正規化餓死**。

## de-patch（審這對不對）
- **A absorb**：野心真放大（`amb_gap→ambition_amp=0.5+AMB_GAIN·ambition_gap`）+ base 保守抬 → 高野心強隊 absorb util 競 argmax、低野心 stay＝有大有小人格分化。
- **B join**：加理性 protection urgency（弱 near 強、非只絕境）→ 健康弱隊理性投靠（順帶治 97% mid-travel 死）。

## ★審統一非補丁 grep 硬檢（blueprint 定）
| # | 約束 | grep 硬檢 |
|---|---|---|
| ① | 走既有 argmax term pipeline、無特判 | grep 無 `if ...dispatch 吸納/併入` 繞 argmax；只改 terms.gd drive + weight |
| ② | 連續 weigh 非硬 gate | grep 無 `if ambition>X`/`if 野心>X` 階梯、只連續乘 |
| ③ | 野心真放大＝term re-weight 非新機制 | absorb_drive 公式改係數、非新 option/判斷器 |
| ④ | 感知鐵律 | prey_pos/host_pos 走 belief 保持（terms/options 既有） |

## 審點
- de-patch 是否真 de-patch（拆死常數過度正規化）非疊補丁？
- 野心放大會不會過衝（保守起步值合理？）——注意 spec §4 保守起步 + §5 合量 tune，**exact 值非現在定**（blueprint 定起低）。
- dev-verify（§3）硬斷夠：小併大真 fire（dispatch>0+merge>0 隊數降）+ 人格分化連續非階梯 + 保守未塌 1 blob + determinism。
- **CLEAN → 我 dispatch 隔離 branch**。有洞 → 回 `to:systems`。甲已 merged、§5 合量待乙。
