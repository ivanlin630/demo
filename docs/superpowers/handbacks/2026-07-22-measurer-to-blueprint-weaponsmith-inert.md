---
from: measurer
to: blueprint
status: consumed
topic: "[weaponsmith-deficit fix·★formula-correct 但 OUTCOME-INERT·真根更深=build-completion] 0aa7d3ae vs ede2eb06。fix 抬高 weaponsmith 選址 score(選中 12→19)但★build 0→0、weapon pool 36→36(僅開局武器,零生產)、doom byte-identical(seed1337 7/21.2/350、seed42 6/22.5/335 逐位元同)。teams 反覆 dispatch 建設卻 ZERO 完工事件→facility 從不在 sim 完工(census 12farming/5workshop=worldgen 開局非 sim-built)。∴選址非真 gap(baseline 已選 12×),真根=build-completion(建設 task loops 不完工)。fix inert 建議別當 economy-fix merge,systems 查 build-completion。gates 綠。"
measured_at_head: 0aa7d3ae
baseline_head: ede2eb06
---

# weaponsmith-deficit fix 量測 → blueprint（★fix OUTCOME-INERT，真根更深）

branch `feat/weaponsmith@0aa7d3ae`（_deficit_weaponsmith=max(self_defense, market×commercial_inclination)），baseline `ede2eb06`（=main）。

## fix 做到的：選址 score 抬高
- weaponsmith **選中次數 12→19**（FAC-SPEC，baseline 已選 12× ← 非我 9c084d3a 那輪的 1×，世界不同）。fix +7。weaponsmith score with-ore 4.51→5.55。**formula 生效**。

## ★但 OUTCOME 全 INERT
| 指標 | baseline | branch |
|---|---|---|
| weaponsmith **build** | 0 | **0** |
| smelter/armorsmith build | 0 | 0 |
| weapon_melee **pool** | 36 | **36**（僅開局武器，零生產）|
| weapon_ranged pool | 0 | 0 |
| doom seed1337 | starve 7 / attr 21.2 / pop 350 | **7 / 21.2 / 350（逐位元同）** |
| doom seed42 | 6 / 22.5 / 335 | **6 / 22.5 / 335（同）** |

- **build 0→0、weapon 0、doom byte-identical** → fix 對世界零效果。選址多選 weaponsmith 7 次但**沒一個真建起來**。

## ★真根更深：build-completion（非選址）
- log：teams **反覆 dispatch 建設**（Team32/45/35 loop）但 **ZERO facility 完工事件**（無 [Build] complete / level-up print）。
- census farming 12 / workshop 5 = **worldgen 開局設施**（非 sim 期建），因 sim 全程零完工。
- ∴ 選址 argmax **不是真 gap**（baseline 已選 weaponsmith 12×）；真根 = **build-completion——建設 task 在 sim 期 loops 卻從不完工**（facility level 從不 +1）。選址 fix 抬高選中率但完工被擋 → inert。
- 這比我上輪「facility-scoring 平衡」verdict **更深一層**：我上輪看選址（9c084d3a 世界選 1×），但 ede2eb06 世界 baseline 已選 12×，暴露真瓶頸在完工不在選址。誠實修正我的框。

## 判定 + 建議
- **fix formula-correct 但 economy-inert**（build/weapon/doom 零變）→ **建議別當 economy-weapon-fix merge**（它不產武器）。若當「選址 score 語意正確化」小改可留（無害，gates 綠），但別記為解 economy。
- **真序 = build-completion 調查**（交 systems）：為何 teams dispatch 建設但 facility 從不完工？（construction task 持續性 / 資源 / tick 累積 / 完工 gate）。這才是 weapons(及所有 sim-期設施)產不出的真根。

## gates
constitution 75/removed=0（temp FAC-SPEC 帶 `# gate-ok` 保綠）、headless branch=known 5-fail 0-new、determinism implementer 1e72aeb2（formula 無 RNG）。8-config sanity 未跑（fix outcome-inert + headless clean + formula-only → 低崩險；如要我補）。

## 溯源
raw `docs/measurements/2026-07-22-weaponsmith-{baseline,branch,facspec}*`。instrumentation（census+FAC-SPEC）純 probe 已 revert、main+branch clean。副本 systems（build-completion 調查）。
