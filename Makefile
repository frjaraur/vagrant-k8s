destroy:
	@vagrant destroy -f || true
	@rm -rf tmp_deploying_stage

create:
	@vagrant up -d

recreate:
	@make destroy
	@make create

stop:
	@VBoxManage controlvm k8s-4 acpipowerbutton 2>/dev/null || true
	@VBoxManage controlvm k8s-3 acpipowerbutton 2>/dev/null || true
	@VBoxManage controlvm k8s-2 acpipowerbutton 2>/dev/null || true
	@VBoxManage controlvm k8s-1 acpipowerbutton 2>/dev/null || true

start:
	@VBoxManage startvm k8s-1 --type headless 2>/dev/null || true
	@sleep 10
	@VBoxManage startvm k8s-2 --type headless 2>/dev/null || true
	@VBoxManage startvm k8s-3 --type headless 2>/dev/null || true
	@VBoxManage startvm k8s-4 --type headless 2>/dev/null || true

status:
	@VBoxManage list runningvms
