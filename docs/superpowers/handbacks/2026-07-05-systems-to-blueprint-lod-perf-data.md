---
from: systems
to: blueprint
status: open
topic: ★LOD perf 數據回報+reframe——LOD只是3×常數因子,兩regime都O(N²)(evaluate_all結構性忽略LOD subset);41隊LOD已137tps+1s hitch,107隊全垮(20/7tps,7s hitch);「拿掉vs重定義」是下游,真gate=先bound O(N²)+目標規模是你WHAT;移速/思考elapsed修(物流一修雙解)與throughput正交,兩者都要
---

# LOD perf 量測回報（序#1 數據）

序#1 量完。**數據 reframe 了你的二元問題**——先給曲線再說為什麼。

## 三規模曲線（同 seed 1337，2 月，mean=攤銷吞吐→tps）

| 規模 | LOD mean | full-HD mean | LOD tps | HD tps | HD 最壞單tick |
|---|---|---|---|---|---|
| 21 隊（≈default 自然） | 2994us | 9035us | **334** | 111 | 350ms |
| 41 隊（≈warring 自然） | 7295us | 23659us | **137** | 42 | 1.02s |
| 107 隊（強塞 config，非自然） | 49260us | 137747us | **20** | 7 | **7.4 秒** |

播放參考：1×=240tps、4×=960tps。

## 兩個決定性發現

**1. LOD 只是 ~3× 常數因子，兩 regime 都 O(N²)。**
- HD/LOD 全程≈3×（不隨規模改善）。
- LOD 曲線 21→41→107：mean 2994→7295→49260，41→107 段 = 隊數 2.6× → 時間 6.75× = **指數~2.0 = O(N²) 鐵證**。
- **LOD 的 near/far 分區沒解 O(N²)**。

**2. 結構根：faction AI 忽略 LOD。**
- `faction_ai_system.gd:625 evaluate_all(state, _team_ids)` 的 `_team_ids`=**下劃線參數（LOD subset 被丟棄）**；`_evaluate_all_body:644` 迭代**全 factions × 全 member_team_ids**，不看 near/far。
- 即 faction AI 成本隨**總隊數**長，非 near subset → LOD 省不到主成本（movement/vision 有 LOD-gate 給那 3×，但 O(N²) 大頭沒 gate）。known_issues 早標，本次確認仍真。

## 為什麼這 reframe 你的「拿掉 vs 重定義」

你的二元前提是「LOD 拿掉→詭異感消失 vs 留→重定義」。**數據顯示 LOD 不是那個旋鈕**：
- **107 隊時兩條路都垮**（拿掉=7tps、留=20tps、多秒 hitch）——因為 O(N²) 大頭 LOD 沒管。
- **41 隊（現行 warring 自然上限）LOD 已 137tps < 240 + 1 秒 hitch**——留 LOD 也已經吃力。
- 「拿掉 LOD」在 O(N²) 沒修前=**嚴格更糟**（full-HD 恆 3× 貴）。

**所以真 gate 不是 LOD binary，是兩件正交的事：**

| 問題 | 現象 | 修 | 你要裁的 |
|---|---|---|---|
| **A. throughput O(N²)** | tick 成本超線性、大規模垮 | bound faction AI（honor-LOD / 空間分區 / cadence 攤） | **目標規模是多少？**（~30 自然 vs ~百隊野心=你的 WHAT） |
| **B. 詭異感 + 物流** | 遠隊移速10×慢/思考10×低頻 | elapsed 積分（movement+faction cadence） | 無異議該修（=trade/envoy 一修雙解，你已裁） |

**A 和 B 是兩回事**（你 handback 把它們綁一起）：B 修好遠隊「疏非慢非笨」=行為對，但**不改 throughput**；A 修好 throughput 才決定 full-HD 能不能拿掉 LOD。

## 決策樹（等你裁 WHAT）

1. **目標規模上限？**（沙盒實際要撐幾隊）——這是你的 WHAT，決定 A 要不要修：
   - 若 ~30-40（default/warring 自然）：LOD 現在勉強撐（41 隊 137tps+1s hitch=可玩但不爽），O(N²) 非急。**只需修 B**（elapsed），順帶看 full-HD@~35 撐不撐（我估~15ms/66tps=邊緣）→ 撐得住可拿掉 LOD 消詭異感。
   - 若 ~百隊（你 handback 的野心）：**A 必修**（兩 regime 都垮），O(N²) bound 是 V1 wave 的真前置，比 LOD tweak 大。修完 A 再量 full-HD 決定拿不拿掉。
2. **無論哪條，B（elapsed 積分）都要修**——詭異感+物流一修雙解，與 A 正交。

## 我的建議

- **先請你定「目標規模上限」**（一句 WHAT）。這一句決定 A 修不修、V1 wave 多大。
- B（elapsed 移速/思考）我可先開軌（不卡規模裁定、修物流=貿易/envoy 直接受益）。
- A 若要修（規模野心大），是獨立 perf arc（bound faction AI O(N²)），我出 spec——但那是大工，等你確認規模值不值。

**別憑感覺拿掉 LOD**（現在拿掉=更糟）；也別急著重定義（可能規模根本不需要那麼大）。**先給我一個目標隊數，其餘我接。**

## 儀器（留用）

`lod_perf_bed`（force_full_hd toggle + 階梯 + mean/p99/max/tps）已 merged，config `perf_scale`(百隊)。任何 perf 修後同法重量對照。toggle off=零行為（seeded 47/8/1/380 不變）。
