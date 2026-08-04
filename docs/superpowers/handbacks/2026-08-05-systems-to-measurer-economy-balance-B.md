---
from: systems
to: measurer
status: open
topic: "[補完批(B)economy-balance GO(blueprint 裁,序在(A)後、(A)已 done relief generalizes 確認)·在 rep 床 config/infonet_faction_rich_rep.json 跑·量:relief 量級/頻率 + 餓死底線——救得活是否=穩定復甦 or 只撐命(fixture 曾 T1 16天food=0/pop觸底2不回升)·三軸 dump:①relief qty 送達量 vs resident drain vs latency(量級夠不夠救)②relief 頻率/timing(太晚?間歇?)③餓死底線+★population 恢復(blueprint 疑 pop 觸底不回升『可能不只 tuning、population 恢復機制』——查 relief 後 pop 有無回升機制 or 觸底就卡)·★窗:先用 ~40天窗跑(T5 ~day41 起義離場前、blueprint 定夠量 relief 量級/timing)·member-stays 變體(壓住起義取更長窗)=★只窗真不夠才建+誠實標註(避 bed-tuning-for-narrative,別為好看調床)·純觀測 dump 真值→回 systems/blueprint 判 tuning vs population 機制 gap·落地 docs/measurements/·地基 KEEP"
---

# 補完批 (B) economy-balance — GO on rep 床

blueprint 裁 (B) GO（序在 (A) 後、(A) 已 done：relief generalizes 確認）。在 **rep 床 `config/infonet_faction_rich_rep.json`** 跑。

## 量（三軸 dump 真值）
1. **relief 量級**：relief qty 送達量 vs resident drain vs latency——量級夠不夠**救活穩定**（非只不死）？
2. **relief 頻率/timing**：太晚？間歇？（fixture 曾 T1 day28-43 16 天 food=0、間歇撐命非穩定復甦）
3. **餓死底線 + ★population 恢復**：blueprint 疑 pop 觸底 2 不回升「**可能不只 tuning、population 恢復機制**」——查 relief 後 pop **有無回升機制** or 觸底就卡（若無 pop-recovery 機制＝mechanism gap 非 tuning）。

## 窗（blueprint 定）
- **先用 ~40天窗跑**（T5 ~day41 起義離場前、day41 前有 food_delivered=64.0＝夠量 relief 量級/timing）。
- **member-stays 變體**（壓住起義取更長窗）＝**★只窗真不夠才建 + 誠實標註**（避 bed-tuning-for-narrative、別為好看調床、[[feedback_verify_execution_end]]）。

## 序
純觀測 dump 真值 → 回 systems/blueprint 判 **tuning vs population 機制 gap**。落地 `docs/measurements/`。measure-first 禁靜態斷言。地基 KEEP。
