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
  return region4() and mineKeyTotal(1)
end


function region6()
  return region5() and mineKeyTotal(2)
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
  return region13() and fajroKeyTotal(1)
end

function region15()
  return region14() and fajroKeyTotal(3)
end

function region16()
  return region15() and fajroKeyTotal(4)
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
  return region21()
end

function region24()
  return region21() and has ("pondPass")
end

function region25()
  return region23() and zirvitarKeyTotal(2)
end

function region26()
  return region23() and sonajizKeyTotal(4)
end

function region27()
  return region26() and sonajizKeyTotal(5) and (has ("radiantKey"))
end

function region28()
  return region23() and (has ("eleWave") and has ("eleShock") and has ("dropShade") and has ("boltShade"))
end

function region29()
  return region28() and kryskajoKeyTotal(2)
end

function region30()
  return region28() and has ("kryskajoMaster")
end

function region31()
  return region30() and has ("starShade")
end

function region32()
  return region31() and has ("dojoKey")
end

function region33()
  return region32() and has ("meteorShade")
end

-- Open Mode Logic

function regionOpen2()
  return has ("settingOpenMode")
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
  return regionOpen4_1() and mineKeyTotal(1)
end

function regionOpen4_3()
  return regionOpen4_2() and mineKeyTotal(2)
end

function regionOpen4_4()
  return regionOpen4_3() and mineKeyTotal(3)
end

function regionOpen4_5()
  return regionOpen4_4() and mineKeyTotal(6)
end

function regionOpen4_6()
  return regionOpen4_3() and has ("eleHeat")
end

function regionOpen4_7()
  return regionOpen4_6() and mineKeyTotal(10)
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
  return regionOpen7_1() and fajroKeyTotal(1)
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
  return regionOpen12() and zirvitarKeyTotal(2)
end

function regionOpen13_2()
  return regionOpen13_1() and has ("eleWave")
end

function regionOpen14_1()
  return regionOpen12() and sonajizKeyTotal(4)
end

function regionOpen14_2()
  return regionOpen14_1() and sonajizKeyTotal(5) and has ("radiantKey")
end

function regionOpen14_3()
  return regionOpen14_2() and has ("eleShock")
end

function regionOpen15_1()
  return regionOpen12() and (has ("boltShade") and has ("azureShade") and has ("eleWave") and has ("eleShock"))
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

function regionOpen16_1()
  return regionOpen16() and has ("meteorShade")
end

function regionOpen19()
  return regionOpen16_1() and (has ("eleHeat") and has ("eleCold") and has ("eleWave") and has ("eleShock"))
end

-- Dungeon Keys

function mineKeyTotal(amount)
  minekeyTotal=Tracker:ProviderCountForCode("mineKey")*1
  return (minekeyTotal >= amount)
end

function fajroKeyTotal(amount)
  fajrokeyTotal=Tracker:ProviderCountForCode("fajroKey")*1
  return (fajrokeyTotal >= amount)
end

function zirvitarKeyTotal(amount)
  zirvitarkeyTotal=Tracker:ProviderCountForCode("zirvitarKey")*1
  return (zirvitarkeyTotal >= amount)
end

function sonajizKeyTotal(amount)
  sonajizkeyTotal=Tracker:ProviderCountForCode("sonajizKey")*1
  return (sonajizkeyTotal >= amount)
end

function kryskajoKeyTotal(amount)
  kryskajokeyTotal=Tracker:ProviderCountForCode("kryskajoKey")*1
  return (kryskajokeyTotal >= amount)
end