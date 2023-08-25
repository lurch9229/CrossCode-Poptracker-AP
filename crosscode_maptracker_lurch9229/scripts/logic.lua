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
  if region3() == true and (has ("minePass") and has("guildPass"))
  then
    return 1
  else
    return 0
  end
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
  if region7() == true and (has ("eleHeat") and has ("thiefKey"))
  then
    return 1
  else
    return 0
  end
end

function region10()
  return region9() and mineKeyTotal(10)
end

function region11()
  if region10() == true and (has ("mineMaster") and has ("iceShade"))
  then
    return 1
  else
    return 0
  end
end

function region12()
  return region11()  and has ("maroonPass")
end

function region13()
  if region12() ==true and (has ("eleHeat") and has("sandShade"))
  then
    return 1
  else
    return 0
  end
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
  if region16() == true and has ("eleCold")
  then
    return 1
  else
    return 0
  end
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
  if region19() == true and has ("flameShade")
  then
    return 1
  else
    return 0
  end
end

function region21()
  return region20() and has ("seedShade")
end

function region23()
  if region21() == true
  then
    return 1
  else
    return 0
  end
end

function region24()
  if region21() == true and has ("pondPass")
  then
    return 1
  else
    return 0
  end
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
  if region28() == true and has ("kryskajoMaster")
  then
    return 1
  else
    return 0
  end
end

function region31()
  return region30() and has ("starShade")
end

function region32()
  if region31() == true and has ("dojoKey")
  then
    return 1
  else
    return 0
  end
end

function region33()
  return region32() and has ("meteorShade")
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