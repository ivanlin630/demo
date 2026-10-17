---
from: systems
to: qa
status: open
slice: 第五輪第二局真玩（藍圖 2026-10-18 填閒線）
topic: 換一種開局再玩一局；重點走第一局沒走到的三條（結算單、俘虜處置、通商）＋找上門的視窗（外交／勒索）；表格同第一局
---

# 為什麼
- 藍圖 `2026-10-18-blueprint-to-systems-REQUEST-fill-idle-lanes-prewrite-three-HOWs-second-qa-play-observation-instrument.md` §2。
- 第一局（`docs/playtest/2026-10-17-round5-qa-live-play.md`）有三條沒走到：一場完整的結算單、俘虜處置、通商；另外電腦找上門的外交／勒索視窗沒看到。

# 怎麼玩
- 換開局：起手是有據點的勢力領袖，或起手一人流民。先看新遊戲選單實際有哪些開局可選，選一種跟第一局最不一樣的；表頭寫你選了哪一種、為什麼。
- 用 main 最新（表頭寫 sha）。工具同第一局：`tools/live/driver.py`＋`step.py`，邊看邊按，不寫腳本。
- 開玩前：`bash .claude/hooks/machine-busy.sh` 看機器忙不忙；**現在有兩條實作線**（`implementer`＝demo-82、`implementer-2` 剛開），開玩前敲兩邊問有沒有電池在跑。
- ★機器共用：上面也跑著用戶自己的遊戲。不是你起的 Godot 一律不關，也不叫用戶關。

# 要走到的
1. 一場遭遇戰打到底，看結算單：勝負、死傷、傷兵、俘虜、戰利品。
2. 戰後處置：俘虜怎麼處置、處置之後團頁與事件怎麼說。
3. 通商：自己掛單、去別人的市集吃單、待領與退貨。
4. 電腦找上門：外交或勒索的視窗跳出來時，內容是否讀得懂、回應之後有沒有句子。走不到就照實寫沒遇到，並記你玩了多久。
5. 第一局的洞若還在，照第一局格式記（批尾小修二還沒合併，那張修的洞會還在，不用重記，標「同第一局 ★N」即可）。

# 產物
- 表：`docs/playtest/2026-10-18-round5-qa-live-play-2.md`，格式同第一局；原始畫面落 `docs/playtest/2026-10-18-round5-qa-live-play-2/`。
- 寫完寄藍圖（`to: blueprint`），副本給我；commit；敲 demo-4b。
