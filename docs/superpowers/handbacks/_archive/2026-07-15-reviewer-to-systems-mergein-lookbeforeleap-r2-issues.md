---
from: reviewer
to: systems
status: consumed
topic: "[R②判決·issues] Fix A-2併入look-before-leap——感知鐵律/不誤殺/code定音皆CLEAN,但has_acceptable_join_host漏host對應(strong_neighbor vs consolidate_target二選一)"
---

# R② 判決：Fix A-2 併入 look-before-leap

verdict: **issues**
premise_contradiction: false

## 逐點驗（file:line 全查證）

1. **感知鐵律 CLEAN**：`belief_system.gd:114-124 best_estimate(state, obs_id, tgt_id)` 讀的是 `claims(state, obs_id, tgt_id)`——joiner 自身 claims-based 情報（可失真/stale），非 god-view 讀 host 真值；`claims` 空 → 回 `{}`，對應 spec「無 belief→保守不入候選」設計正確。與既有 `_find_aid_target` 用 belief 判斷的先例（上輪異質框外審已核）同構，non-god-view 一致。
2. **不誤殺 CLEAN**：spec 明寫 belief 估（含 stale/失真副本）算 acceptable，同 Fix A「不濾 stale」原則一致，到場真被拒走既有 release 撲空 emergent——架構上與已核准的 Fix A 家族一致，非新矛盾。
3. **code 定音 CLEAN（診斷屬實）**：`interaction_system.gd:1066 _absorber_accepts`（`:1079 feed_ok`/`:1080 accept_util`/`:1081 ACCEPT_UTIL_THRESHOLD`）、`:1094 _resolve_join`（`:1100-1103` 拒絕只 `clear_social_target`+`release`，**無 cooldown/黑名單**）——「餓世界恆拒→joiner 重選併入→又拒」loop 診斷坐實，非漏看漸進 path（`_resolve_mergein` 命名+ full-absorb 呼叫模式無 partial 參數，支持 full-or-nothing 判斷）。

## issue：host 對應未定（refute點3延伸出的具體缺口）

`options.gd:181`（`to_task` 併入分支）host 選擇有**明確優先序**：`host = strong_neighbor_id if strong_neighbor_id != -1 else consolidate_target_id`——兩個候選 host 語意不同（跨 faction 保護傘 vs 同 faction 整併），`decision_context.gd:44/106` 確認兩欄位各自獨立存在、可能同時有值。

spec `:54`「有可達 host（strong_neighbor/consolidate_target）」把兩者並列成單一 `has_acceptable_join_host` 布林，**未指定該 belief-估的是哪一個 host**。若 implementer 對兩者取 OR（任一 acceptable 就算 true），會重現本刀正要修的 bug 的變形：consolidate_target 被 belief 判為 acceptable → gate 通過 → 但 `to_task:181` 優先派往 strong_neighbor（若存在，未必被評過/未必 acceptable）→ 實際 dispatch 的 host 與 gate 驗證的 host 不同 → 仍可能恆拒 loop（gate 通過但 resolver 拒的，正是你 refute 點3 自己點名要防的錯配）。

**要求**：`has_acceptable_join_host` 須鏡射 `options.gd:181` 同一優先序算——先取 `host = strong_neighbor_id if != -1 else consolidate_target_id`，belief 估**這一個** host，非兩者獨立判斷後 OR。

## 框外審評估
同意——非新大框（Fix A 家族小增補），標準審足夠，不需再升異質。

## 結論
機制/感知鐵律/診斷皆 CLEAN，**唯一 issue＝host 對應未鎖定**（一行澄清即可，非重新設計）。**issues → halt，退回一行補充後可 CLEAN。**
