================
Lua MSTranslator
================

:Author: Arezqui Belaid and Joshua Patten
:Description: Bing Speech API Helper for Lua
:Documentation: https://github.com/newfies-dialer/lua-mstranslator
:Contributors: `list of contributors <https://github.com/newfies-dialer/lua-mstranslator/graphs/contributors>`_
:License: MIT

.. image:: https://travis-ci.org/newfies-dialer/lua-mstranslator.svg?branch=master
    :target: https://travis-ci.org/newfies-dialer/lua-mstranslator



Lua Bing Speech Wrapper
-------------------------------

lua-mstranslator is a library to synthesize text into human sounding speech
using `Microsoft Cognitive Services`_.

In order to utilize this service you must sign up for Microsoft Cognitive
service and register an application. More information on creating a Microsoft
account is located at the `getting started with Text to Speech`_ page.

Quickstart
----------

::

    MSTranslator = require "mstranslator"

    subscription_key = 'XXXXXXXXXXXX'
    directory = '/tmp/'
    tts_mstranslator = MSTranslator:new(subscription_key, directory)
    tts_mstranslator:prepare("This is a test message", "en-US", "female", "riff-8khz-8bit-mono-mulaw")
    output_filename = tts_mstranslator:run()

    print("Recorded TTS = "..output_filename)


Test with French and Spanish.

::

    MSTranslator = require "mstranslator"

    subscription_key = 'XXXXXXXXXXXX'
    directory = '/tmp/'
    tts_mstranslator = MSTranslator:new(subscription_key, directory)
    tts_mstranslator:prepare("Bonjour, Je sais parler Francais, mais aussi Anglais et Espagnol", "fr-FR", "female")
    -- or
    -- tts_mstranslator:prepare("Hola, como estas encanto te gustaría un paseo?", 'es-ES')
    output_filename = tts_mstranslator:run()

    print("Recorded TTS = "..output_filename)


Dependencies
------------

There are a few dependencies: md5, lfs and lua-http.

    luarocks install md5
    luarocks install luafilesystem
    luarocks install http


Feedback
--------

Feedback are more than welcome, post bugs and feature requests on github:

http://github.com/newfies-dialer/lua-mstranslator/issues


Extra information
-----------------

Newfies-Dialer, an Open Source Voice BroadCasting Solution, uses this module
to synthetize audio files being play to the end-user. Further information
about Newfies-Dialer can be found at https://www.newfies-dialer.org

This module is built and supported by Star2Billing: https://www.star2billing.com


Source download
---------------

The source code is currently available on github. Fork away!

http://github.com/newfies-dialer/lua-mstranslator


Other libraries
---------------

* Javascript: https://github.com/nanek/mstranslator
* Python: https://pypi.python.org/pypi/mstranslator
* Python: https://github.com/bebound/Python-Microsoft-Translate-API

* Check also Lua-Bing-TTS: https://github.com/westparkcom/Lua-Bing-TTS


.. _Microsoft Cognitive Services: https://www.microsoft.com/cognitive-services/en-us/
.. _getting started with Text to Speech: https://www.microsoft.com/cognitive-services/en-us/speech-api
