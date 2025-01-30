---@diagnostic disable: lowercase-global
function has(item, amount)
  local count = Tracker:ProviderCountForCode(item)
  amount = tonumber(amount)
  if not amount then
    return count > 0
  else
    return count == amount
  end
end

--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------REGIONS-----------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
 
function region2()
  return 1
end

function region3()
  return region2() and has ("leafShade")
end

function region4()
  return region3() and (has ("minePass") and has ("guildPass"))
end

function region5()
  return mineKeyTotal(1) and region4()
end


function region6()
  return mineKeyTotal(2) and region5()
end

function region7()
  return region6() and mineKeyTotal(3)
end

function region8()
  return region7() and mineKeyTotal(6)
end

function region9()
  return region7() and (has ("eleHeat") and has ("thiefKey"))
end

function region10()
  return region9() and mineKeyTotal(10)
end

function region11()
  return region10() and (has ("mineMaster") and has ("iceShade"))
end

function region12()
  return region11()  and has ("maroonPass")
end

function region13()
  return region12() and (has ("eleHeat") and has("sandShade"))
end

function region14()
  return fajroKeyTotal(1) and region13()
end

function region15()
  return region14() and fajroKeyTotal(3)
end

function region16()
  return fajroKeyTotal(4) and region15()
end

function region17()
  return region16() and has ("eleCold")
end

function region17half()
  return region17() and has ("whiteKey")
end

function region18()
  return region17half() and fajroKeyTotal(9)
end

function region19()
  return region17half() and has ("fajroMaster")
end

function region20()
  return region19() and has ("flameShade")
end

function region21()
  return region20() and has ("seedShade")
end

function region23()
  return region21() and (has ("eleHeat") and has ("eleCold"))
end

function region24()
  return region21() and has ("pondPass")
end

function region25()
  return zirvitarKeyTotal(2) and region23()
end

function region26()
  return sonajizKeyTotal(3) and region23()
end

function region27()
  return region26() and sonajizKeyTotal(4) and (has ("radiantKey"))
end

function region28()
  return region23() and (has ("eleWave") and has ("eleShock") and has ("dropShade") and has ("boltShade"))
end

function region29()
  return kryskajoKeyTotal(2) and region28()
end

function region30()
  return region28() and has ("kryskajoMaster")
end

function region31()
  return region30() and has ("starShade")
end

function region22()
  return region31()
end

function region32()
  return region31() and has ("dojoKey")
end

function region33()
  return region32() and has ("meteorShade")
end

function region34()
  return region22() and
    (has ("settingVTGateOpen") and
        has ("eleHeat") and
          has ("eleCold") and
            has ("elewave") and 
              has ("eleShock")) 
  or        
    region22() and 
      (has ("eleHeat") and 
        has ("eleCold") and 
          has ("eleWave") and 
            has ("eleShock") and
              has ("minesWon") and
                has ("fajroWon") and
                  has ("sonajizWon") and
                    has ("zirvitarWon"))
end

-- Open Mode Logic

function regionOpen2()
  return has ("settingOpenModeOpen")
end

function regionOpen3()
  return regionOpen2() and has ("leafShade")
end

function regionOpen3_1()
  return regionOpen2() and has ("minePass")
end

function regionOpen4_1()
  return regionOpen3() and has ("minePass")
end

function regionOpen4_2()
  return mineKeyTotal(1) and regionOpen4_1()
end

function regionOpen4_3()
  return regionOpen4_2() and mineKeyTotal(2)
end

function regionOpen4_4()
  return regionOpen4_3() and mineKeyTotal(3)
end

function regionOpen4_5()
  return regionOpen4_4() and mineKeyTotal(4)
end

function regionOpen4_6()
  return regionOpen4_3() and has ("eleHeat")
end

function regionOpen4_7()
  return regionOpen4_6() and mineKeyTotal(5)
end

function regionOpen4_8()
  return regionOpen4_1() and has ("mineMaster")
end

function regionOpen5()
  return regionOpen3() and has ("iceShade")
end

function regionOpen6()
  return regionOpen5() and has ("maroonPass")
end

function regionOpen7_1()
  return regionOpen5() and (has ("sandShade") and has ("eleHeat"))
end

function regionOpen7_2()
  return fajroKeyTotal(1) and regionOpen7_1()
end

function regionOpen7_3()
  return regionOpen7_2() and fajroKeyTotal(3)
end

function regionOpen7_4()
  return regionOpen7_3() and fajroKeyTotal(4)
end

function regionOpen7_5()
  return regionOpen7_4() and has ("eleCold")
end

