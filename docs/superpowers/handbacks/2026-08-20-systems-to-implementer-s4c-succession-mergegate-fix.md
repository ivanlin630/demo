---
from: systems
to: implementer
status: consumed
topic: "[merge-gate 硬讀 diff 回報:兩件核心 HOW 皆 held、但 3 項要動才 merge(小、先修再回 investigation③)·★A 繼承-lite:succeed_or_disband_faction 內那行 f.known_member_states.erase(dead_leader_tid) 刪掉——三處語境:erase_teams 呼叫前一行 :341 已 erase(冗餘)/faction_ai:3482 該隊稍後走 cleanup→erase_teams 也會 erase(冗餘)/★npc_combat:733 那條路【團還活著】(只是 named leader 死且 on_leader_death 回 false)、把一支仍在世成員隊的 faction belief 記錄抹掉=未經 spec 的 belief 破壞、可能改 faction 決策·★B §4c quality_multiplier clamp 下界 0.0→0.25:兩次同地失敗→bias=-1.0→mult=0→settle_site_quality/camp_drive 直接歸零=【絕對門檻 pre-empt 引擎】(瀕餓隊唯一去處也不能紮)=patch-gate 病型違憲;下界 0.25=記憶重度折價但仍可被絕境秤贏、上界 2.0 保留·★C §4c 補 tap(憲法級全量暫態可觀測性、新決策輸入不得無 tap):MEMORY_MAX=20 FIFO 且與人際記憶共用 p.memory、site 記憶 TTL 30 天很可能【還沒到期就被擠掉】=反饋迴路靜默失效;寫端 Probe.bump('site_memory.write')、讀端 quality_multiplier 回傳 !=1.0 時 Probe.bump('site_memory.applied')→write vs applied 落差直接量出 eviction 吞掉多少(現在零 tap=大考時無法判定此 slice 有沒有在運作)·★D 裁定(答你 §4c 註的問):§4b merge 後【擴點】一併乘 quality_multiplier(同一品質層、不新增 term 線、與紮根/紮營一致)——由 §4b 收尾時加·修完重跑 TDD+det×3+constitution+headless、fp 會變(B/C 都動行為/欄位)報新 fp·然後回 investigation③(它是 12mo 大考 blocker#1、優先序最高)·地基KEEP"
---

# merge-gate 回報：兩件核心 HOW 皆 held，3 項要動才 merge

我硬讀了兩支 diff。**核心 HOW 全部 held**：繼承 tie-break 是真全序（`best==-1 or cid<best` 不靠 array 序）、`persons.get(-1)`→null→cmd 0.0 安全、三處接線傳的死集合正確；§4c 薄函式真的跳過三個 interpersonal side-effect、`camp_team_id` 三個 production 賦值點（`faction_ai:4775` 建 / `harvest:45` decay 清 / `outpost:376` 完工清）配對完整無孤兒、已進 fp。

以下 3 項要動（小、先修再回 investigation③）：

## ★A 繼承-lite：刪掉函式內 `f.known_member_states.erase(dead_leader_tid)`
三處語境不同：
- `erase_teams`：呼叫**前一行 `:341` 已經 erase** → 冗餘。
- `faction_ai:3482`：該隊稍後走 `cleanup_extinct_teams`→`erase_teams` 也會 erase → 冗餘。
- **`npc_combat:733`：錯**——那條路上**團還活著**（只是 named leader 死、`on_leader_death` 回 `false`），把一支**仍在世**成員隊的 faction belief 記錄抹掉＝**未經 spec 的 belief 破壞**、可能改 faction 決策。
→ 刪那行；清 belief 的職責留在真死亡 chokepoint（`erase_teams`）。

## ★B §4c：`quality_multiplier` clamp 下界 `0.0` → `0.25`
兩次同地失敗 → `bias=-1.0` → `mult=0` → `settle_site_quality` / `camp_drive` **直接歸零**＝**絕對門檻 pre-empt 引擎**（瀕餓隊即使那是唯一去處也不能紮）＝**patch-gate 病型、違憲**。
下界 `0.25`＝記憶重度折價但**仍可被絕境秤贏**（term 非 gate）。上界 `2.0` 保留。

## ★C §4c：補 tap（憲法級「全量暫態可觀測性」——新決策輸入不得無 tap）
`MEMORY_MAX=20` FIFO，且 site 記憶與**人際記憶共用同一 `p.memory`**、TTL 30 天 → 社交活躍的 leader 很可能**還沒到期就被擠掉**＝反饋迴路**靜默失效**。現在**零 tap** → 大考時無法判定此 slice 到底有沒有在運作。
- 寫端：`Probe.bump("site_memory.write")`
- 讀端：`quality_multiplier` 回傳 `!= 1.0` 時 `Probe.bump("site_memory.applied")`
→ **write vs applied 的落差直接量出 eviction 吞掉多少**。

## ★D 裁定（答你 §4c 註的提問）
§4b merge 後**「擴點」一併乘 `quality_multiplier`**（同一品質層、不新增 term 線、與紮根/紮營一致）——由 §4b 收尾時加。

修完重跑 TDD + det×3 + constitution + headless，**fp 會變**（B/C 都動行為/欄位）→ 報新 fp。然後回 **investigation③**（12mo 大考 blocker#1、優先序最高）。地基 KEEP。
