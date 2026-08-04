---
from: systems
to: measurer
status: consumed
topic: "[re-measure症1 on persist bed(game_setup faction-key修後20a7d8ef):①T1仍救活confirm(alive_at_end+runway回升,faction fix不退)②★T3死歸因confirm genuine人格vs masked gap(measure-first別浪漫化,同T3 setup教訓):implementer報T3死day41=faction2 relief鏈不engage(T3 proud求生0.2不broadcast求援+T2 neglectful不scout偵察→T2聞0)·需dump證genuine人格gate:(a)T3每cadence求援mini-util值+人格traits(求生欲/傲氣)——mini-util真低因傲(HELP_PRIDE_SUPPRESS)vs mini-util算得高但applicable/dispatch被擋(masked)?(b)T2偵察mini-util值+人格(關切/疏忽)——真低因neglect vs 被擋?(c)★關鍵discriminator:若人工把T3 distress塞進T2 team_known,T2會不會賑濟?(證鏈下游OK只上游人格不broadcast=genuine)vs仍不賑濟(masked下游gap)·bed config/infonet_whole.json persist,GODOT_TIMEOUT=1200·faction結構確認T2/T3同faction(fac1)·+症1 specimen trace(T1救活故事+T3死因故事)餵QA·純觀測·落地docs/measurements→我讀定genuine人格emergent(feature)vs masked gap(bug)·別下accept結論分機制/人格層"
---

# re-measure 症1 on persist bed（game_setup 修後）：T1 confirm + T3 死歸因 genuine 人格 vs masked

game_setup faction-key 修（`20a7d8ef`）：faction 結構=config 意圖（T2/T3 同 faction fac1）。**branch** `feat/info-network-whole 20a7d8ef`、worktree、`GODOT_TIMEOUT=1200`。

## ①T1 仍救活 confirm
- `alive_at_end` + runway 回升保持（faction fix 不退 T1 救活）。

## ②★T3 死歸因 confirm：genuine 人格 vs masked gap（measure-first、別浪漫化）
implementer 報 T3 死 day41=faction2 relief 鏈不 engage（T3 proud 求生 0.2 不 broadcast 求援 + T2 neglectful 不 scout 偵察 → T2 聞 0）。**需 dump 證 genuine 人格 gate**：
- **(a) T3 每 cadence 求援 mini-util 值 + 人格 traits（求生欲/傲氣）**——mini-util **真低因傲**（`HELP_PRIDE_SUPPRESS`）vs mini-util 算得高但 applicable/dispatch 被擋（masked）？
- **(b) T2 偵察 mini-util 值 + 人格（關切/疏忽）**——**真低因 neglect** vs 被擋？
- **(c) ★關鍵 discriminator**：**若人工把 T3 distress 塞進 T2 team_known、T2 會不會賑濟?**（證鏈下游 OK、只上游人格不 broadcast=**genuine 人格 emergent**）vs 仍不賑濟（masked 下游 gap=bug）。

## faction 結構確認
- tap 確認 T2/T3 同 faction（fac1）、T0/T1 同 faction（fac0）=config 意圖（faction fix 生效）。

## specimen（餵 QA）
- 症1 specimen trace：**T1 救活故事**（求援→letter→領主聞→賑濟→糧到）+ **T3 死因故事**（proud 不求援/neglectful 不偵察→無 relief→死）→ 餵 QA 故事稽核。

## 交付
- 純觀測。落地 `docs/measurements/` → 我讀**定 genuine 人格 emergent（feature）vs masked gap（bug）**。**★別下 accept 結論、分機制/人格層。** 卡 → 報 `to:systems`。
