 
****************************************
Report : resources
Design : DRAM_Controller
Version: U-2022.12
Date   : Tue May  6 18:37:02 2025
****************************************


Resource Report for Ungrouped Hierarchy rw_cmd_out_fifo/U1/U1/U1 in file
        ./DWsc_fifoctl_s1_df__rtl.v.e
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| add_x_1        | DW01_inc       | width=3    | add_208                    |
| add_x_3        | DW01_inc       | width=3    | add_213                    |
| sub_x_4        | DW01_dec       | width=2    | sub_226                    |
| add_x_5        | DW01_inc       | width=2    | add_228                    |
| lte_x_11       | DW_cmp         | width=2    | lte_246                    |
| gte_x_12       | DW_cmp         | width=2    | gte_254                    |
=============================================================================


Resource Report for Ungrouped Hierarchy rw_cmd_out_fifo/U1/U1
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| U1             | DWsc_fifoctl_s1_df | depth=4 | U1                        |
|                |                | err_mode=2 |                            |
|                |                | addr_width=2 |                          |
|                |                | gang_all_status=1 |                     |
=============================================================================


Resource Report for Ungrouped Hierarchy rw_cmd_out_fifo/U1
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| U1             | DW_fifoctl_s1_sf | depth=4  | U1                         |
|                |                | ae_level=1 |                            |
|                |                | af_level=1 |                            |
|                |                | err_mode=2 |                            |
|                |                | rst_mode=0 |                            |
=============================================================================


Resource Report for Ungrouped Hierarchy isu_fifo/U1/U1/U1 in file
        ./DWsc_fifoctl_s1_df__rtl.v.e
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| add_x_1        | DW01_inc       | width=3    | add_208                    |
| add_x_3        | DW01_inc       | width=3    | add_213                    |
| sub_x_4        | DW01_dec       | width=2    | sub_226                    |
| add_x_5        | DW01_inc       | width=2    | add_228                    |
| lte_x_11       | DW_cmp         | width=2    | lte_246                    |
| gte_x_12       | DW_cmp         | width=2    | gte_254                    |
=============================================================================


Resource Report for Ungrouped Hierarchy isu_fifo/U1/U1
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| U1             | DWsc_fifoctl_s1_df | depth=4 | U1                        |
|                |                | err_mode=2 |                            |
|                |                | addr_width=2 |                          |
|                |                | gang_all_status=1 |                     |
=============================================================================


Resource Report for Ungrouped Hierarchy isu_fifo/U1
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| U1             | DW_fifoctl_s1_sf | depth=4  | U1                         |
|                |                | ae_level=1 |                            |
|                |                | af_level=1 |                            |
|                |                | err_mode=2 |                            |
|                |                | rst_mode=0 |                            |
| U2             | DW_ram_r_w_s_dff | data_width=24 | U2                    |
|                |                | depth=4    |                            |
|                |                | rst_mode=0 |                            |
=============================================================================


Resource Report for Ungrouped Hierarchy U1/U1/U1 in file
        ./DWsc_fifoctl_s1_df__rtl.v.e
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| add_x_1        | DW01_inc       | width=3    | add_208                    |
| add_x_3        | DW01_inc       | width=3    | add_213                    |
| sub_x_4        | DW01_dec       | width=2    | sub_226                    |
| add_x_5        | DW01_inc       | width=2    | add_228                    |
| lte_x_11       | DW_cmp         | width=2    | lte_246                    |
| gte_x_12       | DW_cmp         | width=2    | gte_254                    |
=============================================================================


Resource Report for Ungrouped Hierarchy U1/U1
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| U1             | DWsc_fifoctl_s1_df | depth=4 | U1                        |
|                |                | err_mode=2 |                            |
|                |                | addr_width=2 |                          |
|                |                | gang_all_status=1 |                     |
=============================================================================


Resource Report for Ungrouped Hierarchy U1
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| U1             | DW_fifoctl_s1_sf | depth=4  | U1                         |
|                |                | ae_level=1 |                            |
|                |                | af_level=1 |                            |
|                |                | err_mode=2 |                            |
|                |                | rst_mode=0 |                            |
| U2             | DW_ram_r_w_s_dff | data_width=1024 | U2                  |
|                |                | depth=4    |                            |
|                |                | rst_mode=0 |                            |
=============================================================================


Resource Report for Ungrouped Hierarchy BackendController_0/Rank0/wdata_fifo
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| U1             | DW_fifo_s1_sf  | width=1024 | U1 (Ctrl.sv:1653)          |
|                |                | depth=4    |                            |
|                |                | ae_level=1 |                            |
|                |                | af_level=1 |                            |
|                |                | err_mode=2 |                            |
|                |                | rst_mode=0 |                            |
=============================================================================