function regionOpen7_6()
  return regionOpen7_5() and has ("whiteKey")
end

function regionOpen7_7()
  return regionOpen7_5() and fajroKeyTotal(9)
end

function regionOpen7_8()
  return regionOpen7_5() and has ("fajroMaster")
end

function regionOpen8()
  return regionOpen2() and has ("flameShade")
end

function regionOpen9()
  return regionOpen2() and has ("flameShade")
end

function regionOpen20()
  return regionOpen2() and has ("meteorShade")
end

function regionOpen9_1()
  return regionOpen9() and has ("seedShade")
end

function regionOpen10()
  return regionOpen9() and has ("seedShade")
end

function regionOpen11()
  return regionOpen10() and has ("pondPass")
end

function regionOpen12()
  return regionOpen10()
end

function regionOpen13_1()
  return zirvitarKeyTotal(2) and regionOpen10()
end

function regionOpen13_2()
  return regionOpen13_1() and has ("eleWave")
end

function regionOpen14_1()
  return sonajizKeyTotal(1) and regionOpen10() and (has("eleHeat") or has("eleCold") or has ("eleWave") or has ("eleShock"))
end

function regionOpen14_2()
  return regionOpen10() and sonajizKeyTotal(3) and has("eleHeat")
end

function regionOpen14_3()
  return regionOpen14_2() and has ("eleCold")
end

function regionOpen14_4()
  return regionOpen14_3() and has("radiantKey") and sonajizKeyTotal(4)
end

function regionOpen14_5()
  return regionOpen14_4() and has("eleShock")
end

function regionOpen15_1()
  return regionOpen12() and (has ("boltShade") and has ("dropShade") and has ("eleWave") and has ("eleShock"))
end

function regionOpen15_2()
  return regionOpen15_1() and kryskajoKeyTotal(2)
end

function regionOpen15_3()
  return regionOpen15_2() and has ("kryskajoMaster")
end

function regionOpen16()
  return regionOpen9() and has ("starShade")
end

function regionOpen17()
  return regionOpen16() and has ("dojoKey")
end

function regionOpen18()
  return regionOpen16()
end

function regionOpen16_1()
  return regionOpen16() and has ("meteorShade")
end

function regionOpen19()
  return 
    regionOpen18() and 
      (has ("settingVTGateOpen") and
        has ("eleHeat") and
          has ("eleCold") and
            has ("elewave") and 
              has ("eleShock")) 
  or        
    regionOpen18() and 
      (has ("eleHeat") and 
        has ("eleCold") and 
          has ("eleWave") and 
            has ("eleShock") and
              has ("minesWon") and
                has ("fajroWon") and
                  has ("sonajizWon") and
                    has ("zirvitarWon"))
end

-- Dungeon Keys

function mineKeyTotal(amount)
  if has("settingKeyringsOn") then
    mineKeyAmount=Tracker:ProviderCountForCode("mineKey")*5
    count = Tracker:FindObjectForCode("mineKey")
    if count.AcquiredCount > 0 then
      count.AcquiredCount = 5
    end
  else
    mineKeyAmount=Tracker:ProviderCountForCode("mineKey")*1
  end
  return (mineKeyAmount >= amount)
end

function fajroKeyTotal(amount)
  if has("settingKeyringsOn") then
    fajroKeyAmount=Tracker:ProviderCountForCode("fajroKey")*9
    count = Tracker:FindObjectForCode("fajroKey")
    if count.AcquiredCount > 0 then
      count.AcquiredCount = 9
    end
  else
    fajroKeyAmount=Tracker:ProviderCountForCode("fajroKey")*1
  end
  return (fajroKeyAmount >= amount)
end

function zirvitarKeyTotal(amount)
  if has("settingKeyringsOn") then
    zirvitarKeyAmount=Tracker:ProviderCountForCode("zirvitarKey")*2
    count = Tracker:FindObjectForCode("zirvitarKey")
    if count.AcquiredCount > 0 then
      count.AcquiredCount = 2
    end
  else
    zirvitarKeyAmount=Tracker:ProviderCountForCode("zirvitarKey")*1
  end
  return (zirvitarKeyAmount >= amount)
end

function sonajizKeyTotal(amount)
  if has("settingKeyringsOn") then
    sonajizKeyAmount=Tracker:ProviderCountForCode("sonajizKey")*4
    count = Tracker:FindObjectForCode("sonajizKey")
    if count.AcquiredCount > 0 then
      count.AcquiredCount = 4
    end
  else
    sonajizKeyAmount=Tracker:ProviderCountForCode("sonajizKey")*1
  end
  return (sonajizKeyAmount >= amount)
