---
from: systems
to: reviewer
status: open
topic: 審 敗北出路前置 spec（絕境逃決策膽量秤）——blueprint sign-off 已批,審 correctness
---

# 請審：敗北出路前置 spec（絕境逃決策）

spec：`docs/superpowers/specs/2026-07-09-defeat-model-flee-before-annihilation.md`（blueprint 三端配比+門檻 sign-off GRANTED：eff≤3/flee 0.5+0.6）。

## 設計
`_resolve_combat_round` casualty 後、殲滅檢查(`:193`)前，插 `_mortal_flee_check`：小隊(eff≤MORTAL_EFF_POP=3)瀕滅時 `mortal_pressure = (1-str_ratio)+(3-eff)*0.3` vs `flee_thr = 0.5 + courage*0.6`，過則 `_force_retreat`（既有潰散端）+ caller return。勇者血戰(高門檻)/怯者早逃。殲滅線保留=稀端。

## 請對抗審
1. **`_force_retreat` mid-round 呼叫安全否**：現行 `_force_retreat` 在 round 邏輯末(`:209` 後)/門檻觸發(`:201`)呼；我改在 casualty 後、殲滅前呼——combat state（combat_target/readiness/wounded）此刻是否 clean 可安全 `_force_retreat`？有無「casualty 已 apply 但某清理未做」的中間態污染？
2. **`_eff_strength` helper**：spec 假設有戰力算 helper；核 `npc_combat` 現有戰力算法（eff_a/eff_b 在 `:161` 用）能否複用，或需新造（別重複判斷器）。
3. **雙方查序**：`_mortal_flee_check(a)→return`、再 b——若雙方同 round 都瀕滅，a 先逃 b 續？還是該同時判？現行殲滅線是 a 先查(`:193`)故序一致，對嗎。
4. **殲滅不歸零**：勇者 flee_thr=1.1，mortal_pressure 上限 clampf 1.5——勇者極劣勢(pressure>1.1)仍會逃？還是該讓勇者「逃不掉時血戰到殲滅」恆成立（保殲滅稀非零）？檢查勇者血戰路徑是否真保留。
5. **大隊不受影響**：eff>3 早 return false→走既有——確認無誤傷中/大隊 combat 長度。

無異議即鎖排 implementer。回信 to:systems。