Resource Report for Ungrouped Hierarchy BackendController_0/Rank0 in file
        ../01_RTL/bank_FSM.sv
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| eq_x_8         | DW_cmp         | width=16   | eq_169 (bank_FSM.sv:169)   |
| sub_x_14       | DW01_dec       | width=7    | ba0/sub_266 (bank_FSM.sv:266) |
| add_x_16       | DW01_inc       | width=12   | ba0/add_288 (bank_FSM.sv:288) |
| lte_x_56       | DW_cmp         | width=3    | lte_930 (Ctrl.sv:930)      |
| gte_x_104      | DW_cmp         | width=3    | gte_1342 (Ctrl.sv:1342)    |
| gte_x_105      | DW_cmp         | width=3    | gte_1342_2 (Ctrl.sv:1342)  |
| gte_x_106      | DW_cmp         | width=3    | gte_1342_3 (Ctrl.sv:1342)  |
| gte_x_107      | DW_cmp         | width=3    | gte_1342_4 (Ctrl.sv:1342)  |
| gte_x_108      | DW_cmp         | width=3    | gte_1342_5 (Ctrl.sv:1342)  |
| gte_x_121      | DW_cmp         | width=10   | gte_1506 (Ctrl.sv:1506)    |
| gt_x_123       | DW_cmp         | width=3    | gt_1517 (Ctrl.sv:1517)     |
| gt_x_124       | DW_cmp         | width=3    | gt_1517_2 (Ctrl.sv:1517)   |
| gt_x_125       | DW_cmp         | width=3    | gt_1517_3 (Ctrl.sv:1517)   |
| gt_x_126       | DW_cmp         | width=3    | gt_1517_4 (Ctrl.sv:1517)   |
| gt_x_127       | DW_cmp         | width=3    | gt_1522 (Ctrl.sv:1522)     |
| gt_x_128       | DW_cmp         | width=3    | gt_1522_2 (Ctrl.sv:1522)   |
| gt_x_129       | DW_cmp         | width=3    | gt_1522_3 (Ctrl.sv:1522)   |
| gt_x_130       | DW_cmp         | width=3    | gt_1522_4 (Ctrl.sv:1522)   |
| gt_x_131       | DW_cmp         | width=3    | gt_1527 (Ctrl.sv:1527)     |
| gt_x_132       | DW_cmp         | width=3    | gt_1527_2 (Ctrl.sv:1527)   |
| gt_x_133       | DW_cmp         | width=3    | gt_1527_3 (Ctrl.sv:1527)   |
| gt_x_134       | DW_cmp         | width=3    | gt_1527_4 (Ctrl.sv:1527)   |
| gt_x_135       | DW_cmp         | width=3    | gt_1532 (Ctrl.sv:1532)     |
| gt_x_136       | DW_cmp         | width=3    | gt_1532_2 (Ctrl.sv:1532)   |
| gt_x_137       | DW_cmp         | width=3    | gt_1532_3 (Ctrl.sv:1532)   |
| gt_x_138       | DW_cmp         | width=3    | gt_1532_4 (Ctrl.sv:1532)   |
| gt_x_139       | DW_cmp         | width=3    | gt_1537 (Ctrl.sv:1537)     |
| gt_x_140       | DW_cmp         | width=3    | gt_1537_2 (Ctrl.sv:1537)   |
| gt_x_141       | DW_cmp         | width=3    | gt_1537_3 (Ctrl.sv:1537)   |
| gt_x_142       | DW_cmp         | width=3    | gt_1537_4 (Ctrl.sv:1537)   |
| add_x_156      | DW01_inc       | width=3    | add_1605 (Ctrl.sv:1605)    |
| add_x_157      | DW01_inc       | width=3    | add_1606 (Ctrl.sv:1606)    |
| add_x_158      | DW01_inc       | width=3    | add_1607 (Ctrl.sv:1607)    |
| add_x_159      | DW01_inc       | width=3    | add_1608 (Ctrl.sv:1608)    |
| add_x_160      | DW01_inc       | width=3    | add_1609 (Ctrl.sv:1609)    |
| add_x_166      | DW01_inc       | width=3    | add_1616 (Ctrl.sv:1616)    |
| isu_fifo/U1    | DW_fifo_s1_sf  | width=24   | isu_fifo/U1 (Ctrl.sv:1653) |
|                |                | depth=4    |                            |
|                |                | ae_level=1 |                            |
|                |                | af_level=1 |                            |
|                |                | err_mode=2 |                            |
|                |                | rst_mode=0 |                            |
| rw_cmd_out_fifo/U1              |            |                            |
|                | DW_fifo_s1_sf  | width=2    | rw_cmd_out_fifo/U1 (Ctrl.sv:1653) |
          |                | depth=4    |                            |