end

function kryskajoKeyTotal(amount)
  if has("settingKeyringsOn") then
    kryskajoKeyAmount=Tracker:ProviderCountForCode("kryskajoKey")*2
    count = Tracker:FindObjectForCode("kryskajoKey")
    if count.AcquiredCount > 0 then
      count.AcquiredCount = 2
    end
  else
    kryskajoKeyAmount=Tracker:ProviderCountForCode("kryskajoKey")*1
  end
  return (kryskajoKeyAmount >= amount)
end

-- Misc --

function canGrind()
  return has ("leafShade") or has ("flameShade")
end

-- Shop Logic --

-- Slot Shuffle

-- Rookie Harbor Shops

function RHitem1()
  return has ("settingShopReceiveSlots") and has ("RHitem1")
end

function RHitem2()
  return has ("settingShopReceiveSlots") and has ("RHitem2")
end

function RHitem3()
  return has ("settingShopReceiveSlots") and has ("RHitem3")
end

function RHitem4()
  return has ("settingShopReceiveSlots") and has ("RHitem4")
end

function RHitem5()
  return has ("settingShopReceiveSlots") and has ("RHitem5")
end

function RHitem6()
  return has ("settingShopReceiveSlots") and has ("RHitem6")
end

function RHitem7()
  return has ("settingShopReceiveSlots") and has ("RHitem7")
end

function RHitem8()
  return has ("settingShopReceiveSlots") and has ("RHitem8")
end

function RHitem9()
  return has ("settingShopReceiveSlots") and has ("RHitem9")
end

function RHitem10()
  return has ("settingShopReceiveSlots") and has ("RHitem10")
end

function RHitem11()
  return has ("settingShopReceiveSlots") and has ("RHitem11")
end

function RHitem12()
  return has ("settingShopReceiveSlots") and has ("RHitem12")
end

function RHitem13()
  return has ("settingShopReceiveSlots") and has ("RHitem13")
end

function RHitem14()
  return has ("settingShopReceiveSlots") and has ("RHitem14")
end

function RHitem15()
  return has ("settingShopReceiveSlots") and has ("Rhitem15")
end

function RHweapon1()
  return has ("settingShopReceiveSlots") and has ("RHweapon1")
end

function RHweapon2()
  return has ("settingShopReceiveSlots") and has ("RHweapon2")
end

function RHweapon3()
  return has ("settingShopReceiveSlots") and has ("RHweapon3")
end

function RHweapon4()
  return has ("settingShopReceiveSlots") and has ("RHweapon4")
end

function RHweapon5()
  return has ("settingShopReceiveSlots") and has ("RHweapon5")
end

function RHweapon6()
  return has ("settingShopReceiveSlots") and has ("RHweapon6")
end

function RHweapon7()
  return has ("settingShopReceiveSlots") and has ("RHweapon7")
end

function RHweapon8()
  return has ("settingShopReceiveSlots") and has ("RHweapon8")
end

function RHweapon9()
  return has ("settingShopReceiveSlots") and has ("RHweapon9")
end

function RHweapon10()
  return has ("settingShopReceiveSlots") and has ("RHweapon10")
end

function RHweapon11()
  return has ("settingShopReceiveSlots") and has ("RHweapon11")
end

function RHweapon12()
  return has ("settingShopReceiveSlots") and has ("RHweapon12")
end

function RHchef1()
  return has ("settingShopReceiveSlots") and has ("RHchef1")
end

function RHchef2()
  return has ("settingShopReceiveSlots") and has ("RHchef2")
end

function RHchef3()
  return has ("settingShopReceiveSlots") and has ("RHchef3")
end

function RHchef4()
  return has ("settingShopReceiveSlots") and has ("RHchef4")
end

function RHchef5()
  return has ("settingShopReceiveSlots") and has ("RHchef5")
end

function RHchef6()
  return has ("settingShopReceiveSlots") and has ("RHchef6")
end

function RHchef7()
  return has ("settingShopReceiveSlots") and has ("RHchef7")
end

function RHchef8()
  return has ("settingShopReceiveSlots") and has ("RHchef8")
end

function RHchef9()
  return has ("settingShopReceiveSlots") and has ("RHchef9")
end

function RHchef10()
  return has ("settingShopReceiveSlots") and has ("RHchef10")
end

function RHchef11()
  return has ("settingShopReceiveSlots") and has ("RHchef11")
end

function RHchef12()
  return has ("settingShopReceiveSlots") and has ("RHchef12")
end

function RHbackWeapon1()
  return has ("settingShopReceiveSlots") and has ("RHbackWeapon1")
