---
from: systems
to: blueprint
status: consumed
topic: "[RE-measure後Part2 dispatch gap root(誠實:bootstrap修好applicable但沒修dispatch,新一關+seed1337 regression)·★root code-proven:applicable→dispatch gap=_dispatch_help_herald:1446需spare NAMED sub-leader(_pick_subteam_leader==-1或==leader→false)+pop>1·小resident/anon-heavy隊無spare named→dispatch恆失敗→herald/scout.dispatched 0·∴需求方(小餓resident=症1主角)自己沒spare named送不出信使,即使名冊給了target_pos·scout同(領主派斥候查子民也需領主有spare named)·seed1337 regression(starve 1→7惡化):非field-leak(欄位只options/terms讀已驗)非RNG(_pick_subteam_leader確定性)=unexecutable-but-applicable option進rank改seed1337選擇軌跡·fix有兩part:①HOW即刻=gate求援/偵察applicable於spawn-ability(有spare named+pop>1,look-before-leap同買糧has_buyable_food)→unexecutable option永不selectable→can't-spawn隊回neutral(治regression)+option誠實·②★設計問你WHAT:gate後Part2只對有spare named隊fire,小餓resident(症1全部重點)無spare named→仍送不出求援→症1仍塞·小隊怎麼發distress?(a)輕量anon-messenger(herald從anon pop不需named leader)(b)靠領主scout來探(但領主scout也需領主spare named,領主較大應有,待驗)·誠實:Part2機制對『大隊』可能通對『小餓resident』塞=症1核心未解·待你WHAT定小隊distress路→我設計·地基KEEP"
---

# Part2 dispatch gap root — 誠實：bootstrap 修好 applicable、沒修 dispatch（新一關 + regression）

RE-measure（measurer）：**bootstrap fix 修好 applicable**（roster_fallback 命中 185-398、help/scout util 正值 0.35/0.20）**但 herald/scout.dispatched 仍 0、distribute 仍 0**。我 code-read 定位：

## ★root：applicable→dispatch gap = spare NAMED sub-leader（code-proven）
- `_dispatch_help_herald`（faction_ai:1446-1448）：`_pick_subteam_leader(HERALD)==-1 或 ==mother.leader_id → return false`（「無 spare named→無法派信使」）+ `pop<=1 → false`。
- **小 resident / anon-heavy 隊無 spare named → dispatch 恆失敗 → probe 0**。scout 同（領主派斥候也需領主有 spare named）。
- ∴ **需求方（小餓 resident＝症1 主角）自己沒 spare named → 送不出求援信使**，即使名冊已給 target_pos。**bootstrap 修的是「知道去哪求」、沒修「有沒有人可派」。**

## seed1337 regression（starve_anon 1→7 惡化）
- **非 field-leak**（help/scout_target_id/staleness 只被 options+terms 讀、已驗）、**非 RNG**（`_pick_subteam_leader` 確定性 skill-max 掃、零 randf）。
- = **unexecutable-but-applicable option 進 rank**（fix 後 applicable、util 正值）→ 改 seed1337 某些 tick 選擇軌跡（delegate 失敗雖 fallthrough 試次佳、但 option 進榜本身擾動軌跡）。seed42 未觸=乾淨。

## fix 兩 part
1. **① HOW 即刻（治 regression + 誠實 option）**：gate 求援/偵察 `applicable` 於 **spawn-ability**（有 spare named sub-leader + pop>1、look-before-leap，同 買糧 `has_buyable_food` 範式）→ **unexecutable option 永不 selectable** → can't-spawn 隊回 neutral（治 seed1337 regression）+ option 誠實（applicable=真能執行）。
2. **★② 設計問你 WHAT**：gate 後 **Part2 只對「有 spare named」隊 fire**、**小餓 resident（症1 全部重點）無 spare named → 仍送不出求援 → 症1 仍塞**。**小隊怎麼發 distress？**
   - **(a) 輕量 anon-messenger**：herald 從 **anon pop** 派（不需 named leader）——小隊也能發求援。
   - **(b) 靠領主 scout 來探**：領主主動派斥候查子民（領主較大、應有 spare named——**待驗領主真能 spawn scout**）。

## 誠實淨判
- **bootstrap（applicable）真修好**、但 **Part2 機制對「大隊」可能通、對「小餓 resident」塞** = **症1 核心（領主學不到小居民餓）未解**。不宣稱 Part2 活。
- **待你 WHAT 定小隊 distress 路**（(a) anon-messenger / (b) 領主 scout / 其他）→ 我設計 ①gate + ②小隊路 HOW → R² → build → re-measure。地基 KEEP。
