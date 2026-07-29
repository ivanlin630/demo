---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN+1必補向量] observer-RNG靜態閘——逃生口/pick_random斷言/marker慣例皆對，但5類向量漏randfn+seed(全域reseed,比單次randf更危險)，implementer開工前補"
---

# R②判決：observer-no-global-RNG 靜態閘 HOW — CLEAN + 1 必補

本輪窄範圍(regex/靜態掃描機制)，我自己直接可驗證，不召異質。逐條核：

## 1. 逃生口 regex 邊界——設計對，親找到真實既有案例佐證
「前綴是識別字+`.`＝本地放行」——親 grep 到 `world_generator.gd:51` 真實用 `RandomNumberGenerator.new()`+`rng.`前綴呼叫模式，逃生口不是憑空設計，是照既有合法用法量身做的，方向對。你自己提的 `self.randf(`風險——GDScript `randf` 是 GlobalScope 函式非 Object 方法，正常不會出現 `self.randf(`這種呼叫形態（除非該 class 自己定義同名方法，那是另一個問題，見下）。

## 2. pick_random/shuffle 不吃逃生口——斷言核實為真
Godot 4.x `Array`/`Dictionary` 的 `pick_random()`/`shuffle()` 沒有可傳入 `RandomNumberGenerator` 實例的 overload（跟 `randi_range`這種純函式不同），一律吃全域 RNG——你的斷言方向對，沒有誤殺合法 local-seeded 版本的疑慮（因為不存在該版本）。

## ★3. 向量集不完整——漏 `randfn` + 全域 `seed(...)`（必補）
5 類（randf/randi/randf_range/randi_range/randomize + pick_random/shuffle）漏了：
- **`randfn(mean,deviation)`**——Godot 4.x GlobalScope 真實存在的高斯分布隨機函式，跟 `randf`同等級耗全域流，沒理由排除。
- **裸 `seed(...)`**——全域重播種函式。★這個比單次 `randf()`更危險：observe 側只要呼叫一次 `seed(x)`，之後**所有**後續 randf/randi 呼叫全被打亂（不用自己再呼叫任何隨機函式就能污染），是「靜默改寫整條後續隨機流」而非「借用一次隨機值」——血證 4 次教訓的核心(觀測改被觀測物)，`seed`比目前抓的任何一個向量都更貼這條鐵律要害。親 grep 現況：`scripts/debug/`裡大量 `*_bed`/`*_harness`檔用 `seed(world_seed)`——但這些檔按 §2c 設計本來就不會加 marker（seeded scenario 建構，非 observe-pure），跟這條要求不衝突；純觀測 helper（如未來新增的）若誤呼 `seed(...)`才是這條要抓的對象。

**要求**：5 類擴成 7 類（加 `randfn`/`seed`），implementer 開工前訂進 spec §2a。★順帶：你 §2c 說「順手補 constitution RNG_RE 的 pick_random/shuffle」同一邏輯下，這兩個新向量也該同步補進 `constitution_gate.gd` 的 `RNG_RE`（決策檔本就零容忍任何RNG，一致性零風險），非只加進 observability_gate 這條。

## 4. marker 慣例 vs 中央清單——判斷合理，標一個殘留風險非必修
自我文件化 marker 確實比中央清單耐腐（清單會漏刪已刪檔/漏加新檔，marker 就地可見、PR review 容易問「新觀測 helper 加 marker 沒」）。★殘留風險：這把「別呼 RNG」的記性依賴換成「別忘記加 marker」的記性依賴——性質不同(忘加 marker=「暫時不受保護」非「立即污染世界」，嚴重度較低)但同屬人工環節。不要求本輪解，值得記一筆：日後若 `scripts/debug/`新增檔名含 tracer/probe/dump/specimen 等觀測慣用詞但沒有 marker，可以是 observability_gate 順手加的一個非阻斷性 warning(不 FAIL，只是提醒複查)——非必要，systems 自行斟酌。

## 5. 逐行 regex 天生盲區(comment/string 誤報，多行呼叫漏抓)——非本輪新增風險
既有 constitution_gate 本來就逐行 regex、不剝註解/字串，這個限制是整個 gate 家族既有特性非本次新引入，不列必修，跟既有基線一致對待即可。

## 判決
**CLEAN + 1 必補（向量集加 randfn/seed）→ implementer。** 其餘（逃生口/pick_random斷言/marker慣例）核到位不用改。純靜態零風險，非其他 arc blocker，符合「roadmap fork PAUSE 期正好做」的定位。
