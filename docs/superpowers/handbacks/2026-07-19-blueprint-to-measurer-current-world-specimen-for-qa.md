---
from: blueprint
to: measurer
status: consumed
topic: "[用戶要 QA 對當前世界正式故事判] 請對當前 main(bb1e75ff,①②餓死+slice2 god-view merged)產 seeded 全量 specimen → 交 QA 故事審 → 判回 blueprint。單 seed 足夠故事稽核。想看:逃跑主導/人口重摔是 coherent 悲劇還是 broken。"
---

# 當前世界 specimen → QA 故事審（用戶要）

## 觸發
用戶要看「**QA 對當前世界正式怎說**」。我跑的 multi-sim(無 seed drift)非 QA 素材 → 走正規 pipeline。

## 請 measurer 做
- **對當前 main（`bb1e75ff`：① survival priority + ② 絕境階梯 + slice2 god-view A1/A2/A3 全 merged）產 seeded 全量 specimen**（motive→action→outcome trace，你標準 full_probe 床 / observe specimen 格式）。
- **seed 1337 足夠**（roles 定：單 seed trace 就足以故事稽核，不必等 multi-seed；要嘛加 seed42 交叉但非必須）。
- **窗口**：夠長看出「逃跑主導 / 人口重摔」是不是 coherent(3-6 月級,你判合適長度)。

## 我要 QA 看什麼（故事判的靶）
我剛 headless multi-sim 見:**逃跑 54% 主導 + warzone 人口 135→40(-70%) + 數隊 food=0 餓**。問 QA 故事判:
- 這些**逃跑/餓死有沒有真原因**(真被威脅/真沒糧/絕境階梯真跑過)= **coherent 悲劇**?
- 還是 **broken**(對空氣逃跑 / 有糧還死 / mis-fire / 傻站餓死)?
- = motive→action→outcome 鏈完不完整。

## 鏈
measurer 產 specimen → **交 QA 故事審**(`to:qa`,04_qa §第五職)→ QA 判回 `to:blueprint`。

## 注意
- **可溯源**:specimen 落檔 + 標 commit hash(bb1e75ff)。
- QA 故事判 ≠ balance 判(死多少是我/economy 的,QA 判故事對不對,承 QA 這 session 兩次線)。

## 溯源
用戶「跑」;我 headless multi-sim 見逃跑主導/pop 重摔;roles 量測→QA 故事稽核→blueprint 鏈;QA slice2/②ladder 兩次 proper-窮死 PASS 先例。
