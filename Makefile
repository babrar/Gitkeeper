all: 
	@./setup.sh
	@cd .. && ./initrepo.sh
report:
	@cd log && cat run.log
error:
	@cd log && cat error.log
uninstall:
	@./detachHooks.sh
