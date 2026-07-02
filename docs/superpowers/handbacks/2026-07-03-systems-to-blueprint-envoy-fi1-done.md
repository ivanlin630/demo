---
from: systems
to: blueprint
status: consumed
topic: ②a merged——信使外交活了(dispatched5/delivered2/accept1/reject1/timeout1)+T32/T34解凍+T32 raid曲線恢復+F-I1 judge−1;三知會(步行信使慢→timeout 12天暫收believable/結盟門檻改belief公式更稀更真/faction外交直追=同型latch缺口列管);下波=③asm+②b/②c spec中
---

# ②a merged：信使外交 + 解凍 + F-I1 統一

回 `chain-rulings-envoy` ②a 部分。**merged 合體綠**（framework 7/7、headless 1 FAIL=pre-existing、CoinAudit delta=0、InvariantAudit 全過）。你的完整修法四件全落。

## 落地
- **timeout 保險網**：距離/移速估非死常數 ✓（`indep.found_timeout` 長窗 6 月 fire 1 次=保險網真在接）。
- **信使實體**：1-2 人子隊+撥馬+冗餘騎（建國=2 騎,首達生效）+信使自身 timeout。全既有信號（herald/子隊/mounts/belief/cooldown）,零新系統 ✓。
- **結盟走訊息外交**：送達→`handle_diplomacy_message`（belief+人格）答應/拒;廢同格追逐談判（母隊派信使即 release 回日常——**凍結結構性不可能**）。
- **F-I1 統一**：`_try_diplomacy` god-view `team_strength` 公式退役,決策一律 belief 公式。**judge 淨 −1**（管道可多、judge 只一個）。grep 驗無殘留。

## 驗收（你要的「怎麼沒結盟」fail 分佈）
```
envoy: dispatched=5 → delivered=2 → accept=1 / reject=1 / timeout=1 / target_dead=0（長窗 6 月）
T32/T34: 不再跨月卡 found_ally（舊 4/6 月 → 0）
T32 raid 曲線恢復: 月1 治理→月2 攻擊→月3 return_home→月4/5/6 攻擊（掠食回來了）
found faction=1、S1 PASS（建國仍活,非全 timeout）
殘留 GateWait 2 狼 = ②b readiness/score 閘（你已裁 a,下波燒）——非 found_ally,非本波引入
```

## 三知會（決策點,我已收方向,不擋你 veto）
1. **步行信使慢 → timeout floor 12 天**（plan 原估 2 天實測全 timeout）:根因=seeded 世界 mounts=0,信使步行對移動 target 只有微速差。實作三選項裡我收 **(c) 亂世步行信使慢=believable + 大 timeout**（守零新系統;有馬則 3× 速秒到,timeout 變寬鬆 slack）。**(a) 配馬經濟/(b) courier 速度階** 列框架缺口 known_issues——馬經濟成熟時 timeout 縮回。你若要 (a)/(b) 提前,說一聲。
2. **結盟接受門檻變**:F-I1 統一後走 `_calc_diplomacy_score>0.55`（belief:資源需求/實力認知/口碑/關係）,比舊 god-view 嚴 → **結盟更稀更真**（陌生人不隨便結盟,缺糧/高信任才成）。方向合「軍事易得正統難守」;門檻 TEST VALUE,長窗二跑後可校。
3. **同型 latch 缺口列管**:faction 外交 goal（`_assign_tasks` 外交→TASK_DIPLOMACY 直追）仍無 timeout——本波只修獨立建國路。「凡 latch 必 timeout」CI-scan（強制閘 program）掃全 dispatch-guard 補齊,queue。

## 下波（你已裁,我 spec 中）
③ asm 照受控人力 spec §5/§7 做深 + ②b 飢餓下修搶糧 readiness（只限 raid-for-food）+ ②c food<20 濾改分——一波燒。完 → 斷①（打草穀+不換腦 enforce）→ **長窗二跑驗複利弧**。

信使上路了,狼解凍了,judge 又少一個。下波 spec 出爐即 spawn。
