================
Lua MSTranslator
================

:Author: Arezqui Belaid and Joshua Patten
:Description: Microsoft Translator API Helper for Lua
:Documentation: https://github.com/newfies-dialer/lua-mstranslator
:Contributors: `list of contributors <https://github.com/newfies-dialer/lua-mstranslator/graphs/contributors>`_
:License: MIT

.. image:: https://img.shields.io/travis/newfies-dialer/lua-mstranslator.svg
        :target: https://travis-ci.org/newfies-dialer/lua-mstranslator



Lua Microsoft Translate Wrapper
-------------------------------

lua-mstranslator is a library to produce a text-to-speech file using `Microsoft Translate`_ web services.

In order to utilize this service you must sign up for Microsoft Translator service and register an application. More information on creating a Microsoft account is located at the `getting started with Microsoft Translator API`_ page.


Quickstart
----------

::

    MSTranslator = require "mstranslator"

    CLIENT_ID = 'XXXXXXXXXXXX'
    CLIENT_SECRET = 'YYYYYYYYYYYYYY'
    SERVICE_URL = 'http://api.microsofttranslator.com/V2/Http.svc/Speak'

    tts_mstranslator = MSTranslator:new(CLIENT_ID, CLIENT_SECRET, SERVICE_URL, directory)

    TEXT = "This is a test of the Microsoft Translate text to speech service."
    LANG = 'EN'
    tts_mstranslator:prepare(TEXT, LANG)
    output_filename = tts_mstranslator:run()

    print("Recorded TTS = "..output_filename)


Features
--------

* Produce text to speech in different languages

Dependencies
------------

There are a few dependencies: md5, lfs and lua-curl.
We use this version of lua curl : http://msva.github.com/lua-curl/

To install md5 and lfs::

    luarocks install md5
    luarocks install luafilesystem


To install lua-curl::

    cd /usr/src/
    wget https://github.com/msva/lua-curl/archive/master.zip -O lua-curl.zip
    unzip lua-curl.zip
    cd lua-curl-master
    cmake . && make install


Feedback
--------

Feedback are more than welcome, post bugs and feature requests on github:

http://github.com/newfies-dialer/lua-mstranslator/issues


Extra information
-----------------

Newfies-Dialer, an Open Source Voice BroadCasting Solution, uses this module to synthetize audio files being play to the end-user.
Further information about Newfies-Dialer can be found at http://www.newfies-dialer.org

This module is built and supported by Star2Billing : http://www.star2billing.com


Source download
---------------

The source code is currently available on github. Fork away!

http://github.com/newfies-dialer/lua-mstranslator


API Methods
-----------

Microsoft Translator API Reference](http://msdn.microsoft.com/en-us/library/ff512404.aspx)

  * addTranslation (not implemented)
  * addTranslationArray (not implemented)
  * breakSentences (not working)
  * detect (not implemented)
  * detectArray (not implemented)
  * getAppIdToken (not implemented) This is a legacy, replaced by
    Access Token
  * getLanguageNames (not implemented)
  * getLanguagesForSpeak (not implemented)
  * getLanguagesForTranslate (not implemented)
  * getTranslations (not implemented)
  * getTranslationsArray (not implemented)
  * speak: implemented
  * translate (not implemented)
  * translateArray (not implemented)
  * translateArray2 (not implemented)


Other libraries
---------------

* Javascript: https://github.com/nanek/mstranslator
* Python: https://pypi.python.org/pypi/mstranslator
* Python: https://github.com/bebound/Python-Microsoft-Translate-API


.. _Microsoft Translate: http://www.microsoft.com/en-us/translator/translatorapi.aspx
.. _getting started with Microsoft Translator API: https://www.microsoft.com/en-us/translator/getstarted.aspx
