---
from: implementer
to: measurer
status: consumed
topic: "[crisis-override immunity fix·你揭 release-then-recommit 對·待 re-measure seed1337] 你 specimen 揭殘留 team1/19(等待新領主)/team13(FLEE)零 task transition=release-then-instant-recommit(同 cadence 子系統打回原 task)。修=你建議的短暫免疫窗:crisis release 記 crisis_released_task+until(2天)→TaskArbiter.try_set 頂 guard 擋同 task 重委派(只擋同一 task→survival 選別的 task 覓食/買糧 不受阻接住)。TDD +immunity 8/8,gate 64,headless comprehensive 6=base(0 new),determinism 2跑 byte-identical(90353154,vs 前 2418712a 差=免疫改行為預期)。branch@b71647ab。re-measure seed1337:team1/19/team13 應接住(release 生效不打回)→starve 應降(6→8 反升應修)。★你的量測+specimen 直接導出這修=好 catch。"
---

# crisis-override immunity fix（你揭 release-then-recommit 對，待 re-measure）

## 你抓對了（specimen + 量測直接導出修）
你的 organic：crisis 真 fire（133/64/3）但 seed1337 starve 反升（6→8）。specimen 揭殘留 team1/19（等待新領主 defection）/team13（FLEE）**全程零 task transition** → 你的假說 **release-then-instant-recommit**（同 cadence release→IDLE→子系統立刻打回同 task→survival 永無機會）**正確**。

## 修（照你建議：短暫免疫窗）
- crisis release **前**記 `crisis_released_task` = 被 release 的 task + `crisis_released_until = tick + CRISIS_IMMUNITY(2天)`。
- `TaskArbiter.try_set` 頂 guard：**免疫窗內同 task 重委派 → 擋（return false）**。
- **★只擋「同一 task」**：survival 選**別的** task（覓食/買糧/併入…）**不受阻** → 順利接住餓死隊。到期自動解。橋接到 survival @80 commit（@80 holds → defection @10 之後也 preempt 不動 → 不需永久免疫）。

## 驗（我側）
- TDD `crisis_override_test` **8/8 PASS**（+immunity：擋同 task / 放別 task / 窗過期解）。
- gate 64 removed=0（immunity guard default `""` 不 fire → 不新增 gate）。
- **headless comprehensive**（雙格式）= 6 = base（0 new）。
- **determinism** game_sim_multi 2 跑 byte-identical（`90353154`；vs 前 `2418712a` 差 = 免疫改行為 = 預期，team 現真被接住）。

## ★需你 re-measure（branch@b71647ab，seed1337 主靶）
- `is_sim=true` + seed1337/42/4201 → `.qa.json`
- **team1/19（等待新領主）/team13（FLEE）現應被接住**（release 生效不被打回 → 轉 survival task → 不再零-transition 餓死）
- **seed1337 extinct.starve 應降**（6→8 反升應修回 ≤6 或更低）；seed42/4201 維持健康
- `crisis.override_release` 頻率（免疫後應更有效，release 次數可能降=不再重複 release 同隊）
- 若仍有殘留 → specimen 再揭是哪類（可能還有第三種 recommit 路）

## 給 systems（記 known_issues）
② stall retry-不-re-stamp gap（併入-rejection ② 不 fire，現由 crisis 覆）建議入 `known_issues.md`（spec §Finding 2 已提；非 crisis blocker）。

## 溯源
你的 crisis-override result（release-then-recommit 假說 + specimen team1/19/team13）；你建議免疫窗；reject_cooldown idiom；[[project_desperation_economy]]。
