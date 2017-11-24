destroy:
	@vagrant destroy -f
	@rm -rf tmp_deploying_stage

create:
	@vagrant up -d

recreate:
	@make destroy
	@make create

stop:
	@VBoxManage controlvm k8-4 acpipowerbutton
	@VBoxManage controlvm k8-3 acpipowerbutton
	@VBoxManage controlvm k8-2 acpipowerbutton
	@VBoxManage controlvm k8-1 acpipowerbutton

start:
	@VBoxManage startvm k8-1 --type headless
	@VBoxManage startvm k8-2 --type headless
	@VBoxManage startvm k8-3 --type headless
	@VBoxManage startvm k8-4 --type headless

status:
	@VBoxManage list runningvms