|                |                | ae_level=1 |                            |
|                |                | af_level=1 |                            |
|                |                | err_mode=2 |                            |
|                |                | rst_mode=0 |                            |
| gte_x_191      | DW_cmp         | width=3    | gte_1209 (Ctrl.sv:1209)    |
|                |                |            | gte_1267 (Ctrl.sv:1267)    |
| eq_x_192       | DW_cmp         | width=3    | eq_1348 (Ctrl.sv:1348)     |
|                |                |            | eq_1373 (Ctrl.sv:1373)     |
|                |                |            | eq_1616 (Ctrl.sv:1616)     |
| eq_x_193       | DW_cmp         | width=3    | tP_ba0/eq_102 (tP_counter.sv:102) |
          |                |            | tP_ba0/eq_107 (tP_counter.sv:107) |
          |                |            | tP_ba0/eq_108 (tP_counter.sv:108) |
          |                |            | tP_ba0/eq_109 (tP_counter.sv:109) |
          |                |            | tP_ba0/eq_67 (tP_counter.sv:67) |
            |                |            | tP_ba0/eq_69 (tP_counter.sv:69) |
            |                |            | tP_ba0/eq_77 (tP_counter.sv:77) |
            |                |            | tP_ba0/eq_88 (tP_counter.sv:88) |
| sub_x_178      | DW01_dec       | width=5    | tP_ba0/sub_67 (tP_counter.sv:67) |
           |                |            | tP_ba0/sub_75 (tP_counter.sv:75) |
           |                |            | tP_ba0/sub_86 (tP_counter.sv:86) |
           |                |            | tP_ba0/sub_88 (tP_counter.sv:88) |
           |                |            | tP_ba0/sub_89 (tP_counter.sv:89) |
| sub_x_101      | DW01_dec       | width=10   | sub_1315 (Ctrl.sv:1315)    |
|                |                |            | sub_1316 (Ctrl.sv:1316)    |
|                |                |            | sub_1318 (Ctrl.sv:1318)    |
|                |                |            | sub_1320 (Ctrl.sv:1320)    |
| sub_x_26       | DW01_dec       | width=5    | sub_565 (Ctrl.sv:565)      |
|                |                |            | sub_566 (Ctrl.sv:566)      |
|                |                |            | sub_567 (Ctrl.sv:567)      |
| sub_x_23       | DW01_dec       | width=3    | sub_547 (Ctrl.sv:547)      |
|                |                |            | sub_548 (Ctrl.sv:548)      |
| sub_x_20       | DW01_dec       | width=2    | sub_535 (Ctrl.sv:535)      |
|                |                |            | sub_536 (Ctrl.sv:536)      |
=============================================================================


Resource Report for Ungrouped Hierarchy BackendController_3/Rank0/wdata_fifo
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| U1             | DW_fifo_s1_sf  | width=1024 | U1 (Ctrl.sv:1653)          |
|                |                | depth=4    |                            |
|                |                | ae_level=1 |                            |
|                |                | af_level=1 |                            |
|                |                | err_mode=2 |                            |
|                |                | rst_mode=0 |                            |
=============================================================================


