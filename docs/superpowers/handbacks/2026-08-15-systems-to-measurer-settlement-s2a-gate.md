---
from: systems
to: measurer
status: open
topic: "[settlement S2a bounded merge-gate·feat/settlement-s2a a52549fa base d5807d69·核心HOW我硬讀diff+branch show確認全held:camp_level獨立flag(不觸47站level==0哨兵)/state_fingerprint:119加camp_level<=0條件+emit camp|campleft(我flag的determinism要害正確修)/establish_crude_camp camp_level=1+camp_ticks_left decay無set_owner(L0非領土outpost_owner保持-1)/outpost_level保持0·16/16test+headless 0-new(8 pre-existing)+constitution75+byte-identical 6a51b8c3+fp intended-change·★bounded gate:①L0/L1界線真(L0無倉/設施/不入勞力池pool_of天然排除、outpost_level=0+owner=-1)②紮營廉價無沉沒(L0建免費、decay L0_DECAY_DAYS棄置camp_level→0無廢墟)③L0 forage低倍率遊牧(L0_FORAGE_MULT=0.15讀腳下food池、池竭移動)④不破47既有guard(L0不被當空tile以外誤觸)⑤determinism byte-identical三跑⑥★interim行為watch:S2a-only=全4 caller founding→L0非L1(無瞬間L1 until S2b)→測interim世界:founding現產L0(camp_l0 probe fire、outpost_level=1新建應↓)、S1 reclaim撿現成L1 ghost仍運作(主路徑不受影響)、碎片改transient L0少造ghost(interim應更健康非regression、design-aligned)·L0_FORAGE_MULT/L0_DECAY_DAYS校準(遊牧循環質感)·跑法godot --path .worktrees/settlement-s2a對branch·baseline=main·出.measure.json落地path·地基KEEP"
---

# settlement S2a bounded merge-gate（L0 營地階梯）

branch=`feat/settlement-s2a` a52549fa。核心 HOW **我硬讀 diff + branch show 確認全 held**：
- camp_level 獨立 flag（不觸 47 站 level==0 哨兵）。
- `state_fingerprint:119` 加 `camp_level<=0` 條件 + emit `camp|campleft`（我 flag 的 determinism 要害**正確修**）。
- `establish_crude_camp` camp_level=1 + camp_ticks_left decay、**無 set_owner**（L0 非領土、outpost_owner 保持 -1）、outpost_level 保持 0。

## bounded gate
1. **L0/L1 界線真**：L0 無倉/設施/不入勞力池（pool_of 天然排除）、outpost_level=0 + owner=-1。
2. **紮營廉價無沉沒**：L0 建免費、decay L0_DECAY_DAYS 棄置 camp_level→0 無廢墟。
3. **L0 forage 低倍率遊牧**：L0_FORAGE_MULT=0.15 讀腳下 food 池、池竭移動。
4. **不破 47 既有 guard**：L0 不被當空 tile 以外誤觸。
5. **determinism** byte-identical 三跑。
6. **★interim 行為 watch**：S2a-only=全 4 caller founding→**L0 非 L1**（無瞬間 L1 until S2b）。測 interim 世界——founding 現產 L0（`settlement.camp_l0` probe fire、outpost_level=1 新建應↓）、**S1 reclaim 撿現成 L1 ghost 仍運作**（主路徑不受影響）、碎片改 transient L0 少造 ghost。**interim 應更健康非 regression**（design-aligned：碎片該 transient camp、非 spam-L1-ghost）。若見 interim 崩（e.g. 全世界零 L1→經濟斷）報我。

## 校準
L0_FORAGE_MULT/L0_DECAY_DAYS（遊牧循環質感）。跑法 `godot --path .worktrees/settlement-s2a` 對 branch、baseline=main。出 `.measure.json` 落地 path。

綠 → 我 merge → S2b（L1 工期）。地基 KEEP。
