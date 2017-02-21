--
-- mstranslator.lua - Lua wrapper for text-to-speech synthesis with Microsoft Translate
-- Copyright (C) 2015 Arezqui Belaid <areski@gmail.com> and Joshua Patten <joshpatten@gmail.com>
--
-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation files
-- (the "Software"), to deal in the Software without restriction,
-- including without limitation the rights to use, copy, modify, merge,
-- publish, distribute, sublicense, and/or sell copies of the Software,
-- and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
-- BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
-- ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
-- CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local md5 = require "md5"
local http = require("http.request")
require "lfs"


-- Check file exists and readable
function file_exists(path)
    local attr = lfs.attributes(path)
    if (attr ~= nil) then
        return true
    else
        return false
    end
end

--
-- Get url and return binary result
--
function ms_wget(postheaders, setbody, outputfile)
    local posturl = "https://speech.platform.bing.com/synthesize"
    local request = http.new_from_uri(posturl)
    for k,v in pairs(postheaders) do
        request.headers:upsert(k, v)
    end
    request.headers:upsert(":method", "POST")
    request:set_body(setbody)
    local headers, stream = request:go(10)
    if headers:get(":status") ~= "200" then
        print("Error: " .. headers:get(":status"))
        print(stream:get_body_as_string()..'\n')
        return nil
    end

    -- open output file
    f = assert(io.open(outputfile, 'w'))
    f:write(stream:get_body_as_string())
    f:close()
    return true
end

--
-- URL Encoder
--
function url_encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w ])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str
end

--
-- Token Generator for Azure Cognitive API
--
function ms_token_gen(subscription_key, auth_url)
    local request = http.new_from_uri(auth_url)
    request.headers:upsert("Ocp-Apim-Subscription-Key", subscription_key)
    request.headers:upsert(":method", "POST")
    local headers, stream = request:go(10)
    if headers:get(":status") ~= "200" then
        print("Error: " .. headers:get(":status"))
        print(stream:get_body_as_string()..'\n')
        return nil
    end
    return stream:get_body_as_string()
end


--
-- MSTranslator Class
--

local MSTranslator = {
    -- default field values
    subscription_key = 'XXXXXXXXXXXX',
    -- service_url = 'http://api.microsofttranslator.com/V2/Http.svc/Speak',
    auth_url = "https://api.cognitive.microsoft.com/sts/v1.0/issueToken",
    DIRECTORY = '/tmp/',
    -- Properties
    filename = nil,
    cache = true,
    data = {},
    langs = {},
}

-- Meta information
MSTranslator._COPYRIGHT   = "Copyright (C) 2015-2017 Arezqui Belaid and Joshua Patten"
MSTranslator._DESCRIPTION = "Lua wrapper for text-to-speech synthesis with Microsoft Bing Speech"
MSTranslator._VERSION     = "lua-mstranslator 0.2.0"


