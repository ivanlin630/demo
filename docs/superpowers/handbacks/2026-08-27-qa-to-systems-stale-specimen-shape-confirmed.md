---
from: qa
to: systems
status: open
slice: gather-dirty-flag-cache
tier: behavior
topic: "★形狀稽核得動,已判——讀過market_known_stale_specimen.gd+FactionAISystem:3510-3527,確認比對點真的在【命中的當下】(cache-hit分支內、決策即將用值那一刻),不是tick結束後掃描;n_pairs=807是full-window計數(抽樣只發生在落地檔案輸出,不影響分母);措辭『窗內未見不一致』守住,沒寫『從不』——這張票在specimen這一半可以往下走;唯一非阻塞小建議:missing_in_npc只記單向(truth有NPC沒有),沒記extra_in_npc(NPC以為有但truth已無),same雖已對稱抓到但診斷細節少一半"
---

# 形狀稽核得動——已核過 code，判 ✅

## 核過的東西
讀了 `scripts/debug/market_known_stale_specimen.gd` 全檔 + `faction_ai_system.gd:3510-3527`（比對點本體），不是只信你信裡的敘述：

1. **比對點真的在「命中的當下」**：`if state.team_market_known_key... == _mk_key:`（cache-hit 分支）**內部**才記錄，precisely 是「決策即將用這個值」的那一刻，不是 tick 結束後掃存量——你自己踩過的坑（把「沒人讀過的舊值」報成不一致）在這版看不到了。
2. **真值來源乾淨**：清鍵後呼叫**同一支 production 函式**（`_harvest_market_known`）重算，不是另抄一份掃描邏輯——避開「抄錯產生假一致/假不一致」那個雙向風險。
3. **`n_pairs=807` 是 full-window 計數，不是抽樣**：`vr.size()`（`_mk_verify_rows`）在整個 2400-tick 迴圈裡逐筆 append，抽樣只發生在**落地檔案**那一步（全部不一致 + 每 97 筆一個一致案例，為了給我兩種都看得到）——分母沒被抽樣稀釋，這點我特別查過（你知道我在意這個）。
4. **措辭守住**：`[FAIL]`/print 那句是「樣本窗內未見不一致，窗=2400 tick/807 筆配對」，沒有寫「從不」。✅

**⇒ 這張票在 specimen 這一半，形狀可以往下走，不用再改。**

## 一個非阻塞的小建議（你要不要都行）
`missing_in_npc` 只記單向（**truth 有、NPC 沒有**），沒記 `extra_in_npc`（**NPC 以為有、但 truth 已經沒有**——這才是真正的「過期」語意：舊資訊還留著沒被清掉）。
`same`（hash 比對）本身是對稱的，兩個方向的差異都會被抓到、不會漏——**但診斷細節目前只看得到一半**：若哪天真的出現 `same=false`，你會知道「NPC 少了什麼」，但看不到「NPC 多了什麼過期的」。現在 807/0 用不上這格，**留著給未來哪天真出現不一致時排查用**，不阻塞現在。

已讀完，改 consumed。
