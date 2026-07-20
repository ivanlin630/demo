---
from: systems
to: implementer
status: open
topic: "[dispatch·god-view Slice D·最大塊·異質 R² v3 CLEAN(3輪)·★off LOCAL main 3dee8b5a·measure 敏感] spec=2026-07-20-godview-slice-D-pathsystem-freshness-gate.md。★感知鐵律最大違憲點+measure 敏感(動全盤 threat/combat)→非盲改。修=差異化 belief-gate(velocity≠position):①observe_velocity(:175)本tick可見(belief last_tick==current_tick)→live velocity/斷視線→{visible:false}(非last-seen);移 trusted ②predict_intercept(:241)斷視線→belief last-seen 位(非 live)/sentinel(-1,-1)+★envoy caller faction_ai:1403-1408 lockstep(別靠!=target.tile_pos)③estimate_catch_up(:202)catch_cost:210 position→belief last-seen ④_is_moving_away_observed(:226)被 observe_velocity fix 級聯保護(verify)⑤★fold threat_assessment:20 dist_factor→belief(可見live距/斷視線last-seen/positionless→dist_factor=0=不 flee 無位威脅合 null-belief-flee)。★caller 10(faction_ai:205/293/1403/2134/3607/3636/3666/3715/3747+threat:27,非3596)——★落地前再 grep 確認(別信 stale 行號=fileline 紀律)。★★off LOCAL main 3dee8b5a 禁 origin,pre-push hook 已裝。TDD 差異化7型+leak測。gate/headless 0new/★measure=before/after doom-delta+threat/combat 行為+★combat_target 凍結隊數(D 餵 stale,顯著增=撲空放棄網缺口另票)+逐隊 coherent/broken 切(承 Slice E)。task=systems+reviewer。"
---

# dispatch：god-view Slice D（最大塊，異質 R² v3 CLEAN 3 輪）

spec：`docs/superpowers/specs/2026-07-20-godview-slice-D-pathsystem-freshness-gate.md`（v3，異質審 3 輪磨：v1 velocity 語意錯→v2 差異化→v3 fold dist_factor）。**★感知鐵律最大違憲點 + measure 敏感（動全盤 threat/combat/flee）→ 非盲改**。

## ★★ branch base
- **off LOCAL main `3dee8b5a`**（禁 origin 落後）。pre-push hook 已裝。

## 修（差異化 belief-gate：velocity≠position）
freshness = `belief last_tick == current_tick`（本 tick 可見）：
- **① observe_velocity（velocity，`:175`）**：可見→live velocity；**斷視線→`{visible:false}`（非 last-seen！velocity 無 belief analog）**；移 `trusted`。→ 級聯保護 predict_intercept + _is_moving_away。
- **② predict_intercept（velocity，`:241`）**：observe invisible→**belief last-seen 位（非 live `target.tile_pos`）**；sentinel=last-seen/`(-1,-1)`。★**envoy caller `faction_ai:1403-1408` lockstep**（別靠 `!= target.tile_pos` 判 fallback→改讀明確 sentinel or 自己 has_belief 先判，防誤寫 `(-1,-1)` 進 move_target）。
- **③ estimate_catch_up（position，`:202`）**：`catch_cost:210` 的 target 位→可見 live/斷視線 **belief last-seen**（eta 有意義）；velocity 部分自動 degrade。
- **④ _is_moving_away_observed（`:226`）**：observe invisible→dir ZERO→`:228` 短路 return false（**被 ① 級聯保護，verify 不讀 live**）。
- **⑤ ★fold threat_assessment:20 dist_factor**：`_hex_dist(self, other.tile_pos)` 讀 live→**belief**（可見 live 距/斷視線 last-seen/**positionless→`dist_factor=0`**=不 flee 無位威脅，合 null-belief-flee+既有 dist≥5 逃出生天）。→「威脅評估 belief 化」真達成（approach+dist+rep+power 全 belief）。

## ★caller inventory（reviewer 親驗 10，非我 v1 stale 行號）
`faction_ai:205/293/1403/2134/3607/3636/3666/3715/3747` + `threat_assessment:27`。~~3596~~ 非 caller。**★落地前再 grep 確認**（fileline 紀律血教訓，別信 stale 行號）。

## 驗收
- **TDD 差異化 7 型**（spec §驗收①-⑦：velocity→invisible/position→last-seen/predict sentinel/estimate 混態/moving_away 級聯/envoy lockstep/dist_factor belief）+ leak 測。
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical。
- **★measure（→measurer，非盲改）**：before/after doom-delta（seed1337/42/4201）+ threat/combat 行為對照（威脅評估分佈/追擊撲空率/flee 率）+ **★combat_target 凍結隊數 before/after**（D 餵 stale，顯著增=撲空放棄網缺口另票）+ **逐隊 coherent/broken 切**（承 Slice E：doom-delta 升是 intended 脫視野甩追 vs pre-existing bug 暴露）。
- **★god-view audit**：D 後 path_system 4 func + threat:20 全 belief-gate→「威脅評估 belief 化」誠實斷言。

## 完成判定 = systems + reviewer/QA。做完 → to:measurer（before/after）。