end

function RHbackWeapon2()
  return has ("settingShopReceiveSlots") and has ("RHbackWeapon2")
end

function RHbackWeapon3()
  return has ("settingShopReceiveSlots") and has ("RHbackWeapon3")
end

function RHbackWeapon4()
  return has ("settingShopReceiveSlots") and has ("RHbackWeapon4")
end

function RHbackWeapon5()
  return has ("settingShopReceiveSlots") and has ("RHbackWeapon5")
end

function RHbackWeapon6()
  return has ("settingShopReceiveSlots") and has ("RHbackWeapon6")
end

function RHbackWeapon7()
  return has ("settingShopReceiveSlots") and has ("RHbackWeapon7")
end

function RHbackWeapon8()
  return has ("settingShopReceiveSlots") and has ("RHbackWeapon8")
end

function RHtara1()
  return has ("settingShopReceiveSlots") and has ("RHtara1")
end

-- Bergen Trail Shops

function BThermit1()
  return has ("settingShopReceiveSlots") and has ("BThermit1")
end

function BThermit2()
  return has ("settingShopReceiveSlots") and has ("BThermit2")
end

function BThermit3()
  return has ("settingShopReceiveSlots") and has ("BThermit3")
end

-- Bergen Village Shops

function BVitem1()
  return has ("settingShopReceiveSlots") and has ("BVitem1")
end

function BVitem2()
  return has ("settingShopReceiveSlots") and has ("BVitem2")
end

function BVitem3()
  return has ("settingShopReceiveSlots") and has ("BVitem3")
end

function BVitem4()
  return has ("settingShopReceiveSlots") and has ("BVitem4")
end

function BVitem5()
  return has ("settingShopReceiveSlots") and has ("BVitem5")
end

function BVitem6()
  return has ("settingShopReceiveSlots") and has ("BVitem6")
end

function BVitem7()
  return has ("settingShopReceiveSlots") and has ("BVitem7")
end

function BVitem8()
  return has ("settingShopReceiveSlots") and has ("BVitem8")
end

function BVitem9()
  return has ("settingShopReceiveSlots") and has ("BVitem9")
end

function BVitem10()
  return has ("settingShopReceiveSlots") and has ("BVitem10")
end

function BVitem11()
  return has ("settingShopReceiveSlots") and has ("BVitem11")
end

function BVitem12()
  return has ("settingShopReceiveSlots") and has ("BVitem12")
end

function BVitem13()
  return has ("settingShopReceiveSlots") and has ("BVitem13")
end

function BVitem14()
  return has ("settingShopReceiveSlots") and has ("BVitem14")
end

function BVitem15()
  return has ("settingShopReceiveSlots") and has ("BVitem15")
end

function BVweapon1()
  return has ("settingShopReceiveSlots") and has ("BVweapon1")
end

function BVweapon2()
  return has ("settingShopReceiveSlots") and has ("BVweapon2")
end

function BVweapon3()
  return has ("settingShopReceiveSlots") and has ("BVweapon3")
end

function BVweapon4()
  return has ("settingShopReceiveSlots") and has ("BVweapon4")
end

-- Bakii Kum Shops

function BKitem1()
  return has ("settingShopReceiveSlots") and has ("BKitem1")
end

function BKitem2()
  return has ("settingShopReceiveSlots") and has ("BKitem2")
end

function BKitem3()
  return has ("settingShopReceiveSlots") and has ("BKitem3")
end

function BKitem4()
  return has ("settingShopReceiveSlots") and has ("BKitem4")
end

function BKitem5()
  return has ("settingShopReceiveSlots") and has ("BKitem5")
end

function BKitem6()
  return has ("settingShopReceiveSlots") and has ("BKitem6")
end

function BKitem7()
  return has ("settingShopReceiveSlots") and has ("BKitem7")
end

function BKitem8()
  return has ("settingShopReceiveSlots") and has ("BKitem8")
end

function BKitem9()
  return has ("settingShopReceiveSlots") and has ("BKitem9")
end

function BKitem10()
  return has ("settingShopReceiveSlots") and has ("BKitem10")
end

function BKitem11()
  return has ("settingShopReceiveSlots") and has ("BKitem11")
end

function BKitem12()
  return has ("settingShopReceiveSlots") and has ("BKitem12")
end

function BKitem13()
  return has ("settingShopReceiveSlots") and has ("BKitem13")
end

function BKitem14()
  return has ("settingShopReceiveSlots") and has ("BKitem14")
end

function BKitem15()
  return has ("settingShopReceiveSlots") and has ("BKitem15")
end

