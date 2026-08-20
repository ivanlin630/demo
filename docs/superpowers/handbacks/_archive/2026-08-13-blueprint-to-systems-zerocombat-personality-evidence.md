---
from: blueprint
to: systems
status: consumed
topic: "[零戰死診斷加硬證(用戶要各隊個性時挖到、餵你在跑的零戰死pin):★好戰個性存在但攻擊從不在候選=候選#1(combat option不生成)強過候選#2(force-draw)·8指標團初始leader_traits好戰∈[0.02,0.6]:team6好戰0.6/team42好戰0.57(野心0.62)=真好戰團,但兩者(及全8團)初始decision candidates從來沒有攻擊/圍攻/戰鬥option——team6只{建設},team42只{囤貨,建設},team36{覓食,囤貨,駐守,建設},最多到駐守=沒一個團的util競秤裡有『打』這個選項·∴零戰死root強烈指向『攻擊候選根本不被generate』(engine option-set缺戰鬥分支 or 生成條件極嚴從不滿足)、非『打了被force-draw』也非『好戰太低沒人想打』(好戰0.6擺著沒用=個性WEIGHS但無option可秤=死線索)·★仍請你排除bed:76 encounter watchdog(可能另一層)但candidate-set無attack是更上游·連[[feedback_patch_gate_first]]?非補丁是option缺失·★另富窮分明餵famine診斷:富團倉糧800→存糧1300(team0/12/36)vs窮團倉糧0→存糧250/180(team6/18/24/30/42)=餓死全是無倉糧團=無home-base→只私糧250÷日耗8≈31天餓死·famine可能=無base團結構性缺糧非全域經濟崩、餵measurer genuine-vs-bug·數據檔docs/measurements/2026-08-13-phase3-initial-attrs-personality.md·禁預設"
---

# 零戰死診斷加硬證：好戰個性存在但「攻擊」從不在候選

用戶要各隊個性時挖到，餵你在跑的零戰死 pin。

## ★候選#1(combat option 不生成)強過候選#2(force-draw)
8 指標團初始 leader_traits 好戰 ∈ [0.02, 0.6]：
- team6 好戰=**0.6**、team42 好戰=**0.57**（野心0.62）= 真好戰團。
- 但兩者（及全 8 團）初始 decision `candidates` **從來沒有攻擊/圍攻/戰鬥 option**：team6 只 `{建設}`、team42 只 `{囤貨,建設}`、team36 `{覓食,囤貨,駐守,建設}`，最多到「駐守」。
- ∴ 沒一個團的 util 競秤裡有「打」這個選項。

→ 零戰死 root **強烈指向「攻擊候選根本不被 generate」**（engine option-set 缺戰鬥分支、或生成條件極嚴從不滿足），**非「打了被 force-draw」、也非「好戰太低沒人想打」**（好戰 0.6 擺著沒用 = 個性 WEIGHS 但無 option 可秤 = 死線索）。
★仍請排除 bed `:76` encounter watchdog（可能另一層），但 candidate-set 無 attack 是更上游。是 option 缺失、非補丁閘。

## ★富窮分明（餵 famine 診斷）
富團倉糧 800→存糧 1300（team0/12/36）vs 窮團倉糧 0→存糧 250/180（team6/18/24/30/42）= **餓死全是無倉糧團 = 無 home-base → 只私糧 250 ÷ 日耗 8 ≈ 31 天餓死**。
→ famine 可能 = 無 base 團結構性缺糧、非全域經濟崩 → 餵 measurer genuine-vs-bug。

數據檔 `docs/measurements/2026-08-13-phase3-initial-attrs-personality.md`。禁預設。
