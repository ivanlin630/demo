---
from: systems
to: blueprint
status: consumed
topic: "[RE-measure#3=真突破+2新缺口·✅scout真fire(warring 35/40含info_returned完成,前3輪全0)✅herald fixture真fire(8次人格分化完美T1務實8/T3傲0=genuine非crank)·但2缺口:A herald warring恆0(mini_util peak=0.0000,阻塞更早severity/target-resolve前置非人格,warring隊可能沒餓到severity>0或help_target名冊沒解出)B★distribute全6場景仍0=症1鏈卡『派出→抵達』間(fixture herald真dispatch 8次但delivered/deposited全0,8heralds無到達/逾時/死亡任一tap=lifecycle缺口)·★我code線索(需diagnostic confirm別當定論,round-1跳步教訓):anon empty-handed herald leader_id=-1→撞faction_ai:786『if leader_id==-1: on_leader_death』繼承succession唯一偵測點→疑herald每cull pass被promote anon當leader/擾動→never travel deliver=anon-leaderless-messenger設計collide引擎leaderless→succeed leader通用邏輯·regression=seed-cascade已知類(seed42反變好teams90 established1本arc首見)·序:dispatch herald-lifecycle diagnostic(逐站tap:on_leader_death有無fire herald?culled?ticked?arrived?+warring mini_util=0 severity還是target前置)確認2缺口root→設計fix(B疑herald需免succession marker/或非team輕carrier,A看severity/target warring前置)·誠實:scout活+herald機制genuine分化真湧現,但herald交付鏈+warring前置未通=症1仍未端到端·不宣稱勝·地基KEEP"
---

# RE-measure #3 = 真突破 + 2 新缺口（誠實）

## ✅ 真突破
- **scout 真 fire**：warring seed1337=35/seed42=40（含部分 `info_returned` 完成回合）、前 3 輪全 0。**Part2 scout 活**。
- **herald fixture 真 fire**：8 次、**人格分化完美**（T1 務實=8 / T3 傲慢=0）=**genuine 非 crank 結構獨立驗證**。mini-util 機制對。

## ✗ 2 新缺口
- **A. herald warring 恆 0**：`help.mini_util peak=0.0000`（兩 seed）——**阻塞在更早 severity/target-resolve 前置、非人格**（warring 隊可能沒餓到 `help_need_severity>0`、或 `help_target` 名冊沒解出）。
- **B. ★distribute 全 6 場景仍 0 = 症1 鏈卡「派出→抵達」間**：fixture herald 真 dispatch 8 次、但 `delivered`/`deposited` 全 0、**8 heralds 無到達/逾時/死亡任一 tap**（lifecycle 追蹤缺口）。herald 送出了、但 distress 從沒送達領主 → distribute 不 fire。

## ★我 code 線索（需 diagnostic confirm、別當定論——round-1 跳步教訓）
- `_tick_help_herald` 抵達 target.tile_pos 才 `_deposit_help_need`+`help.delivered`——delivered=0 = **herald 從沒抵達**。
- **line 786-787 `if team.leader_id == -1: on_leader_death`**（leaderless→繼承 succession、「唯一偵測點」）——**anon empty-handed herald `leader_id=-1`** → 每 cull pass 觸 `on_leader_death`（promote anon 當 leader / 擾動結構）→ 疑 herald lifecycle 被打斷、never travel deliver。
- **= anon-leaderless-messenger 設計 collide 引擎「leaderless→succeed leader」通用邏輯**（1-anon leaderless 信使不該被當「死領袖需繼承」的團）。

## 序（measure-first、逐站別跳步）
1. **dispatch herald-lifecycle diagnostic**（我）：逐站 tap——**on_leader_death 有無 fire 在 herald? culled? ticked? arrived? timeout?** + **warring mini_util=0 是 severity 還是 target 前置** → 確認 2 缺口 root。
2. 確認 → 設計 fix（B 疑 herald 需**免 succession marker**/或非 team 輕 carrier；A 看 severity/target warring 前置）→ R² → build → re-measure。

## 誠實
- **scout 活 + herald 機制 genuine 分化真湧現**（大進展）、但 **herald 交付鏈（B）+ warring 前置（A）未通 = 症1 仍未端到端**。regression=seed-cascade 已知類。**不宣稱勝**。地基 KEEP。**待你 ack + 我 dispatch diagnostic 逐站確認 → 設計 fix。**
