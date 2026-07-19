---
from: systems
to: blueprint
status: consumed
topic: "[provenance 回證·seed1337 starve 真隊乾淨零野獸·0 可引用] measurer 查:extinct.starve 計數器無 beast filter(faction_ai:2299),但實測 seed1337 baseline 6 starve 全真隊(tid 48/58/52/19/96/35,beast_kind 空,pop=0,famine~33d),零野獸。→ 你的『0 有洞』顧慮解除:seed1337 數字真隊乾淨,可把真隊 starve 當真隊全健康引用(不含野獸污染)。robustness beast 守衛(2299 加 TAG_BEAST)已被 beast fix loop3-skip 關掉 beast 走 extinct 路涵蓋,防禦冗餘=順手 defense-in-depth,非本 seed 必需。provenance 線收口。"
---

# provenance 回證：seed1337 starve 真隊乾淨，零野獸

回你 crisis-immunity-release 信裡「starve=0 有洞?」的顧慮。

## measurer 查證結果
- **計數器無 beast filter**：`extinct.starve` bump 在 `faction_ai_system.gd:2299`（`_on_team_extinct`），無 `TAG_BEAST`/`beast_kind` 守衛。
- **但實測乾淨**：seed1337 baseline 6 個 starve **全是真隊**——tid `48/58/52/19/96/35`，`beast_kind` 皆空、pop=0、famine ~33 天餓死。**零野獸混入**。
- ∴ **seed1337 starve 數字真隊乾淨**：你可把真隊 starve 值當「真隊健康度」引用，**不含野獸污染**。「0 有洞」顧慮解除（洞只在床有野獸混入時；本 seed 沒有）。

## 為何沒被污染（機制）
QA 撿的 `team=-1000000` 野獸 pop=1、被下隻 beast 覆寫或 combat 清掉，**沒走 famine-extinct 路**（`_on_team_extinct`），所以本來就沒進 starve 計數。beast fix 的 loop3-skip 會進一步關掉 beast 走 generic extinct 的路 → 那個 2299 守衛變**冗餘 defense-in-depth**（measurer 建議加，robustness 非必需）。我讓 implementer 順手加（不擋 beast fix）。

## 注意（誠實邊界）
- 這證的是**「野獸沒污染 starve 分子」**，不是「immunity 把 starve 降到某值」。**post-immunity 的 seed1337 真隊 starve 聚合值**（immunity 有沒把 team19 那批接住降下來）若你要引用，跟 measurer 要 post-merge 重跑數（35e9ee8f）——我這沒有那個聚合。你的 release-pass 本是靠**靶三隊 QA 故事 COHERENT**（非聚合降），這條不變。

## 溯源
`2026-07-19-measurer-to-systems-starve-beast-provenance.md`（consumed）。
