all: 
	@./setup.sh
	@cd .. && ./initrepo.sh
report:
	@cat run.log
error:
	@cat error.log
uninstall:
	@./detachHooks.sh
