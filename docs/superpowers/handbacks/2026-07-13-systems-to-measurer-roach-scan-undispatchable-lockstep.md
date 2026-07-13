---
from: systems
to: measurer
status: consumed
topic: [★蟑螂普查] 掃有無其他隊卡「util最高但恆不可派→fallthrough鎖死同一task」模式(>30天單一task不變);crisis de-patch定序待此結果
---

# 工單：undispatchable-lockstep 蟑螂普查

用戶裁定（`2026-07-13-blueprint-to-systems-and-measurer-final-dispatch.md §4`）：crisis de-patch(重評381根) 押後，**先廣查蟑螂**——Team7 的 71% 買糧查出是健康行為（餓且本地無獵→合法買糧 fallthrough，非 bug，見 `2026-07-13-systems-to-blueprint-argmax-anomaly-resolved.md`），但不代表別隊/別 seed 沒真病態鎖死。

## 查什麼
掃描是否有隊**長期(>30天)卡在同一 task 不變**，且成因是 Team7 同款模式：**某 option util 最高但其 target 恆 (-1,-1)/不可派 → 每 tick fallthrough 到同一次佳 → 鎖死同一動作**。

判準（病態 vs 健康）：
- **健康**（如 Team7 買糧）：util-top option 不可派是**環境合理**（本地真無獵物），fallthrough 到的動作**真解決需求**（買糧真補糧、隊存活、pop 穩）。
- **病態蟑螂**：fallthrough 到的動作**沒解決需求**（如卡某 task 但 food 持續掉/pop 崩/繞圈），或 util-top option **本該可派卻因 bug 恆 -1**（target 解析錯，非環境真無）。

## 怎麼查（新工具已就緒）
1. **★新 log 標記已上**（我剛加，`specimen_tracer.gd`）：specimen 隊的 candidates print 現在對不可派 option 標 `✗`（如 `覓食=0.87✗ 買糧=0.58`）。∴ 一眼看出「util 最高但 ✗ 不可派 → winner 是別的」的 fallthrough 鎖死。
2. 用**現有 3-5 隊 90 天日記**（`docs/process/verdicts/winner-dist-contradiction-resolved.measure.json team_diaries`）先掃：找 winner 連續 >30 天同一 task 不變的隊。
3. 對疑似隊：把它設 specimen（`state.specimen_team_ids=[tid]`）重跑同 seed，讀 ✗ 標記的 candidates timeline，判「util-top 恆 ✗ fallthrough」是否成立 + fallthrough 動作有沒有解決需求。
4. 可補 1-2 個其他 seed 擴覆蓋（非必須，看時間）。

## 回報
- **找到真蟑螂** → 回報：哪隊/哪 seed、卡哪 task、util-top ✗ option 是誰、fallthrough 動作為何沒解決需求、pop/food 走勢佐證。
- **查無** → 回報「查無蟑螂」（Team7 模式是孤例/健康普遍）。
- crisis de-patch(i現在做/ii押後) 定序**等你這結果**才回頭問用戶，故此普查是 gating。

## ★可溯源協議（新鐵律，2026-07-13，務必遵守）
今起數字/證據寫 handback **必附來源檔+hash**（我剛定，見 `03b_measurer.md §量測可溯源協議` + `00_roles §量測可溯源鐵律`）：
- raw stdout **tee 落地** `docs/measurements/YYYY-MM-DD-<topic>-<seed>-<shortHASH>.log`（背景 task .output 是 scratchpad 會清，非落地檔）。
- handback 引數字附 `該log:行` + frontmatter `measured_at_head: <shortHASH>[-dirty]`。
- 別再裸轉述（71/22/7% 教訓）。

## 交接
留 main dir，`--path` 跑 branch code 或直接 main HEAD（現查 main 行為）。查完寄 `to:systems status:open`（★寄件永遠 open，consumed 由我讀後改）。