Resource Report for Ungrouped Hierarchy BackendController_3/Rank0 in file
        ../01_RTL/bank_FSM.sv
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| eq_x_8         | DW_cmp         | width=16   | eq_169 (bank_FSM.sv:169)   |
| sub_x_14       | DW01_dec       | width=7    | ba0/sub_266 (bank_FSM.sv:266) |
| add_x_16       | DW01_inc       | width=12   | ba0/add_288 (bank_FSM.sv:288) |
| lte_x_56       | DW_cmp         | width=3    | lte_930 (Ctrl.sv:930)      |
| gte_x_104      | DW_cmp         | width=3    | gte_1342 (Ctrl.sv:1342)    |
| gte_x_105      | DW_cmp         | width=3    | gte_1342_2 (Ctrl.sv:1342)  |
| gte_x_106      | DW_cmp         | width=3    | gte_1342_3 (Ctrl.sv:1342)  |
| gte_x_107      | DW_cmp         | width=3    | gte_1342_4 (Ctrl.sv:1342)  |
| gte_x_108      | DW_cmp         | width=3    | gte_1342_5 (Ctrl.sv:1342)  |
| gte_x_121      | DW_cmp         | width=10   | gte_1506 (Ctrl.sv:1506)    |
| gt_x_123       | DW_cmp         | width=3    | gt_1517 (Ctrl.sv:1517)     |
| gt_x_124       | DW_cmp         | width=3    | gt_1517_2 (Ctrl.sv:1517)   |
| gt_x_125       | DW_cmp         | width=3    | gt_1517_3 (Ctrl.sv:1517)   |
| gt_x_126       | DW_cmp         | width=3    | gt_1517_4 (Ctrl.sv:1517)   |
| gt_x_127       | DW_cmp         | width=3    | gt_1522 (Ctrl.sv:1522)     |
| gt_x_128       | DW_cmp         | width=3    | gt_1522_2 (Ctrl.sv:1522)   |
| gt_x_129       | DW_cmp         | width=3    | gt_1522_3 (Ctrl.sv:1522)   |
| gt_x_130       | DW_cmp         | width=3    | gt_1522_4 (Ctrl.sv:1522)   |
| gt_x_131       | DW_cmp         | width=3    | gt_1527 (Ctrl.sv:1527)     |
| gt_x_132       | DW_cmp         | width=3    | gt_1527_2 (Ctrl.sv:1527)   |
| gt_x_133       | DW_cmp         | width=3    | gt_1527_3 (Ctrl.sv:1527)   |
| gt_x_134       | DW_cmp         | width=3    | gt_1527_4 (Ctrl.sv:1527)   |
| gt_x_135       | DW_cmp         | width=3    | gt_1532 (Ctrl.sv:1532)     |
| gt_x_136       | DW_cmp         | width=3    | gt_1532_2 (Ctrl.sv:1532)   |
| gt_x_137       | DW_cmp         | width=3    | gt_1532_3 (Ctrl.sv:1532)   |
| gt_x_138       | DW_cmp         | width=3    | gt_1532_4 (Ctrl.sv:1532)   |
| gt_x_139       | DW_cmp         | width=3    | gt_1537 (Ctrl.sv:1537)     |
| gt_x_140       | DW_cmp         | width=3    | gt_1537_2 (Ctrl.sv:1537)   |
| gt_x_141       | DW_cmp         | width=3    | gt_1537_3 (Ctrl.sv:1537)   |
| gt_x_142       | DW_cmp         | width=3    | gt_1537_4 (Ctrl.sv:1537)   |
| add_x_156      | DW01_inc       | width=3    | add_1605 (Ctrl.sv:1605)    |
| add_x_157      | DW01_inc       | width=3    | add_1606 (Ctrl.sv:1606)    |
| add_x_158      | DW01_inc       | width=3    | add_1607 (Ctrl.sv:1607)    |
| add_x_159      | DW01_inc       | width=3    | add_1608 (Ctrl.sv:1608)    |
| add_x_160      | DW01_inc       | width=3    | add_1609 (Ctrl.sv:1609)    |
| add_x_166      | DW01_inc       | width=3    | add_1616 (Ctrl.sv:1616)    |
| isu_fifo/U1    | DW_fifo_s1_sf  | width=24   | isu_fifo/U1 (Ctrl.sv:1653) |
|                |                | depth=4    |                            |
|                |                | ae_level=1 |                            |
|                |                | af_level=1 |                            |
|                |                | err_mode=2 |                            |
|                |                | rst_mode=0 |                            |
| rw_cmd_out_fifo/U1              |            |                            |
|                | DW_fifo_s1_sf  | width=2    | rw_cmd_out_fifo/U1 (Ctrl.sv:1653) |
          |                | depth=4    |                            |
|                |                | ae_level=1 |                            |
|                |                | af_level=1 |                            |
|                |                | err_mode=2 |                            |
|                |                | rst_mode=0 |                            |
| gte_x_191      | DW_cmp         | width=3    | gte_1209 (Ctrl.sv:1209)    |
|                |                |            | gte_1267 (Ctrl.sv:1267)    |
| eq_x_192       | DW_cmp         | width=3    | eq_1348 (Ctrl.sv:1348)     |
|                |                |            | eq_1373 (Ctrl.sv:1373)     |
|                |                |            | eq_1616 (Ctrl.sv:1616)     |
| eq_x_193       | DW_cmp         | width=3    | tP_ba0/eq_102 (tP_counter.sv:102) |
          |                |            | tP_ba0/eq_107 (tP_counter.sv:107) |
          |                |            | tP_ba0/eq_108 (tP_counter.sv:108) |
          |                |            | tP_ba0/eq_109 (tP_counter.sv:109) |
          |                |            | tP_ba0/eq_67 (tP_counter.sv:67) |
            |                |            | tP_ba0/eq_69 (tP_counter.sv:69) |
            |                |            | tP_ba0/eq_77 (tP_counter.sv:77) |
            |                |            | tP_ba0/eq_88 (tP_counter.sv:88) |
| sub_x_178      | DW01_dec       | width=5    | tP_ba0/sub_67 (tP_counter.sv:67) |
           |                |            | tP_ba0/sub_75 (tP_counter.sv:75) |
           |                |            | tP_ba0/sub_86 (tP_counter.sv:86) |
           |                |            | tP_ba0/sub_88 (tP_counter.sv:88) |
           |                |            | tP_ba0/sub_89 (tP_counter.sv:89) |
| sub_x_101      | DW01_dec       | width=10   | sub_1315 (Ctrl.sv:1315)    |
|                |                |            | sub_1316 (Ctrl.sv:1316)    |
|                |                |            | sub_1318 (Ctrl.sv:1318)    |
|                |                |            | sub_1320 (Ctrl.sv:1320)    |
| sub_x_26       | DW01_dec       | width=5    | sub_565 (Ctrl.sv:565)      |
|                |                |            | sub_566 (Ctrl.sv:566)      |
|                |                |            | sub_567 (Ctrl.sv:567)      |
| sub_x_23       | DW01_dec       | width=3    | sub_547 (Ctrl.sv:547)      |
|                |                |            | sub_548 (Ctrl.sv:548)      |
| sub_x_20       | DW01_dec       | width=2    | sub_535 (Ctrl.sv:535)      |
|                |                |            | sub_536 (Ctrl.sv:536)      |
=============================================================================