function BKweapon1()
  return has ("settingShopReceiveSlots") and has ("BKweapon1")
end

function BKweapon2()
  return has ("settingShopReceiveSlots") and has ("BKweapon2")
end

function BKweapon3()
  return has ("settingShopReceiveSlots") and has ("BKweapon3")
end

function BKweapon4()
  return has ("settingShopReceiveSlots") and has ("BKweapon4")
end
function BKweapon5()
  return has ("settingShopReceiveSlots") and has ("BKweapon5")
end

function BKweapon6()
  return has ("settingShopReceiveSlots") and has ("BKweapon6")
end

function BKweapon7()
  return has ("settingShopReceiveSlots") and has ("BKweapon7")
end

function BKweapon8()
  return has ("settingShopReceiveSlots") and has ("BKweapon8")
end

-- Basin Keep Shops

function BKEitem1()
  return has ("settingShopReceiveSlots") and has ("BKEitem1")
end

function BKEitem2()
  return has ("settingShopReceiveSlots") and has ("BKEitem2")
end

function BKEitem3()
  return has ("settingShopReceiveSlots") and has ("BKEitem3")
end

function BKEitem4()
  return has ("settingShopReceiveSlots") and has ("BKEitem4")
end

function BKEitem5()
  return has ("settingShopReceiveSlots") and has ("BKEitem5")
end

function BKEitem6()
  return has ("settingShopReceiveSlots") and has ("BKEitem6")
end

function BKEitem7()
  return has ("settingShopReceiveSlots") and has ("BKEitem7")
end

function BKEitem8()
  return has ("settingShopReceiveSlots") and has ("BKEitem8")
end

function BKEitem9()
  return has ("settingShopReceiveSlots") and has ("BKEitem9")
end

function BKEitem10()
  return has ("settingShopReceiveSlots") and has ("BKEitem10")
end

function BKEitem11()
  return has ("settingShopReceiveSlots") and has ("BKEitem11")
end

function BKEitem12()
  return has ("settingShopReceiveSlots") and has ("BKEitem12")
end

function BKEitem13()
  return has ("settingShopReceiveSlots") and has ("BKEitem13")
end

function BKEitem14()
  return has ("settingShopReceiveSlots") and has ("BKEitem14")
end

function BKEitem15()
  return has ("settingShopReceiveSlots") and has ("BKEitem15")
end

function BKEweapon1()
  return has ("settingShopReceiveSlots") and has ("BKEweapon1")
end

function BKEweapon2()
  return has ("settingShopReceiveSlots") and has ("BKEweapon2")
end

function BKEweapon3()
  return has ("settingShopReceiveSlots") and has ("BKEweapon3")
end

function BKEweapon4()
  return has ("settingShopReceiveSlots") and has ("BKEweapon4")
end
function BKEweapon5()
  return has ("settingShopReceiveSlots") and has ("BKEweapon5")
end

function BKEweapon6()
  return has ("settingShopReceiveSlots") and has ("BKEweapon6")
end

function BKEweapon7()
  return has ("settingShopReceiveSlots") and has ("BKEweapon7")
end

function BKEweapon8()
  return has ("settingShopReceiveSlots") and has ("BKEweapon8")
end

function BKEvendor1()
  return has ("settingShopReceiveSlots") and has ("BKEvendor1")
end

function BKEvendor2()
  return has ("settingShopReceiveSlots") and has ("BKEvendor2")
end

function BKEvendor3()
  return has ("settingShopReceiveSlots") and has ("BKEvendor3")
end

function BKEvendor4()
  return has ("settingShopReceiveSlots") and has ("BKEvendor4")
end

function BKEvendor5()
  return has ("settingShopReceiveSlots") and has ("BKEvendor5")
end

function BKEvendor6()
  return has ("settingShopReceiveSlots") and has ("BKEvendor6")
end

function BKEvendor7()
  return has ("settingShopReceiveSlots") and has ("BKEvendor7")
end

function BKEvendor8()
  return has ("settingShopReceiveSlots") and has ("BKEvendor8")
end

function BKEvendor9()
  return has ("settingShopReceiveSlots") and has ("BKEvendor9")
end

function BKEvendor10()
  return has ("settingShopReceiveSlots") and has ("BKEvendor10")
end

function BKEvendor11()
  return has ("settingShopReceiveSlots") and has ("BKEvendor11")
end

function BKEvendor12()
  return has ("settingShopReceiveSlots") and has ("BKEvendor12")
end

function BKEvendor13()
  return has ("settingShopReceiveSlots") and has ("BKEvendor13")
end

function BKEvendor14()
  return has ("settingShopReceiveSlots") and has ("BKEvendor14")
