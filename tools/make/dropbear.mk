#################################################################
## DROPBEAR                                                    ##
#################################################################

SFTPVERSION := $(shell cat $(SOURCES) | jq -r '.sftp.version' )
SFTPARCHIVE := $(shell cat $(SOURCES) | jq -r '.sftp.archive' )
SFTPURI     := $(shell cat $(SOURCES) | jq -r '.sftp.uri' )

DROPBEARVERSION := $(shell cat $(SOURCES) | jq -r '.dropbear.version' )
DROPBEARARCHIVE := $(shell cat $(SOURCES) | jq -r '.dropbear.archive' )
DROPBEARURI     := $(shell cat $(SOURCES) | jq -r '.dropbear.uri' )


#################################################################
##                                                             ##
#################################################################

$(SOURCEDIR)/$(SFTPARCHIVE): $(SOURCEDIR)
	$(call box,"Downloading SFTP source code")
	test -f $@ || $(DOWNLOADCMD) $@ $(SFTPURI) || rm -f $@


$(SOURCEDIR)/$(DROPBEARARCHIVE): $(SOURCEDIR)
	$(call box,"Downloading dropbear source code")
	test -f $@ || $(DOWNLOADCMD) $@ $(DROPBEARURI) || rm -f $@


#################################################################
##                                                             ##
#################################################################

$(BUILDDIR)/sftp: $(SOURCEDIR)/$(SFTPARCHIVE) $(BUILDDIR)/zlib $(BUILDDIR)/openssl
	$(call box,"Building sftp")
	@mkdir -p $(BUILDDIR) && rm -rf $(BUILDDIR)/openssh-$(SFTPVERSION)
	@tar -xzf $(SOURCEDIR)/$(SFTPARCHIVE) -C $(BUILDDIR)
	@cd $(BUILDDIR)/openssh-$(SFTPVERSION) 		\
	&& $(BUILDENV)								\
		./configure								\
			--host=$(TARGET)					\
			--prefix=$(PREFIXDIR)				\
			--with-zlib=$(PREFIXDIR)			\
			--sysconfdir=/etc					\
			--enable-shared						\
			--disable-static					\
		&& make -j$(PROCS) sftp-server			\
		&& cp sftp-server $(PREFIXDIR)/bin
	@rm -rf $(BUILDDIR)/openssh-$(SFTPVERSION)
	@touch $@


$(BUILDDIR)/dropbear: $(SOURCEDIR)/$(DROPBEARARCHIVE) $(BUILDDIR)/zlib $(BUILDDIR)/sftp
	$(call box,"Building dropbear")
	@mkdir -p $(BUILDDIR) && rm -rf $@-$(DROPBEARVERSION)
	@tar -xjf $(SOURCEDIR)/$(DROPBEARARCHIVE) -C $(BUILDDIR)
	sed -i 's|\(#define DROPBEAR_PATH_SSH_PROGRAM\).*|\1 "/tmp/sd/ft/dbclient"|' $@-$(DROPBEARVERSION)/default_options.h
	sed -i 's|\(#define SFTPSERVER_PATH\).*|\1 "/tmp/sd/firmware/bin/sftp-server"|' $@-$(DROPBEARVERSION)/default_options.h
	sed -i 's|\(#define DEFAULT_PATH\).*|\1 "/tmp/sd/firmware/bin:/tmp/sd/firmware/scripts:/bin:/sbin:/usr/bin:/usr/sbin:/tmp/sd/ft:/mnt/data/ft"|' $@-$(DROPBEARVERSION)/default_options.h
	@cd $@-$(DROPBEARVERSION)			\
	&& $(BUILDENV)						\
		./configure						\
			--prefix=$(PREFIXDIR)		\
			--host=$(TARGET)			\
			--with-zlib=$(PREFIXDIR)	\
			--disable-wtmp				\
			--disable-lastlog			\
		&& make PROGRAMS="dropbear scp dbclient dropbearkey" MULTI=0 -j$(PROCS) \
		&& make PROGRAMS="dropbear scp dbclient dropbearkey" MULTI=0 -j$(PROCS) install
	@rm -rf $@-$(DROPBEARVERSION)
	@touch $@


#################################################################
##                                                             ##
#################################################################

