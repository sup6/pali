export GOROOT=$(realpath ../go)
export GOPATH=$(realpath .)
export PATH := $(GOROOT)/bin:$(GOPATH)/bin:$(PATH)

DATA_REPO_DIR=$(CURDIR)/data
COMMON_DIR=$(CURDIR)/common
LOCALE_DIR=$(COMMON_DIR)/locale
DICTIONARY_DIR=$(CURDIR)/dictionary
TIPITAKA_DIR=$(CURDIR)/tipitaka

tpkdevserver:
	cd $(TIPITAKA_DIR); python devNotGaeRun.py

mintpkcss:
	@echo "\033[92m(Tipiṭaka) minify css ...\033[0m"
	cd $(TIPITAKA_DIR)/app/css; make

mintpkjs:
	@echo "\033[92m(Tipiṭaka) Concatenate and compress js ...\033[0m"
	@go fmt $(TIPITAKA_DIR)/minjs.go
	@go run $(TIPITAKA_DIR)/minjs.go

tpktanslation:
	@echo "\033[92mCreate Tipiṭaka-related translations for server and client ...\033[0m"
	@python2 $(TIPITAKA_DIR)/setup/setTranslationData.py

dicdevserver:
	cd $(DICTIONARY_DIR); python devNotGaeRun.py

mindiccss:
	@echo "\033[92m(Dictionary) minify css ...\033[0m"
	cd $(DICTIONARY_DIR)/app/css; make

mindicjs:
	@echo "\033[92m(Dictionary) Concatenate and compress js ...\033[0m"
	@go fmt $(DICTIONARY_DIR)/minjs.go
	@go run $(DICTIONARY_DIR)/minjs.go

setup: install cptpkcss symlinks setupPOMO ngjs parsedics prefix_words_html succinct_trie ngdatajs parsetpk tpktanslation

ec2setup: cptpkcss symlinks setupPOMO ngjs parsedics prefix_words_html succinct_trie ngdatajs parsetpk tpktanslation

parsetpk:
	@echo "\033[92mParsing Tipiṭaka data ...\033[0m"
	@python2 $(TIPITAKA_DIR)/setup/init1getTocs.py
	@python2 $(TIPITAKA_DIR)/setup/init2tocsToJson.py
	@python2 $(TIPITAKA_DIR)/setup/init3addSubpathInJson.py

ngdatajs:
	@echo "\033[92mCreating ng js module for books info and succinct trie data...\033[0m"
	@python2 $(DICTIONARY_DIR)/setup/init4jsonToJS.py

succinct_trie:
	@echo "\033[92mCreating succinct trie json ...\033[0m"
	@cp $(DATA_REPO_DIR)/src/succinct_trie.json $(DICTIONARY_DIR)/pylib/json/

prefix_words_html:
	@echo "\033[92mCreating prefix-words HTML ...\033[0m"
	@python2 $(DICTIONARY_DIR)/setup/init3prefixWordsHtml.py

parsedics:
	@echo "\033[92mParse Dictionary Books Information ...\033[0m"
	@python2 $(DICTIONARY_DIR)/setup/init1parseBooks.py
	@echo "\033[92mParse Dictionary Words ...\033[0m"
	@python2 $(DICTIONARY_DIR)/setup/init2parseWords.py

ngjs:
	@echo "\033[92mCreating client-side i18n js ...\033[0m"
	@python2 setup/i18nUtils.py js

cptpkcss:
	@echo "\033[92mCopying tipitaka css ...\033[0m"
	@cp $(DATA_REPO_DIR)/tipitaka/romn/cscd/tipitaka-latn.css $(TIPITAKA_DIR)/app/css/

symlinks:
	@echo "\033[92mCreating symbolic links ...\033[0m"
	@[ -L $(TIPITAKA_DIR)/common ] || (cd $(TIPITAKA_DIR); ln -s $(COMMON_DIR) common)
	@[ -L $(TIPITAKA_DIR)/pylib/translation ] || (cd $(TIPITAKA_DIR)/pylib; ln -s $(DATA_REPO_DIR)/tipitaka/translation/ translation)
	@[ -L $(TIPITAKA_DIR)/pylib/romn ] || (cd $(TIPITAKA_DIR)/pylib; ln -s $(DATA_REPO_DIR)/tipitaka/romn/ romn)
	@[ -L $(DICTIONARY_DIR)/common ] || (cd $(DICTIONARY_DIR); ln -s $(COMMON_DIR) common)
	@[ -L $(COMMON_DIR)/pylib/jianfan ] || (cd $(COMMON_DIR)/pylib; ln -s $(DATA_REPO_DIR)/pylib/jianfan/ jianfan)

install:
	@echo "\033[92mInstalling git via apt-get ...\033[0m"
	@sudo apt-get install git
	@# gettext installed on Ubuntu 15.10 by default
	@#apt-cache policy gettext
	@echo "\033[92mInstalling Python webpy via apt-get ...\033[0m"
	@sudo apt-get install python3-webpy
	@echo "\033[92mInstalling Python jinja2 via apt-get ...\033[0m"
	@sudo apt-get install python-jinja2
	@echo "\033[92mInstalling Python lxml via apt-get ...\033[0m"
	@sudo apt-get install python-lxml