Resource Report for Ungrouped Hierarchy BackendController_2/Rank0/wdata_fifo
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| U1             | DW_fifo_s1_sf  | width=1024 | U1 (Ctrl.sv:1653)          |
|                |                | depth=4    |                            |
|                |                | ae_level=1 |                            |
|                |                | af_level=1 |                            |
|                |                | err_mode=2 |                            |
|                |                | rst_mode=0 |                            |
=============================================================================


Resource Report for Ungrouped Hierarchy BackendController_2/Rank0 in file
        ../01_RTL/bank_FSM.sv
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| eq_x_8         | DW_cmp         | width=16   | eq_169 (bank_FSM.sv:169)   |
| sub_x_14       | DW01_dec       | width=7    | ba0/sub_266 (bank_FSM.sv:266) |
| add_x_16       | DW01_inc       | width=12   | ba0/add_288 (bank_FSM.sv:288) |
| lte_x_56       | DW_cmp         | width=3    | lte_930 (Ctrl.sv:930)      |
| gte_x_104      | DW_cmp         | width=3    | gte_1342 (Ctrl.sv:1342)    |
| gte_x_105      | DW_cmp         | width=3    | gte_1342_2 (Ctrl.sv:1342)  |
| gte_x_106      | DW_cmp         | width=3    | gte_1342_3 (Ctrl.sv:1342)  |
| gte_x_107      | DW_cmp         | width=3    | gte_1342_4 (Ctrl.sv:1342)  |
| gte_x_108      | DW_cmp         | width=3    | gte_1342_5 (Ctrl.sv:1342)  |
| gte_x_121      | DW_cmp         | width=10   | gte_1506 (Ctrl.sv:1506)    |
| gt_x_123       | DW_cmp         | width=3    | gt_1517 (Ctrl.sv:1517)     |
| gt_x_124       | DW_cmp         | width=3    | gt_1517_2 (Ctrl.sv:1517)   |
| gt_x_125       | DW_cmp         | width=3    | gt_1517_3 (Ctrl.sv:1517)   |
| gt_x_126       | DW_cmp         | width=3    | gt_1517_4 (Ctrl.sv:1517)   |
| gt_x_127       | DW_cmp         | width=3    | gt_1522 (Ctrl.sv:1522)     |
| gt_x_128       | DW_cmp         | width=3    | gt_1522_2 (Ctrl.sv:1522)   |
| gt_x_129       | DW_cmp         | width=3    | gt_1522_3 (Ctrl.sv:1522)   |
| gt_x_130       | DW_cmp         | width=3    | gt_1522_4 (Ctrl.sv:1522)   |
| gt_x_131       | DW_cmp         | width=3    | gt_1527 (Ctrl.sv:1527)     |
| gt_x_132       | DW_cmp         | width=3    | gt_1527_2 (Ctrl.sv:1527)   |
| gt_x_133       | DW_cmp         | width=3    | gt_1527_3 (Ctrl.sv:1527)   |
| gt_x_134       | DW_cmp         | width=3    | gt_1527_4 (Ctrl.sv:1527)   |
| gt_x_135       | DW_cmp         | width=3    | gt_1532 (Ctrl.sv:1532)     |
| gt_x_136       | DW_cmp         | width=3    | gt_1532_2 (Ctrl.sv:1532)   |
| gt_x_137       | DW_cmp         | width=3    | gt_1532_3 (Ctrl.sv:1532)   |
| gt_x_138       | DW_cmp         | width=3    | gt_1532_4 (Ctrl.sv:1532)   |
| gt_x_139       | DW_cmp         | width=3    | gt_1537 (Ctrl.sv:1537)     |
| gt_x_140       | DW_cmp         | width=3    | gt_1537_2 (Ctrl.sv:1537)   |
| gt_x_141       | DW_cmp         | width=3    | gt_1537_3 (Ctrl.sv:1537)   |
| gt_x_142       | DW_cmp         | width=3    | gt_1537_4 (Ctrl.sv:1537)   |
| add_x_156      | DW01_inc       | width=3    | add_1605 (Ctrl.sv:1605)    |
| add_x_157      | DW01_inc       | width=3    | add_1606 (Ctrl.sv:1606)    |
| add_x_158      | DW01_inc       | width=3    | add_1607 (Ctrl.sv:1607)    |
| add_x_159      | DW01_inc       | width=3    | add_1608 (Ctrl.sv:1608)    |
| add_x_160      | DW01_inc       | width=3    | add_1609 (Ctrl.sv:1609)    |
| add_x_166      | DW01_inc       | width=3    | add_1616 (Ctrl.sv:1616)    |
| isu_fifo/U1    | DW_fifo_s1_sf  | width=24   | isu_fifo/U1 (Ctrl.sv:1653) |
|                |                | depth=4    |                            |
|                |                | ae_level=1 |                            |
|                |                | af_level=1 |                            |
|                |                | err_mode=2 |                            |
|                |                | rst_mode=0 |                            |
| rw_cmd_out_fifo/U1              |            |                            |
|                | DW_fifo_s1_sf  | width=2    | rw_cmd_out_fifo/U1 (Ctrl.sv:1653) |
          |                | depth=4    |                            |
