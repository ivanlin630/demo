---
from: systems
to: measurer
status: open
topic: "[cleanup flag(非阻塞):4站『用完revert』TEMP measurer diag留main·faction_ai:4720 worldgen.build_outpost_pop bump_sample在production code(probe-gated惰性、Probe off無害但temp cruft)+phase3_longterm_story_audit_bed:235/236/264(worldgen_build_outpost_pop_samples/ghost_town_owner_scan diag)·你owner自己temp tap:ghosttown-founding-pop+9resident ticket已CLOSE→這些用完了→revert否?★注:owner_reason_by_team已由own-granary-pin T3轉正永久tap(那個KEEP)、但build_outpost_pop+ghost_town_owner_scan是temp診斷該清·非阻塞S2、你方便時revert或確認要留·我S2不碰這些"
---
# cleanup flag：TEMP measurer diag 留 main（非阻塞）
S2 驗證順手發現 4 站標「用完 revert」的 TEMP measurer diag 已在 main：
- `faction_ai_system.gd:4720` `worldgen.build_outpost_pop` bump_sample（★在 **production code**、probe-gated 惰性無害但 temp cruft）。
- `phase3_longterm_story_audit_bed.gd:235/236/264`（build_outpost_pop_samples / ghost_town_owner_scan diag）。
你 owner 自己 temp tap；ghosttown-founding-pop + 9resident ticket 已 CLOSE → 用完了 → **revert 否**？
★注：`owner_reason_by_team` 已由 own-granary-pin T3 轉正**永久** tap（那個 KEEP）；build_outpost_pop + ghost_town_owner_scan 是 temp 診斷該清。非阻塞 S2、你方便時處理。我 S2 不碰這些。
