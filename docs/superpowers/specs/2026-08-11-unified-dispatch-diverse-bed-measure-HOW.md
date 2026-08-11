# 統一派遣模型 大多樣床 measure-HOW（攻 UNTESTABLE 兩題 + O(N²) + 下游 unblock）

**status**: measure-spec（用戶要大測試+多樣化、blueprint 轉）。量測員建 config+跑、branch feat/unified-dispatch(285bca8f) vs main 對照。
**溯源**：上輪 4-隊 fixture 得核心修坐實（anon 穩/機械升格 0/幽靈團降）但 3 題 UNTESTABLE/inconclusive（組成分化 1-named 測不出、named-scarcity 光譜、下游 unblock 無 distress 觸發）。
**命門**：4×over-claim 血淚——**禁預設 payoff、硬數字、RNG-confound 誠實標（需多 seed 加做）、UNTESTABLE 照實報非硬套**。

## 床設計（diversity = 關鍵）
- **①更多團**：~16 隊（O(N²) 趨勢+dispatch 活動量可見、非太重）。
- **②pop 多樣**：混 pop 4 / 8 / 12 / 20。
- **③★記名數多樣（關鍵）**：混 **1-named 嚴格隊**（無 bench）+ 2-named + **3~4-named 充裕隊**（有競爭候選）→ 組成看重要性 pick 測得出 + named-scarcity 光譜。
- **④distress 觸發**：部分隊低食 runway（→distress→relief/care/rescue 情境真 fire、上輪無此測不到下游）。
- 幾個 faction（lord+members、含 distress-prone members 讓 care/relief 有對象）。seed determinism、branch vs main 對照。

## 量測（5 題 + 新 3）
1. **anon 穩無 drain**（跨多樣隊、各隊 anon 池逐日穩否）。
2. **機械升格 0**（raw log『從匿名晉升新領袖』branch=0 跨多隊 confirm）。
3. ★**組成看重要性**（多-named 隊派任務有無挑對：要害偵察→高信任/高統領記名？routine→次要記名？規模→記名帶團？util 秤人格 modulate、非固定模板）。
4. ★**named-scarcity 光譜**（多-named 隊能派多 / 1-named 隊嚴少派 → 光譜合不合理 = 餵用戶判 A/B）。
5. ★**O(N²)/幽靈團 at scale**（更多團更多 dispatch 下：機械升格源真 0 否、團數成長曲線 branch vs main、per-tick 成本趨勢）。
6. ★**下游 unblock**（有 distress→relief/care/builder 真 fire 否、這輪測得到；★硬數字非預設、RNG-confound 標、care/relief fire 數 branch vs main）。

## output（→ blueprint + 用戶）
真光譜數據（組成 pick 對否 + named-scarcity 光譜合理否 + O(N² 降否 + 下游 fire 否）→ 餵 blueprint + **用戶判 named-scarcity A/B**（A=約束合理弱勢 / B=太嚴需調）。
- ★長跑附 specimen 送 QA 故事稽核。★RNG-confound 若擋因果=多 seed 加做（誠實標）。UNTESTABLE 照實報。
- 序：量 → verdict → systems consolidate → blueprint 推用戶（帶真光譜）。地基 KEEP。
