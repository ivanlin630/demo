---
from: systems
to: implementer
status: consumed
topic: "[dispatch·null-belief-flee 凍結根治·R² CLEAN(applicability-gate)·★Slice D 前必修·off LOCAL main af1838bd] spec=2026-07-20-nullbelief-flee-release.md。root:個體 FLEE(faction_ai:1595/1948)flee_from_pos=_flee_threat_pos=威脅 belief 位,positionless→(-1,-1),movement:82 無座標時無 target+continue(沒人 release)→卡 task=逃跑 凍結餓死(team75/4/13)。修(reviewer 建議 applicability-gate 真根治收斂 A+B):FLEE/逃跑 applicable 僅當 _flee_threat_pos!=(-1,-1)→positionless 不選 FLEE→落次佳覓食/defend。impl 找 FLEE applicable() 或 dispatch 前 gate。B movement release=冗餘 defense 可選(timing 邊角)。不回退 live-track(無座標=轉覓食非偷讀 live)。★★branch off LOCAL main af1838bd,禁 origin。pre-push hook 已裝。TDD:①positionless→不選 FLEE 轉覓食 ②有座標正常 flee 不誤傷(team67/54 型)③(可選)movement backstop。gate/headless 0new/determinism/measure(team75/4/13 不凍死,coherent flee 不退化)。★Slice D 前落地(D belief-化不再被污染)。task 完成=systems+reviewer。"
---

# dispatch：null-belief-flee 凍結根治（R² CLEAN，applicability-gate）

spec：`docs/superpowers/specs/2026-07-20-nullbelief-flee-release.md`。R² CLEAN + reviewer 建議 applicability-gate（真根治收斂 A+B）。**★Slice D 前必修**（blueprint 裁）。PRE-EXISTING（獨立於 Slice E）。

## ★★ branch base
- **off LOCAL main `af1838bd`**（禁 origin 落後）。pre-push hook 已裝。

## 修（applicability-gate，reviewer 建議真根治）
root：個體 FLEE `faction_ai:1595/1948` flee_from_pos=`_flee_threat_pos`=威脅 belief 位；positionless→(-1,-1)；`movement:82` 無座標時無 target+`continue`（沒人 release）→ 卡 task=逃跑 凍結餓死。

- **A（primary，applicability-gate）**：FLEE/逃跑 option **applicable 僅當 `_flee_threat_pos(state, team) != (-1,-1)`**（威脅有 belief 座標可算逃向）→ positionless 不選 FLEE → survival/threat rank 落次佳（覓食/defend）。找 FLEE 的 applicable() 判準加此條件；若 FLEE 選在 threat 系統無 applicable()，等價「dispatch 前 gate：無座標不派 FLEE 落次佳」。
- **B（optional backstop）**：`movement:82` 落實 release（`if FLEE and flee_from_pos==(-1,-1): TaskArbiter.release`）= 冗餘 defense（A 後 FLEE 不會無座標被選），timing 邊角可選，A 為主。
- **★不回退 live-track**：無座標=轉覓食（顧眼前），**非偷讀 live 位逃**（守 belief-化，感知鐵律）。

## 驗收
- **TDD**：①FLEE 威脅 positionless（`_flee_threat_pos`=(-1,-1)）→ **不選 FLEE**（team 落覓食/次佳，非 task=逃跑 凍結）②威脅有座標 → 正常 flee（不誤傷 coherent，team67/54 型）③（可選）movement backstop release。
- **gate** PASS / **headless** 0 new(baseline 3) / **determinism** 2 跑 byte-identical。
- **measure（→measurer）**：seed1337 team75/4/13 不再 task=逃跑 凍結餓死（轉覓食/re-rank）；coherent flee（真座標遠離/投靠）不退化；42/4201 無 regression。
- **★Slice D 前落地**。

## 完成判定 = systems + reviewer/QA。做完 → to:measurer。
