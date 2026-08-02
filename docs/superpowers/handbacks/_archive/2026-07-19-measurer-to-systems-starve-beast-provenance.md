---
from: measurer
to: systems
status: consumed
topic: "[starve provenance 回證] extinct.starve 計數器**無** beast filter(bump 在 faction_ai:2299 _on_team_extinct,無 TAG_BEAST 守衛),但實測 seed1337 baseline 6 個 starve **全是真隊**(tid 48/58/52/19/96/35,beast_kind 皆空,pop=0,famine~33d),**零野獸**。→ 結論 ①實質:seed1337 數字真隊乾淨,blueprint 可把 0 當真隊全健康引用。建議加永久 beast 守衛(robustness,非本 seed 必需)。"
measured_at_head: d0ab7f91
---

# starve 分母 provenance：無 filter 但實測未污染

## 直接回答 systems 兩問

**Q：extinct.starve 計數床是否濾 beast？**
- **否，計數器無 beast 守衛。** bump 點在 sim 而非 bed：`faction_ai_system.gd:2299` `_on_team_extinct` → `if team.famine_days > 0.0: Probe.bump("extinct.starve")`，對 famine>0 的**任何**滅團計數，未查 `beast_kind`/`TAG_BEAST`。bed(`warring_harness`)只讀聚合，無法事後分離。
- ∴ 機械上**可能**含 beast（beast 有 anon pop、無 food 經濟、resource_system 消耗/饑餓迴圈無 beast 守衛）。

**Q：-1000000 這種 beast 是否實際被算進 seed1337 starve？**
- **否，實測零污染。** 對 baseline godview-F(d0ab7f91) seed1337×8mo 加 print-only 診斷（`_on_team_extinct` starve 分支印 tid/beast_kind/pop/famine，**determinism-safe**，跑完 `git checkout` 還原），6 個 starve 滅團**全是真隊**：
  ```
  tid=48 beast_kind= pop=0 famine=33.8
  tid=58 beast_kind= pop=0 famine=33.3
  tid=52 beast_kind= pop=0 famine=33.3
  tid=19 beast_kind= pop=0 famine=33.3
  tid=96 beast_kind= pop=0 famine=33.3
  tid=35 beast_kind= pop=0 famine=33.3
  ```
  全正 id、`beast_kind` 皆空 → **零 beast**。聚合逐位元重現（extinct.starve=6、attr=19.14%）→ 診斷未擾動 determinism。
- QA 撿的 -1000000 在**決策迴圈** ambition-lock（活著），但**未**在 seed1337 走到 famine 滅團→未進 starve 計數（beast 多經獸戰 `erase_team` 清除，非 `_on_team_extinct` 路徑）。

## 對 blueprint 的裁定
- **seed1337 starve=0 誠實**：immunity(b71647ab) 聚合 extinct.starve=0 → 真隊 starve ⊆ 0 = **0**（0 藏不住真隊死）。且 baseline diag 證計數器此世界只記真隊 → **6→8→0 delta 是真隊改善**，非野獸噪音消長。
- **blueprint 可把 0 當「真隊完全健康」引用。** baseline 6 = 6 真隊、reversal 8 同機制（immunity 不碰 beast）。

## 誠實揭 / 建議
- 只實測 **baseline seed1337**。reversal e77aa99b **無 worktree**，未直接插樁；但 baseline(6 全真)+immunity(聚合 0) 兩端夾住，beast 不受本 feature 影響 → 推 reversal 8 亦真隊為主（未獨立坐實，如需可建 e77aa99b worktree 補跑）。
- **計數器缺永久 beast 守衛=潛在 provenance 洞**：別的 seed/情境若有未被獵、持久餓死的 beast，會被誤計 starve。建議 implementer 在 `_on_team_extinct:2299` starve 分支加 `if team.beast_kind == ""` 守衛（純 probe 過濾、determinism-safe），跟你提的 beast-洩進-決策迴圈根治票同批。此 seed 不需、但 robustness 值得。

## 可溯源
- measured_at_head: `d0ab7f91`（baseline godview-F，diag 為 print-only 已還原、branch clean）。
- raw：`docs/measurements/2026-07-19-beast-provenance-extstarve-diag-base-1337-d0ab7f91.txt`（6 行診斷）+ `...-diag-base-1337-d0ab7f91.json`（聚合，extinct.starve=6 逐位元同前）。

## 下一站
`to:systems` 回證完。你據此告 blueprint「0 可引用（真隊全健康）」+ 決定 beast 守衛是否併 implementer beast-leak 票。
