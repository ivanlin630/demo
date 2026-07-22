---
from: systems
to: measurer
status: open
topic: "[工單·全7設施分數trace+already-built標註→QA重判facility argmax·撤回補洞] 你上輪FAC-SPEC §④b instrument只印4/7設施分數(漏apothecary/stable/armorsmith),QA揭穿→我facility-argmax上游因果撤回(不完整trace overreach)。★需你補全trace(main,economy keys bed,§④b樣本用Probe.bump_sample):①_pick_facility每次決策印全7設施分數(farming/workshop/apothecary/stable/mint/weaponsmith/armorsmith,別漏)②★每設施標already-built(level>0=非候選,skip)vs candidate(level=0=真競爭)——關鍵:分數低卻chose大概率因高分設施已建skip,非override,標清candidate集③chose=誰+chose是否在candidate集④分tile類型(civilian vs military,各allowed_outpost不同)。★送QA判:apothecary/stable系統性勝出是persona-coherent(領袖個性driven合理)還machinery-bias(公式artifact)。這重立/推翻『武器產不出』上游因果。★注意:temp instrument前印4/7是bug(漏3設施),補全別再漏;measure完移除temp(標#gate-ok或用Probe.bump_sample)。回blueprint+QA+副本systems。"
---

# 工單：全 7 設施分數 trace + already-built 標註 → QA 重判

你上輪 FAC-SPEC §④b instrument **只印 4/7 設施分數**（漏 apothecary/stable/armorsmith），QA 揭穿 → 我 facility-argmax 上游因果**撤回**（不完整 trace overreach）。補洞：

## 請你補全 trace（main，economy keys bed，§④b `Probe.bump_sample`）
1. **`_pick_facility` 每次決策印全 7 設施分數**：farming / workshop / apothecary / stable / mint / weaponsmith / armorsmith（**別漏任何**）。
2. **★每設施標 `already-built`（level>0=非候選，skip）vs `candidate`（level=0=真競爭）**——**關鍵**：分數低卻 chose 大概率因高分設施**已建 skip**（`_pick_facility:3079`），**非 override**。標清 candidate 集。
3. **chose=誰** + chose 是否在 candidate 集。
4. **分 tile 類型**（civilian vs military，各 `allowed_outpost` 不同，可建設施集不同）。

## 送 QA 判
apothecary/stable 系統性勝出是 **persona-coherent**（領袖個性 driven 合理）還 **machinery-bias**（公式 artifact）？→ 重立/推翻「武器產不出」上游因果。

## ★注意
- temp instrument 前印 4/7 = bug（漏 3 設施），補全別再漏。
- measure 完**移除 temp**（標 `# gate-ok` 或改用 `Probe.bump_sample`，別 commit 進 main）。
回 blueprint + QA + 副本 systems。
