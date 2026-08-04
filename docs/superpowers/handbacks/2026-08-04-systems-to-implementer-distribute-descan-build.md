---
from: systems
to: implementer
status: consumed
topic: "[dispatch build distribute de-scan(R²CLEAN+1非阻塞追蹤,spec=2026-08-04-infonet-distribute-descan-HOW.md,blueprint de-scan GO,arc最後一哩)·root:letter-carrier根治交付(delivered8/8領主真聞)但distribute.dispatch仍0=goal_resolver:168-169 _resident_food_runway(resident)直讀resident live population/minor_population/effective_food=god-view殘留(用戶否定的領主直掃)+DISTRIB_DEFICIT_DAYS=4.0死常數門檻·fix de-scan:①移:168 _resident_food_runway(resident) live god-view read②移:169 runway>=DISTRIB_DEFICIT_DAYS死常數硬continue閘③:182 deficit_severity改need_signal=clampf(eff_rem/DISTRIB_RELIEF_NORM,0,1)源自buy-order剩餘qty(belief送達need訊)非live runway,relief_term=need_signal×(0.3+honor)人格weigh,coin_term不變·applicability剩全belief/surplus-based(buy-order food+intra-faction resident is_resident_static結構+food_surplus+同格免convoy+eff_rem>0)·順手訂正:122-123舊comment(intra-faction deficit=合法非god-view自辯已被用戶資訊網arc否定,改註belief-only)·守:god-view真移除(distribute零resident live欄直讀,constitution_gate該綠)/死常數真移/relief belief-sourced genuine非crank(DISTRIB_RELIEF_NORM=scale非gate calibration錨真值典型food買單量DERIVED非invent能fire常數,交代錨定依據)/determinism零新randf/economy food_surplus守reserve不變/★全量tap(distribute.dispatch·relief_term值)·branch續feat/info-network-whole·完HANDBACK to:systems我路measurer re-measure症1端到端on FACTION bed(distribute.dispatch>0+糧真到resident runway回升)→QA"
branch: feat/info-network-whole
---

# dispatch build — distribute de-scan（R² CLEAN、blueprint de-scan GO、arc 最後一哩）

**spec**：`docs/superpowers/specs/2026-08-04-infonet-distribute-descan-HOW.md`（R² CLEAN）。**branch**：續 `feat/info-network-whole`。
**root**：letter-carrier 根治交付（delivered 8/8、領主真聞）但 distribute.dispatch 仍 0＝`goal_resolver:168-169` `_resident_food_runway(resident)` 直讀 resident live pop/food=**god-view 殘留（用戶否定的領主直掃）** + `DISTRIB_DEFICIT_DAYS=4.0` 死常數門檻。

## 建什麼（de-scan）
1. **移 `:168` `_resident_food_runway(state, resident)`**（live god-view read：resident.population/minor_population/effective_food）。
2. **移 `:169` `if runway >= DISTRIB_DEFICIT_DAYS: continue`**（死常數硬 continue 閘）。
3. **`:182` `deficit_severity` 改 `need_signal = clampf(eff_rem / DISTRIB_RELIEF_NORM, 0, 1)`**（源自 buy-order 剩餘 qty=belief 送達 need 訊、非 live runway）；`relief_term = need_signal × (0.3 + honor)`（人格 weigh）；`coin_term` **不變**。
4. **applicability 剩全 belief/surplus-based**：buy-order food + intra-faction resident（`is_resident_static`=結構）+ food_surplus + 同格免 convoy + eff_rem>0 + qty>=1。
5. **順手訂正 `:122-123` 舊 comment**（「intra-faction deficit=合法非 god-view」自辯已被用戶資訊網 arc 否定 → 改註 belief-only）。

## 守（build 硬守）
- **★god-view 真移除**：distribute **零 resident live 欄直讀**（`constitution_gate` 該綠）。
- **死常數真移**（DISTRIB_DEFICIT_DAYS 門檻閘刪）。
- **relief belief-sourced genuine 非 crank**（[[feedback_genuine_value_not_crank]]）：base=buy-order qty（真 need 訊 belief）、人格 MODULATE。**`DISTRIB_RELIEF_NORM`=scale 非 gate、calibration 錨真值**（典型 food 買單量 DERIVED、**禁 invent 能讓 distribute fire 常數**、TEST VALUE 標 + 交代錨定依據）。
- **determinism 零新 randf** + **economy 不爆**（`food_surplus` 守 reserve 不變）。
- **★全量 tap**：`distribute.dispatch`/`relief_term 值`——餵 measurer 驗症1 端到端。

## 驗收（re-measure 症1 端到端 on FACTION bed、我路 measurer）
- **`distribute.dispatch / food_delivered > 0`**（領主聞 distress→憑 belief+人格賑濟→convoy 送糧）。
- **★糧真到 resident runway 回升**（端到端真效果、[[feedback_verify_execution_end]]）。
- 人格分化（honor 高救子民）+ **constitution_gate 綠（god-view 移）** + determinism + Part1+3+scout 不退 + economy 不爆。

**完 → HANDBACK `to:systems` → 我路 measurer re-measure 症1 端到端（`lord_distribution_bed`/`peaceful_economy_bed`、糧真到 resident）→ QA 故事稽核（回溯三因果+whole、verdict ref）→ blueprint 對用戶驗收。** 卡 → 報 `to:systems`。

**★注（非本 fix 責任、systems 另記 tracking）**：R² 揭 constitution_gate `GV_TEAMSTATE_RE` 漏「`var X=state.teams[...]` 後讀 `X.<動態欄>`」間接 pattern（本違規因此活過多輪 review）——systems 記 known_issues + 另掃 decision/+faction_ai 同 pattern。**本 fix 不需等 gate 補強。**
