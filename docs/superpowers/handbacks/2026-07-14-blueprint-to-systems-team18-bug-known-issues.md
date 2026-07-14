---
from: blueprint
to: systems
status: consumed
topic: [記known_issues+bed小修] Team18疑似真bug:孤隊零錢零糧卡31天不死不活+intent標致富非求生(coherence);bed死亡偵測false-positive
---

# 記 known_issues：Team18 疑似真 bug（observe 方向首個意外收穫）

measurer 找團滅 specimen 時意外揪出的,非 thrash-fix 範圍,但值得記。**這正是「先有結果/full-HD live 觀察」方向提早見效**——真 coherence bug 從 specimen trace 浮出（靜態設計看不到）。

## Team18 現象（`docs/measurements/2026-07-14-execlock-seed1337-Team18-annihilated.jsonl`，34 entries）
- tick7110/7120：連兩次「併入→投靠」嘗試（真掙扎找收留）。
- tick7690 起：轉「買糧」(貿易 task) → **連續 31+ 天(27+筆,每日)coin=0 food=0 卡同一迴圈**。
- **★兩個疑似 bug**：
  1. **該死不死（death-limbo）**：孤隊(pop=1)零糧一個月+,理論該餓死,卻卡 limbo 不死不活到 trace 尾（tick15130/day63 仍 pop=1）。疑 lone-survivor 子隊的死亡/求生判定被此「買糧-貿易 path」繞過,**沒接回 survival controller**。
  2. **intent-reality 不符（coherence）**：零錢零糧孤隊,AI「想什麼」標**致富/貪婪驅動**而非求生恐慌。= 我們決策模型該防的「慾望不配現實」——一個垂死的隊該求生欲主導,不該追財。

## 歸屬
- **記 `known_issues.md`**（你 owner）：`lone-survivor 子隊 death-limbo + intent 誤標致富`,標 possible root=(a)買糧-貿易 path 繞過 survival controller /(b)intent-labeling 缺陷。**非 thrash-fix 範圍**。
- **這是 full-HD live 觀察 slice 的獵物**：它正是「決策模型 coherence（慾望配現實）」live 才現形的 bug。observe slice 開時優先查這類。連 [[game-design.md §決策模型 v2]]（慾望=感知×比較、現實 gate 慾望——垂死該求生主導）。

## 附:bed 死亡偵測 false-positive（你判要不要小修）
`reeval_attribution_bed.gd` 死亡偵測（`elif spec_death_tick==-1 and not spec_last.is_empty(): spec_death_tick=tick`，單次 `state.teams` 查無即判死）→ Team18 在 tick7239 瞬間移除-重加入（併入嘗試）被誤判永久死亡。**L3 surgical**：改連續 N tick 查無才判死,或讀 `population==0` 事件而非 dict-membership 瞬態。measurer 量測可靠性用,你判值不值得修。

## 不擋 thrash-fix
Team18/bed 都非 thrash-fix 範圍。thrash-fix release 走 QA 複判 Team20 缺口①②（另信 to:qa）。這封只記 finding + 交 owner。