end

function BKEvendor15()
  return has ("settingShopReceiveSlots") and has ("BKEvendor15")
end

function BKEcalzone1()
  return has ("settingShopReceiveSlots") and has ("BKEcalzone1")
end

-- Sapphire Ridge Shops

function SRitem1()
  return has ("settingShopReceiveSlots") and has ("SRitem1")
end

function SRitem2()
  return has ("settingShopReceiveSlots") and has ("SRitem2")
end

function SRitem3()
  return has ("settingShopReceiveSlots") and has ("SRitem3")
end

function SRitem4()
  return has ("settingShopReceiveSlots") and has ("SRitem4")
end

function SRitem5()
  return has ("settingShopReceiveSlots") and has ("SRitem5")
end

function SRitem6()
  return has ("settingShopReceiveSlots") and has ("SRitem6")
end

function SRitem7()
  return has ("settingShopReceiveSlots") and has ("SRitem7")
end

function SRitem8()
  return has ("settingShopReceiveSlots") and has ("SRitem8")
end

function SRitem9()
  return has ("settingShopReceiveSlots") and has ("SRitem9")
end

function SRitem10()
  return has ("settingShopReceiveSlots") and has ("SRitem10")
end

function SRitem11()
  return has ("settingShopReceiveSlots") and has ("SRitem11")
end

function SRitem12()
  return has ("settingShopReceiveSlots") and has ("SRitem12")
end

function SRitem13()
  return has ("settingShopReceiveSlots") and has ("SRitem13")
end

function SRitem14()
  return has ("settingShopReceiveSlots") and has ("SRitem14")
end

function SRitem15()
  return has ("settingShopReceiveSlots") and has ("SRitem15")
end

function SRweapon1()
  return has ("settingShopReceiveSlots") and has ("SRweapon1")
end

function SRweapon2()
  return has ("settingShopReceiveSlots") and has ("SRweapon2")
end

function SRweapon3()
  return has ("settingShopReceiveSlots") and has ("SRweapon3")
end

function SRweapon4()
  return has ("settingShopReceiveSlots") and has ("SRweapon4")
end
function SRweapon5()
  return has ("settingShopReceiveSlots") and has ("SRweapon5")
end

function SRweapon6()
  return has ("settingShopReceiveSlots") and has ("SRweapon6")
end

function SRweapon7()
  return has ("settingShopReceiveSlots") and has ("SRweapon7")
end

function SRweapon8()
  return has ("settingShopReceiveSlots") and has ("SRweapon8")
end

-- Rhombus Square Shops

function RSitem1()
  return has ("settingShopReceiveSlots") and has ("RSitem1")
end

function RSitem2()
  return has ("settingShopReceiveSlots") and has ("RSitem2")
end

function RSitem3()
  return has ("settingShopReceiveSlots") and has ("RSitem3")
end

function RSitem4()
  return has ("settingShopReceiveSlots") and has ("RSitem4")
end

function RSitem5()
  return has ("settingShopReceiveSlots") and has ("RSitem5")
end

function RSitem6()
  return has ("settingShopReceiveSlots") and has ("RSitem6")
end

function RSitem7()
  return has ("settingShopReceiveSlots") and has ("RSitem7")
end

function RSitem8()
  return has ("settingShopReceiveSlots") and has ("RSitem8")
end

function RSitem9()
  return has ("settingShopReceiveSlots") and has ("RSitem9")
end

function RSitem10()
  return has ("settingShopReceiveSlots") and has ("RSitem10")
end

function RSitem11()
  return has ("settingShopReceiveSlots") and has ("RSitem11")
end

function RSitem12()
  return has ("settingShopReceiveSlots") and has ("RSitem12")
end

function RSitem13()
  return has ("settingShopReceiveSlots") and has ("RSitem13")
end

function RSitem14()
  return has ("settingShopReceiveSlots") and has ("RSitem14")
end

function RSitem15()
  return has ("settingShopReceiveSlots") and has ("RSitem15")
end

function RSweapon1()
  return has ("settingShopReceiveSlots") and has ("RSweapon1")
end

function RSweapon2()
  return has ("settingShopReceiveSlots") and has ("RSweapon2")
end

function RSweapon3()
  return has ("settingShopReceiveSlots") and has ("RSweapon3")
end

function RSweapon4()
  return has ("settingShopReceiveSlots") and has ("RSweapon4")
end
function RSweapon5()
  return has ("settingShopReceiveSlots") and has ("RSweapon5")
end

function RSweapon6()
  return has ("settingShopReceiveSlots") and has ("RSweapon6")
