# -*- coding: utf-8 -*-
# version: v1.0
# data: 2/26/2021
# Author: xinx.e.zhang@intel.com
# brife: tbd

# Example: 
# >>> import os
# >>> import sys
# >>> sys.path.append(os.path.abspath("C:\\Users\\xx\\test"))
#
# >>> import owl
# >>> owl.Ext_sv.read_credit_value()
# unlock bus debug
# read the credit value
# socket0.uncore0.iio_itcctrl45_b0d05f0.max_cache_dat_crdt - 0x8
# socket1.uncore0.iio_itcctrl45_b0d05f0.max_cache_dat_crdt - 0x8
# socket2.uncore0.iio_itcctrl45_b0d05f0.max_cache_dat_crdt - 0x8
# socket3.uncore0.iio_itcctrl45_b0d05f0.max_cache_dat_crdt - 0x8

import __main__
sv = __main__.sv

class Ext_sv:
  
    def __init__(self):
        self.skt_list = []
        
    def pre_env(self):
        # get the socket name
        for skt in sv.socketlist:
            self.skt_list.append(skt._name) 

    def read_mitigation_all():
        print("read the high bits value of mitigation")
        print(sv.sockets.uncore0.pxp_b0d07f7_iimi_asc0ldvalhi.ldhival.read())
        print(sv.sockets.uncore0.pxp_b1d07f7_iimi_asc0ldvalhi.ldhival.read())
        print(sv.sockets.uncore0.pxp_b2d07f7_iimi_asc0ldvalhi.ldhival.read())
        print(sv.sockets.uncore0.pxp_b4d07f7_iimi_asc0ldvalhi.ldhival.read())
        
        print("read the low bits value of mitigation")
        print(sv.sockets.uncore0.pxp_b0d07f7_iimi_asc0ldvallo.ldlowval.read())
        print(sv.sockets.uncore0.pxp_b1d07f7_iimi_asc0ldvallo.ldlowval.read())
        print(sv.sockets.uncore0.pxp_b2d07f7_iimi_asc0ldvallo.ldlowval.read())
        print(sv.sockets.uncore0.pxp_b4d07f7_iimi_asc0ldvallo.ldlowval.read())
        
        print(sv.sockets.uncore0.pxp_b0d07f7_iimi_asccontrol.asc0en.read())
        print(sv.sockets.uncore0.pxp_b1d07f7_iimi_asccontrol.asc0en.read())
        print(sv.sockets.uncore0.pxp_b2d07f7_iimi_asccontrol.asc0en.read())
        print(sv.sockets.uncore0.pxp_b4d07f7_iimi_asccontrol.asc0en.read())
        
        print(sv.sockets.uncore0.pxp_b0d07f7_itcrspfunc.startsel0.read())
        print(sv.sockets.uncore0.pxp_b1d07f7_itcrspfunc.startsel0.read())
        print(sv.sockets.uncore0.pxp_b2d07f7_itcrspfunc.startsel0.read())
        print(sv.sockets.uncore0.pxp_b4d07f7_itcrspfunc.startsel0.read())
        
        print(sv.sockets.uncore0.pxp_b0d07f7_itcrspfunc.stopsel0.read())
        print(sv.sockets.uncore0.pxp_b1d07f7_itcrspfunc.stopsel0.read())
        print(sv.sockets.uncore0.pxp_b2d07f7_itcrspfunc.stopsel0.read())
        print(sv.sockets.uncore0.pxp_b4d07f7_itcrspfunc.stopsel0.read())
        
        print("read the typemask")
        print(sv.sockets.uncore0.pxp_b0d07f7_itcarbblock.typemask.read())
        print(sv.sockets.uncore0.pxp_b1d07f7_itcarbblock.typemask.read())
        print(sv.sockets.uncore0.pxp_b2d07f7_itcarbblock.typemask.read())
        print(sv.sockets.uncore0.pxp_b4d07f7_itcarbblock.typemask.read())
        
        print(sv.sockets.uncore0.pxp_b0d07f7_itcarbblock.enable.read())
        print(sv.sockets.uncore0.pxp_b1d07f7_itcarbblock.enable.read())
        print(sv.sockets.uncore0.pxp_b2d07f7_itcarbblock.enable.read())
        print(sv.sockets.uncore0.pxp_b4d07f7_itcarbblock.enable.read())

    def read_credit_value():
        print("unlock bus debug")
        sv.sockets.uncore0.iio_dfx_lck_ctl = 0
        sv.sockets.uncore0.iio_pstack0_iio_dfx_lck_ctl.dbgbuslck = 0
        sv.sockets.uncore0.iio_pstack1_iio_dfx_lck_ctl.dbgbuslck = 0
        sv.sockets.uncore0.iio_pstack3_iio_dfx_lck_ctl.dbgbuslck = 0
        
        print("read the credit value")
        print(sv.sockets.uncore0.iio_itcctrl45_b0d05f0.max_cache_dat_crdt)
        print(sv.sockets.uncore0.iio_itcctrl45_b1d05f0.max_cache_dat_crdt)
        print(sv.sockets.uncore0.iio_itcctrl45_b2d05f0.max_cache_dat_crdt)
        print(sv.sockets.uncore0.iio_itcctrl45_b4d05f0.max_cache_dat_crdt)
