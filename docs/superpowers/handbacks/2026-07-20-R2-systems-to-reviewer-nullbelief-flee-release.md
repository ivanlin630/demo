---
from: systems
to: reviewer
status: open
topic: "[R² spec·null-belief-flee 凍結根治·Slice D 前必修] blueprint 認可修方向。spec=2026-07-20-nullbelief-flee-release.md。root:個體 FLEE(faction_ai:1595/1948)flee_from_pos=_flee_threat_pos=威脅 belief 位;positionless→(-1,-1);movement:82 無座標時無 target+continue(『靠 release 收』空話沒人 release)→卡 task=逃跑 凍結餓死(team75/4/13)。修 look-before-leap:A dispatch flee_from_pos==(-1,-1)→release FLEE(轉 IDLE→re-rank 覓食);B movement backstop 落實 release 非 continue-freeze。審點:①A release 後 survival re-rank 真接得到覓食(非又卡別的)②不誤傷 coherent flee(team67/54 有座標正常逃)③不回退 live-track(無座標=轉覓食非偷讀 live 逃,守 belief-化)④A+B 是否重複(A 夠則 B 冗餘 defense or 真需 backstop 邊角)⑤release 撤 FLEE 的 side-effect(flee_from_pos 清?combat?)。off main HEAD。CLEAN→dispatch。Slice E measure(baseline diff)另線確認 pre-existing 中,此 fix 獨立(治 pre-existing bug,非 Slice E)。"
---

# R² spec：null-belief-flee 凍結根治（Slice D 前必修）

spec：`docs/superpowers/specs/2026-07-20-nullbelief-flee-release.md`。blueprint 認可修方向（look-before-leap）。PRE-EXISTING（獨立於 Slice E，Slice E measure 另線確認中）。

## root（file:line 坐實）
個體 FLEE `faction_ai:1595/1948` flee_from_pos=`_flee_threat_pos`=威脅 belief 位；positionless→(-1,-1)；`movement:82` 無座標時無 target + `continue`（註「靠 release 收」= 空話沒人 release）→ 卡 task=逃跑 凍結餓死。

## 修（look-before-leap）
- **A（primary）**：FLEE dispatch `flee_from_pos==(-1,-1)` → `TaskArbiter.release(team)`（撤 FLEE→IDLE→re-rank 覓食）。或 FLEE option applicability gate（`_flee_threat_pos != (-1,-1)` 才 applicable）。
- **B（backstop）**：`movement:82` 落實 release（非 continue-freeze）防邊角。

## R² 審點
1. **A release 後真接得到覓食**：release→IDLE→survival re-rank 真選覓食（非又卡別態）？（finder-check 揭 survival option 通常 finder-hit → 應接得到，確認。）
2. **不誤傷 coherent flee**：team67/54 型（威脅有座標）正常逃不受影響（只 gate positionless）。
3. **不回退 live-track**：無座標→轉覓食（顧眼前），**非偷讀 live 位逃**（守 belief-化，感知鐵律）。
4. **A+B 重複?**：A（dispatch gate）夠則 B（movement）是冗餘 defense；還是真需 backstop（timing：FLEE 設後 belief 過期成 positionless，A 抓不到）？
5. **release side-effect**：撤 FLEE 清 flee_from_pos？combat lock？（`TaskArbiter.release` 已清 move_target/flee_from_pos，確認 FLEE 撤乾淨。）

## 回覆
`to:systems`：CLEAN / blocking。CLEAN → dispatch implementer（off main HEAD）。★Slice D 前必落地（blueprint 裁：D belief-化不再被此污染）。
