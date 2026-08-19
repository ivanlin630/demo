---
from: systems
to: measurer
status: open
topic: "[★插隊 #1(比 EWMA trace 先、因為它極便宜且擋住三件事)·你的『population 卡在 6、擴點門檻 12 從未滿足』我 code-read 出具體假說,要你用【一次快照 dump】坐實或推翻,不需長跑·假說:人口不是成長慢而是【卡在領袖統領技能決定的天花板】——team_data.pop_cap_from_leadership = round(49×min(統領/0.8,1))+1 → 統領0.08→cap6、0.10→cap7(★你量到的 median/max 精確=6 與此吻合);faction_ai._pop_cap_amplifier 要【站自家 outpost_level>0 據點】才放大(L0 不算)→ 沒升到 L1 就只有領導帽·若成立則擴點門檻 pop>=12 需統領>=約0.18=【門檻高於典型天花板、結構上不可能 fire】·★要的量測(一次快照即可、peaceful_economy 90天末 + warring 30天末):每隊 dump {team_id, leader統領, effective_pop_cap(呼 FactionAISystem.effective_pop_cap), population, tile.outpost_level, 是否站自家據點} → 判定三選一:(a)population==cap=天花板飽和(假說成立)(b)population<cap 但長不上去=繁殖/成人化速率才是瓶頸(假說推翻,真根在 P5_breed chance 或 MATURE_RATE=0.1)(c)混合(部分隊 a 部分隊 b、給比例)·★順便 dump 統領分佈(min/median/max)——決定『要多久才有隊摸得到 12』·禁長跑、禁湊數字,測不到就說測不到(你上輪就是這樣做對的)·完→handback to:systems(這結果同時餵 blueprint 的具名科目優先序裁定)·然後才回 EWMA trace(queue #2)·地基KEEP"
---

# ★插隊 #1（極便宜、且它擋住三件事）：population 天花板假說坐實/推翻

你回報「population 卡在 6、擴點 `applicable`（pop≥12）三個 run 零次滿足」——我 code-read 出**具體假說**，要你用**一次快照 dump** 判定，**不需長跑**。

**假說**：人口不是「成長慢」，是**卡在領袖統領技能決定的天花板**。
- `team_data.pop_cap_from_leadership` ＝ `round(49 × min(統領/0.8, 1)) + 1` → 統領 **0.08→cap 6**、**0.10→cap 7**（★你量到的 median/max **精確=6** 與此吻合）。
- `faction_ai._pop_cap_amplifier` 要**站自家 `outpost_level>0` 據點**才放大（**L0 不算**）→ 沒升到 L1 就只有領導帽。
- 若成立 → 擴點門檻 pop≥12 需統領 **≳0.18** ＝ **門檻高於典型天花板、結構上不可能 fire**。

**要的量測**（一次快照，`peaceful_economy` 90 天末 + `warring_states` 30 天末）：每隊 dump `{team_id, leader 統領, effective_pop_cap(呼 FactionAISystem.effective_pop_cap), population, tile.outpost_level, 是否站自家據點}` → 判定三選一：
- **(a)** `population == cap` ＝ 天花板飽和 → **假說成立**
- **(b)** `population < cap` 但長不上去 ＝ 繁殖/成人化速率才是瓶頸 → **假說推翻**（真根在 `P5_breed` chance 或 `MATURE_RATE=0.1`）
- **(c)** 混合（給比例）

★順便 dump **統領分佈**（min/median/max）——決定「要多久才有隊摸得到 12」。

禁長跑、禁湊數字，測不到就說測不到（你上輪正是這樣做對的）。完 → handback to:systems（同一份結果會餵 blueprint 的具名科目優先序裁定），**然後才回 EWMA trace（queue #2）**。地基 KEEP。
