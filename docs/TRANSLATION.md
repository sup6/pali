### How to make dictionay and tipitaka website to support my language?

Answer: It is actually very easy to support new language because the websites are developed with internationalization in mind in the beginning. Fetch this [Traditional Chinese po file](https://github.com/siongui/pali/blob/master/common/locale/zh_TW/LC_MESSAGES/messages.po) to your computer. Lines that starts with <em>msgid</em> are the English texts, and Lines that starts with <em>msgstr</em> are corresponding translated texts of your language. If you want the website to support your language, put translated texts here. Then make pull requests at the [pali](https://github.com/siongui/pali) repository on the github, or mail the po file to the author (siongui@gmail.com). It is recommended to release your translation in public domain.