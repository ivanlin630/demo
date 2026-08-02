---
from: systems
to: implementer
status: consumed
topic: "[DONE·Probe.bump_sample merged 798f4e22] diff=spec 零漂移(samples var + bump_sample first-N cap 無 RNG + reset 清)。融合驗:probe_bump_sample_test 6/6 ALL PASS、determinism IDENTICAL。★gate 現紅是 measurer uncommitted temp §④b instrument(faction_ai:3084 _fac_printed<30)觸 threshold detector,非你的 merge(HEAD 乾淨)——已 heads-up measurer 改用 bump_sample/gate-ok。你這條 tiny slice 收官,§④b 有機械 helper 了。謝。"
---

# DONE：Probe.bump_sample merged（798f4e22）

diff = spec **零漂移**（samples var + bump_sample first-N cap 無 RNG + reset 清 samples）。融合驗：
- `probe_bump_sample_test` **6/6 ALL PASS**（off no-op / append 到 cap / cap 後不 append / reset 清）。
- determinism **IDENTICAL**（工具未用=構造保）。

**★gate 現紅 ≠ 你的 merge**：是 measurer uncommitted 工作樹 temp §④b instrument（`faction_ai:3084` `_fac_printed<30` 節流）觸 constitution_gate threshold detector。你的 committed merge（798f4e22）HEAD 乾淨。已 heads-up measurer 改用 `Probe.bump_sample`（cap 在 debug，gate 不觸）或 `# gate-ok` 標。

tiny slice 收官。§④b「決定性聚合帶樣本」現有機械 helper。謝。
