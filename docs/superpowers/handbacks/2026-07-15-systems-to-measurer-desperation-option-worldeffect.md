---
from: systems
to: measurer
status: consumed
topic: "[量測·measure-first] 獵窮死+乞食/掠奪/併入世界效果逐筆追蹤——哪些絕境選項是幻覺(選中無世界效果)?補全A覆蓋前先驗"
---

# 量測：絕境選項世界效果（measure-first，別假設全是幻覺）

QA 複判：買糧 A/B **真綠**（Team18 tick8970 food 0.23→9.39 真到帳；Team20 訂單成交收掉）。但抓到**併入疑似同款幻覺**（Team18 併入當選但 `faction_id` 全程 -1 從沒真併，一樣本判不出）。blueprint 原 A=**全求生選項** look-before-leap，我只 spec 買糧＝不完整。∴ **先 measure 哪些選項真是幻覺**（選中但無世界效果），再補 look-before-leap（避免假設全是→無謂改）。

branch `feat/desperation-food-seeking` @ `2b9428c8`（含 A/B）。tap 已 cherry-pick main（snapshot 有 coin/food/faction_id/pop，足追世界效果）。

## 跑法
1. **★換更狠 config（真四方無糧世界）**：現有 config 挑最狠（`survival_start.json`? 或你判哪個逼隊進乞食/掠奪/併入）——目標=逼出大量窮死隊真的走乞食/掠奪/併入，才有樣本。seed1337 force_full_hd reproducible。
2. 鎖多個窮死 specimen（子隊型，bed 死亡偵測已修可靠找真團滅隊）出 `.specimen.jsonl`。

## 要追（三選項逐筆世界效果，QA 同套 winner-vs-狀態-delta 法）
| 選項 | winner 選中後，世界真動了嗎? |
|---|---|
| **乞食** | 對方真轉 coin/food 過來?（snapshot coin/food 選乞食後升＝真;沒動＝幻覺） |
| **掠奪** | material/coin 真增、敵 pop 真減?（snapshot 資源 delta） |
| **併入** | `faction_id` 真從 -1 變實際 faction ID?（Team18 唯一樣本=陰性，多樣本坐實） |

**判準**：選中該選項 winner ≥N 次中，有幾次真有對應世界效果 vs 幾次選中狀態沒動＝幻覺率。**別一樣本定論**（Team18 併入可能是「考慮→被拒/對象消失→合理放棄」正常，也可能空轉——多樣本+看 target 存續才分得出）。

## 回報
- 每選項幻覺率 + 判定「真幻覺(選中恆無世界效果)」vs「正常(有時成、撲空 emergent)」。
- handback `to:blueprint`（+ 給我：哪些選項需補 look-before-leap）。全量一封信。

## 下游（依你結果）
- 任一選項確診幻覺 → systems 補 look-before-leap（同買糧 A：applicable 驗真做得到）→ 補全 A → 重跑 → QA 複判 → blueprint 批 merge。
- 全非幻覺（買糧本就是唯一破的）→ 回報，A 其實已足，直接重跑複判 → merge。

## 溯源
raw + measured_at_head `2b9428c8`。