function MSTranslator:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function MSTranslator:prepare(textstr, lang, gender, format)
    -- Prepare Microsoft Translate TTS
    lang = lang or "en-US"
    gender = gender or "female"
    format = format or "riff-8khz-8bit-mono-mulaw"
    if string.len(textstr) == 0 then
        return false
    end
    concatkey = textstr..'-'..lang..'-'..gender..'-'..format
    hash = md5.sumhexa(concatkey)

    key = 'mstranslator'..'_'..hash
    self.filename = key..'-'..lang..'.wav'

    namemap = {
        ["ar-EG,Female"] = "Microsoft Server Speech Text to Speech Voice (ar-EG, Hoda)",
        ["de-DE,Female"] = "Microsoft Server Speech Text to Speech Voice (de-DE, Hedda)",
        ["de-DE,Male"] = "Microsoft Server Speech Text to Speech Voice (de-DE, Stefan, Apollo)",
        ["en-AU,Female"] = "Microsoft Server Speech Text to Speech Voice (en-AU, Catherine)",
        ["en-CA,Female"] = "Microsoft Server Speech Text to Speech Voice (en-CA, Linda)",
        ["en-GB,Female"] = "Microsoft Server Speech Text to Speech Voice (en-GB, Susan, Apollo)",
        ["en-GB,Male"] = "Microsoft Server Speech Text to Speech Voice (en-GB, George, Apollo)",
        ["en-IN,Male"] = "Microsoft Server Speech Text to Speech Voice (en-IN, Ravi, Apollo)",
        ["en-US,Male"] = "Microsoft Server Speech Text to Speech Voice (en-US, BenjaminRUS)",
        ["en-US,Female"] = "Microsoft Server Speech Text to Speech Voice (en-US, ZiraRUS)",
        ["es-ES,Female"] = "Microsoft Server Speech Text to Speech Voice (es-ES, Laura, Apollo)",
        ["es-ES,Male"] = "Microsoft Server Speech Text to Speech Voice (es-ES, Pablo, Apollo)",
        ["es-MX,Male"] = "Microsoft Server Speech Text to Speech Voice (es-MX, Raul, Apollo)",
        ["fr-CA,Female"] = "Microsoft Server Speech Text to Speech Voice (fr-CA, Caroline)",
        ["fr-FR,Female"] = "Microsoft Server Speech Text to Speech Voice (fr-FR, Julie, Apollo)",
        ["fr-FR,Male"] = "Microsoft Server Speech Text to Speech Voice (fr-FR, Paul, Apollo)",
        ["it-IT,Male"] = "Microsoft Server Speech Text to Speech Voice (it-IT, Cosimo, Apollo)",
        ["ja-JP,Female"] = "Microsoft Server Speech Text to Speech Voice (ja-JP, Ayumi, Apollo)",
        ["ja-JP,Male"] = "Microsoft Server Speech Text to Speech Voice (ja-JP, Ichiro, Apollo)",
        ["pt-BR,Male"] = "Microsoft Server Speech Text to Speech Voice (pt-BR, Daniel, Apollo)",
        ["ru-RU,Female"] = "Microsoft Server Speech Text to Speech Voice (ru-RU, Irina, Apollo)",
        ["ru-RU,Male"] = "Microsoft Server Speech Text to Speech Voice (ru-RU, Pavel, Apollo)",
        ["zh-CN,Female"] = "Microsoft Server Speech Text to Speech Voice (zh-CN, HuihuiRUS)",
        ["zh-CN,Male"] = "Microsoft Server Speech Text to Speech Voice (zh-CN, Kangkang, Apollo)",
        ["zh-HK,Male"] = "Microsoft Server Speech Text to Speech Voice (zh-HK, Danny, Apollo)",
        ["zh-TW,Female"] = "Microsoft Server Speech Text to Speech Voice (zh-TW, Yating, Apollo)",
        ["zh-TW,Male"] = "Microsoft Server Speech Text to Speech Voice (zh-TW, Zhiwei, Apollo)"
    }
    -- Capitalize first letter
    gender = gender:sub(1,1):upper()..gender:sub(2)
    langmap = lang .. ',' .. gender
    if namemap[langmap] == nil then
        return false
    end
    servicename = namemap[langmap]
    self.data = {
        -- ["client_secret"] = client_secret,
        ["language"] = lang,
        ["format"] = format,
        ["gender"] = gender,
        ["text"] = textstr,
        ["service"] = servicename
    }
end

function MSTranslator:set_cache(value)
    -- Enable Cache of file, if files already stored return this filename
    self.cache = value
end

function MSTranslator:run()
    -- Run will call Bing TTS API and reproduce audio

    -- Check if file exists
    if self.cache and file_exists(self.DIRECTORY..self.filename) then
        return self.DIRECTORY..self.filename
    else
        -- Generate Authorization Token
        token = ms_token_gen(self.subscription_key, self.auth_url)
        if token == nil then
            print('Token error.\n')
            return False
        end

        -- Build Authorization Headers
        headertable = {["Content-type"] = "application/ssml+xml",
                       ["Authorization"] = "Bearer "..token,
                       ["X-Microsoft-OutputFormat"] = self.data["format"],
                       }
        postbody = "<speak version='1.0' xml:lang='"..self.data["language"].."'><voice xml:lang='"..self.data["language"].."' xml:gender='"..self.data["gender"].."' name='"..self.data["service"].."'>"..self.data["text"].."</voice></speak>"
        ms_wget(headertable, postbody, self.DIRECTORY..self.filename)

        if file_exists(self.DIRECTORY..self.filename) then
            return self.DIRECTORY..self.filename
        else
            --Error
            return false
        end

    end
end

return MSTranslator
