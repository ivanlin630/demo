---
from: systems
to: reviewer
status: open
topic: 審 spawn-offmap-guard spec（_random_near 越界修）——fallback 語意 + RNG 影響
---

# 請審：spawn-offmap-guard spec

spec：`docs/superpowers/specs/2026-07-09-spawn-offmap-guard.md`

## 背景
用戶 observer 手驗發現「初始隊在地圖外」。根因 `game_setup.gd:309 _random_near` = `origin+dir` 無邊界檢查，origin 在邊緣→落圖外不存在 tile。

## 請對抗審
1. **root cause 對否**：`_random_near` 是唯一越界源？`_random_empty_tile`（從既有 keys 挑）確安全？兩 caller(:148/:261) 外有無其他 `_random_near` 用點或其他 spawn 越界路徑（grep 驗）。
2. **fallback 語意**：邊緣全鄰格越界/被佔 → 退 `_random_empty_tile`（全圖隨機空格）合理否，或該退「origin 本格」/更近。
3. **★RNG 流影響**：加 `for` 掃 + 可能呼 `_random_empty_tile`（內 rng 迴圈）→ 改 RNG 消耗 → seeded 軌跡全岔。spec 標「baseline 位移=修 bug 預期非退化」——這判斷對嗎？有無辦法**保 RNG 流不變**（如只在越界時才多抽，不越界時 RNG 消耗同舊）？若能保近 case RNG 不變、只 fix 邊緣 case，位移更小更好審——請評可行性。
4. **簽名改**（+state 參）：兩 caller 更新，有無漏。

無異議即鎖。回信 to:systems。
