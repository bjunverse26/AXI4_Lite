# AXI4-Lite Slave Design and Verification Project

32-bit AXI4-Lite Slave? Register Map???ㅺ퀎?섍퀬, Directed Testbench 諛?SVA瑜??듯빐 湲곕뒫怨??꾨줈?좎퐳???④퍡 寃利앺븳 RTL ?꾨줈?앺듃?낅땲??

## ?ㅻ뜑

**?꾨줈?앺듃 ?쒕ぉ**  
AXI4-Lite Slave Design and Verification Project

**?쒖쨪 ?ㅻ챸**  
32-bit AXI4-Lite Slave? 16媛??덉??ㅽ꽣 留듭쓣 吏곸젒 ?ㅺ퀎?섍퀬, ?뚯뒪?몃깽移섏? Assertion 湲곕컲 寃利??섍꼍?쇰줈 ?쎄린/?곌린 ?숈옉 諛?AXI4-Lite ?꾨줈?좎퐳 以???щ?瑜??뺤씤???꾨줈?앺듃?낅땲??

## ?듭떖 ?깃낵

### 1. AXI4-Lite Slave ?쒕툕?쒖뒪??吏곸젒 ?ㅺ퀎
- Before: ?⑥닚 ?명꽣?섏씠???댄빐 ?섏?
- After: [`src/axi_lite_slave.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/src/axi_lite_slave.sv), [`src/axi_register_map.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/src/axi_register_map.sv), [`src/axi_top.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/src/axi_top.sv)濡?援ъ꽦??32-bit AXI4-Lite Slave 援ъ“瑜??ㅺ퀎

### 2. ?뺤옣 媛?ν븳 16媛??덉??ㅽ꽣 留?援ы쁽
- Before: ?뚯닔 ?덉??ㅽ꽣 以묒떖???⑥닚 援ъ“
- After: 4媛?二쇱슂 ?덉??ㅽ꽣? 12媛??곗씠???덉??ㅽ꽣瑜??ы븿??珥?16媛?二쇱냼 怨듦컙 援ъ꽦

### 3. ?ㅼ뼇???곌린 ??대컢 耳?댁뒪瑜?泥섎━?섎뒗 FSM 援ы쁽
- Before: 二쇱냼? ?곗씠?곌? ??긽 媛숈? ?쒖꽌濡??꾩갑?쒕떎怨?媛?뺥븷 媛?μ꽦 議댁옱
- After: `AW->W`, `W->AW`, `AW+W ?숈떆`??3媛吏 ?곌린 ?쒕굹由ъ삤瑜?泥섎━?섎룄濡?Write FSM ?ㅺ퀎

### 4. ?ㅺ퀎 寃곌낵瑜??뺣웾?곸쑝濡?寃利?- Before: ?⑥닚 ?쎄린/?곌린 寃곌낵 ?뺤씤 以묒떖
- After: [`sim/tb_axi.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/sim/tb_axi.sv)??4媛?二쇱슂 ?쒕굹由ъ삤, 5媛??곗씠??寃利?耳?댁뒪? [`sim/axi_sva.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/sim/axi_sva.sv)??11媛?Assertion, 6媛?Coverage Point濡?寃利?踰붿쐞瑜??섏튂??
## 湲곕뒫

- 32-bit AXI4-Lite Slave ?명꽣?섏씠???ㅺ퀎
- AW, W, B, AR, R 梨꾨꼸 遺꾨━ 湲곕컲 ?몃옖??뀡 泥섎━
- Read FSM / Write FSM 湲곕컲 ?쒖뼱 濡쒖쭅 援ы쁽
- `WSTRB`瑜??댁슜??Byte-enable Write 吏??- Control, Status, Config, Error, Data Register瑜??ы븿??16媛??덉??ㅽ꽣 留?援ъ꽦
- 二쇱냼/?곗씠?곗쓽 ?쒖감, ??닚, ?숈떆 ?꾩갑??泥섎━?섎뒗 ?곌린 寃쎈줈 吏??- Directed Testbench 湲곕컲 湲곕뒫 寃利?- SVA 湲곕컲 ?꾨줈?좎퐳 Assertion 諛?Coverage ?섏쭛

## 湲곗닠 ?ㅽ깮

- **?몄뼱**: SystemVerilog
- **?ㅺ퀎 諛⑹떇**: RTL Design, Parameterized Module, `always_ff`, `always_comb`
- **?꾨줈?좎퐳**: AXI4-Lite
- **寃利?諛⑹떇**: Directed Testbench, SystemVerilog Assertions (SVA)
- **?쒖빟 ?뚯씪**: [`constraints/Zybo-Z7-Master.xdc`](/c:/Users/rlaqj/Project/AXI4_Lite/constraints/Zybo-Z7-Master.xdc)

## ?꾨줈?앺듃 援ъ“

```text
AXI4_Lite/
+-- constraints/
|   +-- Zybo-Z7-Master.xdc
+-- docs/
|   +-- 0. AXI4-Lite Portfolio.pdf
+-- sim/
|   +-- axi_sva.sv
|   +-- tb_axi.sv
+-- src/
|   +-- axi_lite_slave.sv
|   +-- axi_register_map.sv
|   +-- axi_top.sv
+-- LICENSE
+-- README.md
```

## 寃곌낵

- AXI4-Lite Slave, Register Map, Top Module濡?援ъ꽦???ㅺ퀎 ?먯궛怨?Testbench, SVA Monitor濡?援ъ꽦??寃利??먯궛??紐⑤몢 援ъ텞
- 32-bit ?곗씠????낵 16媛??덉??ㅽ꽣 怨듦컙??媛뽯뒗 Register-mapped 援ъ“ 援ы쁽
- 11媛?Assertion?쇰줈 VALID ?좎?, ?곗씠???덉젙?? Reset ?숈옉, Write ?쒖꽌 ?쒖빟 寃利?- 6媛?Coverage Point濡?二쇱슂 handshake 諛?back-to-back write ?쒕굹由ъ삤 愿李?媛??- ?ㅺ퀎? 寃利앹쓣 ?④퍡 ?ㅻ챸?????덈뒗 ?ы듃?대━??臾몄꽌 ?뺥깭濡??뺣━

## ?뚯씪 ?ㅻ챸

- [`src/axi_top.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/src/axi_top.sv): AXI Slave? Register Map???곌껐?섎뒗 Top Module
- [`src/axi_lite_slave.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/src/axi_lite_slave.sv): AXI4-Lite ?쎄린/?곌린 ?쒖뼱 濡쒖쭅
- [`src/axi_register_map.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/src/axi_register_map.sv): ?덉??ㅽ꽣 留?諛??곗씠?????援ъ“
- [`sim/tb_axi.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/sim/tb_axi.sv): Directed 湲곕뒫 寃利앹슜 ?뚯뒪?몃깽移?- [`sim/axi_sva.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/sim/axi_sva.sv): AXI4-Lite ?꾨줈?좎퐳 Assertion 諛?Coverage