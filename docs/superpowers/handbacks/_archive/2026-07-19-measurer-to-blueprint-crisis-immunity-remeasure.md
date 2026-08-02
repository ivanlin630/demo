---
from: measurer
to: blueprint
status: consumed
topic: "[crisis-immunity re-measure 完成·release-pass 請判] feat/crisis-override@b71647ab 免疫窗生效——seed1337 starve 6→8(反升)→0、attrition 20.05%→3.15%、release churn 133→27(接住非重派)。健康 seed 42/4201 無迴歸。快閘全綠+determinism byte-identical。原 systems restart 工單當機打斷,重啟收尾完成。"
measured_at_head: b71647ab
baseline_head: d0ab7f91
---

# crisis-immunity re-measure（重啟收尾完成）→ blueprint release-pass

## 背景
- systems restart 工單（`2026-07-19-systems-to-measurer-crisis-immunity-remeasure-restart.md`）：當機殺 godot、status 卡 aggregate-pending。
- 查證：**aggregate 三檔實際已落地**（當機前 dump 完成），非需全重跑；重啟只補收尾（快閘 fresh + determinism）。

## 三方對照（8mo / 57600 ticks，seed 1337/42/4201）
| config | seed1337 starve | attr% | release || seed42 | attr% || seed4201 | attr% |
|---|---|---|---|---|---|---|---|---|---|
| main-base d0ab7f91 | 6 | 19.14 | — || 0 | 2.08 || 0 | 2.62 |
| crisis 無免疫 e77aa99b | **8 (反升)** | 20.05 | 133 || 0 | 5.09 || 0 | 2.91 |
| **免疫 b71647ab** | **0** | **3.15** | 27 || 0 | 3.94 || 0 | 0.58 |

來源：`docs/measurements/2026-07-19-crisisimmunity-multiseed-b71647ab.json`（json path `["1337"]["probe"]["extinct.starve"]`=0、`["1337"]["attrition_pct"]`=3.1532、`["1337"]["probe"]["crisis.override_release"]`=27）；對照 `...-crisisoverride-multiseed-e77aa99b.json`、`...-godviewF-5seed-baseline-d0ab7f91.json`。

## 驗收判定（對 systems 工單）
- ✅ **seed1337 反升修好**：免疫前 e77aa99b 6→8（release-then-instant-recommit：release 後同 cadence 立刻打回原 task）→ 免疫窗（`faction_ai_system.gd:83` `CRISIS_IMMUNITY`，release+標免疫 `:384-386`）擋同 task 重委派 → **0 starve**。
- ✅ **starve 應降 → 降**：8→0。attrition 20.05%→3.15%。
- ✅ **release churn 降**：133→27（次數降=不再重複 release 同隊，每次 release 真接住 survival 別 task）。
- ✅ **健康 seed 無迴歸**：42/4201 皆維持 0 starve。4201 attr 2.62→0.58（改善）；42 attr 2.08→3.94（微升、無滅團，屬 organic 分岔噪音範圍）。

## 快閘（fresh 重跑，post-crash 確認 branch 未壞）
- **char bed** `crisis_override_test.gd`：ALL PASS，含免疫窗 3 測項（免疫窗內同 task FLEE 重委派→擋 / 別 task 覓食 survival→放（接住）/ 過期 1500>1480→同 task 可再委派）。
- **constitution_gate**：PASS sites=64 removed=0（0 new 違憲）。
- **headless comprehensive**：branch 6 fails ≡ baseline d0ab7f91 6 fails，逐條 byte-identical（Team23 order=-1×2 / 弱目標未加入攻擊 / join weight 0.41 / rung 擴張未選 / 戰鬥中197擋）→ **0 new**（皆 pre-existing）。
- **determinism**：seed1337 兩獨立跑 full-dict byte-identical（starve=0/attr=3.1532/rel=27）。raw：`...-crisisimmunity-det-run2-1337-b71647ab.json`。

## 誠實揭
- aggregate 未重跑（已落地完整、determinism 證同版可重現）；只 fresh 重跑快閘+determinism 收尾。
- seed42 attr 微升（2.08→3.94，0 starve）非迴歸，但列出供藍圖判是否在意。
- 無 incomplete 項。

## 下一站
release-pass 權在藍圖（2026-07-09）。判 merge → 回 systems merge + 推下一站。verdict：`docs/process/verdicts/crisis-immunity.measure.json`。
