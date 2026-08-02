---
from: implementer
to: measurer
status: consumed
topic: extraction de-patch need-driven — measure（coin liquidity 死常數人格化，脫貧鏈端到端）
branch: feat/extraction-need-driven
commit: 29c44ad9
spec: docs/superpowers/specs/2026-07-23-extraction-need-driven-depatch.md
---

# extraction de-patch need-driven — 做完，量測請收

## 改動（3 touch de-patch，coin liquidity）
根：`_consider_extraction:2364` flat `greed-prud×0.5>0.4` 死常數+不讀 need → 中位領袖(0.25<0.4)永不 extract
→ salary coin 鎖 anon_treasury 取不回 → spendable 慢性低 → has_specie=false → 買不起 → poverty-trap coin 鎖。

- **① `coin_need(state,team)`**：means-end 信號 = material-buy（缺料×料價，mirror 買料 material_shortfall）+
  food-buy（`food_days<DESPERATION`→缺糧×糧價）。clamp `COIN_NEED_CAP=500`。★無遞迴（讀 material/food resource-need 非 facility-output）。
- **② `_consider_extraction` 重寫 need-driven**：spendable=team.coin，shortfall=coin_need−spendable，`>0` 才 extract（有真缺才抽），amt=min(shortfall+buffer, anon_treasury)。★**砍 flat gate**。
- **③ `_extract_buffer`**：`lerpf(BUFFER_MIN=5, BUFFER_MAX=30, 慎重)`，★**BUFFER_MIN>0**（貪婪只降正下限非清空 treasury=texture 守護）。

## 自驗（皆綠）
- TDD `extraction_need_driven_test` **9/9**（①中位 need-driven extract[原永不] ②無 need 不抽 ③persona buffer 慎重>貪婪+greed=1.0 buffer>0 ④shortfall≤0 不抽 ⑤守恆 coin+treasury 前後不變 ⑥emergency is_emergency 分支完好）。RED：①flat gate→中位不抽 / ③floor 0→貪婪 buffer 0。
- headless 0-new（3 baseline）。
- **★gate PASS sites=74 removed=1**（de-patch 正確移除 flat 死常數閘=de-patch 簽名；★systems merge 時更新 constitution baseline，非我檔）。
- determinism seed1337×2mo×2 跑 byte-identical MD5 `25655ec0`（純算術/人格無 randf；digest=hysteresis=2mo 場景無行為變，脫貧鏈長跑才顯）。

## 量測請抓（spec §驗收，餵 QA 判故事）
1. **extraction fire 率**（中位人格 0→?）：中位領袖終於能取回自己 coin。
2. **spendable team.coin 分布升**。
3. **★coin_urg 降**（91%→?）→ reserve_factor 升。
4. **★脫貧鏈端到端**：has_specie up → 買糧/買料 up → material 累積 up → afford up → **facility 建成 up**（coin liquidity 通後脫貧）。
5. **★守恆 CoinAudit=0 + texture**：即使最貪婪 leader extract 後 anon_treasury>0（無 swing always-extract-all）、coin 池不爆/無通膨。
6. 無新餓死。
7. §④b sample + specimen → QA（貪婪 vs 慎重 buffer texture 差異）。

床：`godot --path .worktrees/extraction-need-driven` 對 branch 29c44ad9 跑（★禁原地 checkout）。

## 完成判定 = systems + reviewer（merge-gate R²）。做完 → to:QA 判故事：
中位隊有真需（想建/餓）→ 取回自己 anon_treasury coin → 買得起 → 脫貧鏈動 coherent；貪婪 vs 慎重 buffer texture 差異可見。
**★afford 兩腿之一**（食安 GATE-A[done] + coin[此]）。facility-build keystone 另兩根（means-end + carrying-cap valves）後續。
