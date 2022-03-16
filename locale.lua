--[[
      Credits: esx-framework [https://github.com/esx-framework/esx-legacy/blob/main/%5Besx%5D/es_extended/locale.lua]
--]] 
Locales = {}

function _(str, ...) -- Traducir string

  if Locales[Config.Locale] ~= nil then

    if Locales[Config.Locale][str] ~= nil then
      return string.format(Locales[Config.Locale][str], ...)
    else
      return 'La traducción [' .. Config.Locale .. '][' .. str .. '] no existe'
    end

  else
    return 'La traducción [' .. Config.Locale .. '] no existe'
  end

end

function _U(str, ...) -- Traducir string con el primer caracter en mayuscula
  return tostring(_(str, ...):gsub("^%l", string.upper))
end