ubuntu_upgrade:
	@echo "\033[92mUpgrading Ubuntu Linux ...\033[0m"
	sudo apt-get update
	sudo apt-get upgrade

clone:
	@echo "\033[92mClone Pāli data Repo ...\033[0m"
	@git clone https://github.com/siongui/data.git $(DATA_REPO_DIR)

clean: cleanPOMO
	-rm $(TIPITAKA_DIR)/app/css/tipitaka-latn.css
	-rm $(DICTIONARY_DIR)/common
	-rm $(TIPITAKA_DIR)/common
	-rm $(TIPITAKA_DIR)/pylib/romn
	-rm $(TIPITAKA_DIR)/pylib/translation
	-rm $(COMMON_DIR)/pylib/jianfan
	-rm common/app/scripts/services/data/i18nStrings.js
	rm -rf $(DICTIONARY_DIR)/pylib/json/
	rm -rf $(DICTIONARY_DIR)/pylib/paliwords/
	rm -rf $(DICTIONARY_DIR)/pylib/prefixWordsHtml/
	-rm common/app/scripts/services/data/dicBooks.js
	-rm common/app/scripts/services/data/succinctTrie.js
	-rm $(DICTIONARY_DIR)/app/all_compiled.js
	-rm $(DICTIONARY_DIR)/app/css/app.min.css
	rm -rf $(TIPITAKA_DIR)/build/
	rm -rf $(TIPITAKA_DIR)/pylib/json/
	rm -rf $(TIPITAKA_DIR)/app/scripts/services/data/
	-rm $(TIPITAKA_DIR)/app/all_compiled.js
	-rm $(TIPITAKA_DIR)/app/css/app.min.css

setupPOMO: pot initenuspo twpo2cn po2mo

pot:
	@echo "\033[92mCreating PO template ...\033[0m"
	@xgettext --no-wrap --from-code=UTF-8 --keyword=_ --output=$(LOCALE_DIR)/messages.pot \
	`find $(DICTIONARY_DIR)/app -name *.html` \
	`find $(DICTIONARY_DIR)/pylib/partials -name *.html` \
	`find $(TIPITAKA_DIR)/app -name *.html` \
	`find $(TIPITAKA_DIR)/pylib/partials -name *.html`

initenuspo:
	msginit --no-wrap --no-translator --input=$(LOCALE_DIR)/messages.pot --locale=en_US -o $(LOCALE_DIR)/en_US/LC_MESSAGES/messages.po

twpo2cn:
	@echo "\033[92mCheck if OpenCC exists ...\033[0m"
	@[ -x $(shell command -v opencc 2> /dev/null) ] || sudo apt-get install opencc
	@echo "\033[92mCreating zh_CN PO from zh_TW PO ...\033[0m"
	@[ -d $(LOCALE_DIR)/zh_CN/LC_MESSAGES/ ] || mkdir -p $(LOCALE_DIR)/zh_CN/LC_MESSAGES/
	@opencc -c tw2s.json -i $(LOCALE_DIR)/zh_TW/LC_MESSAGES/messages.po -o $(LOCALE_DIR)/zh_CN/LC_MESSAGES/messages.po
	@sed 's/zh_TW/zh_CN/' -i $(LOCALE_DIR)/zh_CN/LC_MESSAGES/messages.po

po2mo:
	@echo "\033[92mmsgfmt PO to MO ...\033[0m"
	@msgfmt $(LOCALE_DIR)/zh_TW/LC_MESSAGES/messages.po -o $(LOCALE_DIR)/zh_TW/LC_MESSAGES/messages.mo
	@msgfmt $(LOCALE_DIR)/zh_CN/LC_MESSAGES/messages.po -o $(LOCALE_DIR)/zh_CN/LC_MESSAGES/messages.mo
	@msgfmt $(LOCALE_DIR)/vi_VN/LC_MESSAGES/messages.po -o $(LOCALE_DIR)/vi_VN/LC_MESSAGES/messages.mo
	@msgfmt $(LOCALE_DIR)/fr_FR/LC_MESSAGES/messages.po -o $(LOCALE_DIR)/fr_FR/LC_MESSAGES/messages.mo
	@msgfmt $(LOCALE_DIR)/en_US/LC_MESSAGES/messages.po -o $(LOCALE_DIR)/en_US/LC_MESSAGES/messages.mo

cleanPOMO:
	@echo "\033[92mRemoving unnecessary PO and MO ...\033[0m"
	-rm $(LOCALE_DIR)/messages.pot
	-rm $(LOCALE_DIR)/en_US/LC_MESSAGES/messages.po
	rm -rf $(LOCALE_DIR)/zh_CN/
	-rm `find $(LOCALE_DIR) -name *.mo`
