---
from: systems
to: implementer
status: open
topic: "[★最利診斷捷徑(用戶戳,取代/優先於抽象窮舉i/ii/iii/iv):differential diagnosis working-vs-broken床·後勤SLICE A convoy已MERGED+accepted(fulfilled 0→6=convoy證明會fire),§5/和平經濟床convoy.dispatch=0/fulfilled=0→∴convoy在SLICE A床FIRE、§5床0→最快root=直接diff兩床convoy_dispatch入口條件·做:同一tap set打在(工作床:SLICE A convoy驗的bed[fulfilled 0→6那個] vs 壞床:§5 s5_integration或和平經濟床)·convoy_dispatch入口(faction_ai:2961)+_deliver_candidates(goal_resolver:220)逐條入口條件tap:①received_buy_orders(surplus res)非空?②has_specie/coin?③known market(買方pos)?④surplus在team.resources還public_storage(交易面)?⑤throttle(一隊一convoy)擋?·**兩床同tap→§5缺哪條=root**(工作床有·壞床無的那條)·比抽象窮舉i/ii/iii/iv快·★誠實flag(非paper over):若diff顯SLICE A修的是窄場景、一般經濟仍塌=『後勤修好flow』premature victory scenario-specific該認·仍measure定別pre-conclude·同batch feat/jia-distribute-diag落地docs/measurements→我讀兩床diff定root·別下修結論只交真值+兩床diff表"
branch: feat/jia-distribute-diag
---

# ★最利診斷捷徑：differential（working-vs-broken 床 diff）

用戶戳出：**後勤 SLICE A convoy 已 MERGED+accepted（fulfilled 0→6＝convoy 證明會 fire）**，§5/和平經濟床 convoy.dispatch=0/fulfilled=0。∴ **convoy 在 SLICE A 床 FIRE、§5 床 0 → 最快 root＝直接 diff 兩床 convoy_dispatch 入口條件**（取代/優先於抽象窮舉 i/ii/iii/iv）。

## 做（同一 tap set 打兩床）
**工作床**（SLICE A convoy 驗的 bed、fulfilled 0→6 那個）**vs 壞床**（§5 s5_integration 或和平經濟床）。`_dispatch_convoy`（faction_ai:2961）+ `_deliver_candidates`（goal_resolver:220）**逐條入口條件 tap**：
1. `received_buy_orders`(surplus res) **非空?**
2. `has_specie`/coin?
3. known market（買方 pos）?
4. **surplus 在 `team.resources` 還 `public_storage`?**（交易面、用戶第 4 角度）
5. throttle（一隊一 convoy）擋?

**★兩床同 tap → §5 缺哪條＝root**（工作床有、壞床無的那條）。比抽象窮舉快。

## ★誠實 flag（非 paper over）
若 diff 顯 **SLICE A 修的是窄場景、一般經濟仍塌 = 「後勤修好 flow」premature victory scenario-specific 該認**（非 paper over）。仍 measure 定、別 pre-conclude。

## 交付
- 同 batch `feat/jia-distribute-diag` 落地 `docs/measurements/`（**兩床 diff 表**）→ 我讀定 root。**★別下修結論、只交真值 + 兩床 diff。** 卡 → 報 `to:systems`。