end

function RSweapon7()
  return has ("settingShopReceiveSlots") and has ("RSweapon7")
end

function RSweapon8()
  return has ("settingShopReceiveSlots") and has ("RSweapon8")
end

function RSchef1()
  return has ("settingShopReceiveSlots") and has ("RSchef1")
end

function RSchef2()
  return has ("settingShopReceiveSlots") and has ("RSchef2")
end

function RSchef3()
  return has ("settingShopReceiveSlots") and has ("RSchef3")
end

function RSchef4()
  return has ("settingShopReceiveSlots") and has ("RSchef4")
end

function RSchef5()
  return has ("settingShopReceiveSlots") and has ("RSchef5")
end

function RSchef6()
  return has ("settingShopReceiveSlots") and has ("RSchef6")
end

function RSchef7()
  return has ("settingShopReceiveSlots") and has ("RSchef7")
end

function RSchef8()
  return has ("settingShopReceiveSlots") and has ("RSchef8")
end

function RSchef9()
  return has ("settingShopReceiveSlots") and has ("RSchef9")
end

function RSchef10()
  return has ("settingShopReceiveSlots") and has ("RSchef10")
end

function RSchef11()
  return has ("settingShopReceiveSlots") and has ("RSchef11")
end

function RSchef12()
  return has ("settingShopReceiveSlots") and has ("RSchef12")
end

function RScurio1()
  return has ("settingShopReceiveSlots") and has ("RScurio1")
end

-- Vermillion Wasteland Shops

function VWitem1()
  return has ("settingShopReceiveSlots") and has ("VWitem1")
end

function VWitem2()
  return has ("settingShopReceiveSlots") and has ("VWitem2")
end

function VWitem3()
  return has ("settingShopReceiveSlots") and has ("VWitem3")
end

function VWitem4()
  return has ("settingShopReceiveSlots") and has ("VWitem4")
end

function VWitem5()
  return has ("settingShopReceiveSlots") and has ("VWitem5")
end

function VWitem6()
  return has ("settingShopReceiveSlots") and has ("VWitem6")
end

function VWitem7()
  return has ("settingShopReceiveSlots") and has ("VWitem7")
end

function VWitem8()
  return has ("settingShopReceiveSlots") and has ("VWitem8")
end

function VWweapon1()
  return has ("settingShopReceiveSlots") and has ("VWweapon1")
end

function VWweapon2()
  return has ("settingShopReceiveSlots") and has ("VWweapon2")
end

function VWweapon3()
  return has ("settingShopReceiveSlots") and has ("VWweapon3")
end

function VWweapon4()
  return has ("settingShopReceiveSlots") and has ("VWweapon4")
end
function VWweapon5()
  return has ("settingShopReceiveSlots") and has ("VWweapon5")
end

function VWweapon6()
  return has ("settingShopReceiveSlots") and has ("VWweapon6")
end

function VWweapon7()
  return has ("settingShopReceiveSlots") and has ("VWweapon7")
end

function VWweapon8()
  return has ("settingShopReceiveSlots") and has ("VWweapon8")
end

-- Type Shuffle

function typeSandwich()
  return has ("settingShopReceiveTypes") and has ("sandwich")
end

function typeHiSandwich()
  return has ("settingShopReceiveTypes") and has ("hiSandwich")
end

function typeTea()
  return has ("settingShopReceiveTypes") and has ("greenTea")
end

function typeWater()
  return has ("settingShopReceiveTypes") and has ("justWater")
end

function typeKebab()
  return has ("settingShopReceiveTypes") and has ("kebab")
end

function typeRisotto()
  return has ("settingShopReceiveTypes") and has ("risotto")
end

function typeBun()
  return has ("settingShopReceiveTypes") and has ("spicyBun")
end

function typeFruit()
  return has ("settingShopReceiveTypes") and has ("fruitDrink")
end

function typeCracker()
  return has ("settingShopReceiveTypes") and has ("cracker")
end

function typeVeggie()
  return has ("settingShopReceiveTypes") and has ("veggieSticks")
end

function typeIcecream()
  return has ("settingShopReceiveTypes") and has ("iceCream")
end

function typeLemonjuice()
  return has ("settingShopReceiveTypes") and has ("lemonjuice")
end

function typeCoffee()
  return has ("settingShopReceiveTypes") and has ("coffee")
end

function typePeanuts()
  return has ("settingShopReceiveTypes") and has ("peanuts")
end

function typeMix()
  return has ("settingShopReceiveTypes") and has ("snackMix")
end

function typeRisingStar()
  return has ("settingShopReceiveTypes") and has ("risingStar")
