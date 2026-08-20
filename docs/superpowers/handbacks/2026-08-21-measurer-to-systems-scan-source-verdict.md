---
from: measurer
to: systems
status: consumed
topic: "★★票1 verdict(40天完整)：你的假說部分成立但有算術矛盾——★★發現day/N共線confound(scan/team vs N k≈3.87 super-linear,但vs day k≈1.1近乎線性;n_teams本身vs day只k≈0.298次線性)，vs N的super-linear讀法跟既有k≈2.0總成本對不上；唯一乾淨結論=_find_own_outpost全圖掃持續佔74-99%應優先索引"
---

# ★★票1 verdict：40天完整跑完，你的假說「部分成立但有矛盾」

`.measure.json`：`docs/process/verdicts/scan-source-n2-attribution.measure.json`
落地：`docs/measurements/2026-08-21-scan-source-n2-warring-40d.jsonl`（warring_states seed1337 day1-40完整，n_teams 56→139）

## ①|team_discovered|分布：清楚在漲，但vs N還是vs day給出天差地遠的story

median從day1的2漲到day40的76（38倍）——確定不是flat/bounded。但★★：
- vs **n_teams**（你原本的判準）：k≈**3.668** R²=0.989——遠超線性
- vs **day**（elapsed time）：k≈**1.106** R²=0.938——幾乎剛好線性
- **n_teams本身 vs day**：k≈**0.298** R²=0.930——n_teams隨day成長本身是次線性/漸緩

代數上：若真正驅動是day(k≈1.1)，反推vs n_teams的視覺化k≈1.1/0.298≈3.7——跟我量到的3.668幾乎完全吻合。**這代表『vs N』那組super-linear表象，很可能是day↔n_teams共線性造成的數學假象**，真正驅動更像是「累積時間」（vision_system.gd:26-94逐tick偵查機制，append-only從不移除，天然隨經過的tick數累積），不是「隊越多每隊認識的隊越多」這種N直接驅動。

★誠實局限：單一run裡day/N天生共線，這份資料**無法乾淨切開兩個假說**——要真正分離需要對照式量測（不同seed/config讓day/N軌跡分離），本輪短窗預算內沒做。

## ②你的關鍵判準「掃描量/隊是否隨N線性上升」——字面『是』，但跟既有k≈2.0對不上

scan_per_team_day從165漲到8784（53倍），**vs n_teams: k≈3.871 R²=0.981**（vs day: k≈1.183，同樣接近線性）。

★★**算術矛盾**：若scan_per_team真以k≈3.87隨N成長，total scan volume(=scan_per_team×n_teams)對N的冪次會是**3.87+1≈4.87**——遠超你們之前用wall-clock時間量到的**k≈2.0**（`docs/process/verdicts/exam-12mo-verdict.measure.json`的near.faction_ai總成本回歸）。這兩個數字兜不起來，兩種可能：(i) 我這兩個tap(discovered_iter+global_tile)只捕捉了near.faction_ai裡的一部分工作，還有其他沒被tap到的per-eval運算（util評分/候選排序等）才是真正決定k≈2.0的主力，掃描迴圈只是配角(ii) 本run樣本量小(40點)+day/N共線造成回歸不穩定。**不下判斷，誠實報矛盾交你**。

## ③★唯一乾淨、不受day/N混淆干擾的結論：_find_own_outpost值得索引

global_tile_share從day1的99.18%緩降到day40的74.33%——**即使discovered_iter絕對量暴漲53倍，global_tile掃描仍佔了近3/4**。這條不需要解開day/N共線就站得住：`_find_own_outpost`（全圖world.tiles掃，被呼9次）持續是最大宗掃描來源，值得優先索引。

## 交你裁

你的假說「N²來自team_discovered隨N成長」**字面部分成立**（vs N的raw regression確實顯著），但更誠實的讀法是這個上升可能主要是「累積時間」驅動、被day/N共線放大成super-linear-vs-N的表象；且全信N-regression的話，隱含冪次(4.87)跟既有k≈2.0對不上，兩者不能同時為真。**建議先動`_find_own_outpost`索引**（不需要解開這個confound就是乾淨win），day-vs-N因果要不要開對照式量測交你判。temp tap/bed都在worktree(`.worktrees/scan-source-tap`)未merge，等你確認後我移除。地基KEEP。
