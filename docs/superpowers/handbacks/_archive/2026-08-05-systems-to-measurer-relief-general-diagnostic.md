---
from: systems
to: measurer
status: consumed
topic: "[★資訊網補完批①先行=relief 通用化 diagnostic(measure-first,查 general settled 經濟 distribute=0 真根)·systems 結構前分析已揭關鍵線索:所有 settled 經濟床(econ_bed/peaceful_economy/survival_start)全 faction_id=-1 零 faction,warring 床 solo-heavy 也零 faction→distribute relief 需 resident.faction_id==lord.faction_id(goal_resolver:173 intra-faction gate)→無 faction 結構=relief 根本不 applicable,唯一有真 faction 是 fixture infonet_whole.json·∴假說:general distribute=0 可能=『無對床行使 faction-lord-member 結構』而非『機制一般失敗』待你 measure 分辨·branch feat/info-network-whole(godot --path worktree,GODOT_TIMEOUT=1200,禁原地 checkout)·三問:①有無 settled 床真行使 faction(lord-team+member-resident 同 faction,一 member 餓)?econ 床 faction 是否 sim 中 emergent 形成?②若建/跑一 faction-rich settled 床,distribute 鏈斷哪站(candidate_eval→side mini-util→dispatch→convoy→deliver 逐站 tap,同 arc 既有 tap)?③economy-balance:relief 量級/timing/餓死底線——救得到人否 or 太小/太晚(fixture 曾間歇撐命非穩定復甦)·bed 建議:多 faction 各 lord-team+member-resident-team(faction_id 須==leader team_id 或走 branch game_setup cfg_to_actual 修,別踩 faction-key bug),settled 非 warring,跑到一 member 餓;或跑 peaceful_economy 夠久看 faction 是否 emergent 形成+member 餓死觸 relief·出 diagnostic json 落地 docs/measurements/ 回 systems→定 root→補完批 slice·measure-first 禁靜態斷言,dump 真值(candidate_eval/dispatch/deliver 真數+per-station 斷點)"
---

# ★資訊網補完批 ①先行 = relief 通用化 diagnostic（measure-first）

用戶裁核心 arc CLOSED（誠實 scope）；補完批第一步＝查 **general settled 經濟 distribute=0 真根**。blueprint 疑「warring bed solo-heavy≠對床，經濟床有 faction+resident+lord 該通」。

## ★systems 結構前分析（關鍵線索、免你浪費輪）
- **所有 settled 經濟床全 `faction_id: -1`＝零 faction**：`econ_bed.json`（林業村/平原糧鎮/中立商隊）、`peaceful_economy.json`（①立國A-C/②發展A-B）、`survival_start.json`（流民/野村/乞丐團）——**逐一 config faction_id=-1**。
- warring 床 = solo-heavy 也**零 faction**（arc 中證）。
- **distribute relief 需 `resident.faction_id == lord.faction_id`**（`goal_resolver:173` intra-faction gate，PROVEN 正確、不改）→ **無 faction 結構 = relief 根本不 applicable**。
- 唯一有真 faction 的是 fixture `infonet_whole.json`（arc 專屬建）。
- **∴假說**：general distribute=0 可能 = **「無對床行使 faction-lord-member-resident 結構」**、而非「機制一般失敗」。**待你 measure 分辨這兩者**（結構缺失 vs 機制缺陷）。

## 三問（measure-first、dump 真值）
1. **有無 settled 床真行使 faction 結構？**（lord-team + member-resident-team 同 faction、至少一 member 餓）。`econ_bed`/`peaceful_economy` 的 faction 是否在 sim 中 **emergent 形成**（factionless teams via faction_ai 建 faction + member 加入）？還是全程 factionless？
2. **若建/跑一 faction-rich settled 床，distribute 鏈斷哪站？** 逐站 tap（同 arc 既有 tap、別跳步）：`distribute.candidate_eval`（de-scan 後生成數）→ side mini-util（`_try_distribute_side` 過門否）→ `distribute.dispatch` → convoy travel/arrive → `distribute.deliver`/`food_delivered`。斷點決定是 applicability / argmax-side / settle / lifecycle。
3. **economy-balance**：relief **量級/timing/餓死底線**——送達的糧救得到人否？還是**太小/太晚**（fixture 曾 day38-54 17 天 food=0、間歇撐命非穩定復甦）？relief qty vs resident drain vs latency 三者關係 dump。

## bed 建議（你 finalize/run）
- 多 faction，各 **lord-team + member-resident-team 同 faction**，settled（非 warring），跑到一 member 餓。
- **faction_id 須 == leader team_id**（隱含約定）**或**走 branch `game_setup` `cfg_to_actual` 修（已在 branch、別再踩 faction-key bug）。
- **或**：跑 `peaceful_economy` 夠久，看 faction 是否 emergent 形成 + member 餓死觸 relief（若 emergent 路真跑得出，更貼「真世界」）。

## 交付
- branch `feat/info-network-whole`（`godot --path .worktrees/info-network-whole`、`GODOT_TIMEOUT=1200`、**禁原地 checkout**）。
- diagnostic json **落地 `docs/measurements/`**（標 exact path）回 `to:systems` → 我定 root → 補完批 slice / 若純結構缺失則 blueprint 評 bed-strategy。
- **measure-first 禁靜態斷言**，dump 真值（candidate_eval/dispatch/deliver 真數 + per-station 斷點）。blueprint 平行寫 L3+失聯帳本 WHAT spec。地基 KEEP。