|                |                | ae_level=1 |                            |
|                |                | af_level=1 |                            |
|                |                | err_mode=2 |                            |
|                |                | rst_mode=0 |                            |
| gte_x_191      | DW_cmp         | width=3    | gte_1209 (Ctrl.sv:1209)    |
|                |                |            | gte_1267 (Ctrl.sv:1267)    |
| eq_x_192       | DW_cmp         | width=3    | eq_1348 (Ctrl.sv:1348)     |
|                |                |            | eq_1373 (Ctrl.sv:1373)     |
|                |                |            | eq_1616 (Ctrl.sv:1616)     |
| eq_x_193       | DW_cmp         | width=3    | tP_ba0/eq_102 (tP_counter.sv:102) |
          |                |            | tP_ba0/eq_107 (tP_counter.sv:107) |
          |                |            | tP_ba0/eq_108 (tP_counter.sv:108) |
          |                |            | tP_ba0/eq_109 (tP_counter.sv:109) |
          |                |            | tP_ba0/eq_67 (tP_counter.sv:67) |
            |                |            | tP_ba0/eq_69 (tP_counter.sv:69) |
            |                |            | tP_ba0/eq_77 (tP_counter.sv:77) |
            |                |            | tP_ba0/eq_88 (tP_counter.sv:88) |
| sub_x_178      | DW01_dec       | width=5    | tP_ba0/sub_67 (tP_counter.sv:67) |
           |                |            | tP_ba0/sub_75 (tP_counter.sv:75) |
           |                |            | tP_ba0/sub_86 (tP_counter.sv:86) |
           |                |            | tP_ba0/sub_88 (tP_counter.sv:88) |
           |                |            | tP_ba0/sub_89 (tP_counter.sv:89) |
