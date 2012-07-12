all:

# ------ Setup ------

WGET = wget
PERL = perl
PERL_VERSION = latest
PERL_PATH = $(abspath local/perlbrew/perls/perl-$(PERL_VERSION)/bin)

Makefile-setupenv: Makefile.setupenv
	$(MAKE) --makefile Makefile.setupenv setupenv-update \
	    SETUPENV_MIN_REVISION=20120328

Makefile.setupenv:
	$(WGET) -O $@ https://raw.github.com/wakaba/perl-setupenv/master/Makefile.setupenv

lperl local-perl perl-version perl-exec \
local-submodules pmb-update pmb-install \
generatepm: %: Makefile-setupenv
	$(MAKE) --makefile Makefile.setupenv $@

# ------ Test ------

PERL_ENV = PATH="$(abspath ./local/perl-$(PERL_VERSION)/pm/bin):$(PERL_PATH):$(PATH)" PERL5LIB="$(shell cat config/perl/libs.txt)"
PROVE = prove

test: test-deps safetest

test-deps: local-submodules pmb-install

safetest:
	$(PERL_ENV) $(PROVE) t/**.t

# ------ Packaging ------

GENERATEPM = local/generatepm/bin/generate-pm-package
GENERATEPM_ = $(GENERATEPM) --generate-json

dist: generatepm
	$(GENERATEPM_) config/dist/webservice-microsoft-translator.pi dist/

dist-wakaba-packages: local/wakaba-packages dist
	cp dist/*.json local/wakaba-packages/data/perl/
	cp dist/*.tar.gz local/wakaba-packages/perl/
	cd local/generatepm && $(MAKE) lperl
	cd local/wakaba-packages && $(MAKE) all PERL="$(abspath ./local/generatepm/perl)"

local/wakaba-packages: always
	git clone "git@github.com:wakaba/packages.git" $@ || (cd $@ && git pull)
	cd $@ && git submodule update --init

always:
