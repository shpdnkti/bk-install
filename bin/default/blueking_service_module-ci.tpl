服务模板	进程名称	进程别名	进程启动参数	绑定IP	端口	协议
service_template	bk_func_name	bk_process_name	bk_start_param_regex	bind_ip	port	protocol
ci-gateway	nginx	ci-gateway		0.0.0.0	80	TCP
ci-dockerhost	java	ci-dockerhost	boot-dockerhost.jar	0.0.0.0	21923	TCP
ci-agentless	java	ci-agentless	boot-agentless.jar	0.0.0.0	21923	TCP
ci-artifactory	java	ci-artifactory	boot-artifactory.jar	0.0.0.0	21920	TCP
ci-auth	java	ci-auth	boot-auth.jar	0.0.0.0	21936	TCP
ci-dispatch	java	ci-dispatch	boot-dispatch.jar	0.0.0.0	21922	TCP
ci-environment	java	ci-environment	boot-environment.jar	0.0.0.0	21919	TCP
ci-image	java	ci-image	boot-image.jar	0.0.0.0	21933	TCP
ci-log	java	ci-log	boot-log.jar	0.0.0.0	21914	TCP
ci-misc	java	ci-misc	boot-misc.jar	0.0.0.0	21927	TCP
ci-notify	java	ci-notify	boot-notify.jar	0.0.0.0	21911	TCP
ci-openapi	java	ci-openapi	boot-openapi.jar	0.0.0.0	21935	TCP
ci-plugin	java	ci-plugin	boot-plugin.jar	0.0.0.0	21925	TCP
ci-process	java	ci-process	boot-process.jar	0.0.0.0	21921	TCP
ci-project	java	ci-project	boot-project.jar	0.0.0.0	21912	TCP
ci-quality	java	ci-quality	boot-quality.jar	0.0.0.0	21928	TCP
ci-repository	java	ci-repository	boot-repository.jar	0.0.0.0	21916	TCP
ci-store	java	ci-store	boot-store.jar	0.0.0.0	21918	TCP
ci-ticket	java	ci-ticket	boot-ticket.jar	0.0.0.0	21915	TCP
ci-websocket	java	ci-websocket	boot-websocket.jar	0.0.0.0	21924	TCP