| sub_x_101      | DW01_dec       | width=10   | sub_1315 (Ctrl.sv:1315)    |
|                |                |            | sub_1316 (Ctrl.sv:1316)    |
|                |                |            | sub_1318 (Ctrl.sv:1318)    |
|                |                |            | sub_1320 (Ctrl.sv:1320)    |
| sub_x_26       | DW01_dec       | width=5    | sub_565 (Ctrl.sv:565)      |
|                |                |            | sub_566 (Ctrl.sv:566)      |
|                |                |            | sub_567 (Ctrl.sv:567)      |
| sub_x_23       | DW01_dec       | width=3    | sub_547 (Ctrl.sv:547)      |
|                |                |            | sub_548 (Ctrl.sv:548)      |
| sub_x_20       | DW01_dec       | width=2    | sub_535 (Ctrl.sv:535)      |
|                |                |            | sub_536 (Ctrl.sv:536)      |
=============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| add_x_1            | DW01_inc         | apparch (area)     |                |
| add_x_3            | DW01_inc         | apparch (area)     |                |
| sub_x_4            | DW01_dec         | apparch (area)     |                |
| add_x_5            | DW01_inc         | apparch (area)     |                |
| U1                 | DWsc_fifoctl_s1_df | rtl              |                |
| U1                 | DW_fifoctl_s1_sf | rtl                |                |
| add_x_1            | DW01_inc         | apparch (area)     |                |
| add_x_3            | DW01_inc         | apparch (area)     |                |
| sub_x_4            | DW01_dec         | apparch (area)     |                |
| add_x_5            | DW01_inc         | apparch (area)     |                |
| U1                 | DWsc_fifoctl_s1_df | rtl              |                |
| U1                 | DW_fifoctl_s1_sf | rtl                |                |
| U2                 | DW_ram_r_w_s_dff | rtl                |                |
| add_x_1            | DW01_inc         | apparch (area)     |                |
| add_x_3            | DW01_inc         | apparch (area)     |                |
| sub_x_4            | DW01_dec         | apparch (area)     |                |
| add_x_5            | DW01_inc         | apparch (area)     |                |
| U1                 | DWsc_fifoctl_s1_df | rtl              |                |
| U1                 | DW_fifoctl_s1_sf | rtl                |                |
| U1                 | DW_fifo_s1_sf    | rtl                |                |
| eq_x_8             | DW_cmp           | apparch (area)     |                |
| sub_x_14           | DW01_dec         | apparch (area)     |                |
| add_x_16           | DW01_inc         | apparch (area)     |                |
| lte_x_56           | DW_cmp           | apparch (area)     |                |
| gte_x_104          | DW_cmp           | apparch (area)     |                |
| gte_x_105          | DW_cmp           | apparch (area)     |                |
| gte_x_106          | DW_cmp           | apparch (area)     |                |
| gte_x_107          | DW_cmp           | apparch (area)     |                |
| gte_x_108          | DW_cmp           | apparch (area)     |                |
| gte_x_121          | DW_cmp           | apparch (area)     |                |
| gt_x_123           | DW_cmp           | apparch (area)     |                |
| gt_x_124           | DW_cmp           | apparch (area)     |                |
| gt_x_125           | DW_cmp           | apparch (area)     |                |
| gt_x_126           | DW_cmp           | apparch (area)     |                |
| gt_x_127           | DW_cmp           | apparch (area)     |                |
| gt_x_128           | DW_cmp           | apparch (area)     |                |
| gt_x_129           | DW_cmp           | apparch (area)     |                |
| gt_x_130           | DW_cmp           | apparch (area)     |                |
| gt_x_131           | DW_cmp           | apparch (area)     |                |
| gt_x_132           | DW_cmp           | apparch (area)     |                |
| gt_x_133           | DW_cmp           | apparch (area)     |                |
| gt_x_134           | DW_cmp           | apparch (area)     |                |
| gt_x_135           | DW_cmp           | apparch (area)     |                |
| gt_x_136           | DW_cmp           | apparch (area)     |                |
| gt_x_137           | DW_cmp           | apparch (area)     |                |
| gt_x_138           | DW_cmp           | apparch (area)     |                |
| gt_x_139           | DW_cmp           | apparch (area)     |                |
| gt_x_140           | DW_cmp           | apparch (area)     |                |
| gt_x_141           | DW_cmp           | apparch (area)     |                |
| gt_x_142           | DW_cmp           | apparch (area)     |                |
| add_x_156          | DW01_inc         | apparch (area)     |                |
| add_x_157          | DW01_inc         | apparch (area)     |                |
| add_x_158          | DW01_inc         | apparch (area)     |                |
| add_x_159          | DW01_inc         | apparch (area)     |                |
| add_x_160          | DW01_inc         | apparch (area)     |                |
| add_x_166          | DW01_inc         | apparch (area)     |                |
| isu_fifo/U1        | DW_fifo_s1_sf    | rtl                |                |
| rw_cmd_out_fifo/U1 | DW_fifo_s1_sf    | rtl                |                |
| gte_x_191          | DW_cmp           | apparch (area)     |                |
| eq_x_192           | DW_cmp           | apparch (area)     |                |
| eq_x_193           | DW_cmp           | apparch (area)     |                |
| sub_x_178          | DW01_dec         | apparch (area)     |                |
| sub_x_101          | DW01_dec         | apparch (area)     |                |
| sub_x_26           | DW01_dec         | apparch (area)     |                |
| sub_x_23           | DW01_dec         | apparch (area)     |                |
| sub_x_20           | DW01_dec         | apparch (area)     |                |
| U1                 | DW_fifo_s1_sf    | rtl                |                |
| eq_x_8             | DW_cmp           | apparch (area)     |                |
| sub_x_14           | DW01_dec         | apparch (area)     |                |
| add_x_16           | DW01_inc         | apparch (area)     |                |
| lte_x_56           | DW_cmp           | apparch (area)     |                |
| gte_x_104          | DW_cmp           | apparch (area)     |                |
| gte_x_105          | DW_cmp           | apparch (area)     |                |
| gte_x_106          | DW_cmp           | apparch (area)     |                |
| gte_x_107          | DW_cmp           | apparch (area)     |                |
| gte_x_108          | DW_cmp           | apparch (area)     |                |
| gte_x_121          | DW_cmp           | apparch (area)     |                |
| gt_x_123           | DW_cmp           | apparch (area)     |                |
| gt_x_124           | DW_cmp           | apparch (area)     |                |
| gt_x_125           | DW_cmp           | apparch (area)     |                |
| gt_x_126           | DW_cmp           | apparch (area)     |                |
| gt_x_127           | DW_cmp           | apparch (area)     |                |
| gt_x_128           | DW_cmp           | apparch (area)     |                |
| gt_x_129           | DW_cmp           | apparch (area)     |                |
| gt_x_130           | DW_cmp           | apparch (area)     |                |
| gt_x_131           | DW_cmp           | apparch (area)     |                |
| gt_x_132           | DW_cmp           | apparch (area)     |                |
| gt_x_133           | DW_cmp           | apparch (area)     |                |
| gt_x_134           | DW_cmp           | apparch (area)     |                |
| gt_x_135           | DW_cmp           | apparch (area)     |                |
| gt_x_136           | DW_cmp           | apparch (area)     |                |
| gt_x_137           | DW_cmp           | apparch (area)     |                |
| gt_x_138           | DW_cmp           | apparch (area)     |                |
| gt_x_139           | DW_cmp           | apparch (area)     |                |
| gt_x_140           | DW_cmp           | apparch (area)     |                |
| gt_x_141           | DW_cmp           | apparch (area)     |                |
| gt_x_142           | DW_cmp           | apparch (area)     |                |
| add_x_156          | DW01_inc         | apparch (area)     |                |
| add_x_157          | DW01_inc         | apparch (area)     |                |
| add_x_158          | DW01_inc         | apparch (area)     |                |
| add_x_159          | DW01_inc         | apparch (area)     |                |
| add_x_160          | DW01_inc         | apparch (area)     |                |
| add_x_166          | DW01_inc         | apparch (area)     |                |
| isu_fifo/U1        | DW_fifo_s1_sf    | rtl                |                |
| rw_cmd_out_fifo/U1 | DW_fifo_s1_sf    | rtl                |                |
| gte_x_191          | DW_cmp           | apparch (area)     |                |
| eq_x_192           | DW_cmp           | apparch (area)     |                |
| eq_x_193           | DW_cmp           | apparch (area)     |                |
| sub_x_178          | DW01_dec         | apparch (area)     |                |
| sub_x_101          | DW01_dec         | apparch (area)     |                |
| sub_x_26           | DW01_dec         | apparch (area)     |                |
| sub_x_23           | DW01_dec         | apparch (area)     |                |
| sub_x_20           | DW01_dec         | apparch (area)     |                |
| U1                 | DW_fifo_s1_sf    | rtl                |                |
| eq_x_8             | DW_cmp           | apparch (area)     |                |
| sub_x_14           | DW01_dec         | apparch (area)     |                |
| add_x_16           | DW01_inc         | apparch (area)     |                |
| lte_x_56           | DW_cmp           | apparch (area)     |                |
| gte_x_104          | DW_cmp           | apparch (area)     |                |
| gte_x_105          | DW_cmp           | apparch (area)     |                |
| gte_x_106          | DW_cmp           | apparch (area)     |                |
| gte_x_107          | DW_cmp           | apparch (area)     |                |
| gte_x_108          | DW_cmp           | apparch (area)     |                |
| gte_x_121          | DW_cmp           | apparch (area)     |                |
| gt_x_123           | DW_cmp           | apparch (area)     |                |
| gt_x_124           | DW_cmp           | apparch (area)     |                |
| gt_x_125           | DW_cmp           | apparch (area)     |                |
| gt_x_126           | DW_cmp           | apparch (area)     |                |
| gt_x_127           | DW_cmp           | apparch (area)     |                |
| gt_x_128           | DW_cmp           | apparch (area)     |                |
| gt_x_129           | DW_cmp           | apparch (area)     |                |
| gt_x_130           | DW_cmp           | apparch (area)     |                |
| gt_x_131           | DW_cmp           | apparch (area)     |                |
| gt_x_132           | DW_cmp           | apparch (area)     |                |
| gt_x_133           | DW_cmp           | apparch (area)     |                |
| gt_x_134           | DW_cmp           | apparch (area)     |                |
| gt_x_135           | DW_cmp           | apparch (area)     |                |
| gt_x_136           | DW_cmp           | apparch (area)     |                |
| gt_x_137           | DW_cmp           | apparch (area)     |                |
| gt_x_138           | DW_cmp           | apparch (area)     |                |
| gt_x_139           | DW_cmp           | apparch (area)     |                |
| gt_x_140           | DW_cmp           | apparch (area)     |                |
| gt_x_141           | DW_cmp           | apparch (area)     |                |
| gt_x_142           | DW_cmp           | apparch (area)     |                |
| add_x_156          | DW01_inc         | apparch (area)     |                |
| add_x_157          | DW01_inc         | apparch (area)     |                |
| add_x_158          | DW01_inc         | apparch (area)     |                |
| add_x_159          | DW01_inc         | apparch (area)     |                |
| add_x_160          | DW01_inc         | apparch (area)     |                |
| add_x_166          | DW01_inc         | apparch (area)     |                |
| isu_fifo/U1        | DW_fifo_s1_sf    | rtl                |                |
| rw_cmd_out_fifo/U1 | DW_fifo_s1_sf    | rtl                |                |
| gte_x_191          | DW_cmp           | apparch (area)     |                |
| eq_x_192           | DW_cmp           | apparch (area)     |                |
| eq_x_193           | DW_cmp           | apparch (area)     |                |
| sub_x_178          | DW01_dec         | apparch (area)     |                |
| sub_x_101          | DW01_dec         | apparch (area)     |                |
| sub_x_26           | DW01_dec         | apparch (area)     |                |
| sub_x_23           | DW01_dec         | apparch (area)     |                |
| sub_x_20           | DW01_dec         | apparch (area)     |                |
===============================================================================

1
