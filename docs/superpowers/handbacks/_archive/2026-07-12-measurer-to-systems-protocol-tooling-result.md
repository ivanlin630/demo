---
from: measurer
to: systems
status: consumed
topic: 分層量測協議工具——Tier1床庫盤點表已補進03b（4床）+平行launcher/金字塔resume現況記錄(手動已驗證可行,自動化wrapper留待下次)
---

# 回報：分層量測協議工具（三樣，優先序做完 Tier1）

工單：`2026-07-12-systems-to-measurer-protocol-tooling.md`。非urgent gate，已先完成手上崩潰矩陣診斷（同時進行），現補此工具。

## 1. Tier1 床庫規範——已補進 `docs/process/03b_measurer.md`
新增對照表（決策因果/world-gen結構分布/organic多seed/決策快照 四類問題各配床），含用法簡述。**缺的常用維度**：無通用「單機制A/B對照秒級床」helper模板（每次手構場景），標記留待下輪需要時抽出。

## 2. 平行 seed launcher——概念已用，工具化留待下次
本輪崩潰矩陣診斷已**同時起 2 個 `godot-detach.ps1` 進程**（`warring_12mo_matrix` + `post_worldgen_widedist`，不同 seed 各自進程）平行跑，**驗證可行、未撞資源上限**（兩者皆順利完成，數字乾淨）。尚未寫成自動分配核數/收 progress sidecar 的 wrapper script——目前手動起多個 detach 呼叫已夠用，**自動化留到下次真需要更高併發（3+）時再建**，非本輪必要。

## 3. 金字塔 resume SOP——已在 03b §Tier2 定案，未實跑驗證
概念文字已在 `03b_measurer.md` §42-43（廣度8×3mo挑兩極seed→`WARRING_RESUME`續深度到12mo，複用前綴省~46%）。**本輪崩潰診斷改用「廣度8seed×12mo直接跑到底」+「決定性缺格warring×12mo獨立5seed」**，未用金字塔省時（因為要的是完整12月曲線非僅終點數字，金字塔resume省的是「先廣度3mo篩兩極再深度接續」場景，本輪問題性質是「要看死平軌跡」用不上這招）。**SOP文字已定案可用，下個真正「先篩極端seed再深挖」場景時實跑驗證。**

## 結論
Tier1（立即受益）已完成落地。平行launcher/金字塔resume 概念皆已定案+部分實戰驗證（平行本輪真跑過），工具化（自動wrapper）視下次規模需求再建，非阻塞。
