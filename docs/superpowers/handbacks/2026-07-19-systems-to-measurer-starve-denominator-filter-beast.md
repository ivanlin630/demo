---
from: systems
to: measurer
status: consumed
topic: "[provenance·starve 分母是否濾野獸·影響 seed1337=0 誠不誠實] QA 撿 team=-1000000 = 野獸(beast_system.gd:16 負區段 id,TAG_BEAST/無food),非真隊。你的 starve/extinct 計數床是否濾掉 beast(TAG_BEAST 或 beast_kind!='')? ①若已濾→seed1337 真隊 starve=0 誠實可引用,回證(哪行濾)。②若沒濾(-1000000 曾計入 starve 分子/分母)→provenance bug,床加 filter(beast 不進真隊 starve 計數)+重報 seed1337 真隊 starve。標 commit + 原始輸出落 docs/measurements/*.json(可溯源鐵律)。這決定 blueprint 能不能把 0 當『真隊完全健康』引用。"
---

# provenance：starve 分母是否濾野獸

## 背景
- crisis-immunity QA 故事稽核撿 `team=-1000000` 連 300 tick ambition-lock food=0。
- systems 裁定身分 = **野獸**（`beast_system.gd:16` `_next_beast_id=-1000000`；TAG_BEAST/`leader_id=-1`/無 food 經濟 = 戰鬥標的 pseudo-team，非真隊）。
- 根因 = beast 洩進 evaluate_all 決策迴圈（獨立票，known_issues 立）。

## 要你確認一件事
你的 **starve / extinct.starve 計數床**（seed1337 報 starve=6→8→…那個數）：**是否濾掉野獸？**

- 濾條件可用 `team.beast_kind != ""` 或 `team.tags.has(TeamData.TAG_BEAST)`。
- **① 已濾** → seed1337 **真隊 starve 數字誠實**，回證（床哪行濾 beast）→ 我告 blueprint 0 可引用。
- **② 沒濾**（-1000000 這種 beast 被算進 starve 分子或分母）→ **provenance bug**：
  - 床加 filter：beast 不進真隊 starve 統計。
  - 重報 seed1337 真隊 starve（濾後值）。
  - 標 commit hash + 原始輸出落 `docs/measurements/*.json`（可溯源鐵律）。

## 為何重要
blueprint 需要知道 seed1337 starve=0 是**真隊全健康**還是**漏算了野獸的假 0 / 含野獸的髒數**。release 數字要乾淨才能進 baseline 宣稱。

## 注意
- 這是**量測床 provenance**問題（濾非真隊），**非**要你改 sim code。
- beast 洩進決策迴圈的**根治**（讓 beast 不再 ambition-lock）是**另一條** implementer 票（off crisis-merge 後），與你這個濾床工作獨立、不互卡。

## 回覆
`to:systems`：濾了(回哪行) / 沒濾(修床+重報真隊 starve)。
