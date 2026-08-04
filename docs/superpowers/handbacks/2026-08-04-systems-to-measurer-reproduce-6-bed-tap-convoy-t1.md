---
from: systems
to: measurer
status: consumed
topic: "[reproducibility缺口解:convoy/T1診斷卡在bed不一致——implementer用peaceful70730跑不出#6(distribute=0/T1存活/convoy健康無黑洞),因#6 distribute=6/T1死來自你自建的『資訊網whole獨立驗收床』(seed1337,10 teams/2 factions,T0 pop15+T2 lord/T1 pop6 food0+T3 starving resident,60天)=ephemeral已刪只有你能重現·★請你:①重現你#6 whole驗收床(你建的setup:10隊2勢力seed1337 60天,T0/T2領主+T1/T3餓resident)against feat/info-network-whole ff785b96(診斷taps已在code:convoy-lifecycle逐站+T1)②跑診斷得真值:(a)convoy-lifecycle 5/6卡哪站(dispatch=6 deliver卡1:spawn?tick?travel?arrive?timeout/cull?deliver?——疑convoy是team撞succession/cull同herald家族or target-moving/throttle)(b)T1死因(#6 T1死6輪首次:T1有無派herald detach 1 anon抽勞力?side-dispatch改覓食時序?seed?歸因機制害死vs真湧現vs seed)③★★persist bed(commit進scripts/debug/或config/,別再ephemeral刪掉)——治reproducibility缺口(feedback_specimen_handoff_landed_path:ephemeral fixture下游重現不出,#6卡在此),往後症1驗收床固定可重跑·GODOT_TIMEOUT=1200·純觀測zero行為變·落地docs/measurements→我讀定2 root·別下修結論只交真值+convoy卡哪站表+T1死因歸因"
---

# reproducibility 缺口解：measurer 重現 #6 whole 床 + 跑 convoy/T1 診斷 + persist bed

implementer 診斷卡在 **bed 不一致**：它用 `peaceful_economy seed70730` 跑不出 #6（distribute.dispatch=0/T1 存活/convoy 健康**無**黑洞）。**#6 的 distribute=6/T1 死來自你自建的「資訊網whole 獨立驗收床」**（`seed1337`、**10 teams/2 factions**、T0 pop15+T2 領主 / T1 pop6 food0+T3 starving resident、60天）＝**ephemeral 已刪、只有你能重現**。

## ★請你（measurer、你 owns 這 bed）
1. **重現你 #6 whole 驗收床**（你建的 setup：10 隊 2 勢力、seed1337、60天、T0/T2 領主 + T1/T3 餓 resident）**against `feat/info-network-whole ff785b96`**（診斷 taps 已在 code：convoy-lifecycle 逐站 + T1）。
2. **跑診斷得真值**：
   - **(a) convoy-lifecycle 5/6 卡哪站**（`dispatch=6` 但 `deliver` 卡 1）：spawn? tick? travel? arrive? timeout/cull? deliver?——**疑 convoy 是 team 撞 succession/cull（同 herald 家族）或 target-moving/throttle 重複佔位**。
   - **(b) T1 死因**（#6 T1 死=6 輪首次）：T1 有無派 herald（detach 1 anon 抽勞力害死自己?）/ side-dispatch 改覓食時序? / seed cascade? → **歸因 機制害死 vs 真湧現 vs seed**。
3. **★★persist bed（commit 進 `scripts/debug/` 或 `config/`、別再 ephemeral 刪掉）**——**治 reproducibility 缺口**（[[feedback_specimen_handoff_landed_path]]：ephemeral fixture 下游重現不出、#6 就卡在此）、往後症1 驗收床固定可重跑。

## 交付
- `GODOT_TIMEOUT=1200`、純觀測 zero 行為變。落地 `docs/measurements/` → 我讀**定 2 root**。**★別下修結論、只交真值 + convoy 卡哪站表 + T1 死因歸因。** 卡 → 報 `to:systems`。
