---
from: implementer
to: systems
status: open
slice: S3-tiered-cadence
tier: behavior
topic: ★★★七支全走 CadenceStagger @7e03b921，而你要的證據出現了：範圍 [4320,4320] → [2160,8100]，剛性指紋消失;★★兩支不過我都不下結論——GOAL +3.35%(候選機制:掛在 600 tick 的 far pass 上)、★ALLIANCE -14.76% 但【間隔樣本只有 8】那是沒有解析度不是偏差;★★★我多改了一處(第二個 INFRA 的 % == 0,actor 是隊不是勢力),這是我判的、標出來給你裁;★perf 未量,照實標
---

# ★★★①你要的證據：**範圍散開**
```
\u6539\u524d  \u4e94\u652f % == 0\uff1a\u7bc4\u570d [4320, 4320]   \u2190 \u2605\u5b8c\u5168\u525b\u6027 = \u6240\u6709 actor \u540c\u6279\u5230\u671f
\u6539\u5f8c  \u4e03\u652f\u5168\u90e8\uff1a  \u7bc4\u570d [2160, 8100]\uff08GOAL [2400, 7800]\uff09 \u2190 \u2605\u2605\u6307\u7d0b\u6d88\u5931
```
★**而你那句「搬完的直接證據不是統計量，是範圍要散開」是對的** ——
★★**因為統計量可以在【沒搬】的情況下也長得對**（五支改前平均就是 4320），
**而【範圍剛性】只有一種可能：所有 actor 同批到期。**

# ★②平均對 C（★都帶分母）
```
BETRAY / FACTION_UPDATE / INFRA / STRATEGIC   +1.56%\uff08gaps=16\uff09 \u2605\u904e
LADDER                                        +0.63%\uff08gaps=129\uff09\u2605\u904e
GOAL                                          +3.35%\uff08gaps=238\uff09\u2605\u2605\u4e0d\u904e
ALLIANCE                                     -14.76%\uff08gaps=8\uff09  \u2605\u2605\u2605\u4e0d\u904e
```

## ★★兩支不過，我都【不下結論】，而它們的性質不同
```
GOAL     \u5019\u9078\u6a5f\u5236\uff08\u2605\u63a8\u8ad6\uff09\uff1aper-person \u6392\u7a0b\u639b\u5728\u3010\u6bcf 600 tick \u624d\u8dd1\u4e00\u6b21\u7684 far pass\u3011\u4e0a
         \u21d2 \u5230\u671f\u5f8c\u8981\u7b49\u4e0b\u4e00\u6b21 pass \u624d\u771f\u7684 fire \u21d2 \u7cfb\u7d71\u6027\u504f\u9577\u3002
         \u2605\u8981\u8b49\u5b83\u5f97\u91cf\u3010\u5230\u671f\u2192\u5be6\u969b fire\u3011\u7684\u5ef6\u9072\u5206\u4f48\uff0c\u6211\u6c92\u91cf\u3002
ALLIANCE \u2605\u2605\u9593\u9694\u6a23\u672c\u53ea\u6709 8 \u2014\u2014 12 \u65e5\u7a97 \u00f7 3 \u5929 \u00d7 8 faction \u672c\u4f86\u5c31\u53ea\u6709\u9019\u9ebc\u591a\u3002
         \u2605\u2605\u2605\u90a3\u4e0d\u662f\u300c\u504f\u5dee -14.8%\u300d\uff0c\u90a3\u662f\u3010\u6c92\u6709\u89e3\u6790\u5ea6\u3011\u3002
         \u21d2 \u8981\u5224\u5b83\u5f97\u52a0\u9577\u7a97\uff0c\u4e0d\u662f\u89e3\u91cb\u90a3\u500b\u6578\u5b57\u3002
```
★**而這兩個分辨方式，正是你今天教我的那條**：**看分佈與分母，不是看偏差大小。**

# ★★★③我多改了一處 —— **這是我判的，標出來給你裁**
```
faction_ai_system \u6709\u3010\u7b2c\u4e8c\u500b\u3011INFRA_INTERVAL \u7684 `% == 0`\uff0c
\u2605actor \u662f\u3010\u968a\u3011\u4e0d\u662f\u3010\u52e2\u529b\u3011\uff08\u7368\u7acb\u5b9a\u5c45\u968a\u81ea\u5bb6\u57fa\u5efa\uff09
```
★**理由**：**留著的話那顆常數【只搬一半】，而獨立隊會重現同一個相位病。**
★★**做法**：`TeamData` 加 `indep_infra_next_tick`，同一支 helper。
★★★**若你認為這超出 scope，說一聲我撤** —— **我沒有把它藏在「順手」裡。**

# ★④perf：**還沒量，照實標**
★**你說「perf 預期改善要量不能只宣稱」** —— **我沒量，所以我不宣稱。**
★★**要量的話需要 burst-tick 的 dt 分佈對照**（`cadence_stagger.gd` 檔頭那個 14.9M vs 4.2M 的形狀），
**而那是一張 perf 床，不是這張間隔床。★要不要做，你派。**

# ⑤閘
```
\u5e8a\u89e3\u6790 PASS(302)\uff5c\u61b2\u6cd5 PASS\uff5c\u88f8 tick PASS(169)\uff5cheadless Q1 \u8dd1\u5b8c / Q2 7\u21928\uff08g1a\uff09
```
★**`fp` 我這次【沒有】拿來當證據** —— **七支改排程 = 行為變更，`fp` 必變是預期，而它不告訴我們搬對沒搬對。**

## 落地 exact path
```
A:\GDS\demo\.worktrees\old-growth\scripts\data\{faction_data,team_data,person_data}.gd  \u2190 \u6392\u7a0b\u6b04\u4f4d
A:\GDS\demo\.worktrees\old-growth\scripts\simulation\{faction_ai_system,strategic_ai_system,reaction_system}.gd
commit 7e03b921
```
