
local TestUtil = class("TestUtil")

function TestUtil:ctor()
    -- simu login reward switch
    self.simuLogrinRewardJust = false

    -- 比较各个语言包中的项是否完整
    --self.compareLangResource()

    -- 告知服务器设备类型
    self.simuDevice = "android"
end

-- simu login reward data
function TestUtil.simuLoginReward()
    nk.userData.loginReward = {
        ret = 1,
        chips = 10000,
        data = {
            {tag=0, chips=3000, type="base", id=0, days=5},
            {tag=0, chips=2000, type="fb", id=2}
        },
        baseReward = {1500, 3000, 5000, 8000, 10000, 12000},
        vipRewardTips = "ยินดีด้วยค่ะ ท่านได้รับ 1000 ชิป + ตั๋วห้องชิงชิปเงินสด 800 บาท 7 ใบ +  ค่าเสน่ห์ 50 แต้ม"
    }
end

function TestUtil.compareLangResource()
    local cn = require("lang")
    local th = require("lang_th")
    local vn = require("lang_vn")
    local en = require("lang_en")

    print("======= th not exists ========")
    bm.LangUtil.compareResource(cn, th, "L")
    print("======= cn not exists ========")
    bm.LangUtil.compareResource(th, cn, "L")
    print("=========== end  =============")

    print("======= vn not exists ========")
    bm.LangUtil.compareResource(cn, vn, "L")
    print("======= cn not exists ========")
    bm.LangUtil.compareResource(vn, cn, "L")
    print("=========== end  =============")

    print("======= en not exists ========")
    bm.LangUtil.compareResource(cn, en, "L")
    print("======= cn not exists ========")
    bm.LangUtil.compareResource(en, cn, "L")
    print("=========== end  =============")
end

return TestUtil