end

function typePepper()
  return has ("settingShopReceiveTypes") and has ("dkPepper")
end

function typeMaultasche()
  return has ("settingShopReceiveTypes") and has ("maultasche")
end

function typeSpaetzle()
  return has ("settingShopReceiveTypes") and has ("spaetzle")
end

function typeDurian()
  return has ("settingShopReceiveTypes") and has ("durian")
end

function typePengo()
  return has ("settingShopReceiveTypes") and has ("pengoPop")
end

function typeBeatZero()
  return has ("settingShopReceiveTypes") and has ("beatZero")
end

function typeWerewolf()
  return has ("settingShopReceiveTypes") and has ("werewolf")
end

function typeMooncake()
  return has ("settingShopReceiveTypes") and has ("mooncake")
end

function typeWillis()
  return has ("settingShopReceiveTypes") and has ("willis")
end

function typePumpkin()
  return has ("settingShopReceiveTypes") and has ("pumpkinCoffee")
end

function typeToast()
  return has ("settingShopReceiveTypes") and has ("toast")
end

function typeBrHelm()
  return has ("settingShopReceiveTypes") and has ("brHelm")
end

function typeBrEdge()
  return has ("settingShopReceiveTypes") and has ("brEdge")
end

function typeBrMail()
  return has ("settingShopReceiveTypes") and has ("brMail")
end

function typeBrBoots()
  return has ("settingShopReceiveTypes") and has ("brBoots")
end

function typeIrHelm()
  return has ("settingShopReceiveTypes") and has ("irHelm")
end

function typeIrEdge()
  return has ("settingShopReceiveTypes") and has ("irEdge")
end

function typeIrMail()
  return has ("settingShopReceiveTypes") and has ("irMail")
end

function typeIrBoots()
  return has ("settingShopReceiveTypes") and has ("irBoots")
end

function typeSilHelm()
  return has ("settingShopReceiveTypes") and has ("silHelm")
end

function typeSilEdge()
  return has ("settingShopReceiveTypes") and has ("silEdge")
end

function typeSilMail()
  return has ("settingShopReceiveTypes") and has ("silMail")
end

function typeSilBoots()
  return has ("settingShopReceiveTypes") and has ("silBoots")
end

function typeStHelm()
  return has ("settingShopReceiveTypes") and has ("stHelm")
end

function typeStEdge()
  return has ("settingShopReceiveTypes") and has ("stEdge")
end

function typeStMail()
  return has ("settingShopReceiveTypes") and has ("stMail")
end

function typeStBoots()
  return has ("settingShopReceiveTypes") and has ("stBoots")
end

function typeTiHelm()
  return has ("settingShopReceiveTypes") and has ("tiHelm")
end

function typeTiEdge()
  return has ("settingShopReceiveTypes") and has ("tiEdge")
end

function typeTiMail()
  return has ("settingShopReceiveTypes") and has ("tiMail")
end

function typeTiBoots()
  return has ("settingShopReceiveTypes") and has ("tiBoots")
end

function typeCoHelm()
  return has ("settingShopReceiveTypes") and has ("coHelm")
end

function typeCoEdge()
  return has ("settingShopReceiveTypes") and has ("coEdge")
end

function typeCoMail()
  return has ("settingShopReceiveTypes") and has ("coMail")
end

function typeCoBoots()
  return has ("settingShopReceiveTypes") and has ("coBoots")
end

function typeLaHelm()
  return has ("settingShopReceiveTypes") and has ("laHelm")
end

function typeLaEdge()
  return has ("settingShopReceiveTypes") and has ("laEdge")
end

function typeLaMail()
  return has ("settingShopReceiveTypes") and has ("laMail")
end

function typeLaBoots()
  return has ("settingShopReceiveTypes") and has ("laBoots")
end


-- Shop Types Global Handler

-- function ReplaceShopMapping()
--   local shop_option = Tracker:FindObjectForCode("<shop_option>").Active
--   if shop_option then -- == true\
--     LOCATION_MAPPING[<ID here>] = {@location1, @location2, ....}
--     LOCATION_MAPPING[<other ID here>] = {@location1, @location2, ....}
--     LOCATION_MAPPING[<more other ID here>] = {@location1, @location2, ....}
--   else 
--     LOCATION_MAPPING[<ID here>] = {@location1}
--     LOCATION_MAPPING[<other ID here>] = {@location2}
--     LOCATION_MAPPING[<more other ID here>] = {....}
--   end
-- end

-- ScriptHost:AddWatchForCode("<shop_option> Change", "<shop_option>", ReplaceShopMapping)