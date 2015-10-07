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
require "lfs"
require "cURL"


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
-- Get an url and save result to file
--
function ms_wget(url, auth_header, outputfile)
    -- open output file
    f = io.open(outputfile, "w")
    local text = {}
    local function writecallback(str)
        f:write(str)
        return string.len(str)
    end
    local c = cURL.easy_init()
    -- setup url
    c:setopt_url(url)
    -- Set auth header
    c:setopt_httpheader({auth_header})
    -- perform, invokes callbacks
    c:perform({writefunction = writecallback})
    -- close output file
    f:close()
    return table.concat(text,'')
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
-- Token Generator for MS Translate API
--
function ms_token_gen(clientID, clientSecret)
        local json = require "json"
        local authUrl = "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13/"
        local params = {
                scope = "http://api.microsofttranslator.com",
                grant_type = "client_credentials",
                client_id = clientID,
                client_secret = clientSecret
        }
        local get_params = ''
        -- URLEncode the parameters
        for k, v in pairs(params) do
            if get_params ~= '' then
                get_params = get_params..'&'
            end
            get_params = get_params..tostring(k)..'='..url_encode(v)
        end
        local c = cURL.easy_init()
        c:setopt_url(authUrl)
        -- We have to post
        c:setopt_post(1)
        c:setopt_postfields(get_params)
        -- Avoid any SSL heartburn
        c:setopt_ssl_verifypeer(0)
        -- Pipe the return response to a function that fills 'buffer' variable
        c:perform({writefunction = function(str)
                                         buffer = str
                                   end})
        -- Turn the JSON response string into a table
        jdata = json.decode(buffer)
        -- Return the access token field
        return jdata["access_token"]
end



--
-- MSTranslator Class
--

local MSTranslator = {
    -- default field values
    client_id = 'XXXXXXXXXXXX',
    client_secret = 'YYYYYYYYYYYYYY',

    service_url = 'http://api.microsofttranslator.com/V2/Http.svc/Speak',
    DIRECTORY = '/tmp/',

    -- Properties
    filename = nil,
    cache = true,
    data = {},
    langs = {},
}

-- Meta information
MSTranslator._COPYRIGHT   = "Copyright (C) 2015 Arezqui Belaid and Joshua Patten"
MSTranslator._DESCRIPTION = "Lua wrapper for text-to-speech synthesis with Microsoft Translate"
MSTranslator._VERSION     = "lua-mstranslator 0.1.0"


function MSTranslator:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function MSTranslator:prepare(textstr, lang)
    -- Prepare Microsoft Translate TTS
    if string.len(textstr) == 0 then
        return false
    end
    lang = string.lower(lang)
    concatkey = textstr..'-'..lang
    hash = md5.sumhexa(concatkey)

    key = 'mstranslator'..'_'..hash
    self.filename = key..'-'..lang..'.wav'

    self.data = {
        language = lang,
        format = 'audio/wav',
        options = 'MinSize',
        text = textstr,
    }
end

function MSTranslator:set_cache(value)
    -- Enable Cache of file, if files already stored return this filename
    self.cache = value
end

function MSTranslator:run()
    -- Run will call Microsoft Translate API and reproduce audio

    -- Check if file exists
    if self.cache and file_exists(self.DIRECTORY..self.filename) then
        return self.DIRECTORY..self.filename
    else
        -- Generate Authorization Token
        token = ms_token_gen(self.client_id, self.client_secret)
        -- Build Authorization Header
        auth_header = "Authorization: Bearer "..token
        -- Get all the Get params and encode them
        get_params = ''
        for k, v in pairs(self.data) do
            if get_params ~= '' then
                get_params = get_params..'&'
            end
            get_params = get_params..tostring(k)..'='..url_encode(v)
        end

        -- print("===HTTP=== HEADER:"..auth_header.."\nCALL:"..self.service_url..'?'..get_params, self.DIRECTORY..self.filename)
        ms_wget(self.service_url..'?'..get_params, auth_header, self.DIRECTORY..self.filename)

        if file_exists(self.DIRECTORY..self.filename) then
            return self.DIRECTORY..self.filename
        else
            --Error
            return false
        end

    end
end

return MSTranslator
