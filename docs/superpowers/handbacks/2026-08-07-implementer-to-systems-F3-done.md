---
from: implementer
to: systems
status: consumed
topic: "[F3 subteam-messenger utils→SubteamSystem DONE·②結構 byte-identical·feat/framework-F3 commit fc2509e1]①3 函式(founding_timeout/equip_envoy_mounts/recall_envoy)+2 const(FOUNDING_TIMEOUT_MULT/FLOOR_DAYS)逐字搬 faction_ai→SubteamSystem(instance→static、零 logic 改、零反向耦合全呼外部)。②caller 全更新 18 site(全 faction_ai:founding×7+equip×4+recall×7)→SubteamSystem.;debug/test 掃=零(守 F2 教訓);interaction _recall_envoy_home=不同函式未動。★★命門:fp 對 ce201650 27/27 byte-identical(diff=0)。驗:constitution 75(recall_envoy 呼 release 非 transition→gate 不抓無新 site、R²④觀察坐實)+headless 0-new+determinism 天然保持。★F3 off main(F0/F1、無 F2:F2 R² pending 未 merged;F3 獨立不同函式=無衝突、baseline ce201650[F1]正確 target)。請 R²(核純移零改+18 caller 無漏+fp byte-identical)→QA→merge=F3 收→F4+。"
branch: feat/framework-F3
commit: fc2509e1
---

# F3 subteam-messenger utils→SubteamSystem DONE（②結構、byte-identical 純程序）

feat/framework-F3 commit `fc2509e1`（已 push、pre-push constitution PASS 75）。★純結構搬移零 logic 改。

## ① SubteamSystem 靜態化搬移（逐字、零 logic 改）
3 函式 + 2 const 自 `faction_ai_system` 逐字搬入 `SubteamSystem`（instance→static）：
- `founding_timeout`（純算術 dist×MOVE_TICKS×MULT / FLOOR）/ `equip_envoy_mounts`（ResourceBank.add 撥馬）/ `recall_envoy`（TaskArbiter.release + state.detach_subteam/remove_tag）+ `FOUNDING_TIMEOUT_MULT`/`FOUNDING_TIMEOUT_FLOOR_DAYS`。
- **零反向耦合**：全呼外部（MovementSystem/WorldState/ResourceBank/TaskArbiter/state）、不回呼 faction_ai。

## ② caller 全更新 18 site（全 faction_ai 內、R² 逐一點名）
- `founding_timeout`×7（:1210/1333/1909/2048/2073/5143/5237）+ `equip_envoy_mounts`×4（:1351/2075/5145/5239）+ `recall_envoy`×7（:1400/1406/1411/1590/1594/1597/1629）→ `SubteamSystem.`。
- ★**debug/test 掃 = 零**（守 F2 教訓、本輪確認無漏）。★`interaction_system._recall_envoy_home`（:451/454/479）= **不同函式、未動**。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| ★★**fp 對 ce201650** | **27/27 byte-identical、diff=0**＝純移零行為變命門證 |
| constitution_gate | **PASS sites=75**（R²④觀察坐實：`recall_envoy` 呼 `TaskArbiter.release` 非 transition/try_set → gate 不抓、baseline 零 _recall_envoy 指紋 → 搬移零 constitution 影響、無新 site） |
| headless | **0-new**（Team23建設/弱目標/p2a/197/rung pre-existing） |
| determinism | 天然保持（fp byte-identical to 3-run-stable ce201650 baseline） |

## ★note（呈你、透明）
F3 off 更新後 main **含 F0/F1、無 F2**（CoinTreasury absent；F2 R² pending 尚未 merged）。F3 與 F2 **獨立**（不同函式：treasury vs subteam-messenger）→ 無衝突、兩者先後 merge 皆可。baseline `ce201650`（F1 行為）為 F3 正確 byte-identical target（F3 base=F1）。

## 路
1. **你 R²**（核：純 code-move 零 logic 改 + 18 caller 無漏 + fp byte-identical 27/27 + 零反向耦合）。
2. → QA → merge = F3 收 → F4+。

地基 KEEP。（F2 disk flag 仍待 systems prune ~115 stale worktrees。）
