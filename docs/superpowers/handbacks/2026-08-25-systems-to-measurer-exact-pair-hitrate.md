---
from: systems
to: measurer
status: consumed
slice: failure-memory-structural-identity
topic: ★動工前的一個數字(R² 把它從事後升格成前提):那 45 次是「同一個 tile 反覆」還是「45 個不同 tile」?
---

# 一個數字，**擋在動工前面**

## 背景
新磚：失敗記憶 key ＝ **`(option 結構 id, target id)`**，語意**先 exact-pair**
（「蓋工坊@tileX 失敗 ⇒ 折 蓋工坊@tileX」），**類級泛化不預做**。

★**risk**：**若 target 幾乎每次都不同，exact-pair 的命中率趨近 0 ⇒ 折價形同不存在**
⇒ **我們會做出第二個「恆 1.0」的機制**（第一個是 `OPTION_FAIL_KEY` 只接 2 個 option）。

★**reviewer 裁定把這個量測從「§5 事後死水欄」升格成【dispatch 前的前提】** ——
理由是本 session 一路「**先量後改**」的同型情境。**我原本把它放在事後，那是錯的位置。**

## 要的（**很小**）
1. ★**team 11 的那 45 次 `build_workshop`：target tile 是同一個，還是 45 個不同？**
   （最好給 **distinct target 數**，不只總數）
2. **一般化**：`root.lost_to` / candidate 勝出事件的 **target 重複率分佈**
   —— **同一 (動作, target) 對重複出現的次數分佈**

## 判讀規則（**先寫好**）
| 結果 | 意義 | 我的處置 |
|---|---|---|
| **target 高度重複** | exact-pair **咬得到** | ✅ 照原設計 dispatch |
| ★**target 幾乎每次不同** | ★**exact-pair ≈ 不存在** | ★**回頭找 blueprint 重定語意**（類級泛化門檻），**我不自行擴大** |

★**兩種結果都收。** 這一顆的價值就在於**它可能否決我們正要做的東西**。

## 紀律
★**母體 vs 樣本**分開報（`bump_sample` 是 first-N，若用樣本要明講）；
**分母對齊語意**（「45 次」的分母是什麼）。
