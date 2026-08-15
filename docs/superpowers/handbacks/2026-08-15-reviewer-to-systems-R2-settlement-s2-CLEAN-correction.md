---
from: reviewer
to: systems
status: consumed
topic: "[R②判決=CLEAN+1較重必查項(窮盡負斷言實際漏4-5倍站點,但結論不變甚至更強)] settlement S2 L0營地階梯HOW——★親grep全scripts/simulation/『outpost_level==0|<=0』獨立驗證『~10處』這個窮盡負斷言:實際命中45+處(need_oracle.gd 2+manufacturing_system.gd 1+game_setup.gd 1+food_flow.gd 1+interaction_system.gd 1+harvest_system.gd 2+player_query_api.gd 1+state_fingerprint.gd 1+resource_system.gd 2+faction_ai_system.gd約20+player_command_system.gd 3+order_system.gd 5+outpost_system.gd 6+observer_query_api.gd 2)——spec的『~10處(need_oracle:42/80+8個faction_ai站點)』只是faction_ai_system.gd這單一檔案內的子集,完全漏列了另外至少10個其他檔案共25+站點,這不是±1行的citation drift量級,是exhaustive claim本身實際只做了單檔掃描;★但結論方向不受影響甚至更強化——漏掉的站點裡最關鍵是outpost_system.gd六處(446/469/511/638/658/681/745,全是L1→L2/L3升級/建造邏輯的outpost_level==0=無據點gate,這正是這個slice自己要接的L0→L1鏈上下游)+state_fingerprint.gd:119(outpost_level<=0進determinism fingerprint計算,直接關聯這個arc自己要求的fp intended-change驗證)——這些額外站點全部支持『outpost_level==0語意早已被大量既有code當作無據點空tile哨兵使用、不該被L0佔用』這個核心論點,只是spec自己都不知道論點有這麼多支撐;要求訂正:(a)把『窮盡』字面改成準確反映實際掃描範圍或補完真正窮盡的全清單(b)implementer測試覆蓋面明確納入outpost_system.gd六站點(最直接相關,升級鏈跟這slice共用同一組level語意)+state_fingerprint.gd:119(determinism relevant)這兩組原本漏掉但最要害的consumer,非只驗faction_ai_system.gd既有清單;②camp_level獨立flag設計本身合理非框架冗餘(outpost_type/level管的是真據點屬性,camp_level管的是transient L0狀態,兩者管轄範圍不重疊,不是同件事做兩次);③機制意圖對照/busy-preemptible重用/感知鐵律proximate讀法皆親驗合理坐實;判決=CLEAN+1較重必查項(窮盡清單補完+測試覆蓋擴大,非阻塞方向、要求implementer開工前納入)→S2a plan→dispatch"
---

# R②判決：settlement S2 L0 營地階梯 HOW — CLEAN + 1較重必查項

## ★負斷言 fact-check——親自獨立重跑，發現「窮盡」實際漏了 4-5 倍站點

親 grep 全 `scripts/simulation/` 的 `outpost_level==0|<=0` 獨立驗證 spec §0 的「窮盡：~10 處」這個負斷言。**實際命中 45+ 處**，橫跨至少 14 個檔案：`need_oracle.gd`(2)/`manufacturing_system.gd`(1)/`game_setup.gd`(1)/`food_flow.gd`(1)/`interaction_system.gd`(1)/`harvest_system.gd`(2)/`player_query_api.gd`(1)/`state_fingerprint.gd`(1)/`resource_system.gd`(2)/`faction_ai_system.gd`(约 20)/`player_command_system.gd`(3)/`order_system.gd`(5)/`outpost_system.gd`(**6**)/`observer_query_api.gd`(2)。

spec 的「~10 處（`need_oracle:42/80` + 8 個 `faction_ai` 站點）」**只是 `faction_ai_system.gd` 這單一檔案內的子集**，完全漏列了另外至少 10 個其他檔案、共 25+ 站點。這不是 ±1 行等級的 citation drift，是「窮盡」這個字面宣稱本身實際上只做了單檔範圍的掃描。

## ★但結論方向不受影響、甚至更被強化——這不是要推翻設計，是要補完證據跟測試覆蓋

漏掉的站點裡最關鍵的兩組：
- **`outpost_system.gd` 六處**（`:446/469/511/638/658/681/745`）——全是 **L1→L2/L3 升級/建造邏輯**的 `outpost_level==0`=無據點 gate，這正是這個 slice 自己要接的 **L0→L1 鏈的直接上下游**，跟這輪 S2b 的「完成 L1」邏輯共用同一組 level 語意。
- **`state_fingerprint.gd:119`**——`outpost_level<=0` 進 determinism fingerprint 計算，直接關聯這個 arc 自己要求的 `fp intended-change` 驗證機制。

這些額外站點**全部支持**「`outpost_level==0` 語意早已被大量既有 code 當作無據點空 tile 哨兵使用、不該被 L0 佔用」這個核心論點——只是 spec 自己都不知道這個論點有這麼多支撐。`camp_level` 獨立 flag 這個設計方向**不但沒被推翻、反而被更多證據撐住**。

**要求**：
(a) 把「窮盡」這個字面表述改成準確反映實際掃描範圍，或補完真正窮盡的全清單；
(b) implementer 測試覆蓋面明確納入 `outpost_system.gd` 六站點（最直接相關，升級鏈跟這 slice 共用同一組 level 語意）+ `state_fingerprint.gd:119`（determinism relevant）這兩組原本漏掉但最要害的 consumer，非只驗 `faction_ai_system.gd` 既有清單那 ~10 處——L0 落地後這些站點若被誤判成「有據點」會是真 regression，值得在 §2 TDD 清單裡明確加測項。

## 其餘審點

**②`camp_level` 獨立 flag——非框架冗餘**：`outpost_type`/`outpost_level` 管的是真據點屬性（升級/建設/稅/領土），`camp_level` 管的是 transient L0 狀態（露宿→L0 這個中間態，無據點但有臨時遮蔽）——兩者管轄範圍不重疊，不是同一件事做兩次，是補一個現況缺的中間態。

**③機制意圖對照/busy-preemptible 重用/感知鐵律 proximate 讀法**：親驗合理坐實（busy-preemptible 已在 settlement WHAT/HOW 前幾輪確認真實存在；proximate 讀法跟 `establish_crude_camp:4708`/`_tick_solo_settle` 既有 pattern 一致）。

`camp_level` 親 grep 確認全 `scripts/` 零命中，新欄無撞，屬實。

## 判決
**CLEAN + 1較重必查項（窮盡清單補完+測試覆蓋擴大，非阻塞設計方向、要求 implementer 開工前納入）→ S2a plan → dispatch。** 設計結論本身正確且被更多證據支撐，問題是「窮盡」這個字面宣稱不精確，若不補完清單，S2a/S2b 的測試覆蓋很可能漏掉 `outpost_system.gd` 升級鏈跟 `state_fingerprint.gd` 這兩組最相關的既有 consumer。
